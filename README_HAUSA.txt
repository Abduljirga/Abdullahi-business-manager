ABDULLAHI IBRAHIM BUSINESS MANAGER — V4 CLOUD STARTER
======================================================

Wannan sigar tana shirya tsarin ONLINE LOGIN + DATABASE da rassa.

ABUBUWAN DA KE CIKI
- login.html: shafin shiga na Super Admin/ma'aikata ta Supabase Auth.
- config.example.js: inda za a saka Supabase Project URL da anon/publishable key.
- supabase_schema.sql: teburin branches, profiles, business_records da tsaron RLS.
- SETUP_HAUSA.txt: matakan kafa Supabase da bude Super Admin.

MUHIMMIN GARGADI
Wannan CLOUD STARTER ne, ba a gama haɗa tsoffin invoices/cash flow/inventory UI da cloud database ba.
Har sai an kammala setup da gwaji, kada a saka bayanan kuɗi na gaske.
Ba a saka password ko secret key a cikin wannan ZIP ba. Kada ka taɓa aika Supabase service_role key ga kowa ko saka shi a browser.
Supabase anon/publishable key ne kawai ake amfani da shi a browser; RLS ne ke kare bayanai.

Abin da ake bukata daga gare ka domin mu kammala:
1. Ƙirƙiri Supabase project.
2. Ka samar da Project URL da anon/publishable key.
3. Ka turo min Project URL da anon/publishable key kawai (ba password ba, ba service_role key ba).
4. Za mu haɗa tsohon tsarin invoices, stock, expenses da reports da database, sannan mu gwada permissions.
