# 🧩 Misi 2 — Physical Model, ETL, Data Quality, Performance & Security
**Data Mart Non-Akademik | Kelompok 3**

---

## 1. 🧱 Physical Data Model

### 1.1 Penyesuaian Logical ➜ Physical
- Surrogate Key → INT IDENTITY(1,1)
- Natural Key → VARCHAR
- Tanggal → DATE
- Nilai uang → NUMERIC(18,2)
- Durasi → INT
- Penamaan tabel:
  - Fact_* → tabel fakta
  - Dim_* → tabel dimensi
  - PK: *_Key
  - NK: Code atau ID

### 1.2 Indexing Strategy
- Clustered Index → SK di setiap dimensi
- Nonclustered Index:
  - Fact_Pengadaan(UnitKey)
  - Fact_RealisasiAnggaran(AkunKey)
  - Fact_SuratMasuk(UnitKey)
- Columnstore Index untuk tabel fakta besar

### 1.3 Partitioning
- Partition by DateKey (YYYYMMDD)
- Tahun aktif: 2020–2025
- Partition function & scheme digunakan pada seluruh fact table

---

## 2. 🗄️ Physical Schema (DDL)

### 2.1 Dimensi

#### 📌 DimUnitKerja
UnitKey INT IDENTITY PRIMARY KEY,
UnitCode VARCHAR(10),
NamaUnit VARCHAR(200),
IsActive BIT,
StartDate DATE,
EndDate DATE


#### 📌 DimAkunBelanja
AkunKey INT IDENTITY PRIMARY KEY,
AkunCode VARCHAR(10),
NamaAkun VARCHAR(200),
Kategori VARCHAR(100)


#### 📌 DimTanggal
DateKey INT PRIMARY KEY,
Tanggal DATE,
Hari INT,
Bulan INT,
Tahun INT,
NamaBulan VARCHAR(20),
Triwulan INT


---

### 2.2 Tabel Fakta

#### 📌 Fact_RealisasiAnggaran
RealisasiKey INT IDENTITY PRIMARY KEY,
DateKey INT FOREIGN KEY REFERENCES DimTanggal(DateKey),
AkunKey INT FOREIGN KEY REFERENCES DimAkunBelanja(AkunKey),
UnitKey INT FOREIGN KEY REFERENCES DimUnitKerja(UnitKey),
NilaiRealisasi NUMERIC(18,2)


#### 📌 Fact_SuratMasuk
SuratMasukKey INT IDENTITY PRIMARY KEY,
DateKey INT,
UnitKey INT,
AsalKey INT,
PerihalKey INT,
JumlahSurat INT


#### 📌 Fact_Pengadaan
PengadaanKey INT IDENTITY PRIMARY KEY,
DateKey INT,
UnitKey INT,
VendorKey INT,
NilaiPengadaan NUMERIC(18,2),
StatusKey INT


---

## 3. ⚙️ ETL Architecture

### 3.1 Lapisan ETL
#### 🔸 Staging Layer
- Menampung data mentah (Excel, CSV, PDF)
- Tanpa transformasi berat

#### 🔸 Transformation Layer
- Standardisasi nama unit
- Mapping akun belanja
- Normalisasi vendor
- Penghapusan duplikasi
- Parsing tanggal (dd/mm/yyyy → DATE)
- Perhitungan durasi peminjaman fasilitas

#### 🔸 Loading Layer
- Dimensi dimuat terlebih dahulu
- Fakta dimuat terakhir
- SCD Type 2 → Unit, Vendor, Fasilitas
- SCD Type 1 → Status, Tanggal, Perihal

---

## 4. 🧪 Data Quality Checking

### 4.1 Completeness
- Cek DateKey kosong
- Realisasi tanpa nilai
- Aset tanpa unit pemilik

### 4.2 Consistency
- Format tanggal konsisten
- Validasi referential integrity (FK)

### 4.3 Accuracy
- Cross-check nilai realisasi
- Validasi mapping akun belanja resmi

### 4.4 Timeliness
- Tanggal surat harus sesuai metadata
- Tidak boleh ada peminjaman fasilitas overlap

---

## 5. ⚡ Performance Design

### 5.1 Index Optimization
- Nonclustered index pada seluruh FK fact table
- Columnstore index pada tabel fakta besar
- Partition elimination untuk query berbasis DateKey

### 5.2 Query Optimization
- Merge join untuk dimensi ukuran kecil
- Hindari scalar function pada WHERE clause
- Optimasi join order

---
# 📝 Misi II Checklist

| Title                                   | Date           | Status     |
|-----------------------------------------|----------------|------------|
| Database dibuat di SQL Server           | Nov 17, 2025   | Completed  |
| Dimension tables dibuat                 | Nov 17, 2025   | Completed  |
| Fact tables dibuat                      | Nov 17, 2025   | Completed  |
| Primary keys dan foreign keys defined   | Nov 17, 2025   | Completed  |
| Indexes dibuat                          | Nov 18, 2025   | Completed  |
| Partitioning implemented (if applicable)| Nov 18, 2025   | Completed  |
| Staging tables dibuat                   | Nov 22, 2025   | Completed  |
| ETL design terdokumentasi               | Nov 22, 2025   | Completed  |
| ETL implemented (SSIS atau scripts)     | Nov 22, 2025   | Completed  |
| Data loaded successfully                | Nov 23, 2025   | Completed  |
| Data quality checks dilakukan           | Nov 23, 2025   | Completed  |
| Performance testing dilakukan           | Nov 23, 2025   | Completed  |
| SQL scripts committed ke GitHub         | Nov 24, 2025   | Completed  |
| Technical documentation lengkap         | Nov 24, 2025   | Completed  |
