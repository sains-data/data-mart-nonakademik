
-- ================================================
-- 05_Create_Partitions.sql
-- Partitioning Strategy for DW Non-Akademik
-- ================================================

USE DM_NonAkademik_DW;
GO

----------------------------------------------------
-- 1. PARTITION FUNCTION (Range by Year)
-- We use DateKey in format YYYYMMDD
----------------------------------------------------

CREATE PARTITION FUNCTION PF_YearlyRange (INT)
AS RANGE RIGHT FOR VALUES
(
    20200101,
    20210101,
    20220101,
    20230101,
    20240101,
    20250101,
    20260101
);
GO

----------------------------------------------------
-- 2. PARTITION SCHEME (All on PRIMARY for simplicity)
----------------------------------------------------
CREATE PARTITION SCHEME PS_YearlyRange
AS PARTITION PF_YearlyRange
ALL TO ([PRIMARY]);
GO

----------------------------------------------------
-- 3. Move FACT TABLES to Partition Scheme
-- (Re-create clustered index ON PS_YearlyRange(DateKey))
----------------------------------------------------

-- Fact Realsiasi Anggaran
CREATE CLUSTERED INDEX CIX_FactRealisasi_Partitioned
ON dbo.Fact_RealisasiAnggaran(DateKey, RealisasiKey)
ON PS_YearlyRange(DateKey);
GO

-- Fact Pengadaan
CREATE CLUSTERED INDEX CIX_FactPengadaan_Partitioned
ON dbo.Fact_Pengadaan(DateKey, PengadaanKey)
ON PS_YearlyRange(DateKey);
GO

-- Fact Peminjaman Fasilitas
CREATE CLUSTERED INDEX CIX_FactPeminjaman_Partitioned
ON dbo.Fact_PeminjamanFasilitas(DateKey, PeminjamanKey)
ON PS_YearlyRange(DateKey);
GO

-- Fact Surat Masuk
CREATE CLUSTERED INDEX CIX_FactSuratMasuk_Partitioned
ON dbo.Fact_SuratMasuk(DateKey, SuratMasukKey)
ON PS_YearlyRange(DateKey);
GO

-- Fact Surat Keluar
CREATE CLUSTERED INDEX CIX_FactSuratKeluar_Partitioned
ON dbo.Fact_SuratKeluar(DateKey, SuratKeluarKey)
ON PS_YearlyRange(DateKey);
GO

