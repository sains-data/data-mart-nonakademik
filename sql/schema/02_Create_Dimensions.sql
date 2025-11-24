
/***********************************************
  FULL: Create Dimensions + Facts (safe for partitioning)
  - Dimensions: PK as identity (clustered default)
  - Facts: identity keys but NO PRIMARY KEY (so no automatic clustered PK)
  - All FK constraints created to link facts -> dims
***********************************************/

USE DM_NonAkademik_DW;
GO

-- ===========================
-- DIMENSIONS
-- ===========================

-- DimTanggal
IF OBJECT_ID('dbo.DimTanggal') IS NULL
CREATE TABLE dbo.DimTanggal (
    DateKey INT NOT NULL PRIMARY KEY, -- format YYYYMMDD
    FullDate DATE NOT NULL,
    DayNumberOfWeek TINYINT NOT NULL,
    DayName VARCHAR(20) NOT NULL,
    DayNumberOfMonth TINYINT NOT NULL,
    DayNumberOfYear SMALLINT NOT NULL,
    WeekNumberOfYear TINYINT NOT NULL,
    MonthName VARCHAR(20) NOT NULL,
    MonthNumber TINYINT NOT NULL,
    Quarter TINYINT NOT NULL,
    QuarterName VARCHAR(10) NOT NULL,
    YearNumber SMALLINT NOT NULL,
    IsWeekend BIT NOT NULL,
    IsHoliday BIT NOT NULL,
    HolidayName VARCHAR(100) NULL,
    AcademicYear VARCHAR(9) NULL,
    Semester TINYINT NULL,
    CreatedDate DATETIME DEFAULT GETDATE()
);
GO

-- DimUnitKerja
IF OBJECT_ID('dbo.DimUnitKerja') IS NULL
CREATE TABLE dbo.DimUnitKerja (
    UnitKey INT IDENTITY(1,1) PRIMARY KEY,
    UnitCode VARCHAR(50) NULL,
    UnitName VARCHAR(250) NOT NULL,
    UnitType VARCHAR(100) NULL,
    ParentUnitCode VARCHAR(50) NULL,
    EffectiveDate DATE NOT NULL DEFAULT GETDATE(),
    ExpiryDate DATE NULL,
    IsCurrent BIT NOT NULL DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedDate DATETIME DEFAULT GETDATE()
);
GO

-- DimVendor
IF OBJECT_ID('dbo.DimVendor') IS NULL
CREATE TABLE dbo.DimVendor (
    VendorKey INT IDENTITY(1,1) PRIMARY KEY,
    VendorCode VARCHAR(100) NULL,
    VendorName VARCHAR(250) NOT NULL,
    Category VARCHAR(100) NULL,
    City VARCHAR(100) NULL,
    ContactPerson VARCHAR(150) NULL,
    ContactPhone VARCHAR(50) NULL,
    Email VARCHAR(150) NULL,
    CreatedDate DATETIME DEFAULT GETDATE()
);
GO

-- DimAsalSurat
IF OBJECT_ID('dbo.DimAsalSurat') IS NULL
CREATE TABLE dbo.DimAsalSurat (
    AsalKey INT IDENTITY(1,1) PRIMARY KEY,
    AsalName VARCHAR(250) NOT NULL,
    AsalType VARCHAR(100) NULL,
    Kota VARCHAR(100) NULL,
    CreatedDate DATETIME DEFAULT GETDATE()
);
GO

-- DimTujuanSurat
IF OBJECT_ID('dbo.DimTujuanSurat') IS NULL
CREATE TABLE dbo.DimTujuanSurat (
    TujuanKey INT IDENTITY(1,1) PRIMARY KEY,
    TujuanName VARCHAR(250) NOT NULL,
    TujuanType VARCHAR(100) NULL,
    Kota VARCHAR(100) NULL,
    CreatedDate DATETIME DEFAULT GETDATE()
);
GO

-- DimAkunBelanja
IF OBJECT_ID('dbo.DimAkunBelanja') IS NULL
CREATE TABLE dbo.DimAkunBelanja (
    AkunKey INT IDENTITY(1,1) PRIMARY KEY,
    KodeAkun VARCHAR(50) NOT NULL,
    NamaAkun VARCHAR(250) NOT NULL,
    KelompokAkun VARCHAR(100) NULL,
    KategoriBelanja VARCHAR(100) NULL,
    CreatedDate DATETIME DEFAULT GETDATE()
);
GO

-- DimFasilitas
IF OBJECT_ID('dbo.DimFasilitas') IS NULL
CREATE TABLE dbo.DimFasilitas (
    FasilitasKey INT IDENTITY(1,1) PRIMARY KEY,
    FasilitasCode VARCHAR(100) NULL,
    NamaFasilitas VARCHAR(250) NOT NULL,
    JenisFasilitas VARCHAR(100) NULL,
    LokasiCode VARCHAR(100) NULL,
    Kapasitas INT NULL,
    UnitPengelolaCode VARCHAR(50) NULL,
    CreatedDate DATETIME DEFAULT GETDATE()
);
GO

-- DimKategoriPengadaan
IF OBJECT_ID('dbo.DimKategoriPengadaan') IS NULL
CREATE TABLE dbo.DimKategoriPengadaan (
    KategoriKey INT IDENTITY(1,1) PRIMARY KEY,
    KategoriName VARCHAR(200) NOT NULL,
    SubKategori VARCHAR(200) NULL,
    CreatedDate DATETIME DEFAULT GETDATE()
);
GO

-- DimLokasi
IF OBJECT_ID('dbo.DimLokasi') IS NULL
CREATE TABLE dbo.DimLokasi (
    LokasiKey INT IDENTITY(1,1) PRIMARY KEY,
    LokasiCode VARCHAR(100) NULL,
    LokasiName VARCHAR(250) NOT NULL,
    Alamat VARCHAR(300) NULL,
    Kota VARCHAR(100) NULL,
    Provinsi VARCHAR(100) NULL,
    CreatedDate DATETIME DEFAULT GETDATE()
);
GO

-- DimKeperluan
IF OBJECT_ID('dbo.DimKeperluan') IS NULL
CREATE TABLE dbo.DimKeperluan (
    KeperluanKey INT IDENTITY(1,1) PRIMARY KEY,
    KeperluanDesc VARCHAR(250) NOT NULL,
    CreatedDate DATETIME DEFAULT GETDATE()
);
GO

-- DimPerihalSurat
IF OBJECT_ID('dbo.DimPerihalSurat') IS NULL
CREATE TABLE dbo.DimPerihalSurat (
    PerihalKey INT IDENTITY(1,1) PRIMARY KEY,
    PerihalDesc VARCHAR(250) NOT NULL,
    CreatedDate DATETIME DEFAULT GETDATE()
);
GO

-- DimStatus (single status table for multiple processes)
IF OBJECT_ID('dbo.DimStatus') IS NULL
CREATE TABLE dbo.DimStatus (
    StatusKey INT IDENTITY(1,1) PRIMARY KEY,
    ProcessType VARCHAR(50) NOT NULL, -- SURAT / PENGADAAN / PEMINJAMAN / LAYANAN / BMN
    StatusName VARCHAR(100) NOT NULL,
    Description VARCHAR(250) NULL,
    CreatedDate DATETIME DEFAULT GETDATE()
);
GO

-- DimBMN
IF OBJECT_ID('dbo.DimBMN') IS NULL
CREATE TABLE dbo.DimBMN (
    BMNKey INT IDENTITY(1,1) PRIMARY KEY,
    KodeBarang VARCHAR(100) NOT NULL,
    NamaBarang VARCHAR(250) NOT NULL,
    KategoriBarang VARCHAR(150) NULL,
    JenisBarang VARCHAR(150) NULL,
    TanggalPerolehan DATE NULL,
    SumberPerolehan VARCHAR(100) NULL,       -- Pengadaan / Hibah
    HargaPerolehan DECIMAL(18,2) NULL,
    KondisiAwal VARCHAR(100) NULL,
    KondisiSaatIni VARCHAR(100) NULL,
    LokasiAwalKey INT NULL,
    LokasiSaatIniKey INT NULL,
    UnitPenggunaKey INT NULL,
    StatusAset VARCHAR(100) NULL,            -- Aktif / Tidak Layak / Dihapus / Dipindah
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedDate DATETIME DEFAULT GETDATE()
);
GO

-- add FK on DimBMN to lokasi/unit (if dims exist)
IF OBJECT_ID('dbo.DimLokasi') IS NOT NULL AND OBJECT_ID('dbo.DimUnitKerja') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_BMN_LokasiAwal')
        ALTER TABLE dbo.DimBMN
        ADD CONSTRAINT FK_BMN_LokasiAwal FOREIGN KEY (LokasiAwalKey) REFERENCES dbo.DimLokasi(LokasiKey);

    IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_BMN_LokasiSaatIni')
        ALTER TABLE dbo.DimBMN
        ADD CONSTRAINT FK_BMN_LokasiSaatIni FOREIGN KEY (LokasiSaatIniKey) REFERENCES dbo.DimLokasi(LokasiKey);

    IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_BMN_UnitPengguna')
        ALTER TABLE dbo.DimBMN
        ADD CONSTRAINT FK_BMN_UnitPengguna FOREIGN KEY (UnitPenggunaKey) REFERENCES dbo.DimUnitKerja(UnitKey);
END
GO

-- DimJenisLayanan (for Layanan Administrasi)
IF OBJECT_ID('dbo.DimJenisLayanan') IS NULL
CREATE TABLE dbo.DimJenisLayanan (
    JenisLayananKey INT IDENTITY(1,1) PRIMARY KEY,
    JenisLayananName VARCHAR(150) NOT NULL,
    Description VARCHAR(250) NULL,
    CreatedDate DATETIME DEFAULT GETDATE()
);
GO

-- optional helpful indexes on dims (SQL Server SAFE)

-- DimUnitKerja
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes 
    WHERE name = 'IX_DimUnitKerja_UnitCode'
      AND object_id = OBJECT_ID('dbo.DimUnitKerja')
)
CREATE INDEX IX_DimUnitKerja_UnitCode 
ON dbo.DimUnitKerja(UnitCode);
GO

-- DimAkunBelanja
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes 
    WHERE name = 'IX_DimAkunBelanja_KodeAkun'
      AND object_id = OBJECT_ID('dbo.DimAkunBelanja')
)
CREATE INDEX IX_DimAkunBelanja_KodeAkun 
ON dbo.DimAkunBelanja(KodeAkun);
GO

-- DimFasilitas
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes 
    WHERE name = 'IX_DimFasilitas_Nama'
      AND object_id = OBJECT_ID('dbo.DimFasilitas')
)
CREATE INDEX IX_DimFasilitas_Nama 
ON dbo.DimFasilitas(NamaFasilitas);
GO

