
--------------------------------------------------
-- 5.5.4 Step 4: Backup and Recovery Strategy
--------------------------------------------------

-- 1. Full Database Backup
BACKUP DATABASE DM_NonAkademik_DW
TO DISK = N'D:\Backup\DM_NonAkademik_DW_Full.bak'
WITH
    COMPRESSION,      -- Mengurangi ukuran backup
    INIT,             -- Menimpa file jika sudah ada
    NAME = N'Full Database Backup',
    STATS = 10;       -- Menampilkan progress setiap 10%
GO

-- 2. Differential Backup (Hanya perubahan sejak full backup terakhir)
BACKUP DATABASE DM_NonAkademik_DW
TO DISK = N'D:\Backup\DM_NonAkademik_DW_Diff.bak'
WITH
    DIFFERENTIAL,
    COMPRESSION,
    INIT,
    NAME = N'Differential Database Backup',
    STATS = 10;
GO

-- 3. Transaction Log Backup (Untuk point-in-time recovery)
BACKUP LOG DM_NonAkademik_DW
TO DISK = N'D:\Backup\DM_NonAkademik_DW_Log.trn'
WITH
    COMPRESSION,
    INIT,
    NAME = N'Transaction Log Backup',
    STATS = 10;
GO

--------------------------------------------------
-- 4. Backup Schedule Recommendation
-- Full Backup: Weekly (Sunday 2 AM)
-- Differential Backup: Daily (2 AM)
-- Transaction Log Backup: Every 6 hours
--------------------------------------------------

-- 5. Optional: Backup to Azure Blob Storage
-- Membutuhkan Storage Account + SAS Token
CREATE CREDENTIAL [AzureStorageCredential]
WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
SECRET = '<SAS_TOKEN>';  -- Ganti dengan SAS Token kamu
GO

BACKUP DATABASE DM_NonAkademik_DW
TO URL = N'https://[storage_account].blob.core.windows.net/backups/DM_NonAkademik_DW.bak'
WITH 
    CREDENTIAL = 'AzureStorageCredential',
    COMPRESSION;
GO

