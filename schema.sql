-- Buat database & aktifkan
CREATE DATABASE db_kecamatan_tarakan;
USE db_kecamatan_tarakan;

-- 1. Tabel Pemohon
CREATE TABLE pemohon (
    id_pemohon INT PRIMARY KEY AUTO_INCREMENT,
    nik VARCHAR(16) NOT NULL,
    no_kk VARCHAR(16) NOT NULL,
    nama_lengkap VARCHAR(100) NOT NULL,
    alamat TEXT NOT NULL,
    no_hp VARCHAR(15) NOT NULL
);

-- 2. Tabel Pegawai
CREATE TABLE pegawai (
    id_pegawai INT PRIMARY KEY AUTO_INCREMENT,
    nip VARCHAR(20) NOT NULL,
    nama_pegawai VARCHAR(100) NOT NULL,
    jabatan VARCHAR(50) NOT NULL,
    pangkat_golongan VARCHAR(50)
);

-- 3. Tabel Jenis Layanan
CREATE TABLE jenis_layanan (
    id_layanan INT PRIMARY KEY AUTO_INCREMENT,
    no_dokumen_sp VARCHAR(50) NOT NULL,
    nama_layanan VARCHAR(150) NOT NULL,
    jangka_waktu VARCHAR(50) DEFAULT '1 hari kerja',
    biaya VARCHAR(20) DEFAULT 'Gratis',
    produk_pelayanan VARCHAR(100) NOT NULL
);

-- 4. Tabel Daftar Persyarat (Sebelumnya master_syarat)
CREATE TABLE daftar_persyarat (
    id_syarat INT PRIMARY KEY AUTO_INCREMENT,
    id_layanan INT NOT NULL,
    nama_persyaratan VARCHAR(255) NOT NULL,
    keterangan_tambahan VARCHAR(100),
    FOREIGN KEY (id_layanan) REFERENCES jenis_layanan(id_layanan) ON DELETE CASCADE
);

-- 5. Tabel Permohonan
CREATE TABLE permohonan (
    id_permohonan INT PRIMARY KEY AUTO_INCREMENT,
    id_pemohon INT NOT NULL,
    id_layanan INT NOT NULL,
    id_petugas INT,
    id_kasi INT,
    id_camat INT,
    no_registrasi VARCHAR(50),
    tgl_pengajuan DATETIME DEFAULT CURRENT_TIMESTAMP,
    status_berkas ENUM('Pending', 'Lengkap', 'Ditolak') DEFAULT 'Pending',
    status_paraf_kasi BOOLEAN DEFAULT FALSE,
    status_ttd_camat BOOLEAN DEFAULT FALSE,
    tgl_selesai DATE,
    FOREIGN KEY (id_pemohon) REFERENCES pemohon(id_pemohon),
    FOREIGN KEY (id_layanan) REFERENCES jenis_layanan(id_layanan),
    FOREIGN KEY (id_petugas) REFERENCES pegawai(id_pegawai),
    FOREIGN KEY (id_kasi) REFERENCES pegawai(id_pegawai),
    FOREIGN KEY (id_camat) REFERENCES pegawai(id_pegawai)
);

-- 6. Tabel Berkas Permohonan
CREATE TABLE berkas_permohonan (
    id_berkas INT PRIMARY KEY AUTO_INCREMENT,
    id_permohonan INT NOT NULL,
    id_syarat INT NOT NULL,
    file_dokumen VARCHAR(255),
    status_verifikasi ENUM('Belum Diperiksa', 'Valid', 'Tidak Valid') DEFAULT 'Belum Diperiksa',
    FOREIGN KEY (id_permohonan) REFERENCES permohonan(id_permohonan) ON DELETE CASCADE,
    FOREIGN KEY (id_syarat) REFERENCES daftar_persyarat(id_syarat)
);