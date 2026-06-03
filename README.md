# 📚 Perpus App - Aplikasi Perpustakaan Digital

Aplikasi Client Mobile Perpustakaan Digital yang dibangun menggunakan **Flutter** dengan penerapan **Clean Architecture**, **Provider State Management**, dan estetika **UI Monokrom (Hitam & Putih) Minimalis Modern** yang dilengkapi fitur **Theme Switcher (Light/Dark Mode)**.

Aplikasi ini terintegrasi dengan backend [Golang Perpustakaan RESTful API](https://github.com/afrizal423/Golang-Perpustakaan-Restful-API).

---

## 📸 Screenshots & Preview

Berikut adalah cuplikan antarmuka (UI) aplikasi dalam **Dark Mode (Tema Gelap)** yang menampilkan estetika minimalis modern beresolusi tinggi dengan sentuhan aksen pastel solid yang premium:

### 1. Halaman Login (Sign In Staf)
Halaman masuk dengan tipografi tebal (`Perpustakaan\nDigital.`), ikon brand minimalis, serta tombol aksi dengan kontras tinggi yang bersih.
<p align="center">
  <img src="screenshots/login_dark.png" width="300" alt="Login Screen Dark Mode" />
</p>

### 2. Dashboard Utama (Semua Kategori & Ringkasan)
Menampilkan salam penyambutan staf, toggle tema matahari/bulan, menu cepat peminjaman aktif, statistik koleksi buku (mint green pastel), denda (gold/sand pastel), serta list peminjaman yang terlambat (*overdue*).
<p align="center">
  <img src="screenshots/dashboard_dark.png" width="300" alt="Dashboard Screen Dark Mode" />
</p>

### 3. Filter Sirkulasi (Modul Katalog)
Menampilkan transisi kategori dashboard saat menyaring menu katalog buku dengan kartu deskripsi solid berwarna pastel hijau mint.
<p align="center">
  <img src="screenshots/dashboard_katalog.png" width="300" alt="Dashboard Catalog Filter" />
</p>

### 4. Halaman Katalog Buku
Daftar koleksi buku lengkap yang disusun menggunakan kartu solid datar (`CustomCard`) dengan informasi status ketersediaan stok buku, fitur pencarian di header, dan tombol tambah buku (+).
<p align="center">
  <img src="screenshots/katalog_buku.png" width="300" alt="Book Catalog List" />
</p>

---

## ✨ Fitur Utama

- **Premium Monochrome UI**: Tampilan antarmuka beresolusi tinggi dengan skema warna Hitam & Putih yang clean, elegan, dan fungsional.
- **Dynamic Theme Switcher**: Mengubah tema (Light & Dark Mode) secara instan melalui tombol toggle di dashboard. Pilihan tema otomatis tersimpan di memori lokal menggunakan `SharedPreferences`.
- **Clean Architecture & State Management**: Pembagian kode yang rapi berdasarkan layer (`core`, `data`, `domain`, `presentation`) dan pengelolaan state reaktif menggunakan `Provider`.
- **Manajemen Katalog & Sirkulasi**:
  - **Dashboard Utama**: Ringkasan data sirkulasi aktif, pintasan transaksi baru, dan panel kategori intuitif.
  - **Koleksi Buku (Katalog)**: Menampilkan daftar buku lengkap beserta sampul, detail buku, serta form tambah/edit buku.
  - **Sirkulasi Peminjaman**: Pencatatan transaksi peminjaman buku baru mahasiswa, daftar peminjaman aktif, dan pemrosesan pengembalian buku secara langsung.
  - **Sistem Denda**: Laporan otomatis keterlambatan pengembalian buku dan pencatatan pembayaran denda.

---

## 🏗️ Arsitektur & Struktur Folder

Aplikasi dirancang dengan mengikuti pola **Clean Architecture** untuk memastikan kode mudah dirawat (maintainable), diuji (testable), dan dikembangkan (scalable):

```text
lib/
├── core/                  # Utilitas global, konstanta, tema, & klien jaringan
│   ├── constants/         # AppColors, konfigurasi global
│   ├── network/           # ApiClient (HTTP/REST client)
│   ├── theme/             # AppTheme (Light & Dark ThemeData)
│   └── utils/             # DateFormatter, ViewState
├── domain/                # Layer Bisnis / Logika Inti (Bebas framework)
│   ├── entities/          # Entitas data (Buku, Peminjaman, Denda, User)
│   └── repositories/      # Interface/Kontrak repositori data
├── data/                  # Layer Implementasi Data
│   ├── models/            # Serialisasi JSON (BukuModel, UserModel, dll)
│   ├── datasources/       # Sumber data (API/Remote & Local Mock database)
│   └── repositories/      # Realisasi konkret dari kontrak Domain Repositories
├── presentation/          # Layer UI (Framework & State Management)
│   ├── providers/         # Controller/State Provider (Auth, Buku, Peminjaman, Denda, Theme)
│   ├── screens/           # Tampilan UI Halaman (Auth, Dashboard, Buku, Peminjaman, Denda)
│   └── widgets/           # Komponen widget reusable (CustomCard, CustomButton, CustomTextField, dll)
└── main.dart              # Titik masuk aplikasi (Setup multi-provider)
```

---

## 🚀 Memulai & Instalasi

### Prasyarat
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (versi terbaru direkomendasikan)
- Dart SDK
- Android SDK (untuk menjalankan di Emulator/HP Android)

### Langkah Langkah Jalankan Aplikasi

1. **Clone repository ini:**
   ```bash
   git clone https://github.com/wishaputra/perpus-app.git
   cd perpus-app
   ```

2. **Dapatkan dependencies project:**
   ```bash
   flutter pub get
   ```

3. **Jalankan Uji Coba Unit & Widget:**
   ```bash
   flutter test
   ```

4. **Konfigurasi API Endpoint (Opsional):**
   Ubah base URL server API Anda pada berkas [api_client.dart](file:///c:/someshit/test%20flutter/lib/core/network/api_client.dart) untuk menghubungkan aplikasi ke backend Golang sesungguhnya.

5. **Jalankan Aplikasi:**
   Koneksikan perangkat HP Anda melalui kabel USB (aktifkan USB Debugging) atau jalankan Emulator Android/iOS, kemudian ketik:
   ```bash
   flutter run
   ```

---

## 🛠️ Tech Stack & Dependencies

- **Framework**: Flutter (Dart)
- **State Management**: `provider`
- **Penyimpanan Lokal (Persistence)**: `shared_preferences`
- **HTTP Client**: `http`
- **Pengujian**: `flutter_test`
