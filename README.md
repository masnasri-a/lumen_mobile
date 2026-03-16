# Lumen Mobile

Aplikasi mobile Flutter untuk **Lumen** — manajemen keuangan pribadi, pasangan, dan tim. Mencatat pengeluaran, melacak anggaran, mengelola reimbursement, dan mendapatkan insight berbasis AI.

## Tech Stack

| Komponen | Teknologi |
|---|---|
| Framework | Flutter (Dart 3.10+) |
| State Management | Provider v6 |
| HTTP Client | Dio v5 |
| Auth Storage | flutter_secure_storage |
| Google Sign-In | google_sign_in v7 |
| Export | share_plus + path_provider |
| Font | DMSerifDisplay |

## Prasyarat

- Flutter SDK 3.10+
- Dart 3.10+
- Android Studio / Xcode (untuk emulator)
- Backend Lumen API berjalan (lihat [backend/README.md](../backend/README.md))

## Cara Menjalankan

### 1. Install dependencies

```bash
cd lumen_mobile
flutter pub get
```

### 2. Konfigurasi URL API

Edit file `lib/config/app_config.dart`:

```dart
class AppConfig {
  static const String baseUrl = 'http://localhost:8080/api/v1';
}
```

Ganti `localhost` dengan IP mesin/server backend jika menjalankan di device fisik.

### 3. Jalankan aplikasi

```bash
# Android / iOS emulator
flutter run

# Pilih device spesifik
flutter run -d <device_id>

# Daftar device yang tersedia
flutter devices
```

### 4. Build release

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release
```

## Struktur Direktori

```
lib/
├── main.dart                    # Entry point, setup Provider
├── config/
│   └── app_config.dart          # Base URL & timeout
├── models/                      # Data model (fromJson / toJson)
│   ├── user_model.dart
│   ├── transaction_model.dart   # TransactionModel, ReimbursementSummaryItem, dll
│   ├── finance_context_model.dart
│   ├── budget_model.dart
│   └── auth_response.dart
├── services/                    # HTTP client & business logic
│   ├── api_client.dart          # Dio singleton + token injection
│   ├── auth_service.dart
│   ├── transaction_service.dart
│   ├── context_service.dart
│   ├── recurring_service.dart
│   ├── spending_alert_service.dart
│   ├── couple_invite_service.dart
│   ├── export_service.dart
│   ├── google_auth_service.dart
│   ├── otp_service.dart
│   └── ai_service.dart
├── providers/                   # State management (ChangeNotifier)
│   ├── auth_provider.dart
│   ├── context_provider.dart
│   └── transaction_provider.dart
├── pages/
│   ├── onboarding/              # Splash, welcome, setup profil
│   ├── auth/                    # Login, register, verifikasi email
│   ├── home/                    # Dashboard utama + bottom nav shell
│   │   ├── main_shell.dart      # Bottom navigation bar
│   │   ├── home_tab.dart        # Tab beranda + quick actions
│   │   └── team_tab.dart
│   ├── transaction/
│   │   ├── add_transaction_page.dart
│   │   ├── transaction_history_page.dart
│   │   ├── transaction_detail_page.dart
│   │   ├── reimbursement_page.dart  # Halaman manajemen reimbursement
│   │   ├── recurring_page.dart
│   │   └── scan_receipt_page.dart
│   ├── analytics/
│   ├── profile/
│   ├── settings/
│   ├── couple/
│   ├── team/
│   └── wallet/
└── theme/
    └── app_theme.dart           # Warna, font, konstanta desain
```

## Fitur Aplikasi

### Autentikasi
- Daftar & login dengan email + password
- Login dengan Google
- Verifikasi OTP via email
- Token JWT disimpan aman dengan `flutter_secure_storage`
- Auto-refresh token saat expired

### Finance Contexts
Pengguna bisa memiliki hingga 3 context keuangan:
- **Personal** — pengeluaran pribadi
- **Pasangan** — pengeluaran bersama pasangan (join via invite code)
- **Tim Kantor** — pengeluaran tim (approval reimbursement)

### Transaksi
- Catat transaksi manual dengan kategori, merchant, catatan
- Scan struk (upload ke S3)
- Filter berdasarkan tanggal, kategori, merchant, jumlah
- Export ke CSV

### Reimbursement
Akses dari tombol **Reimburse** di quick action beranda:
- Lihat semua transaksi yang bisa di-reimburse
- Filter per status: **Semua / Pending / Disetujui / Ditolak**
- Summary statistik (jumlah & total per status) di header halaman
- Approve / tolak langsung dari halaman detail transaksi

### Anggaran (Budget)
- Set anggaran bulanan per context
- Lihat riwayat anggaran

### Transaksi Berulang
- Buat tagihan/langganan berulang (harian, mingguan, bulanan, tahunan)
- Kelola dari tab "Tagihan" di bottom nav

### Analitik
- Grafik pengeluaran per bulan
- Breakdown per kategori

### AI Insights
- Analisis pola pengeluaran menggunakan Groq AI

## Navigasi

```
Splash → Welcome → Onboarding (pilih Personal/Pasangan/Tim)
       → MainShell (bottom nav)
           ├── [0] Beranda      — dashboard, quick actions, transaksi terbaru
           ├── [1] Analitik     — grafik & ringkasan
           ├── [FAB] Tambah     — catat transaksi baru
           ├── [3] Tagihan/Tim  — recurring atau team management
           └── [4] Profil       — pengaturan akun & context
```

Quick actions di beranda:
- **Scan Struk** → kamera untuk scan & upload struk
- **Catat Manual** → form tambah transaksi
- **Input Suara** → (coming soon)
- **Reimburse** → halaman daftar reimbursement aktif context

## State Management

Menggunakan **Provider** pattern dengan 3 provider utama:

| Provider | Tanggung Jawab |
|---|---|
| `AuthProvider` | Status login, token, data user |
| `ContextProvider` | Daftar finance context, context aktif per tab |
| `TransactionProvider` | Cache transaksi per context, loading state |

## API Client

`ApiClient` adalah singleton Dio dengan interceptor:
- Otomatis inject header `Authorization: Bearer <token>`
- Retry refresh token jika dapat respons 401
- Redirect ke halaman login jika refresh gagal

## Mengganti URL Backend

```dart
// lib/config/app_config.dart
class AppConfig {
  static const String baseUrl = 'http://43.157.243.30:8080/api/v1'; // production
  // static const String baseUrl = 'http://localhost:8080/api/v1'; // lokal
}
```

## Lint & Format

```bash
# Analisis kode
flutter analyze

# Format kode
dart format lib/
```

## Dependencies Utama

| Package | Versi | Kegunaan |
|---|---|---|
| `dio` | ^5.8.0 | HTTP client dengan interceptor |
| `provider` | ^6.1.5 | State management |
| `flutter_secure_storage` | ^9.2.4 | Simpan token JWT dengan aman |
| `google_sign_in` | ^7.2.0 | Autentikasi Google |
| `share_plus` | ^10.1.4 | Share/export file CSV |
| `path_provider` | ^2.1.4 | Akses direktori lokal untuk export |
| `flutter_svg` | ^2.2.4 | Render asset SVG (logo Google) |
