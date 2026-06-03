# 📚 Perpus App - Aplikasi Perpustakaan Digital

Aplikasi Client Mobile Perpustakaan Digital yang dibangun menggunakan **Flutter** dengan penerapan **Clean Architecture**, **Provider State Management**, dan estetika **UI Monokrom (Hitam & Putih) Minimalis Modern** yang dilengkapi fitur **Theme Switcher (Light/Dark Mode)**.

Aplikasi ini terintegrasi dengan backend [Golang Perpustakaan RESTful API](https://github.com/afrizal423/Golang-Perpustakaan-Restful-API).

---

## 📸 Screenshots & Preview

Anda dapat menempatkan screenshot aplikasi Anda di bawah ini. Disarankan untuk menaruh file gambar di folder `screenshots/` di dalam project ini, lalu menautkannya secara relatif di `README.md`.

| Light Mode (Tema Terang) | Dark Mode (Tema Gelap) |
| :---: | :---: |
| ![Dashboard Light](screenshots/dashboard_light.png) | ![Dashboard Dark](screenshots/dashboard_dark.png) |
| ![Login Light](screenshots/login_light.png) | ![Login Dark](screenshots/login_dark.png) |

> 💡 *Catatan: Gantilah gambar di atas dengan screenshot asli yang Anda ambil dari HP/Emulator Anda setelah menyimpannya di folder `screenshots/`.*

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
