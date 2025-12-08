# Responsi 2 Mobile Paket 3 H1D023085

## Identitas
- Nama: Karel Tsalasatir Riyan
- NIM: H1D023085
- Shift baru: F
- Shift asal: E

## Video Demo
![Video Demo](Video%20Demo.mp4)

## Penjelasan Kode
- `lib/main.dart`  
  - Inisialisasi Supabase dan menjalankan `MyApp`.
- `lib/app.dart`  
  - `MyApp`: tema, routes, dan `AuthGate`.  
  - `AuthGate`: pilih layar login atau home berdasar status auth.
- `lib/pages/login_page.dart`  
  - Form login/registrasi, `signInWithPassword` dan `signUp`, lalu navigasi ke `/home`.
- `lib/pages/home_page.dart`  
  - Stream `books`, list data, aksi edit/delete, tombol tambah, logout.
  - `_refreshList`: memicu stream baru setelah perubahan data.
- `lib/pages/book_form_page.dart`  
  - Form tambah/edit semua field buku; submit insert/update; `Navigator.pop(context, true)` agar home bisa refresh.

## Spesifikasi API (Supabase)
- Auth: email/password (built-in Supabase).
- Database: tabel `books` seperti di bagian Konfigurasi; operasi insert/update/delete/read dilakukan langsung via Supabase client.
- Tabel: `books` dengan kolom:
  - `id` (int, PK, auto increment)
  - `title` (text)
  - `price` (int)
  - `amount` (int)
  - `entry_date` (text/tanggal)
  - `volume` (int)
  - `author` (text)
  - `publisher` (text)

