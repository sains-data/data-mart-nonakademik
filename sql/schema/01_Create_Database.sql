
-- ================================================
-- 01_Create_Database.sql
-- Create Data Warehouse database for Non-Akademik
-- ================================================
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'DM_NonAkademik_DW')
BEGIN
    CREATE DATABASE DM_NonAkademik_DW
    ON PRIMARY
    (
        NAME = N'DM_NonAkademik_DW_Data',
        FILENAME = N'D:\Data\DM_NonAkademik_DW_Data.mdf',
        SIZE = 1024MB,
        MAXSIZE = UNLIMITED,
        FILEGROWTH = 256MB
    )
    LOG ON
    (
        NAME = N'DM_NonAkademik_DW_Log',
        FILENAME = N'E:\Logs\DM_NonAkademik_DW_Log.ldf',
        SIZE = 256MB,
        MAXSIZE = 2048MB,
        FILEGROWTH = 64MB
    );
END
GO

USE DM_NonAkademik_DW;
GO

