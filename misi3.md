
# Mission 3 Documentation

## 1. System Architecture Document

### 1.1 High-Level Architecture Diagram
```
+------------------+        +------------------+        +--------------------------+
|   Dummy Data     | ---->  |     Staging      | ---->  |   Data Mart (DM)          |
|                  |        |  (Raw Extracts)   |        |  Dim & Fact Tables       |
+------------------+        +------------------+        +--------------------------+
                                                  
                                                    |
                                                    v
                                            +------------------+
                                            |   Dashboards     |
                                            |   (Power BI)     |
                                            +------------------+
```

### 1.2 Technology Stack
```
- Database: SQL Server
- ETL: Manual/Script-based (SSMS)
- Modelling: Star Schema
- Reporting: Power BI
- Security: SQL Server Roles, Data Masking, Audit Trail
```

### 1.3 Data Flow Diagram
```
Data Sources → Extract → Staging → Transform → DW (Dim/Fact) → Views → Power BI
```

### 1.4 Deployment Architecture
```
Local SQL Server Instance
│
├── Database: DM_NonAkademik_DW
├── Security: Roles, Users, Masking
├── ETL Scripts: Manual execution
└── Reporting Layer: Power BI Desktop
```

---

## 2. Data Dictionary

### 2.1 Dimension Tables

*(Struktur lengkap seluruh DIM diambil langsung dari docs/requirements/DW_Kelompok 3_Misi I.pdf & Misi II, sesuai dummy data 10.000 baris yang digenerate di SSMS)*

#### DimAkunBelanja
```
AkunBelanjaKey (PK)
KodeAkun
NamaAkun
KategoriAkun
```

#### DimAsalSurat
```
AsalSuratKey (PK)
NamaInstansi
JenisAsal
```

#### DimBMN
```
BMNKey (PK)
KodeBMN
NamaBMN
KategoriBMN
Kondisi
```

#### DimFasilitas
```
FasilitasKey (PK)
NamaFasilitas
JenisFasilitas
Kapasitas
StatusKey (FK)
```

#### DimJenisLayanan
```
JenisLayananKey (PK)
NamaLayanan
KategoriLayanan
```

#### DimKategoriPengadaan
```
KategoriPengadaanKey (PK)
NamaKategori
```

#### DimKeperluan
```
KeperluanKey (PK)
NamaKeperluan
```

#### DimLokasi
```
LokasiKey (PK)
NamaLokasi
KategoriLokasi
```

#### DimPerihalSurat
```
PerihalSuratKey (PK)
NamaPerihal
JenisSurat
```

#### DimStatus
```
StatusKey (PK)
NamaStatus
TipeStatus
```

#### DimTanggal
```
DateKey (PK)
FullDate
Day
Month
MonthName
Year
Quarter
```

#### DimTujuanSurat
```
TujuanSuratKey (PK)
NamaTujuan
JenisTujuan
```

#### DimUnitKerja
```
UnitKey (PK)
KodeUnit
NamaUnit
JenisUnit
```

#### DimVendor
```
VendorKey (PK)
NamaVendor
KategoriVendor
Email (masked)
ContactPerson (masked)
```

### 2.2 Fact Tables

*(Struktur lengkap seluruh FACT sesuai docs/requirements/DW_Kelompok 3_Misi I.pdf, Misi II, dan Misi III)*

#### Fact_RealisasiAnggaran
```
RealisasiKey (PK)
DateKey (FK)
UnitKey (FK)
AkunBelanjaKey (FK)
NilaiRealisasi
```

#### Fact_SuratMasuk
```
SuratMasukKey (PK)
DateKey (FK)
UnitKey (FK)
AsalSuratKey (FK)
PerihalSuratKey (FK)
JumlahSurat
WaktuProses
StatusKey (FK)
```

#### Fact_SuratKeluar
```
SuratKeluarKey (PK)
DateKey (FK)
UnitKey (FK)
TujuanSuratKey (FK)
PerihalSuratKey (FK)
JumlahSurat
StatusKey (FK)
```

#### Fact_PeminjamanFasilitas
```
PeminjamanKey (PK)
DateKey (FK)
UnitKey (FK)
FasilitasKey (FK)
DurasiHari
StatusKey (FK)
```

#### Fact_Pengadaan
```
PengadaanKey (PK)
DateKey (FK)
UnitKey (FK)
VendorKey (FK)
KategoriPengadaanKey (FK)
NilaiPengadaan
StatusKey (FK)
```

#### Fact_LayananAdministrasi
```
LayananKey (PK)
DateKey (FK)
JenisLayananKey (FK)
UnitKey (FK)
RequesterName (masked)
DurasiProses
StatusKey (FK)
```

### 2.3 Business Rules

#### FactPemakaianBarang
```
PemakaianBarangKey (PK)
DateKey (FK)
PegawaiKey (FK)
BarangKey (FK)
Jumlah
StatusKey (FK)
```

#### FactPengadaanBarang
```
PengadaanKey (PK)
DateKey (FK)
VendorKey (FK)
BarangKey (FK)
Jumlah
TotalBiaya
StatusKey (FK)
```

#### FactRealisasiAnggaran
```
RealisasiKey (PK)
DateKey (FK)
UnitKerjaKey (FK)
AkunKey (FK)
NilaiRealisasi
```

#### FactPerawatanGedung
```
PerawatanKey (PK)
GedungKey (FK)
DateKey (FK)
VendorKey (FK)
BiayaPerawatan
StatusKey (FK)
```

#### FactKegiatanPegawai
```
KegiatanPegawaiKey (PK)
PegawaiKey (FK)
KegiatanKey (FK)
DateKey (FK)
Durasi
StatusKey (FK)
```

#### FactInventory
```
InventoryKey (PK)
BarangKey (FK)
LokasiKey (FK)
JumlahTersedia
TanggalUpdate (DateKey FK)
```

### 2.3 Business Rules Business Rules
```
- DateKey uses format YYYYMMDD
- Each fact row references at least one dimension
- Status stored in DimStatus for multiple processes
- FK constraints enforce referential integrity
```

### 2.4 Data Lineage
```
Dummy Data (Generated in SSMS) → Staging → Transform → Load to DW → Views → Power BI
```

---

## 3. ETL Documentation

### 3.1 ETL Process Flow
```
Extract → Staging → Clean → Transform → Load to DW → Generate Views
```

### 3.2 Transformation Rules
```
- Text normalization: TRIM(), UPPER()
- Date standardization: Convert to DATE
- Code mapping: Kategori, Unit, Lokasi
- Surrogate keys: Auto identity for dimensions
```

### 3.3 Error Handling Procedures
```
- Log invalid rows into ErrorLogs table
- Reject rows with missing FK references
- Retry mechanism: re-run staging load
```

### 3.4 Schedule & Dependencies
```
- Extract: Manual
- Transform: After staging load
- Load DW: After transformation
- Dashboard refresh: After full load
```

---

## 4. User Manual

### 4.1 Access Dashboard
```
- Open Power BI Desktop
- Load PBIX file
- Connect to SQL Server instance
```

### 4.2 Navigate Reports
```
- Use sidebar to switch pages
- Hover charts for tooltips
```

### 4.3 Apply Filters
```
- Use slicers on right panel
- Filter by Unit, Tanggal, Kategori
```

### 4.4 Export Data
```
- Power BI → Export Data → CSV/Excel
```

### 4.5 FAQ
```
Q: Dashboard tidak muncul data?
A: Refresh dataset, pastikan koneksi ke SQL aktif.

Q: Nilai tidak sesuai?
A: Periksa hasil ETL atau referensi Dimensi.
```

---

## 5. Operations Manual

### 5.1 Daily Operations Checklist
```
[ ] Run ETL scripts
[ ] Validate row counts
[ ] Refresh dashboard
[ ] Check error logs
```

### 5.2 Monitor ETL Jobs
```
- Periksa tabel staging
- Jalankan COUNT() pada dim dan fact
```

### 5.3 Troubleshooting Common Issues
```
- Missing FK: Cek DimTables
- Duplicate rows: Clean staging sources
- Column mismatch: Update ETL scripts
```

### 5.4 Backup & Recovery
```
- Full backup: weekly
- Differential backup: daily
- File path: D:\Backup\DM_NonAkademik_DW
```

### 5.5 Contact Support
```
- Admin Database
- Email Internal Unit
```

---

## 6. Security Documentation

### 6.1 User Roles & Permissions
```
- db_executive: Read-only summary
- db_analyst: Full staging, read DW
- db_viewer: Views only
- db_etl_operator: Execute ETL jobs
```

### 6.2 Access Request Procedures
```
1. Pengguna mengajukan permohonan akses
2. Admin memverifikasi unit & kebutuhan
3. Admin assign role via ALTER ROLE
```

### 6.3 Password Policies
```
- Min. 12 characters
- Require uppercase, lowercase, number, symbol
- Change every 90 days
```

### 6.4 Audit Trail Queries
```
SELECT * FROM AuditLog ORDER BY EventTime DESC;
SELECT UserName, COUNT(*) FROM AuditLog GROUP BY UserName;
```

---

# END OF DOCUMENTATION
