# Data Mart – Non-Akademik ITERA  
Tugas Besar Pergudangan Data – Kelompok 3  

---

## 👥 Team Members (Sorted by NIM)
| NIM | Nama |
|-----|------------------------------|
| 122450046 | Vita Anggraini |
| 123450034 | Kharisma Mustika Sari |
| 123450060 | Ridho Benedictus Togi Manik |
| 123450105 | Arielva Simon Siahaan |

---

# 1. Project Description
Data Mart Non-Akademik ITERA adalah proyek pembangunan data warehouse untuk mendukung analisis proses operasional non-akademik di ITERA, meliputi keuangan, pengadaan, BMN, fasilitas, dan persuratan sesuai **struktur organisasi institusi**.  
Dokumentasi ini mencakup seluruh rangkaian pengerjaan **Misi 1 sampai Misi 3**, mulai dari business understanding hingga implementasi data mart.

---

# 2. Business Domain

## 2.1 Domain Scope  
Berikut cakupan domain berdasarkan struktur organisasi resmi ITERA:

| Proses | Deskripsi |
|--------|-----------|
| Anggaran | Alokasi pagu anggaran unit per tahun |
| Realisasi | Transaksi penggunaan anggaran |
| Pengadaan | Proses pengadaan barang/jasa oleh unit |
| Aset/BMN | Daftar aset lembaga yang dikelola unit |
| Fasilitas | Ruang rapat, kendaraan, dan fasilitas umum |
| Peminjaman Fasilitas | Aktivitas penggunaan fasilitas |
| Surat Masuk | Dokumen yang diterima institusi |
| Surat Keluar | Dokumen yang dikirim institusi |

Unit Kerja menjadi entitas pusat karena semua proses terhubung dengan struktur organisasi institusi.

---

## 2.2 Stakeholder Identification

| Tipe Stakeholder | Unit / Jabatan |
|------------------|----------------|
| **Primary Users** | Bagian Umum dan Kepegawaian, Subbag Keuangan & BMN, Bagian Umum dan Keuangan |
| **Decision Maker** | Wakil Rektor Bidang Non-Akademik (Keuangan, dan Umum) |
| **Supporting Stakeholders** | Seluruh Unit Kerja ITERA, Dosen & Tendik, Mahasiswa |

---

## 2.3 Business Process Summary

| Proses | Entitas Utama | Unit Terkait |
|--------|--------------|--------------|
| Anggaran | Anggaran | Unit Kerja, Akun Belanja |
| Realisasi | Realisasi | Unit Kerja, Akun Belanja |
| Pengadaan | Pengadaan | Unit Kerja, Vendor, Akun Belanja |
| BMN | Aset/BMN | Unit Kerja |
| Fasilitas | Fasilitas | Unit Pengelola |
| Peminjaman | Peminjaman Fasilitas | Unit Peminjam, Fasilitas |
| Surat Masuk | SuratMasuk | Unit Tujuan |
| Surat Keluar | SuratKeluar | Unit Pengirim |

---

## 2.4 Analytical Requirements

| Pertanyaan Analitik | Tipe Analisis |
|----------------------|---------------|
| Pagu vs Realisasi Anggaran | Financial Monitoring |
| Jumlah dan nilai pengadaan | Procurement KPI |
| Distribusi aset per unit | Asset Management |
| Frekuensi peminjaman fasilitas | Utilization Analysis |
| Volume surat masuk & keluar | Administrative Workload |
| SLA layanan administrasi | Performance Measurement |

---

# 3. Architecture

| Komponen | Pendekatan |
|---------|------------|
| **Methodology** | Kimball Dimensional Modeling |
| **Model** | Star Schema (Conformed Dimensions) |
| **ETL** | Disiapkan pada Misi 2 |
| **Data Mart Implementation** | Misi 3 |
| **Platform** | Ditentukan dosen (PostgreSQL/SQL Server/Azure VM) |

---

# 4. Dimensional Modeling

## 4.1 Fact Tables

| Fact Table | Grain | Deskripsi |
|------------|--------|-----------|
| **Fact_Realisasi** | per transaksi realisasi | Catatan penggunaan anggaran |
| **Fact_Pengadaan** | per aktivitas pengadaan | Nilai, vendor, tanggal, status |
| **Fact_PeminjamanFasilitas** | per transaksi peminjaman | Durasi, peminjam, fasilitas |
| **Fact_SuratMasuk** | per dokumen masuk | Asal, perihal, tanggal, status |
| **Fact_SuratKeluar** | per dokumen keluar | Tujuan, perihal, tanggal, status |

---

## 4.2 Dimension Tables

| Dimension | Deskripsi |
|-----------|------------|
| **DimUnitKerja** | Struktur organisasi ITERA |
| **DimAkunBelanja** | Kode akun BAS/SAP |
| **DimFasilitas** | Data fasilitas institusi |
| **DimBMN** | Aset yang dikelola |
| **DimStatus** | Status dokumen dan proses |
| **DimTanggal** | Dimensi waktu lengkap |
| **DimKeperluan** | Jenis keperluan administrasi |
| **DimPerihal** | Perihal surat masuk/keluar |
| **DimKategoriPengadaan** | Klasifikasi pengadaan |

---

# 5. Design Documents

## 📌 5.1 Entity Relationship Diagram (ERD)
Diagram hubungan entitas operasional sebagai dasar desain dimensional:

![ERD](docs/ERD.png)

---

## 📌 5.2 Dimensional Model (Star Schema)
Model dimensional lengkap:

![Dimensional Model](docs/dimensional-model.png)

---

# 6. Data Dictionary

## 6.1 Dimension Tables

---

### **DimUnitKerja**
| Kolom | Tipe Data | PK/FK | Deskripsi |
|-------|-----------|-------|-----------|
| UnitKerjaKey | INT | PK | Surrogate key |
| KodeUnit | VARCHAR | - | Kode resmi unit |
| NamaUnit | VARCHAR | - | Nama unit kerja |
| JenisUnit | VARCHAR | - | Fakultas/UPT/Biro |
| Tingkatan | VARCHAR | - | Level organisasi |
| StatusAktif | VARCHAR | - | Aktif/nonaktif |
| StartDate | DATE | - | Awal rekam (SCD2) |
| EndDate | DATE | - | Akhir rekam (SCD2) |
| IsCurrent | BOOL | - | Status terbaru |

---

### **DimAkunBelanja**
| Kolom | Tipe Data | PK/FK | Deskripsi |
|-------|-----------|-------|-----------|
| AkunBelanjaKey | INT | PK | Surrogate key |
| KodeAkun | VARCHAR | - | Kode akun |
| NamaAkun | VARCHAR | - | Nama akun |
| KategoriAkun | VARCHAR | - | Operasional/Modal |
| StartDate | DATE | - | Awal rekam (SCD2) |
| EndDate | DATE | - | Akhir rekam (SCD2) |
| IsCurrent | BOOL | - | Aktif |

---

### **DimFasilitas**
| Kolom | Tipe Data | PK/FK | Deskripsi |
|-------|-----------|-------|-----------|
| FasilitasKey | INT | PK | Surrogate key |
| NamaFasilitas | VARCHAR | - | Nama fasilitas |
| JenisFasilitas | VARCHAR | - | Ruang/Kendaraan |
| Kapasitas | INT | - | Kapasitas |
| UnitPengelolaKey | INT | FK | Unit pengelola |
| Lokasi | VARCHAR | - | Lokasi |
| StatusAktif | VARCHAR | - | Aktif/nonaktif |

---

### **DimBMN**
| Kolom | Tipe Data | PK/FK | Deskripsi |
|-------|-----------|-------|-----------|
| BMNKey | INT | PK | Surrogate key |
| KodeBMN | VARCHAR | - | Kode aset |
| NamaBMN | VARCHAR | - | Nama aset |
| KategoriBMN | VARCHAR | - | Peralatan/mesin/perabot |
| Kondisi | VARCHAR | - | Baik/rusak |
| Lokasi | VARCHAR | - | Lokasi |
| UnitPemilikKey | INT | FK | Unit pemilik |

---

### **DimStatus**
| Kolom | Tipe Data | PK/FK | Deskripsi |
|-------|-----------|-------|-----------|
| StatusKey | INT | PK | Surrogate key |
| NamaStatus | VARCHAR | - | Contoh: proses/selesai |
| TipeStatus | VARCHAR | - | Surat/Pengadaan/Peminjaman |

---

### **DimTanggal**
| Kolom | Tipe Data | PK/FK | Deskripsi |
|--------|-----------|--------|-----------|
| TanggalKey | INT | PK | Format YYYYMMDD |
| Tanggal | DATE | - | Tanggal lengkap |
| Hari | INT | - | Hari ke-n |
| NamaHari | VARCHAR | - | Senin–Minggu |
| Bulan | INT | - | 1–12 |
| NamaBulan | VARCHAR | - | Januari–Desember |
| Tahun | INT | - | Tahun |
| Kuartal | INT | - | Q1–Q4 |
| MingguKe | INT | - | Week number |

---

### **DimKeperluan**
| Kolom | Tipe Data | PK/FK | Deskripsi |
|-------|-----------|-------|-----------|
| KeperluanKey | INT | PK | Surrogate key |
| NamaKeperluan | VARCHAR | - | Keperluan peminjaman |

---

### **DimPerihal**
| Kolom | Tipe Data | PK/FK | Deskripsi |
|-------|-----------|-------|-----------|
| PerihalKey | INT | PK | Surrogate key |
| NamaPerihal | VARCHAR | - | Perihal surat |

---

### **DimKategoriPengadaan**
| Kolom | Tipe Data | PK/FK | Deskripsi |
|------------------------|-----------|-------|-----------|
| KategoriPengadaanKey | INT | PK | Surrogate key |
| NamaKategori | VARCHAR | - | Barang/Jasa/Konstruksi |

---

# 6.2 Fact Tables

---

### **Fact_Realisasi**
| Kolom | Tipe Data | PK/FK | Deskripsi |
|-------|-----------|-------|-----------|
| RealisasiKey | INT | PK | Surrogate key |
| UnitKerjaKey | INT | FK | Unit pelaksana |
| AkunBelanjaKey | INT | FK | Akun belanja |
| TanggalKey | INT | FK | Tanggal transaksi |
| NilaiRealisasi | DECIMAL | - | Nilai transaksi |
| Keterangan | VARCHAR | - | Catatan |

---

### **Fact_Pengadaan**
| Kolom | Tipe Data | PK/FK | Deskripsi |
|-------|-----------|-------|-----------|
| PengadaanKey | INT | PK | Surrogate key |
| UnitKerjaKey | INT | FK | Unit pemohon |
| AkunBelanjaKey | INT | FK | Sumber anggaran |
| Vendor | VARCHAR | - | Nama vendor |
| NilaiPengadaan | DECIMAL | - | Nilai |
| TanggalKey | INT | FK | Tanggal transaksi |
| KategoriPengadaanKey | INT | FK | Kategori |
| StatusKey | INT | FK | Status |

---

### **Fact_PeminjamanFasilitas**
| Kolom | Tipe Data | PK/FK | Deskripsi |
|-------|-----------|-------|-----------|
| PeminjamanKey | INT | PK | Surrogate key |
| FasilitasKey | INT | FK | Fasilitas |
| UnitKerjaKey | INT | FK | Peminjam |
| KeperluanKey | INT | FK | Keperluan |
| TanggalPinjamKey | INT | FK | Mulai |
| TanggalKembaliKey | INT | FK | Selesai |
| DurasiJam | INT | - | Durasi penggunaan |

---

### **Fact_SuratMasuk**
| Kolom | Tipe Data | PK/FK | Deskripsi |
|-------|-----------|-------|-----------|
| SuratMasukKey | INT | PK | Surrogate key |
| UnitTujuanKey | INT | FK | Unit tujuan |
| PerihalKey | INT | FK | Perihal |
| StatusKey | INT | FK | Status |
| TanggalKey | INT | FK | Tanggal masuk |
| AsalSurat | VARCHAR | - | Nama pengirim |

---

### **Fact_SuratKeluar**
| Kolom | Tipe Data | PK/FK | Deskripsi |
|-------|-----------|-------|-----------|
| SuratKeluarKey | INT | PK | Surrogate key |
| UnitPengirimKey | INT | FK | Unit pengirim |
| PerihalKey | INT | FK | Perihal |
| StatusKey | INT | FK | Status |
| TanggalKey | INT | FK | Tanggal keluar |
| TujuanSurat | VARCHAR | - | Tujuan surat |

---

---

# 7. Project Timeline (Misi 1–3)

| Misi | Fokus Pengerjaan | Status |
|------|------------------|--------|
| **Misi 1** | Business Understanding + Dimensional Modeling | 10 - 17 November 2025|
| **Misi 2** | ETL Pipeline (Staging → DW → Mart) | 17 - 24 November 2025 |
| **Misi 3** | Implementasi Data Mart + Dashboard | 24 - 1 Desember 2025 |

---

