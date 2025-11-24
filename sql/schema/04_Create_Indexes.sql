----------------------------------------------------
-- 2. NON-CLUSTERED INDEXES FOR FOREIGN KEYS
-- (Optimize joins from fact → dimensions)
----------------------------------------------------

-- Fact_RealisasiAnggaran FK indexes
CREATE NONCLUSTERED INDEX IX_FactRealisasi_Unit
ON dbo.Fact_RealisasiAnggaran(UnitKey);
GO

CREATE NONCLUSTERED INDEX IX_FactRealisasi_Akun
ON dbo.Fact_RealisasiAnggaran(AkunKey);
GO


-- Fact_Pengadaan FK indexes
CREATE NONCLUSTERED INDEX IX_FactPengadaan_Unit
ON dbo.Fact_Pengadaan(UnitKey);
GO

CREATE NONCLUSTERED INDEX IX_FactPengadaan_Vendor
ON dbo.Fact_Pengadaan(VendorKey);
GO

CREATE NONCLUSTERED INDEX IX_FactPengadaan_Kategori
ON dbo.Fact_Pengadaan(KategoriKey);
GO

CREATE NONCLUSTERED INDEX IX_FactPengadaan_Status
ON dbo.Fact_Pengadaan(StatusKey);
GO


-- Fact_PeminjamanFasilitas FK indexes
CREATE NONCLUSTERED INDEX IX_FactPeminjaman_Fasilitas
ON dbo.Fact_PeminjamanFasilitas(FasilitasKey);
GO

CREATE NONCLUSTERED INDEX IX_FactPeminjaman_Unit
ON dbo.Fact_PeminjamanFasilitas(UnitKey);
GO

CREATE NONCLUSTERED INDEX IX_FactPeminjaman_Keperluan
ON dbo.Fact_PeminjamanFasilitas(KeperluanKey);
GO


-- Fact_SuratMasuk FK indexes
CREATE NONCLUSTERED INDEX IX_FactSuratMasuk_Asal
ON dbo.Fact_SuratMasuk(AsalKey);
GO

CREATE NONCLUSTERED INDEX IX_FactSuratMasuk_Perihal
ON dbo.Fact_SuratMasuk(PerihalKey);
GO

CREATE NONCLUSTERED INDEX IX_FactSuratMasuk_Unit
ON dbo.Fact_SuratMasuk(UnitKey);
GO


-- Fact_SuratKeluar FK indexes
CREATE NONCLUSTERED INDEX IX_FactSuratKeluar_Tujuan
ON dbo.Fact_SuratKeluar(TujuanKey);
GO

CREATE NONCLUSTERED INDEX IX_FactSuratKeluar_Perihal
ON dbo.Fact_SuratKeluar(PerihalKey);
GO

CREATE NONCLUSTERED INDEX IX_FactSuratKeluar_Unit
ON dbo.Fact_SuratKeluar(UnitKey);
GO

----------------------------------------------------
-- 3. COVERING INDEXES FOR COMMON ANALYTICAL QUERIES
-- (Speed up dashboard queries)
----------------------------------------------------

-- Pengadaan: filter by Unit and Date
CREATE NONCLUSTERED INDEX IX_FactPengadaan_Covering
ON dbo.Fact_Pengadaan(UnitKey, DateKey)
INCLUDE (VendorKey, NilaiPengadaan, KategoriKey, StatusKey);
GO

-- Peminjaman Fasilitas: filter by Fasilitas, Date
CREATE NONCLUSTERED INDEX IX_FactPeminjaman_Covering
ON dbo.Fact_PeminjamanFasilitas(FasilitasKey, DateKey)
INCLUDE (UnitKey, DurasiHari, TanggalPinjam, TanggalKembali);
GO

-- Surat Masuk: filter by Date and Unit
CREATE NONCLUSTERED INDEX IX_FactSuratMasuk_Covering
ON dbo.Fact_SuratMasuk(DateKey, UnitKey)
INCLUDE (AsalKey, PerihalKey, JumlahSurat, StatusKey);
GO

-- Surat Keluar: filter by Date and Unit
CREATE NONCLUSTERED INDEX IX_FactSuratKeluar_Covering
ON dbo.Fact_SuratKeluar(DateKey, UnitKey)
INCLUDE (TujuanKey, PerihalKey, JumlahSurat, StatusKey);
GO


----------------------------------------------------
-- 4. COLUMNSTORE INDEXES (optional but recommended)
-- (For large fact tables)
----------------------------------------------------

CREATE NONCLUSTERED COLUMNSTORE INDEX CSX_FactRealisasi
ON dbo.Fact_RealisasiAnggaran (DateKey, UnitKey, AkunKey, NilaiRealisasi);
GO

CREATE NONCLUSTERED COLUMNSTORE INDEX CSX_FactPengadaan
ON dbo.Fact_Pengadaan (DateKey, UnitKey, VendorKey, KategoriKey, NilaiPengadaan);
GO

CREATE NONCLUSTERED COLUMNSTORE INDEX CSX_FactPeminjaman
ON dbo.Fact_PeminjamanFasilitas (DateKey, FasilitasKey, UnitKey, DurasiHari, KeperluanKey);
GO

CREATE NONCLUSTERED COLUMNSTORE INDEX CSX_FactSuratMasuk
ON dbo.Fact_SuratMasuk (DateKey, UnitKey, AsalKey, PerihalKey);
GO

CREATE NONCLUSTERED COLUMNSTORE INDEX CSX_FactSuratKeluar
ON dbo.Fact_SuratKeluar (DateKey, UnitKey, TujuanKey, PerihalKey);
GO

