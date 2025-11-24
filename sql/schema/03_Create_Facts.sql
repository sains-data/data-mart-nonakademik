
-- ===========================
-- FACTS (safe: no PK constraints so clustered index can be created later)
-- ===========================

-- Fact_RealisasiAnggaran
IF OBJECT_ID('dbo.Fact_RealisasiAnggaran') IS NULL
CREATE TABLE dbo.Fact_RealisasiAnggaran (
    RealisasiKey BIGINT IDENTITY(1,1) NOT NULL,
    DateKey INT NOT NULL,
    UnitKey INT NOT NULL,
    AkunKey INT NOT NULL,
    NilaiRealisasi DECIMAL(18,2) NOT NULL,
    SelisihAnggaranRealisasi DECIMAL(18,2) NULL,
    Keterangan VARCHAR(500) NULL,
    SourceSystem VARCHAR(100) NULL,
    LoadDate DATETIME DEFAULT GETDATE()
);
GO

-- FK Realisasi -> dims
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_FactRealisasi_DimTanggal')
ALTER TABLE dbo.Fact_RealisasiAnggaran
ADD CONSTRAINT FK_FactRealisasi_DimTanggal FOREIGN KEY (DateKey) REFERENCES dbo.DimTanggal(DateKey);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_FactRealisasi_DimUnit')
ALTER TABLE dbo.Fact_RealisasiAnggaran
ADD CONSTRAINT FK_FactRealisasi_DimUnit FOREIGN KEY (UnitKey) REFERENCES dbo.DimUnitKerja(UnitKey);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_FactRealisasi_DimAkun')
ALTER TABLE dbo.Fact_RealisasiAnggaran
ADD CONSTRAINT FK_FactRealisasi_DimAkun FOREIGN KEY (AkunKey) REFERENCES dbo.DimAkunBelanja(AkunKey);
GO

-- Fact_Pengadaan
IF OBJECT_ID('dbo.Fact_Pengadaan') IS NULL
CREATE TABLE dbo.Fact_Pengadaan (
    PengadaanKey BIGINT IDENTITY(1,1) NOT NULL,
    DateKey INT NOT NULL,
    UnitKey INT NOT NULL,
    VendorKey INT NULL,
    KategoriKey INT NULL,
    NilaiPengadaan DECIMAL(18,2) NOT NULL,
    StatusKey INT NULL,
    NomorPengadaan VARCHAR(100) NULL,
    VendorName VARCHAR(250) NULL,
    BMNKey INT NULL,
    SourceSystem VARCHAR(100) NULL,
    LoadDate DATETIME DEFAULT GETDATE()
);
GO

-- FK Pengadaan -> dims
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Pengadaan_BMN')
ALTER TABLE dbo.Fact_Pengadaan
ADD CONSTRAINT FK_Pengadaan_BMN FOREIGN KEY (BMNKey) REFERENCES dbo.DimBMN(BMNKey);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_FactPengadaan_DimTanggal')
ALTER TABLE dbo.Fact_Pengadaan
ADD CONSTRAINT FK_FactPengadaan_DimTanggal FOREIGN KEY (DateKey) REFERENCES dbo.DimTanggal(DateKey);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_FactPengadaan_DimUnit')
ALTER TABLE dbo.Fact_Pengadaan
ADD CONSTRAINT FK_FactPengadaan_DimUnit FOREIGN KEY (UnitKey) REFERENCES dbo.DimUnitKerja(UnitKey);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_FactPengadaan_DimVendor')
ALTER TABLE dbo.Fact_Pengadaan
ADD CONSTRAINT FK_FactPengadaan_DimVendor FOREIGN KEY (VendorKey) REFERENCES dbo.DimVendor(VendorKey);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_FactPengadaan_DimKategori')
ALTER TABLE dbo.Fact_Pengadaan
ADD CONSTRAINT FK_FactPengadaan_DimKategori FOREIGN KEY (KategoriKey) REFERENCES dbo.DimKategoriPengadaan(KategoriKey);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_FactPengadaan_Status')
ALTER TABLE dbo.Fact_Pengadaan
ADD CONSTRAINT FK_FactPengadaan_Status FOREIGN KEY (StatusKey) REFERENCES dbo.DimStatus(StatusKey);
GO

-- Fact_PeminjamanFasilitas
IF OBJECT_ID('dbo.Fact_PeminjamanFasilitas') IS NULL
CREATE TABLE dbo.Fact_PeminjamanFasilitas (
    PeminjamanKey BIGINT IDENTITY(1,1) NOT NULL,
    DateKey INT NOT NULL,
    FasilitasKey INT NOT NULL,
    UnitKey INT NOT NULL,
    KeperluanKey INT NULL,
    TanggalPinjam DATE NULL,
    TanggalKembali DATE NULL,
    DurasiHari INT NULL,
    StatusKey INT NULL,
    SourceSystem VARCHAR(100) NULL,
    LoadDate DATETIME DEFAULT GETDATE()
);
GO

-- FK Peminjaman -> dims
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Peminjaman_DimTanggal')
ALTER TABLE dbo.Fact_PeminjamanFasilitas
ADD CONSTRAINT FK_Peminjaman_DimTanggal FOREIGN KEY (DateKey) REFERENCES dbo.DimTanggal(DateKey);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Peminjaman_DimFasilitas')
ALTER TABLE dbo.Fact_PeminjamanFasilitas
ADD CONSTRAINT FK_Peminjaman_DimFasilitas FOREIGN KEY (FasilitasKey) REFERENCES dbo.DimFasilitas(FasilitasKey);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Peminjaman_DimUnit')
ALTER TABLE dbo.Fact_PeminjamanFasilitas
ADD CONSTRAINT FK_Peminjaman_DimUnit FOREIGN KEY (UnitKey) REFERENCES dbo.DimUnitKerja(UnitKey);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Peminjaman_DimKeperluan')
ALTER TABLE dbo.Fact_PeminjamanFasilitas
ADD CONSTRAINT FK_Peminjaman_DimKeperluan FOREIGN KEY (KeperluanKey) REFERENCES dbo.DimKeperluan(KeperluanKey);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Peminjaman_Status')
ALTER TABLE dbo.Fact_PeminjamanFasilitas
ADD CONSTRAINT FK_Peminjaman_Status FOREIGN KEY (StatusKey) REFERENCES dbo.DimStatus(StatusKey);
GO

-- Fact_SuratMasuk
IF OBJECT_ID('dbo.Fact_SuratMasuk') IS NULL
CREATE TABLE dbo.Fact_SuratMasuk (
    SuratMasukKey BIGINT IDENTITY(1,1) NOT NULL,
    DateKey INT NOT NULL,
    AsalKey INT NOT NULL,
    PerihalKey INT NOT NULL,
    UnitKey INT NOT NULL,
    StatusKey INT NOT NULL,
    JumlahSurat INT DEFAULT 1,
    WaktuProses INT NULL,
    NomorSurat VARCHAR(200) NULL,
    SourceSystem VARCHAR(100) NULL,
    LoadDate DATETIME DEFAULT GETDATE()
);
GO

-- FK SuratMasuk -> dims
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_SuratMasuk_DimTanggal')
ALTER TABLE dbo.Fact_SuratMasuk
ADD CONSTRAINT FK_SuratMasuk_DimTanggal FOREIGN KEY (DateKey) REFERENCES dbo.DimTanggal(DateKey);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_SuratMasuk_DimAsal')
ALTER TABLE dbo.Fact_SuratMasuk
ADD CONSTRAINT FK_SuratMasuk_DimAsal FOREIGN KEY (AsalKey) REFERENCES dbo.DimAsalSurat(AsalKey);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_SuratMasuk_DimPerihal')
ALTER TABLE dbo.Fact_SuratMasuk
ADD CONSTRAINT FK_SuratMasuk_DimPerihal FOREIGN KEY (PerihalKey) REFERENCES dbo.DimPerihalSurat(PerihalKey);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_SuratMasuk_DimUnit')
ALTER TABLE dbo.Fact_SuratMasuk
ADD CONSTRAINT FK_SuratMasuk_DimUnit FOREIGN KEY (UnitKey) REFERENCES dbo.DimUnitKerja(UnitKey);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_SuratMasuk_Status')
ALTER TABLE dbo.Fact_SuratMasuk
ADD CONSTRAINT FK_SuratMasuk_Status FOREIGN KEY (StatusKey) REFERENCES dbo.DimStatus(StatusKey);
GO

-- Fact_SuratKeluar
IF OBJECT_ID('dbo.Fact_SuratKeluar') IS NULL
CREATE TABLE dbo.Fact_SuratKeluar (
    SuratKeluarKey BIGINT IDENTITY(1,1) NOT NULL,
    DateKey INT NOT NULL,
    TujuanKey INT NOT NULL,
    PerihalKey INT NOT NULL,
    UnitKey INT NOT NULL,
    StatusKey INT NOT NULL,
    JumlahSurat INT DEFAULT 1,
    WaktuPenyelesaian INT NULL,
    NomorSurat VARCHAR(200) NULL,
    SourceSystem VARCHAR(100) NULL,
    LoadDate DATETIME DEFAULT GETDATE()
);
GO

-- FK SuratKeluar -> dims
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_SuratKeluar_DimTanggal')
ALTER TABLE dbo.Fact_SuratKeluar
ADD CONSTRAINT FK_SuratKeluar_DimTanggal FOREIGN KEY (DateKey) REFERENCES dbo.DimTanggal(DateKey);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_SuratKeluar_DimTujuan')
ALTER TABLE dbo.Fact_SuratKeluar
ADD CONSTRAINT FK_SuratKeluar_DimTujuan FOREIGN KEY (TujuanKey) REFERENCES dbo.DimTujuanSurat(TujuanKey);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_SuratKeluar_DimPerihal')
ALTER TABLE dbo.Fact_SuratKeluar
ADD CONSTRAINT FK_SuratKeluar_DimPerihal FOREIGN KEY (PerihalKey) REFERENCES dbo.DimPerihalSurat(PerihalKey);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_SuratKeluar_DimUnit')
ALTER TABLE dbo.Fact_SuratKeluar
ADD CONSTRAINT FK_SuratKeluar_DimUnit FOREIGN KEY (UnitKey) REFERENCES dbo.DimUnitKerja(UnitKey);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_SuratKeluar_Status')
ALTER TABLE dbo.Fact_SuratKeluar
ADD CONSTRAINT FK_SuratKeluar_Status FOREIGN KEY (StatusKey) REFERENCES dbo.DimStatus(StatusKey);
GO

-- Fact_LayananAdministrasi (optional)
IF OBJECT_ID('dbo.Fact_LayananAdministrasi') IS NULL
CREATE TABLE dbo.Fact_LayananAdministrasi (
    LayananKey BIGINT IDENTITY(1,1) NOT NULL,
    DateKey INT NOT NULL,
    UnitKey INT NOT NULL,
    JenisLayananKey INT NOT NULL,
    StatusKey INT NOT NULL,
    RequesterName VARCHAR(200) NULL,
    DurasiProses INT NULL,
    Remarks VARCHAR(500) NULL,
    LoadDate DATETIME DEFAULT GETDATE()
);
GO

-- FK Layanan -> dims
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Layanan_DimTanggal')
ALTER TABLE dbo.Fact_LayananAdministrasi
ADD CONSTRAINT FK_Layanan_DimTanggal FOREIGN KEY (DateKey) REFERENCES dbo.DimTanggal(DateKey);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Layanan_DimUnit')
ALTER TABLE dbo.Fact_LayananAdministrasi
ADD CONSTRAINT FK_Layanan_DimUnit FOREIGN KEY (UnitKey) REFERENCES dbo.DimUnitKerja(UnitKey);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Layanan_Jenis')
ALTER TABLE dbo.Fact_LayananAdministrasi
ADD CONSTRAINT FK_Layanan_Jenis FOREIGN KEY (JenisLayananKey) REFERENCES dbo.DimJenisLayanan(JenisLayananKey);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Layanan_Status')
ALTER TABLE dbo.Fact_LayananAdministrasi
ADD CONSTRAINT FK_Layanan_Status FOREIGN KEY (StatusKey) REFERENCES dbo.DimStatus(StatusKey);
GO

-- ===========================
-- Done
-- ===========================

