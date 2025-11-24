
/* ============================================================
08_Data_Quality_Checks.sql
Data Quality Assurance – DW Non-Akademik ITERA
============================================================ */
---------------------------------------------------------------
-- 1. CHECK: COMPLETENESS (Cek kolom NULL di DIM table)
---------------------------------------------------------------
-- DimUnitKerja
SELECT
'DimUnitKerja' AS TableName,
COUNT(*) AS TotalRows,
SUM(CASE WHEN UnitName IS NULL THEN 1 ELSE 0 END) AS Null_UnitName,
SUM(CASE WHEN UnitType IS NULL THEN 1 ELSE 0 END) AS Null_UnitType
FROM dbo.DimUnitKerja;
-- DimFasilitas
SELECT
'DimFasilitas' AS TableName,
COUNT(*) AS TotalRows,
SUM(CASE WHEN NamaFasilitas IS NULL THEN 1 ELSE 0 END) AS Null_NamaFasilitas,
SUM(CASE WHEN JenisFasilitas IS NULL THEN 1 ELSE 0 END) AS Null_JenisFasilitas
FROM dbo.DimFasilitas;
-- DimBMN
SELECT
'DimBMN' AS TableName,
COUNT(*) AS TotalRows,
SUM(CASE WHEN NamaBarang IS NULL THEN 1 ELSE 0 END) AS Null_NamaBarang,
SUM(CASE WHEN KodeBarang IS NULL THEN 1 ELSE 0 END) AS Null_KodeBarang
FROM dbo.DimBMN;
---------------------------------------------------------------
-- 2. CHECK: CONSISTENCY (Referential Integrity)
---------------------------------------------------------------
-- Fact Surat Masuk orphan record
SELECT
'Fact_SuratMasuk' AS FactTable,
COUNT(*) AS Orphan_UnitKey
FROM dbo.Fact_SuratMasuk f
LEFT JOIN dbo.DimUnitKerja d ON f.UnitKey = d.UnitKey
WHERE d.UnitKey IS NULL;
-- Fact Pengadaan orphan vendor
SELECT
'Fact_Pengadaan' AS FactTable,
COUNT(*) AS Orphan_VendorKey
FROM dbo.Fact_Pengadaan f
LEFT JOIN dbo.DimVendor d ON f.VendorKey = d.VendorKey
WHERE d.VendorKey IS NULL;
-- Fact Peminjaman orphan fasilitas
SELECT
'Fact_PeminjamanFasilitas' AS FactTable,
COUNT(*) AS Orphan_FasilitasKey
FROM dbo.Fact_PeminjamanFasilitas f
LEFT JOIN dbo.DimFasilitas d ON f.FasilitasKey = d.FasilitasKey
WHERE d.FasilitasKey IS NULL;
---------------------------------------------------------------
-- 3. CHECK: ACCURACY (Valid Ranges / Impossible Values)
---------------------------------------------------------------
-- Nilai Pengadaan tidak boleh negatif
SELECT
COUNT(*) AS InvalidPengadaan_Value
FROM dbo.Fact_Pengadaan
WHERE NilaiPengadaan < 0;
-- Durasi Peminjaman tidak boleh negatif
SELECT
COUNT(*) AS Invalid_DurasiPeminjaman
FROM dbo.Fact_PeminjamanFasilitas
WHERE DurasiHari < 0;
---------------------------------------------------------------
-- 4. CHECK: DUPLICATES
---------------------------------------------------------------
-- Duplicate No Surat Masuk
SELECT
NomorSurat,
COUNT(*) AS DuplicateCount
FROM dbo.Fact_SuratMasuk
GROUP BY NomorSurat
HAVING COUNT(*) > 1;
-- Duplicate BMN berdasarkan KodeBarang
SELECT
KodeBarang,
COUNT(*) AS DuplicateCount
FROM dbo.DimBMN
GROUP BY KodeBarang
HAVING COUNT(*) > 1;
---------------------------------------------------------------
-- 5. CHECK: RECORD COUNT RECONCILIATION (Staging VS DW)
---------------------------------------------------------------
-- Surat Masuk
SELECT 'Staging' AS Source, COUNT(*) AS Total FROM stg.SuratMasuk
UNION ALL
SELECT 'Warehouse', COUNT(*) FROM dbo.Fact_SuratMasuk;
-- Surat Keluar
SELECT 'Staging' AS Source, COUNT(*) AS Total FROM stg.SuratKeluar
UNION ALL
SELECT 'Warehouse', COUNT(*) FROM dbo.Fact_SuratKeluar;
-- Pengadaan
SELECT 'Staging' AS Source, COUNT(*) AS Total FROM stg.Pengadaan
UNION ALL
SELECT 'Warehouse', COUNT(*) FROM dbo.Fact_Pengadaan;
-- BMN
SELECT 'Staging' AS Source, COUNT(*) AS Total FROM stg.BMN
UNION ALL
SELECT 'Warehouse', COUNT(*) FROM dbo.DimBMN;

