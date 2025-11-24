-- =====================================================
-- 06_Create_Staging.sql
-- Staging Schema & Tables untuk DW Non-Akademik
-- =====================================================

CREATE SCHEMA stg;
GO

--------------------------------------------------------
-- STAGING: SURAT MASUK
--------------------------------------------------------
CREATE TABLE stg.SuratMasuk (
    NomorSurat VARCHAR(200),
    AsalSurat VARCHAR(250),
    KotaAsal VARCHAR(100),
    TanggalDiterima DATE,
    Perihal VARCHAR(300),
    JumlahLampiran INT,
    StatusSurat VARCHAR(100),
    UnitTujuan VARCHAR(200),
    LoadDate DATETIME DEFAULT GETDATE()
);
GO

--------------------------------------------------------
-- STAGING: SURAT KELUAR
--------------------------------------------------------
CREATE TABLE stg.SuratKeluar (
    NomorSurat VARCHAR(200),
    TujuanSurat VARCHAR(250),
    KotaTujuan VARCHAR(100),
    TanggalKeluar DATE,
    Perihal VARCHAR(300),
    StatusSurat VARCHAR(100),
    UnitPengirim VARCHAR(200),
    LoadDate DATETIME DEFAULT GETDATE()
);
GO

--------------------------------------------------------
-- STAGING: PENGADAAN BARANG/JASA
--------------------------------------------------------
CREATE TABLE stg.Pengadaan (
    NomorPengadaan VARCHAR(100),
    NamaVendor VARCHAR(250),
    KotaVendor VARCHAR(100),
    KategoriPengadaan VARCHAR(200),
    NilaiPengadaan DECIMAL(18,2),
    StatusPengadaan VARCHAR(100),
    UnitPemohon VARCHAR(200),
    TanggalPengadaan DATE,
    LoadDate DATETIME DEFAULT GETDATE()
);
GO

--------------------------------------------------------
-- STAGING: REALISASI ANGGARAN
--------------------------------------------------------
CREATE TABLE stg.RealisasiAnggaran (
    KodeAkun VARCHAR(50),
    NamaAkun VARCHAR(250),
    NilaiRealisasi DECIMAL(18,2),
    UnitKerja VARCHAR(200),
    TanggalRealisasi DATE,
    Keterangan VARCHAR(500),
    LoadDate DATETIME DEFAULT GETDATE()
);
GO

--------------------------------------------------------
-- STAGING: PEMINJAMAN FASILITAS
--------------------------------------------------------
CREATE TABLE stg.PeminjamanFasilitas (
    NamaFasilitas VARCHAR(250),
    JenisFasilitas VARCHAR(150),
    Lokasi VARCHAR(200),
    UnitPeminjam VARCHAR(200),
    Keperluan VARCHAR(250),
    TanggalPinjam DATE,
    TanggalKembali DATE,
    StatusPeminjaman VARCHAR(100),
    LoadDate DATETIME DEFAULT GETDATE()
);
GO

--------------------------------------------------------
-- STAGING: DATA BMN
--------------------------------------------------------
CREATE TABLE stg.BMN (
    KodeBarang VARCHAR(100),
    NamaBarang VARCHAR(250),
    KategoriBarang VARCHAR(200),
    JenisBarang VARCHAR(200),
    LokasiSaatIni VARCHAR(200),
    UnitPengguna VARCHAR(200),
    TanggalPerolehan DATE,
    SumberPerolehan VARCHAR(100),
    HargaPerolehan DECIMAL(18,2),
    KondisiSaatIni VARCHAR(100),
    LoadDate DATETIME DEFAULT GETDATE()
);
GO

--------------------------------------------------------
-- STAGING: UNIT KERJA
--------------------------------------------------------
CREATE TABLE stg.UnitKerja (
    UnitName VARCHAR(250),
    UnitType VARCHAR(100),
    ParentUnit VARCHAR(200),
    LoadDate DATETIME DEFAULT GETDATE()
);
GO

--------------------------------------------------------
-- STAGING: VENDOR
--------------------------------------------------------
CREATE TABLE stg.Vendor (
    NamaVendor VARCHAR(250),
    Kota VARCHAR(100),
    ContactPerson VARCHAR(150),
    ContactPhone VARCHAR(50),
    Email VARCHAR(150),
    LoadDate DATETIME DEFAULT GETDATE()
);
GO

--------------------------------------------------------
-- STAGING: LOKASI
--------------------------------------------------------
CREATE TABLE stg.Lokasi (
    Lokasi VARCHAR(250),
    Kota VARCHAR(100),
    Provinsi VARCHAR(100),
    LoadDate DATETIME DEFAULT GETDATE()
);
GO

