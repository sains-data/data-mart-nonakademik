;WITH gen AS (
    SELECT TOP (10000)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rn
    FROM sys.objects a CROSS JOIN sys.objects b
)
INSERT INTO Fact_RealisasiAnggaran (
    DateKey, UnitKey, AkunKey, NilaiRealisasi,
    SelisihAnggaranRealisasi, Keterangan, SourceSystem
)
SELECT
    (SELECT TOP 1 DateKey FROM DimTanggal ORDER BY NEWID()),
    (SELECT TOP 1 UnitKey FROM DimUnitKerja ORDER BY NEWID()),
    (SELECT TOP 1 AkunKey FROM DimAkunBelanja ORDER BY NEWID()),
    ABS(CHECKSUM(NEWID())) % 8000000 + 20000,
    NULL,
    CONCAT('Realisasi transaksi ', rn),
    'DUMMY'
FROM gen;
