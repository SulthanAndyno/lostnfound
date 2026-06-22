# Lost & Found Go Backend (SQLite + WebSockets)

Folder ini berisi backend custom berbasis Go untuk menyinkronkan data laporan barang hilang/temuan serta chat secara real-time.

## Prasyarat
- **Go** (Sudah terinstall di laptop kamu)
- **Ngrok** (Sudah terinstall di laptop kamu)

---

## Cara Menjalankan Backend & Sinkronisasi

### Langkah 1: Jalankan Go Backend
Buka terminal di laptop kamu, arahkan ke folder ini, lalu jalankan:
```bash
cd backend
go run main.go
```
Server akan berjalan di port `8080` (`http://localhost:8080`). 
Database SQLite (`lostnfound.db`) akan otomatis dibuat dan diisi dengan data barang bawaan secara otomatis.

### Langkah 2: Jalankan Ngrok
Buka terminal baru di laptop kamu, lalu jalankan ngrok untuk membuat terowongan publik ke port server:
```bash
ngrok http 8080
```
Kamu akan mendapatkan output link HTTPS, misalnya:
`https://a1b2-34-56.ngrok-free.app`

### Langkah 3: Update Host di Flutter
1. Buka file `/lib/features/lost_and_found/services/lost_and_found_service.dart` di editor.
2. Cari variabel `serverHost` di bagian atas class:
   ```dart
   static String serverHost = 'localhost:8080';
   ```
3. Ganti nilainya dengan host ngrok yang kamu dapatkan (tanpa `http://` atau `https://` dan tanpa garis miring `/` di belakangnya).
   *Contoh untuk punyamu:*
   ```dart
   static String serverHost = 'murkiness-utensil-fondly.ngrok-free.dev';
   ```
4. Save file-nya, lalu jalankan aplikasi Flutter kamu di kedua HP!

---

## Skenario Testing 2 HP (Simulasi Chat)

Aplikasi sudah dikonfigurasi untuk membedakan antara **Pemilik Laporan** (Owner) dan **Pihak Lain** (Finder/Claimer).

1. **HP Pertama (User A - Pemilik Laporan)**:
   - Buat laporan baru barang hilang/temuan di aplikasi (misalnya: HP Samsung).
   - Laporan ini akan tersimpan ke database SQLite di laptop kamu lewat ngrok.
   
2. **HP Kedua (User B - Pihak Lain)**:
   - Buka aplikasi. Laporan baru (HP Samsung) otomatis muncul di feed barang hilang.
   - Klik tombol **"Hubungi Pemilik/Penemu"** pada laporan tersebut.
   - Status laporan akan otomatis berubah menjadi **"DALAM KLAIM"** di kedua HP secara realtime.
   - Ketik pesan chat dan kirim.
   
3. **Hasil Real-time**:
   - Pesan yang dikirim oleh User B akan langsung muncul secara instan di layar chat HP User A tanpa perlu reload, dan sebaliknya!
