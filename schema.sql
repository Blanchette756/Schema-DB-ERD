-- ========================================================
-- SISTEM INFORMASI PELAYANAN PUBLIK KECAMATAN TARAKAN TIMUR
-- Berdasarkan Proposal Inovasi & Arahan Dosen Pembimbing
-- Kompatibel penuh dengan Liam ERD & PostgreSQL/MySQL
-- ========================================================

-- ========================================================
-- 1. MODUL WILAYAH & DATA DEMOGRAFI KELURAHAN (Modul 6)
-- ========================================================

CREATE TABLE kelurahan (
    id_kelurahan SERIAL PRIMARY KEY,
    nama_kelurahan VARCHAR(100) NOT NULL,
    luas_wilayah DECIMAL(8, 2), -- dalam km²
    jumlah_rt INT DEFAULT 0,
    jumlah_rw INT DEFAULT 0,
    latitude DECIMAL(10, 8),    -- Koordinat GIS untuk Peta
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
    FOREIGN KEY (id_kelurahan) REFERENCES kelurahan(id_kelurahan) ON DELETE CASCADE
);

-- ========================================================
-- 2. MODUL AUTENTIKASI & PENGGUNA (Revisi Proposal Hal 11)
-- Terhubung ke kelurahan tempat domisili warga
-- ========================================================

CREATE TABLE users (
    id_user SERIAL PRIMARY KEY,
    id_kelurahan INT,                          -- Kelurahan tempat tinggal warga
    nik VARCHAR(16) UNIQUE,
    nama_lengkap VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    no_hp VARCHAR(20) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL,                 -- 'warga', 'admin_pelayanan', 'kasi', 'camat', 'superadmin'
    seksi_jabatan VARCHAR(50),                 -- Khusus Kasi: 'Pemerintahan', 'Kesra', 'Trantib', 'Ekonomi'
    alamat TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_kelurahan) REFERENCES kelurahan(id_kelurahan)
);

-- ========================================================
-- 3. MODUL MASTER LAYANAN & PERSYARATAN (Modul 4)
-- Menampung semua 9 atau 22 layanan kecamatan
-- ========================================================

CREATE TABLE jenis_layanan (
    id_layanan SERIAL PRIMARY KEY,
    nama_layanan VARCHAR(150) NOT NULL,
    seksi VARCHAR(50) NOT NULL,                -- 'Pemerintahan', 'Kesra', 'Trantib', 'Ekonomi'
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
-- 4. MODUL TRANSAKSI PELAYANAN & TTE BARCODE (Modul 4)
-- ========================================================

CREATE TABLE pengajuan_pelayanan (
    id_pengajuan SERIAL PRIMARY KEY,
    no_registrasi VARCHAR(50) UNIQUE NOT NULL,
    id_user INT NOT NULL,                      -- Pemohon (Warga yang login)
    id_layanan INT NOT NULL,
    tgl_pengajuan TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status_pengajuan VARCHAR(50) DEFAULT 'Diajukan', 
    -- Status: 'Diajukan', 'Diverifikasi', 'Perlu Perbaikan', 'Disetujui Kasi', 'Disetujui Camat (Selesai)', 'Ditolak'
    catatan_revisi TEXT,                       -- Catatan admin jika berkas ada yang kurang
    qr_code_tte VARCHAR(255),                  -- Token QR Code / Barcode pengesahan Camat
    file_surat_selesai VARCHAR(255),           -- Berkas PDF sah yang bisa diunduh warga
    id_verifikator INT,                        -- Admin pelayanan yang memeriksa
    id_kasi INT,                               -- Kasi yang memvalidasi
    id_camat INT,                              -- Camat yang mengesahkan
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
    status_berkas VARCHAR(50) DEFAULT 'Menunggu Verifikasi', -- 'Valid', 'Tidak Valid'
    catatan_admin VARCHAR(255),
    FOREIGN KEY (id_pengajuan) REFERENCES pengajuan_pelayanan(id_pengajuan) ON DELETE CASCADE,
    FOREIGN KEY (id_syarat) REFERENCES daftar_persyaratan(id_syarat)
);

-- ========================================================
-- 5. MODUL ASPIRASI & PENGADUAN SP4N-LAPOR! (Modul 5)
-- ========================================================

CREATE TABLE pengaduan_masyarakat (
    id_pengaduan SERIAL PRIMARY KEY,
    id_user INT NOT NULL,                      -- Warga yang melapor
    judul_laporan VARCHAR(200) NOT NULL,
    isi_laporan TEXT NOT NULL,
    kategori VARCHAR(50),                      -- 'Pelayanan', 'Infrastruktur', 'Trantib', dll.
    status_laporan VARCHAR(50) DEFAULT 'Menunggu Tanggapan', -- 'Diproses', 'Selesai', 'Ditolak'
    tanggapan TEXT,
    id_petugas_tanggapan INT,
    tgl_laporan TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_user) REFERENCES users(id_user),
    FOREIGN KEY (id_petugas_tanggapan) REFERENCES users(id_user)
);

-- ========================================================
-- 6. MODUL INFORMASI PUBLIK & AGENDA KECAMATAN (Modul 1 & 2)
-- ========================================================

CREATE TABLE berita_agenda (
    id_konten SERIAL PRIMARY KEY,
    id_penulis INT NOT NULL,
    tipe_konten VARCHAR(20) NOT NULL,          -- 'Berita', 'Pengumuman', 'Agenda'
    judul VARCHAR(255) NOT NULL,
    isi TEXT NOT NULL,
    gambar_thumbnail VARCHAR(255),
    tgl_kegiatan TIMESTAMP,                    -- Khusus jika tipe agenda
    lokasi_kegiatan VARCHAR(255),              -- Khusus jika tipe agenda
    tgl_publikasi TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_penulis) REFERENCES users(id_user)
);
