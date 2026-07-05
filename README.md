# Task App (Aplikasi Manajemen Tugas Mahasiswa)

Aplikasi klien mobile berbasis **Flutter** untuk mengelola tugas (task) mahasiswa. Aplikasi ini berintegrasi dengan backend API server untuk melakukan autentikasi pengguna dan operasi CRUD (Create, Read, Update, Delete) pada tugas.

---

## 📌 Fitur Utama

- **Autentikasi Pengguna**:
  - Registrasi akun baru (Nama, NIM/Username, Password).
  - Login menggunakan NIM dan Password.
  - Penyimpanan JWT Token secara aman menggunakan penyimpanan terenkripsi lokal (`flutter_secure_storage`).
- **Manajemen Tugas**:
  - Menampilkan daftar seluruh tugas mahasiswa.
  - Menambahkan tugas baru dilengkapi dengan judul, deskripsi, dan tenggat waktu (deadline).
  - Mengubah detail tugas dan status penyelesaian tugas (Pending / Completed).
  - Menghapus tugas yang tidak lagi diperlukan.
  - Melakukan pencarian tugas secara real-time.

---

## 📂 Struktur Proyek

Berikut adalah struktur folder dan file utama di dalam direktori `lib/`:

```text
lib/
├── main.dart               # Titik masuk utama (entry point) aplikasi dan konfigurasi rute (routes)
├── model/
│   └── task.dart           # Model data untuk merepresentasikan objek Task
├── service/
│   └── api.dart            # Kelas ApiService untuk integrasi API backend menggunakan Dio
└── ui/
    ├── login.dart          # Halaman login mahasiswa menggunakan NIM
    ├── register.dart       # Halaman registrasi akun baru mahasiswa
    ├── home.dart           # Halaman utama (Dashboard) penampil daftar tugas & kontrol aksi
    ├── add_task.dart       # Halaman formulir penambahan tugas baru
    └── edit_task.dart      # Halaman formulir pengeditan tugas yang sudah ada
```

---

## 🛠️ Dependensi Proyek

Berikut adalah pustaka (packages) pihak ketiga yang digunakan dalam proyek ini, didefinisikan dalam [pubspec.yaml](file:///c:/Users/helm-otaku/Documents/pirman/www/task_app/task_app/pubspec.yaml):

### Dependensi Utama (Production Dependencies)
- **`flutter`**: SDK Flutter untuk membangun antarmuka dan logika aplikasi.
- **`cupertino_icons` (^1.0.2)**: Set ikon gaya iOS untuk Flutter.
- **`dio` (^5.10.0)**: HTTP client yang kuat untuk Dart/Flutter, digunakan untuk memproses request API ke backend, menangani interceptor JWT token, serta penanganan error.
- **`flutter_secure_storage` (^9.2.4)**: Penyimpanan aman untuk menyimpan data sensitif seperti JWT token secara lokal di perangkat.
- **`json_annotation` (^4.9.0)**: Anotasi untuk generator kode serialisasi JSON.

### Dependensi Pengembangan (Dev Dependencies)
- **`flutter_test`**: Paket pengujian bawaan Flutter.
- **`flutter_lints` (^2.0.0)**: Kumpulan aturan linting standar untuk mendorong praktik pengodean yang baik.
- **`build_runner` (^2.4.9)**: Alat CLI untuk menjalankan generator kode di Dart/Flutter.
- **`json_serializable` (^6.8.0)**: Generator kode otomatis untuk mengubah objek Dart dari/ke format JSON.

---

## 📋 Persyaratan Sistem (Requirements to Run)

Sebelum menjalankan aplikasi, pastikan sistem Anda telah memenuhi persyaratan berikut:

1. **Flutter SDK**: Versi yang mendukung rentang Dart SDK `sdk: '>=3.1.2 <4.0.0'` (Disarankan menggunakan **Flutter SDK v3.16.x atau versi stabil terbaru**).
2. **Dart SDK**: Terintegrasi secara otomatis dengan instalasi Flutter.
3. **Android Studio / VS Code**: Dilengkapi dengan ekstensi **Flutter** dan **Dart** yang terinstal.
4. **Android SDK / Xcode**: Untuk menjalankan aplikasi di emulator/simulator atau perangkat fisik Android/iOS.
5. **Backend Server API**: Backend server harus aktif dan dapat diakses. Di dalam proyek ini, alamat dasar API dikonfigurasi ke:
   ```text
   http://10.152.179.137:3000/api
   ```
   *Catatan: Anda dapat menyesuaikan variabel `baseUrl` di dalam file [api.dart](file:///c:/Users/helm-otaku/Documents/pirman/www/task_app/task_app/lib/service/api.dart) sesuai dengan alamat host server backend Anda.*

---

## 🚀 Cara Menjalankan Aplikasi (How to Run)

Ikuti langkah-langkah di bawah ini untuk memasang dan menjalankan aplikasi di lingkungan lokal Anda:

### 1. Dapatkan Dependensi Proyek
Buka terminal di direktori utama proyek (`task_app`) lalu jalankan perintah berikut untuk mengunduh semua package yang dideklarasikan:
```bash
flutter pub get
```

### 2. Jalankan Generator Kode (Opsional)
Jika Anda melakukan perubahan pada anotasi serialisasi JSON dan perlu men-generate ulang file model pendukung:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Periksa Perangkat yang Terhubung
Pastikan emulator sudah berjalan atau perangkat fisik Anda terhubung dengan mode debugging aktif:
```bash
flutter devices
```

### 4. Jalankan Aplikasi
Jalankan perintah berikut untuk memulai aplikasi di perangkat default Anda:
```bash
flutter run
```
Atau jalankan pada target perangkat spesifik:
```bash
flutter run -d <DEVICE_ID>
```
*(Ganti `<DEVICE_ID>` dengan ID perangkat yang didapatkan dari perintah `flutter devices`)*
