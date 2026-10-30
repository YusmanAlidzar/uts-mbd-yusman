-- 1) Buat user
CREATE ROLE backend_dev   LOGIN PASSWORD 'backend123';
CREATE ROLE bi_dev        LOGIN PASSWORD 'bi123';
CREATE ROLE data_engineer LOGIN PASSWORD 'de123';

-- 2) Boleh connect & masuk schema
GRANT CONNECT ON DATABASE postgres TO backend_dev, bi_dev, data_engineer;
GRANT USAGE ON SCHEMA salam TO backend_dev, bi_dev;

-- 3) backend_dev: CRUD semua tabel
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA salam TO backend_dev;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA salam TO backend_dev;

-- 4) bi_dev: hanya SELECT (tabel & view)
GRANT SELECT ON ALL TABLES IN SCHEMA salam TO bi_dev;

-- 5) data_engineer: jadikan OWNER schema & semua tabel/view
--    (owner otomatis boleh CREATE/ALTER/DROP + CRUD)
ALTER SCHEMA salam OWNER TO data_engineer;
DO $$
DECLARE r record;
BEGIN
  FOR r IN
    SELECT c.relname FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE n.nspname = 'salam' AND c.relkind IN ('r','v')
  LOOP
    EXECUTE format('ALTER TABLE salam.%I OWNER TO data_engineer', r.relname);
  END LOOP;
END $$;

-- 6) Objek baru buatan data_engineer otomatis dapat hak untuk role lain
ALTER DEFAULT PRIVILEGES FOR ROLE data_engineer IN SCHEMA salam
  GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO backend_dev;
ALTER DEFAULT PRIVILEGES FOR ROLE data_engineer IN SCHEMA salam
  GRANT SELECT ON TABLES TO bi_dev;