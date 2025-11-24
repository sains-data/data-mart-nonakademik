
# 🧩 Misi 1 — Business Requirements & Conceptual Design  
Dokumentasi lengkap Misi 1 tersedia pada folder `/docs`.  
Berikut ringkasan struktur logis yang digunakan dalam Data Mart.

---

## 1. 🎯 Business Requirements Analysis

### **1.1 Domain Scope**
Data Mart ini berfokus pada area Non-Akademik, meliputi:  
- Administrasi umum  
- Surat masuk & keluar  
- Layanan antar-unit  
- Penggunaan fasilitas  
- Penganggaran & realisasi  
- Pengadaan barang/jasa  
- Pengelolaan aset/BMN  

### **1.2 Stakeholders**
- **Primary Users:** Bagian Umum, Subbagian Keuangan, BMN  
- **Decision Makers:** Wakil Rektor Non-Akademik/Keuangan  
- **Supporting:** seluruh unit kerja, dosen, tenaga kependidikan, mahasiswa  

### **1.3 Business Processes**
- Proses surat masuk & keluar  
- Permohonan layanan administrasi  
- Penggunaan fasilitas (ruangan/kendaraan)  
- Penganggaran & realisasi  
- Pengadaan barang/jasa  
- Pengelolaan aset dan BMN  

### **1.4 KPIs**
- Jumlah surat masuk/keluar  
- SLA layanan administrasi  
- Tingkat penggunaan fasilitas  
- Persentase realisasi anggaran  
- Nilai & jumlah pengadaan  
- Kondisi & distribusi aset  

---

## 2. 📁 Data Source Identification

### Sumber data yang digunakan:
- Laporan Keuangan ITERA Semester I 2025  
- Rekap data administrasi umum (surat, layanan, fasilitas)  
- Rekap pengadaan & aset BMN  
- Asumsi dataset internal (Excel, CSV, PDF, sistem persuratan, sistem keuangan)  

### Aspek analisis data:
- Struktur data (tabel transaksi, tabel master, rekap administrasi)  
- Volume data (harian–tahunan)  
- Kualitas data (missing, duplikasi, konsistensi)  
- Frekuensi update (harian untuk surat / keuangan, semester untuk aset)

---

## 3. 🧩 Conceptual Design — ERD

### **Entities utama**
- Unit Kerja  
- Anggaran  
- Realisasi  
- Akun Belanja  
- Pengadaan  
- Aset/BMN  
- Fasilitas  
- Peminjaman Fasilitas  
- Surat Masuk  
- Surat Keluar  

### **Relationship**
- Unit Kerja 1–M Anggaran  
- Anggaran 1–M Realisasi  
- Fasilitas 1–M Peminjaman  
- Unit Kerja 1–M Surat Masuk & Keluar  
- Akun Belanja 1–M Pengadaan/Realisasi  

(ERD lengkap tersedia di folder `/docs/misi-1/erd.png`)

---

## 4. ⭐ Logical Design — Dimensional Model

### Fact Tables:
- **Fact_RealisasiAnggaran**  
- **Fact_Pengadaan**  
- **Fact_PeminjamanFasilitas**  
- **Fact_SuratMasuk**  
- **Fact_SuratKeluar**

### Dimension Tables:
- DimUnitKerja  
- DimAkunBelanja  
- DimTanggal  
- DimVendor  
- DimFasilitas  
- DimStatus  
- DimKategoriPengadaan  
- DimAsalSurat / DimTujuanSurat  
- DimPerihalSurat  

### Grain:
- Per transaksi (realisasi/pengadaan)  
- Per peminjaman fasilitas  
- Per dokumen surat  

### Additivity:
- nilai_realisasi → additive  
- nilai_pengadaan → additive  
- durasi_peminjaman → additive  
- jumlah_surat → additive  

### Surrogate Keys:
- Semua dimensi menggunakan SK (int auto increment)  
- SCD Type 2 untuk: Unit, Vendor, Fasilitas  
- SCD Type 1 untuk: Status, Tanggal, Perihal Surat  

---

## 5. 📚 Data Dictionary  
Dokumen data dictionary lengkap tersedia di:  
`/docs/requirements/DW_Kelompok 3_Misi 1.PDF`

Berisi:
- Definisi kolom fact & dimension  
- PK/FK  
- Tipe data  
- Business rules  

---

## 6. 📌 Misi 1 Checklist

| Task | Status |
|------|--------|
| Kick-off meeting | ✔ Completed |
| Business Requirements | ✔ Completed |
| Data Source Identification | ✔ Completed |
| KPI Definition | ✔ Completed |
| ERD | ✔ Completed |
| Fact Tables Identification | ✔ Completed |
| Dimension Tables Identification | ✔ Completed |
| Grain Definition | ✔ Completed |
| Dimensional Model | ✔ Completed |
| Data Dictionary | ✔ Completed |
| GitHub Repository Setup | ✔ Completed |
| README.md | ✔ Completed |

---
