
USE DM_NonAkademik_DW;
GO

/*************************************************************
  ETL Procedures (based on your staging and dim/fact schema)
*************************************************************/

-- ========== DIM LOAD PROCEDURES ==========

/* DimLokasi (SCD0: insert if not exists) */
CREATE OR ALTER PROCEDURE dbo.usp_Load_DimLokasi
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.DimLokasi (LokasiCode, LokasiName, Alamat, Kota, Provinsi, CreatedDate)
    SELECT NULL, s.Lokasi, NULL, s.Kota, s.Provinsi, GETDATE()
    FROM stg.Lokasi s
    WHERE NOT EXISTS (
        SELECT 1 FROM dbo.DimLokasi d WHERE d.LokasiName = s.Lokasi
    );
END;
GO

/* DimVendor (SCD0) */
CREATE OR ALTER PROCEDURE dbo.usp_Load_DimVendor
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.DimVendor (VendorCode, VendorName, Category, City, ContactPerson, ContactPhone, Email, CreatedDate)
    SELECT NULL, s.NamaVendor, NULL, s.Kota, s.ContactPerson, s.ContactPhone, s.Email, GETDATE()
    FROM stg.Vendor s
    WHERE NOT EXISTS (
        SELECT 1 FROM dbo.DimVendor d WHERE d.VendorName = s.NamaVendor
    );
END;
GO

/* DimAkunBelanja (SCD0) */
CREATE OR ALTER PROCEDURE dbo.usp_Load_DimAkunBelanja
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.DimAkunBelanja (KodeAkun, NamaAkun, KelompokAkun, KategoriBelanja, CreatedDate)
    SELECT DISTINCT s.KodeAkun, s.NamaAkun, NULL, NULL, GETDATE()
    FROM stg.RealisasiAnggaran s
    WHERE NOT EXISTS (
        SELECT 1 FROM dbo.DimAkunBelanja d WHERE d.KodeAkun = s.KodeAkun
    );
END;
GO

/* DimKategoriPengadaan (SCD0) */
CREATE OR ALTER PROCEDURE dbo.usp_Load_DimKategoriPengadaan
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.DimKategoriPengadaan (KategoriName, SubKategori, CreatedDate)
    SELECT DISTINCT s.KategoriPengadaan, NULL, GETDATE()
    FROM stg.Pengadaan s
    WHERE NOT EXISTS (
        SELECT 1 FROM dbo.DimKategoriPengadaan d WHERE d.KategoriName = s.KategoriPengadaan
    );
END;
GO

/* DimKeperluan (SCD0) */
CREATE OR ALTER PROCEDURE dbo.usp_Load_DimKeperluan
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.DimKeperluan (KeperluanDesc, CreatedDate)
    SELECT DISTINCT s.Keperluan, GETDATE()
    FROM stg.PeminjamanFasilitas s
    WHERE s.Keperluan IS NOT NULL
      AND NOT EXISTS (SELECT 1 FROM dbo.DimKeperluan d WHERE d.KeperluanDesc = s.Keperluan);
END;
GO

/* DimPerihalSurat (SCD0) */
CREATE OR ALTER PROCEDURE dbo.usp_Load_DimPerihalSurat
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.DimPerihalSurat (PerihalDesc, CreatedDate)
    SELECT DISTINCT t.Perihal, GETDATE()
    FROM (
        SELECT Perihal FROM stg.SuratMasuk
        UNION
        SELECT Perihal FROM stg.SuratKeluar
    ) t
    WHERE NOT EXISTS (SELECT 1 FROM dbo.DimPerihalSurat d WHERE d.PerihalDesc = t.Perihal);
END;
GO

/* DimStatus (ProcessType, StatusName) */
CREATE OR ALTER PROCEDURE dbo.usp_Load_DimStatus
AS
BEGIN
    SET NOCOUNT ON;

    -- SURAT statuses (from both masuk & keluar)
    INSERT INTO dbo.DimStatus (ProcessType, StatusName, Description, CreatedDate)
    SELECT 'SURAT', StatusSurat, NULL, GETDATE()
    FROM (
        SELECT StatusSurat FROM stg.SuratMasuk
        UNION
        SELECT StatusSurat FROM stg.SuratKeluar
    ) x
    WHERE x.StatusSurat IS NOT NULL
      AND NOT EXISTS (
        SELECT 1 FROM dbo.DimStatus d WHERE d.ProcessType = 'SURAT' AND d.StatusName = x.StatusSurat
      );

    -- PENGADAAN statuses
    INSERT INTO dbo.DimStatus (ProcessType, StatusName, Description, CreatedDate)
    SELECT 'PENGADAAN', StatusPengadaan, NULL, GETDATE()
    FROM stg.Pengadaan s
    WHERE s.StatusPengadaan IS NOT NULL
      AND NOT EXISTS (
        SELECT 1 FROM dbo.DimStatus d WHERE d.ProcessType = 'PENGADAAN' AND d.StatusName = s.StatusPengadaan
      );

    -- PEMINJAMAN statuses
    INSERT INTO dbo.DimStatus (ProcessType, StatusName, Description, CreatedDate)
    SELECT 'PEMINJAMAN', StatusPeminjaman, NULL, GETDATE()
    FROM stg.PeminjamanFasilitas s
    WHERE s.StatusPeminjaman IS NOT NULL
      AND NOT EXISTS (
        SELECT 1 FROM dbo.DimStatus d WHERE d.ProcessType = 'PEMINJAMAN' AND d.StatusName = s.StatusPeminjaman
      );
END;
GO

/* DimAsalSurat (SCD0) */
CREATE OR ALTER PROCEDURE dbo.usp_Load_DimAsalSurat
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.DimAsalSurat (AsalName, AsalType, Kota, CreatedDate)
    SELECT DISTINCT s.AsalSurat, NULL, s.KotaAsal, GETDATE()
    FROM stg.SuratMasuk s
    WHERE s.AsalSurat IS NOT NULL
      AND NOT EXISTS (SELECT 1 FROM dbo.DimAsalSurat d WHERE d.AsalName = s.AsalSurat);
END;
GO

/* DimTujuanSurat (SCD0) */
CREATE OR ALTER PROCEDURE dbo.usp_Load_DimTujuanSurat
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.DimTujuanSurat (TujuanName, TujuanType, Kota, CreatedDate)
    SELECT DISTINCT s.TujuanSurat, NULL, s.KotaTujuan, GETDATE()
    FROM stg.SuratKeluar s
    WHERE s.TujuanSurat IS NOT NULL
      AND NOT EXISTS (SELECT 1 FROM dbo.DimTujuanSurat d WHERE d.TujuanName = s.TujuanSurat);
END;
GO

/* DimBMN (SCD0: insert if not exists; no IsCurrent in your dim) */
CREATE OR ALTER PROCEDURE dbo.usp_Load_DimBMN
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.DimBMN (
        KodeBarang, NamaBarang, KategoriBarang, JenisBarang,
        TanggalPerolehan, SumberPerolehan, HargaPerolehan,
        KondisiAwal, KondisiSaatIni, CreatedDate, ModifiedDate
    )
    SELECT s.KodeBarang, s.NamaBarang, s.KategoriBarang, s.JenisBarang,
           s.TanggalPerolehan, s.SumberPerolehan, s.HargaPerolehan,
           s.KondisiSaatIni, s.KondisiSaatIni, GETDATE(), GETDATE()
    FROM stg.BMN s
    WHERE NOT EXISTS (SELECT 1 FROM dbo.DimBMN d WHERE d.KodeBarang = s.KodeBarang);
END;
GO

/* DimFasilitas (SCD0 insert-if-not-exists) */
CREATE OR ALTER PROCEDURE dbo.usp_Load_DimFasilitas
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.DimFasilitas (FasilitasCode, NamaFasilitas, JenisFasilitas, LokasiCode, Kapasitas, UnitPengelolaCode, CreatedDate)
    SELECT NULL, s.NamaFasilitas, s.JenisFasilitas, s.Lokasi, NULL, NULL, GETDATE()
    FROM stg.PeminjamanFasilitas s
    WHERE NOT EXISTS (SELECT 1 FROM dbo.DimFasilitas d WHERE d.NamaFasilitas = s.NamaFasilitas);
END;
GO

/* DimUnitKerja (SCD Type 2) - because your dim has IsCurrent/EffectiveDate/ExpiryDate */
CREATE OR ALTER PROCEDURE dbo.usp_Load_DimUnitKerja
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRAN;

    -- 1) expire existing records where attributes changed (match by UnitName)
    UPDATE d
    SET d.ExpiryDate = GETDATE(),
        d.IsCurrent = 0,
        d.ModifiedDate = GETDATE()
    FROM dbo.DimUnitKerja d
    INNER JOIN stg.UnitKerja s ON d.UnitName = s.UnitName
    WHERE d.IsCurrent = 1
      AND (
            ISNULL(d.UnitType,'') <> ISNULL(s.UnitType,'')
         OR ISNULL(d.ParentUnitCode,'') <> ISNULL(s.ParentUnit,'')
      );

    -- 2) insert new records for new units or changed units
    INSERT INTO dbo.DimUnitKerja (UnitCode, UnitName, UnitType, ParentUnitCode, EffectiveDate, ExpiryDate, IsCurrent, CreatedDate, ModifiedDate)
    SELECT NULL, s.UnitName, s.UnitType, s.ParentUnit, GETDATE(), NULL, 1, GETDATE(), GETDATE()
    FROM stg.UnitKerja s
    WHERE NOT EXISTS (
        SELECT 1 FROM dbo.DimUnitKerja d WHERE d.UnitName = s.UnitName AND d.IsCurrent = 1
    );

    COMMIT TRAN;
END;
GO

/* DimJenisLayanan (SCD0) - optional */
CREATE OR ALTER PROCEDURE dbo.usp_Load_DimJenisLayanan
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.DimJenisLayanan (JenisLayananName, Description, CreatedDate)
    SELECT DISTINCT 'Umum', NULL, GETDATE() -- placeholder if you don't have staging; keep to avoid failures
    WHERE NOT EXISTS (SELECT 1 FROM dbo.DimJenisLayanan);
END;
GO

-- ========== FACT LOAD PROCEDURES ==========

/* Fact_SuratMasuk */
CREATE OR ALTER PROCEDURE dbo.usp_Load_FactSuratMasuk
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.Fact_SuratMasuk (
        DateKey, AsalKey, PerihalKey, UnitKey, StatusKey,
        JumlahSurat, WaktuProses, NomorSurat, SourceSystem, LoadDate
    )
    SELECT
        CAST(CONVERT(CHAR(8), s.TanggalDiterima, 112) AS INT) AS DateKey,
        da.AsalKey,
        dp.PerihalKey,
        du.UnitKey,
        ds.StatusKey,
        ISNULL(s.JumlahLampiran,0),
        NULL,
        s.NomorSurat,
        'SURAT_MASUK',
        GETDATE()
    FROM stg.SuratMasuk s
    LEFT JOIN dbo.DimAsalSurat da ON da.AsalName = s.AsalSurat
    LEFT JOIN dbo.DimPerihalSurat dp ON dp.PerihalDesc = s.Perihal
    LEFT JOIN dbo.DimUnitKerja du ON du.UnitName = s.UnitTujuan AND du.IsCurrent = 1
    LEFT JOIN dbo.DimStatus ds ON ds.StatusName = s.StatusSurat AND ds.ProcessType = 'SURAT'
    WHERE NOT EXISTS (SELECT 1 FROM dbo.Fact_SuratMasuk f WHERE f.NomorSurat = s.NomorSurat);
END;
GO

/* Fact_SuratKeluar */
CREATE OR ALTER PROCEDURE dbo.usp_Load_FactSuratKeluar
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.Fact_SuratKeluar (
        DateKey, TujuanKey, PerihalKey, UnitKey, StatusKey,
        JumlahSurat, WaktuPenyelesaian, NomorSurat, SourceSystem, LoadDate
    )
    SELECT
        CAST(CONVERT(CHAR(8), s.TanggalKeluar, 112) AS INT) AS DateKey,
        dt.TujuanKey,
        dp.PerihalKey,
        du.UnitKey,
        ds.StatusKey,
        1,
        NULL,
        s.NomorSurat,
        'SURAT_KELUAR',
        GETDATE()
    FROM stg.SuratKeluar s
    LEFT JOIN dbo.DimTujuanSurat dt ON dt.TujuanName = s.TujuanSurat
    LEFT JOIN dbo.DimPerihalSurat dp ON dp.PerihalDesc = s.Perihal
    LEFT JOIN dbo.DimUnitKerja du ON du.UnitName = s.UnitPengirim AND du.IsCurrent = 1
    LEFT JOIN dbo.DimStatus ds ON ds.StatusName = s.StatusSurat AND ds.ProcessType = 'SURAT'
    WHERE NOT EXISTS (SELECT 1 FROM dbo.Fact_SuratKeluar f WHERE f.NomorSurat = s.NomorSurat);
END;
GO

/* Fact_Pengadaan */
CREATE OR ALTER PROCEDURE dbo.usp_Load_FactPengadaan
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.Fact_Pengadaan (
        DateKey, UnitKey, VendorKey, KategoriKey, NilaiPengadaan,
        StatusKey, NomorPengadaan, VendorName, BMNKey, SourceSystem, LoadDate
    )
    SELECT
        CAST(CONVERT(CHAR(8), s.TanggalPengadaan, 112) AS INT),
        du.UnitKey,
        dv.VendorKey,
        dk.KategoriKey,
        s.NilaiPengadaan,
        ds.StatusKey,
        s.NomorPengadaan,
        s.NamaVendor,
        NULL,
        'PENGADAAN',
        GETDATE()
    FROM stg.Pengadaan s
    LEFT JOIN dbo.DimUnitKerja du ON du.UnitName = s.UnitPemohon AND du.IsCurrent = 1
    LEFT JOIN dbo.DimVendor dv ON dv.VendorName = s.NamaVendor
    LEFT JOIN dbo.DimKategoriPengadaan dk ON dk.KategoriName = s.KategoriPengadaan
    LEFT JOIN dbo.DimStatus ds ON ds.StatusName = s.StatusPengadaan AND ds.ProcessType = 'PENGADAAN'
    WHERE NOT EXISTS (SELECT 1 FROM dbo.Fact_Pengadaan f WHERE f.NomorPengadaan = s.NomorPengadaan);
END;
GO

/* Fact_RealisasiAnggaran */
CREATE OR ALTER PROCEDURE dbo.usp_Load_FactRealisasiAnggaran
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.Fact_RealisasiAnggaran (
        DateKey, UnitKey, AkunKey, NilaiRealisasi, SelisihAnggaranRealisasi, Keterangan, SourceSystem, LoadDate
    )
    SELECT
        CAST(CONVERT(CHAR(8), s.TanggalRealisasi, 112) AS INT),
        du.UnitKey,
        da.AkunKey,
        s.NilaiRealisasi,
        NULL,
        s.Keterangan,
        'REALISASI',
        GETDATE()
    FROM stg.RealisasiAnggaran s
    LEFT JOIN dbo.DimUnitKerja du ON du.UnitName = s.UnitKerja AND du.IsCurrent = 1
    LEFT JOIN dbo.DimAkunBelanja da ON da.KodeAkun = s.KodeAkun
    WHERE NOT EXISTS (
        SELECT 1 FROM dbo.Fact_RealisasiAnggaran f
        WHERE f.DateKey = CAST(CONVERT(CHAR(8), s.TanggalRealisasi, 112) AS INT)
          AND f.UnitKey = du.UnitKey
          AND f.AkunKey = da.AkunKey
          AND f.NilaiRealisasi = s.NilaiRealisasi
    );
END;
GO

/* Fact_PeminjamanFasilitas */
CREATE OR ALTER PROCEDURE dbo.usp_Load_FactPeminjamanFasilitas
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.Fact_PeminjamanFasilitas (
        DateKey, FasilitasKey, UnitKey, KeperluanKey, TanggalPinjam, TanggalKembali, DurasiHari, StatusKey, SourceSystem, LoadDate
    )
    SELECT
        CAST(CONVERT(CHAR(8), s.TanggalPinjam, 112) AS INT),
        df.FasilitasKey,
        du.UnitKey,
        dk.KeperluanKey,
        s.TanggalPinjam,
        s.TanggalKembali,
        CASE WHEN s.TanggalKembali IS NOT NULL THEN DATEDIFF(DAY, s.TanggalPinjam, s.TanggalKembali) + 1 ELSE NULL END,
        ds.StatusKey,
        'PEMINJAMAN',
        GETDATE()
    FROM stg.PeminjamanFasilitas s
    LEFT JOIN dbo.DimFasilitas df ON df.NamaFasilitas = s.NamaFasilitas
    LEFT JOIN dbo.DimUnitKerja du ON du.UnitName = s.UnitPeminjam AND du.IsCurrent = 1
    LEFT JOIN dbo.DimKeperluan dk ON dk.KeperluanDesc = s.Keperluan
    LEFT JOIN dbo.DimStatus ds ON ds.StatusName = s.StatusPeminjaman AND ds.ProcessType = 'PEMINJAMAN'
    WHERE NOT EXISTS (
        SELECT 1 FROM dbo.Fact_PeminjamanFasilitas f
        WHERE f.TanggalPinjam = s.TanggalPinjam
          AND f.FasilitasKey = df.FasilitasKey
          AND f.UnitKey = du.UnitKey
    );
END;
GO

-- ========== MASTER ETL ==========

CREATE OR ALTER PROCEDURE dbo.usp_Master_ETL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;

        -- Load dims (order chosen so lookup dims exist for facts)
        EXEC dbo.usp_Load_DimLokasi;
        EXEC dbo.usp_Load_DimVendor;
        EXEC dbo.usp_Load_DimAkunBelanja;
        EXEC dbo.usp_Load_DimKategoriPengadaan;
        EXEC dbo.usp_Load_DimKeperluan;
        EXEC dbo.usp_Load_DimPerihalSurat;
        EXEC dbo.usp_Load_DimStatus;
        EXEC dbo.usp_Load_DimAsalSurat;
        EXEC dbo.usp_Load_DimTujuanSurat;
        EXEC dbo.usp_Load_DimBMN;
        EXEC dbo.usp_Load_DimFasilitas;

        -- SCD2 for UnitKerja (run after you ensure stg.UnitKerja has required rows)
        EXEC dbo.usp_Load_DimUnitKerja;

        -- Load facts
        EXEC dbo.usp_Load_FactSuratMasuk;
        EXEC dbo.usp_Load_FactSuratKeluar;
        EXEC dbo.usp_Load_FactPengadaan;
        EXEC dbo.usp_Load_FactRealisasiAnggaran;
        EXEC dbo.usp_Load_FactPeminjamanFasilitas;

        -- Optional: update stats
        EXEC sp_updatestats;

        COMMIT TRAN;
        PRINT 'Master ETL completed.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        DECLARE @err NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@err,16,1);
    END CATCH
END;
GO

