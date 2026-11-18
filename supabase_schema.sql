-- ABDULLAHI IBRAHIM BUSINESS MANAGER: secure multi-branch foundation
create extension if not exists pgcrypto;

create table if not exists public.branches (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  address text,
  phone text,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null,
  role text not null default 'cashier'
    check (role in ('super_admin','branch_manager','cashier','storekeeper')),
  branch_id uuid references public.branches(id) on delete set null,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

-- Shared business record foundation. Each financial/business row belongs to one branch.
create table if not exists public.business_records (
  id uuid primary key default gen_random_uuid(),
  branch_id uuid not null references public.branches(id) on delete restrict,
  record_type text not null
    check (record_type in ('invoice','cashflow','expense','customer','inventory','supplier','account')),
  reference text,
  payload jsonb not null default '{}'::jsonb,
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists business_records_branch_type_idx
  on public.business_records(branch_id, record_type, created_at desc);

create or replace function public.current_user_role()
returns text language sql stable security definer
set search_path = public
as $$
  select role from public.profiles
  where id = auth.uid() and is_active = true
$$;

create or replace function public.current_user_branch()
returns uuid language sql stable security definer
set search_path = public
as $$
  select branch_id from public.profiles
  where id = auth.uid() and is_active = true
$$;

create or replace function public.is_active_user()
returns boolean language sql stable security definer
set search_path = public
as $$
  select exists(select 1 from public.profiles where id = auth.uid() and is_active = true)
$$;

alter table public.branches enable row level security;
alter table public.profiles enable row level security;
alter table public.business_records enable row level security;

drop policy if exists "active users read permitted branches" on public.branches;
create policy "active users read permitted branches" on public.branches
for select to authenticated
using (
  public.current_user_role() = 'super_admin'
  or id = public.current_user_branch()
);

drop policy if exists "super admin manages branches" on public.branches;
create policy "super admin manages branches" on public.branches
for all to authenticated
using (public.current_user_role() = 'super_admin')
with check (public.current_user_role() = 'super_admin');

drop policy if exists "users read own profile or admin reads all" on public.profiles;
create policy "users read own profile or admin reads all" on public.profiles
for select to authenticated
using (id = auth.uid() or public.current_user_role() = 'super_admin');

drop policy if exists "super admin manages profiles" on public.profiles;
create policy "super admin manages profiles" on public.profiles
for all to authenticated
using (public.current_user_role() = 'super_admin')
with check (public.current_user_role() = 'super_admin');

drop policy if exists "read own branch records" on public.business_records;
create policy "read own branch records" on public.business_records
for select to authenticated
using (
  public.current_user_role() = 'super_admin'
  or branch_id = public.current_user_branch()
);

drop policy if exists "insert records in permitted branch" on public.business_records;
create policy "insert records in permitted branch" on public.business_records
for insert to authenticated
with check (
  public.is_active_user()
  and (
    public.current_user_role() = 'super_admin'
    or branch_id = public.current_user_branch()
  )
  and created_by = auth.uid()
);

drop policy if exists "update records in permitted branch" on public.business_records;
create policy "update records in permitted branch" on public.business_records
for update to authenticated
using (
  public.current_user_role() = 'super_admin'
  or branch_id = public.current_user_branch()
)
with check (
  public.current_user_role() = 'super_admin'
  or branch_id = public.current_user_branch()
);

drop policy if exists "delete records in permitted branch" on public.business_records;
create policy "delete records in permitted branch" on public.business_records
for delete to authenticated
using (
  public.current_user_role() = 'super_admin'
  or (branch_id = public.current_user_branch()
      and public.current_user_role() in ('branch_manager'))
);

-- BOOTSTRAP SUPER ADMIN:
-- 1) Create your first user in Supabase Authentication > Users.
-- 2) Copy that user's UUID and replace YOUR_AUTH_USER_UUID below.
-- 3) Run this block once. Do not expose the UUID bootstrap procedure to staff.
insert into public.profiles (id, full_name, role, branch_id, is_active)
values ('YOUR_AUTH_USER_UUID', 'Abdullahi Ibrahim', 'super_admin', null, true)
on conflict (id) do update
set full_name = excluded.full_name, role = 'super_admin', is_active = true;
