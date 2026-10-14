-- ========================================================
-- SISTEM INFORMASI PELAYANAN PUBLIK KECAMATAN TARAKAN TIMUR
-- Berdasarkan Proposal Inovasi & Arahan Dosen Pembimbing
-- Kompatibel penuh dengan Liam ERD & PostgreSQL/MySQL
-- ========================================================

-- ========================================================
-- 1. MODUL AUTENTIKASI & PENGGUNA (Revisi Proposal Hal 11)
-- ========================================================

CREATE TABLE users (
    id_user SERIAL PRIMARY KEY,
    nik VARCHAR(16) UNIQUE,
    nama_lengkap VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    no_hp VARCHAR(20) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL, -- 'warga', 'admin_pelayanan', 'kasi', 'camat', 'superadmin'
    seksi_jabatan VARCHAR(50), -- Khusus Kasi: 'Pemerintahan', 'Kesra', 'Trantib', 'Ekonomi'
    alamat TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ========================================================
-- 2. MODUL MASTER LAYANAN & PERSYARATAN (Modul 4)
-- Menampung semua 9 atau 22 layanan (SKTM, Hak Milik Kapal, dll)
-- ========================================================

CREATE TABLE jenis_layanan (
    id_layanan SERIAL PRIMARY KEY,
    nama_layanan VARCHAR(150) NOT NULL,
    seksi VARCHAR(50) NOT NULL, -- 'Pemerintahan', 'Kesra', 'Trantib', 'Ekonomi'
    dasar_hukum TEXT,
    jangka_waktu VARCHAR(50) DEFAULT '1 hari kerja',
    biaya VARCHAR(20) DEFAULT 'Gratis',
    output_dokumen VARCHAR(100) NOT NULL,
    deskripsi TEXT
);

CREATE TABLE daftar_persyaratan (
    id_syarat SERIAL PRIMARY KEY,
    id_layanan INT NOT NULL,
    nama_syarat VARCHAR(255) NOT NULL,
    wajib BOOLEAN DEFAULT TRUE,
    keterangan VARCHAR(255),
    FOREIGN KEY (id_layanan) REFERENCES jenis_layanan(id_layanan) ON DELETE CASCADE
);

-- ========================================================
-- 3. MODUL TRANSAKSI PELAYANAN & TTE BARCODE (Modul 4)
-- ========================================================

CREATE TABLE pengajuan_pelayanan (
    id_pengajuan SERIAL PRIMARY KEY,
    no_registrasi VARCHAR(50) UNIQUE NOT NULL,
    id_user INT NOT NULL,
    id_layanan INT NOT NULL,
    tgl_pengajuan TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status_pengajuan VARCHAR(50) DEFAULT 'Diajukan', 
    catatan_revisi TEXT,
    qr_code_tte VARCHAR(255),
    file_surat_selesai VARCHAR(255),
    id_verifikator INT,
    id_kasi INT,
    id_camat INT,
    tgl_selesai TIMESTAMP,
    FOREIGN KEY (id_user) REFERENCES users(id_user),
    FOREIGN KEY (id_layanan) REFERENCES jenis_layanan(id_layanan),
    FOREIGN KEY (id_verifikator) REFERENCES users(id_user),
    FOREIGN KEY (id_kasi) REFERENCES users(id_user),
    FOREIGN KEY (id_camat) REFERENCES users(id_user)
);

CREATE TABLE berkas_pengajuan (
    id_berkas SERIAL PRIMARY KEY,
    id_pengajuan INT NOT NULL,
    id_syarat INT NOT NULL,
    file_url VARCHAR(255) NOT NULL,
    status_berkas VARCHAR(50) DEFAULT 'Menunggu Verifikasi',
    catatan_admin VARCHAR(255),
    FOREIGN KEY (id_pengajuan) REFERENCES pengajuan_pelayanan(id_pengajuan) ON DELETE CASCADE,
    FOREIGN KEY (id_syarat) REFERENCES daftar_persyaratan(id_syarat)
);

-- ========================================================
-- 4. MODUL DATA DEMOGRAFI & MONOGRAFI KELURAHAN (Modul 6)
-- ========================================================

CREATE TABLE kelurahan (
    id_kelurahan SERIAL PRIMARY KEY,
    nama_kelurahan VARCHAR(100) NOT NULL,
    luas_wilayah DECIMAL(8, 2),
    jumlah_rt INT DEFAULT 0,
    jumlah_rw INT DEFAULT 0,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8)
);

CREATE TABLE demografi_penduduk (
    id_demografi SERIAL PRIMARY KEY,
    id_kelurahan INT NOT NULL,
    tahun INT NOT NULL,
    jumlah_laki_laki INT DEFAULT 0,
    jumlah_perempuan INT DEFAULT 0,
    jumlah_penduduk INT DEFAULT 0,
    jumlah_kk INT DEFAULT 0,
    FOREIGN KEY (id_kelurahan) REFERENCES kelurahan(id_kelurahan)
);

-- ========================================================
-- 5. MODUL ASPIRASI & PENGADUAN SP4N-LAPOR! (Modul 5)
-- ========================================================

CREATE TABLE pengaduan_masyarakat (
    id_pengaduan SERIAL PRIMARY KEY,
    id_user INT NOT NULL,
    judul_laporan VARCHAR(200) NOT NULL,
    isi_laporan TEXT NOT NULL,
    kategori VARCHAR(50),
    status_laporan VARCHAR(50) DEFAULT 'Menunggu Tanggapan',
    tanggapan TEXT,
    id_petugas_tanggapan INT,
    tgl_laporan TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_user) REFERENCES users(id_user),
    FOREIGN KEY (id_petugas_tanggapan) REFERENCES users(id_user)
);

-- ========================================================
-- 6. MODUL INFORMASI PUBLIK, AGENDA & PPID (Modul 1, 2, 7)
-- ========================================================

CREATE TABLE berita_agenda (
    id_konten SERIAL PRIMARY KEY,
    id_penulis INT NOT NULL,
    tipe_konten VARCHAR(20) NOT NULL,
    judul VARCHAR(255) NOT NULL,
    isi TEXT NOT NULL,
    gambar_thumbnail VARCHAR(255),
    tgl_kegiatan TIMESTAMP,
    lokasi_kegiatan VARCHAR(255),
    tgl_publikasi TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_penulis) REFERENCES users(id_user)
);

CREATE TABLE dokumen_ppid (
    id_dokumen SERIAL PRIMARY KEY,
    id_petugas INT NOT NULL,
    judul_dokumen VARCHAR(255) NOT NULL,
    kategori_ppid VARCHAR(50) NOT NULL,
    file_url VARCHAR(255) NOT NULL,
    tahun INT,
    tgl_upload TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_petugas) REFERENCES users(id_user)
);
