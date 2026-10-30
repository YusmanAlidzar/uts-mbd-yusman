CREATE SCHEMA IF NOT EXISTS salam;

-- Tabel utama (PK, UNIQUE, CHECK, NOT NULL)
CREATE TABLE salam.mahasiswas (
    id         SERIAL PRIMARY KEY,
    nim        VARCHAR(12)  NOT NULL UNIQUE,
    nama       VARCHAR(100) NOT NULL,
    email      VARCHAR(100) UNIQUE,
    ipk        NUMERIC(3,2) NOT NULL CHECK (ipk BETWEEN 0 AND 4),
    angkatan   INT          NOT NULL CHECK (angkatan >= 2000),
    created_at TIMESTAMP    DEFAULT NOW()
);

-- 1) Tabel relasi dengan Foreign Key
CREATE TABLE salam.mata_kuliahs (
    kode    VARCHAR(10) PRIMARY KEY,
    nama_mk VARCHAR(100) NOT NULL,
    sks     INT NOT NULL CHECK (sks BETWEEN 1 AND 6)
);

CREATE TABLE salam.krs (
    id           SERIAL PRIMARY KEY,
    mahasiswa_id INT NOT NULL REFERENCES salam.mahasiswas(id) ON DELETE CASCADE,
    kode_mk      VARCHAR(10) NOT NULL REFERENCES salam.mata_kuliahs(kode),
    semester     INT NOT NULL CHECK (semester BETWEEN 1 AND 14),
    UNIQUE (mahasiswa_id, kode_mk, semester)
);

-- 2) Audit log + trigger
CREATE TABLE salam.audit_log (
    id        SERIAL PRIMARY KEY,
    tabel     TEXT,
    aksi      TEXT,
    data_lama JSONB,
    data_baru JSONB,
    user_db   TEXT DEFAULT current_user,
    waktu     TIMESTAMP DEFAULT NOW()
);

CREATE OR REPLACE FUNCTION salam.fn_audit_mahasiswas() RETURNS trigger AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO salam.audit_log(tabel, aksi, data_baru)
        VALUES (TG_TABLE_NAME, TG_OP, to_jsonb(NEW));
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO salam.audit_log(tabel, aksi, data_lama, data_baru)
        VALUES (TG_TABLE_NAME, TG_OP, to_jsonb(OLD), to_jsonb(NEW));
        RETURN NEW;
    ELSE
        INSERT INTO salam.audit_log(tabel, aksi, data_lama)
        VALUES (TG_TABLE_NAME, TG_OP, to_jsonb(OLD));
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_audit_mahasiswas
AFTER INSERT OR UPDATE OR DELETE ON salam.mahasiswas
FOR EACH ROW EXECUTE FUNCTION salam.fn_audit_mahasiswas();

-- 3) View (nanti dipakai untuk uji bi_dev)
CREATE VIEW salam.v_mahasiswa_berprestasi AS
SELECT nim, nama, ipk, angkatan
FROM salam.mahasiswas
WHERE ipk >= 3.5;