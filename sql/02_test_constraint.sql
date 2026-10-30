-- A. Data valid (BERHASIL)
INSERT INTO salam.mahasiswas (nim, nama, email, ipk, angkatan)
VALUES ('1247050022', 'Yusman Alidzar Abdulah', 'yusmanalidzar@mail.com', 3.75, 2022);

INSERT INTO salam.mata_kuliahs VALUES ('MBD01', 'Manajemen Basis Data', 3);
INSERT INTO salam.krs (mahasiswa_id, kode_mk, semester) VALUES (1, 'MBD01', 5);

-- B. PRIMARY KEY duplikat (GAGAL)
INSERT INTO salam.mahasiswas (id, nim, nama, ipk, angkatan)
VALUES (1, '1247050001', 'Tes PK', 3.0, 2022);

-- C. UNIQUE: NIM sama (GAGAL)
INSERT INTO salam.mahasiswas (nim, nama, ipk, angkatan)
VALUES ('1247050022', 'Tes Unique', 3.0, 2022);

-- D. CHECK: IPK > 4 (GAGAL)
INSERT INTO salam.mahasiswas (nim, nama, ipk, angkatan)
VALUES ('1247050002', 'Tes Check', 5.00, 2022);

-- E. NOT NULL (GAGAL)
INSERT INTO salam.mahasiswas (nim, nama, ipk, angkatan)
VALUES ('1247050003', NULL, 3.0, 2022);

-- F. FOREIGN KEY: mahasiswa tidak ada (GAGAL)
INSERT INTO salam.krs (mahasiswa_id, kode_mk, semester) VALUES (999, 'MBD01', 5);

-- G. Bukti trigger
UPDATE salam.mahasiswas SET ipk = 3.90 WHERE nim = '1247050022';
SELECT id, aksi, data_lama, data_baru, user_db, waktu FROM salam.audit_log;

-- H. Transaksi ROLLBACK
BEGIN;
DELETE FROM salam.mahasiswas WHERE nim = '1247050022';
SELECT * FROM salam.mahasiswas;   -- kosong
ROLLBACK;
SELECT * FROM salam.mahasiswas;   -- data kembali