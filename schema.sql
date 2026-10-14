CREATE TABLE pemohon (
    id_pemohon SERIAL PRIMARY KEY,
    nik VARCHAR(16) NOT NULL,
    no_kk VARCHAR(16) NOT NULL,
    nama_lengkap VARCHAR(100) NOT NULL,
    alamat TEXT NOT NULL,
    no_hp VARCHAR(15) NOT NULL
);

CREATE TABLE pegawai (
    id_pegawai SERIAL PRIMARY KEY,
    nip VARCHAR(20) NOT NULL,
    nama_pegawai VARCHAR(100) NOT NULL,
    jabatan VARCHAR(50) NOT NULL,
    pangkat_golongan VARCHAR(50)
);

CREATE TABLE jenis_layanan (
    id_layanan SERIAL PRIMARY KEY,
    no_dokumen_sp VARCHAR(50) NOT NULL,
    nama_layanan VARCHAR(150) NOT NULL,
    jangka_waktu VARCHAR(50),
    biaya VARCHAR(20),
    produk_pelayanan VARCHAR(100) NOT NULL
);

CREATE TABLE daftar_persyarat (
    id_syarat SERIAL PRIMARY KEY,
    id_layanan INT NOT NULL,
    nama_persyaratan VARCHAR(255) NOT NULL,
    keterangan_tambahan VARCHAR(100),
    FOREIGN KEY (id_layanan) REFERENCES jenis_layanan(id_layanan)
);

CREATE TABLE permohonan (
    id_permohonan SERIAL PRIMARY KEY,
    id_pemohon INT NOT NULL,
    id_layanan INT NOT NULL,
    id_petugas INT,
    id_kasi INT,
    id_camat INT,
    no_registrasi VARCHAR(50),
    tgl_pengajuan TIMESTAMP,
    status_berkas VARCHAR(50),
    status_paraf_kasi BOOLEAN,
    status_ttd_camat BOOLEAN,
    tgl_selesai DATE,
    FOREIGN KEY (id_pemohon) REFERENCES pemohon(id_pemohon),
    FOREIGN KEY (id_layanan) REFERENCES jenis_layanan(id_layanan),
    FOREIGN KEY (id_petugas) REFERENCES pegawai(id_pegawai),
    FOREIGN KEY (id_kasi) REFERENCES pegawai(id_pegawai),
    FOREIGN KEY (id_camat) REFERENCES pegawai(id_pegawai)
);

CREATE TABLE berkas_permohonan (
    id_berkas SERIAL PRIMARY KEY,
    id_permohonan INT NOT NULL,
    id_syarat INT NOT NULL,
    file_dokumen VARCHAR(255),
    status_verifikasi VARCHAR(50),
    FOREIGN KEY (id_permohonan) REFERENCES permohonan(id_permohonan),
    FOREIGN KEY (id_syarat) REFERENCES daftar_persyarat(id_syarat)
);