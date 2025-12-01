
USE DM_NonAkademik_DW;
GO

--------------------------------------
-- 1. Create Database Roles
--------------------------------------
CREATE ROLE db_executive;
CREATE ROLE db_analyst;
CREATE ROLE db_viewer;
CREATE ROLE db_etl_operator;
GO

--------------------------------------
-- 2. Grant Permissions for Executive
-- (read-only on summary views & dim)
--------------------------------------
GRANT SELECT ON SCHEMA::dbo TO db_executive;

-- Grant SELECT on views summary
GRANT SELECT ON dbo.vw_SuratMasuk_Summary TO db_executive;
GRANT SELECT ON dbo.vw_SuratKeluar_Summary TO db_executive;
GRANT SELECT ON dbo.vw_PeminjamanFasilitas_Summary TO db_executive;
GRANT SELECT ON dbo.vw_Pengadaan_Summary TO db_executive;
GRANT SELECT ON dbo.vw_RealisasiAnggaran_Summary TO db_executive;
GRANT SELECT ON dbo.vw_LayananAdministrasi_Summary TO db_executive;

-- Grant SELECT on dim tables
GRANT SELECT ON dbo.DimAkunBelanja TO db_executive;
GRANT SELECT ON dbo.DimAsalSurat TO db_executive;
GRANT SELECT ON dbo.DimBMN TO db_executive;
GRANT SELECT ON dbo.DimFasilitas TO db_executive;
GRANT SELECT ON dbo.DimJenisLayanan TO db_executive;
GRANT SELECT ON dbo.DimKategoriPengadaan TO db_executive;
GRANT SELECT ON dbo.DimKeperluan TO db_executive;
GRANT SELECT ON dbo.DimLokasi TO db_executive;
GRANT SELECT ON dbo.DimPerihalSurat TO db_executive;
GRANT SELECT ON dbo.DimStatus TO db_executive;
GRANT SELECT ON dbo.DimTanggal TO db_executive;
GRANT SELECT ON dbo.DimTujuanSurat TO db_executive;
GRANT SELECT ON dbo.DimUnitKerja TO db_executive;
GRANT SELECT ON dbo.DimVendor TO db_executive;
GO

--------------------------------------
-- 3. Grant Permissions for Analyst
-- (full access to staging for ETL & data prep)
--------------------------------------
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::stg TO db_analyst;
GRANT SELECT ON SCHEMA::dbo TO db_analyst;
GO

--------------------------------------
-- 4. Grant Permissions for Viewer
-- (read-only)
--------------------------------------
GRANT SELECT ON dbo.vw_SuratMasuk_Summary TO db_viewer;
GRANT SELECT ON dbo.vw_SuratKeluar_Summary TO db_viewer;
GRANT SELECT ON dbo.vw_PeminjamanFasilitas_Summary TO db_viewer;
GRANT SELECT ON dbo.vw_Pengadaan_Summary TO db_viewer;
GRANT SELECT ON dbo.vw_RealisasiAnggaran_Summary TO db_viewer;
GRANT SELECT ON dbo.vw_LayananAdministrasi_Summary TO db_viewer;

GRANT SELECT ON dbo.DimUnitKerja TO db_viewer;
GRANT SELECT ON dbo.DimTanggal TO db_viewer;
GO

--------------------------------------
-- 5. Grant Permissions for ETL Operator
-- (full access on staging & dbo for ETL jobs)
--------------------------------------
GRANT EXECUTE ON SCHEMA::dbo TO db_etl_operator;
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::stg TO db_etl_operator;
GRANT INSERT, UPDATE ON SCHEMA::dbo TO db_etl_operator;
GO



--------------------------------------------------
-- 2. Create Users and Assign Roles
--------------------------------------------------

-- 1. Create SQL Logins
CREATE LOGIN executive_user WITH PASSWORD = 'StrongP@ssw0rd!';
CREATE LOGIN analyst_user WITH PASSWORD = 'StrongP@ssw0rd!';
CREATE LOGIN viewer_user WITH PASSWORD = 'StrongP@ssw0rd!';
CREATE LOGIN etl_service WITH PASSWORD = 'StrongP@ssw0rd!';
GO

-- 2. Switch to the Non-Akademik DW database
USE DM_NonAkademik_DW;
GO

-- 3. Create Database Users from Logins
CREATE USER executive_user FOR LOGIN executive_user;
CREATE USER analyst_user FOR LOGIN analyst_user;
CREATE USER viewer_user FOR LOGIN viewer_user;
CREATE USER etl_service FOR LOGIN etl_service;
GO

-- 4. Assign Users to Roles
ALTER ROLE db_executive ADD MEMBER executive_user;
ALTER ROLE db_analyst ADD MEMBER analyst_user;
ALTER ROLE db_viewer ADD MEMBER viewer_user;
ALTER ROLE db_etl_operator ADD MEMBER etl_service;
GO



--------------------------------------------------
-- 3. Implement Data Masking
--------------------------------------------------

-- Masking email dan kontak di vendor
ALTER TABLE dbo.DimVendor
ALTER COLUMN ContactPerson ADD MASKED WITH (FUNCTION = 'default()');

ALTER TABLE dbo.DimVendor
ALTER COLUMN Email ADD MASKED WITH (FUNCTION = 'email()');

-- Masking requester name di layanan administrasi
ALTER TABLE dbo.Fact_LayananAdministrasi
ALTER COLUMN RequesterName ADD MASKED WITH (FUNCTION = 'partial(1,"XXXX",0)');

-- Grant UNMASK permission untuk role tertentu
GRANT UNMASK TO db_executive;
GRANT UNMASK TO db_analyst;
GO



--------------------------------------------------
-- 4. Implement Audit Trail
--------------------------------------------------

-- 1. Create Audit Table
CREATE TABLE dbo.AuditLog (
    AuditID BIGINT IDENTITY(1,1) PRIMARY KEY,
    EventTime DATETIME2 DEFAULT SYSDATETIME(),
    UserName NVARCHAR(128) DEFAULT SUSER_SNAME(),
    EventType NVARCHAR(50), -- SELECT, INSERT, UPDATE, DELETE
    SchemaName NVARCHAR(128),
    ObjectName NVARCHAR(128),
    SQLStatement NVARCHAR(MAX),
    RowsAffected INT,
    IPAddress VARCHAR(50),
    ApplicationName NVARCHAR(128) DEFAULT APP_NAME()
);
GO

-- 2. Create Audit Triggers for Fact Tables (Contoh: Fact_LayananAdministrasi)
CREATE TRIGGER trg_Audit_Fact_Layanan
ON dbo.Fact_LayananAdministrasi
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @EventType NVARCHAR(50);
    DECLARE @RowsAffected INT;

    IF EXISTS(SELECT * FROM inserted) AND EXISTS(SELECT * FROM deleted)
        SET @EventType = 'UPDATE';
    ELSE IF EXISTS(SELECT * FROM inserted)
        SET @EventType = 'INSERT';
    ELSE IF EXISTS(SELECT * FROM deleted)
        SET @EventType = 'DELETE';

    SET @RowsAffected = @@ROWCOUNT;

    INSERT INTO dbo.AuditLog (EventType, SchemaName, ObjectName, RowsAffected)
    VALUES (@EventType, 'dbo', 'Fact_LayananAdministrasi', @RowsAffected);
END;
GO

-- 3. Trigger untuk Fact_SuratMasuk
CREATE TRIGGER trg_Audit_Fact_SuratMasuk
ON dbo.Fact_SuratMasuk
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @EventType NVARCHAR(50);
    DECLARE @RowsAffected INT;

    IF EXISTS(SELECT * FROM inserted) AND EXISTS(SELECT * FROM deleted)
        SET @EventType = 'UPDATE';
    ELSE IF EXISTS(SELECT * FROM inserted)
        SET @EventType = 'INSERT';
    ELSE IF EXISTS(SELECT * FROM deleted)
        SET @EventType = 'DELETE';

    SET @RowsAffected = @@ROWCOUNT;

    INSERT INTO dbo.AuditLog (EventType, SchemaName, ObjectName, RowsAffected)
    VALUES (@EventType, 'dbo', 'Fact_SuratMasuk', @RowsAffected);
END;
GO

-- 4. Trigger untuk Fact_SuratKeluar
CREATE TRIGGER trg_Audit_Fact_SuratKeluar
ON dbo.Fact_SuratKeluar
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @EventType NVARCHAR(50);
    DECLARE @RowsAffected INT;

    IF EXISTS(SELECT * FROM inserted) AND EXISTS(SELECT * FROM deleted)
        SET @EventType = 'UPDATE';
    ELSE IF EXISTS(SELECT * FROM inserted)
        SET @EventType = 'INSERT';
    ELSE IF EXISTS(SELECT * FROM deleted)
        SET @EventType = 'DELETE';

    SET @RowsAffected = @@ROWCOUNT;

    INSERT INTO dbo.AuditLog (EventType, SchemaName, ObjectName, RowsAffected)
    VALUES (@EventType, 'dbo', 'Fact_SuratKeluar', @RowsAffected);
END;
GO

-- 5. Trigger untuk DimVendor
CREATE TRIGGER trg_Audit_DimVendor
ON dbo.DimVendor
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @EventType NVARCHAR(50);
    DECLARE @RowsAffected INT;

    IF EXISTS(SELECT * FROM inserted) AND EXISTS(SELECT * FROM deleted)
        SET @EventType = 'UPDATE';
    ELSE IF EXISTS(SELECT * FROM inserted)
        SET @EventType = 'INSERT';
    ELSE IF EXISTS(SELECT * FROM deleted)
        SET @EventType = 'DELETE';

    SET @RowsAffected = @@ROWCOUNT;

    INSERT INTO dbo.AuditLog (EventType, SchemaName, ObjectName, RowsAffected)
    VALUES (@EventType, 'dbo', 'DimVendor', @RowsAffected);
END;
GO



