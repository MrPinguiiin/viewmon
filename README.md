# ViewMon - System Monitoring Dashboard

Script monitoring dashboard untuk VPS/Linux dengan tampilan yang menarik dan informatif.

## Fitur Utama

- **CPU Information**: Menampilkan Model, Cores, Usage (dengan Progress Bar), dan Load Average.
- **Memory Information**: Monitoring RAM dan Swap Usage secara real-time.
- **Disk Usage**: Menampilkan penggunaan disk pada berbagai mount point.
- **Network Information**: Informasi Interface, IP Address, RX/TX Data, dan Active Connections.
- **Top Processes**: List proses yang paling banyak mengonsumsi resource CPU.
- **Modern UI**: Dashboard menggunakan box-drawing characters dan warna ANSI untuk tampilan yang premium.

## Cara Penggunaan

Gunakan perintah satu baris berikut untuk menginstal:

```bash
wget -qO install.sh https://raw.githubusercontent.com/MrPinguiiin/viewmon/main/install.sh && sudo bash install.sh
```

Setelah instalasi selesai, cukup ketik `viewmon` untuk membuka dashboard. Dashboard akan diperbarui secara **real-time** setiap 2 detik.

```bash
viewmon
```

**Tekan `Ctrl + C` untuk keluar.**

## Cara Uninstall

Untuk menghapus ViewMon dari sistem:

```bash
wget -qO uninstall.sh https://raw.githubusercontent.com/MrPinguiiin/viewmon/main/uninstall.sh && sudo bash uninstall.sh
```

## Catatan

- Pastikan Anda memiliki akses `sudo` atau `root` untuk proses instalasi.
- Script ini akan secara otomatis menginstal dependensi yang dibutuhkan (`bc`, `sysstat`, `net-tools`).
- Direkomendasikan menggunakan terminal emulator modern untuk tampilan warna yang optimal.

## About

ViewMon adalah alat monitoring sistem berbasis terminal yang ringan namun powerful, dirancang khusus untuk administrator VPS yang menginginkan ringkasan status server dengan cepat dan visual yang menarik.
