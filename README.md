
---

# 📱 Expense Tracker App

Aplikasi **Expense Tracker** ini dibangun menggunakan Flutter dan `sqflite` untuk menyimpan dan mengelola data pengeluaran pengguna di dalam SQLite. Aplikasi ini mendukung login, pencatatan pengeluaran, penambahan saldo, serta fitur edit dan hapus pengeluaran.

---

## 📌 Fitur Utama

- Menambahkan **saldo awal**
- Menambahkan **pengeluaran**
- Melihat **daftar pengeluaran**
- Mengedit dan menghapus pengeluaran
- Sinkronisasi dengan **user ID (uid)** yang login

---

## 🛠️ Programming Steps

### 1. **Inisialisasi Aplikasi**
- File dimulai dengan `ExpenseTrackerApp` yang menerima `uid` dari hasil login dan meneruskan ke halaman utama aplikasi.

```dart
home: ExpenseTracker(uid: uid),
```

---

### 2. **Stateful Widget ExpenseTracker**
- Komponen utama aplikasi, menangani tampilan dan logika pengeluaran.
- Menyimpan data saldo (`balance`) dan daftar pengeluaran (`expenses`) di state.

---

### 3. **Mendapatkan dan Menampilkan Data**
- `initState()` dipanggil pertama kali untuk:
  - Mendapatkan data pengeluaran (`_fetchExpenses()`)
  - Inisialisasi saldo (`initbalance()`)

```dart
void initState() {
  super.initState();
  _fetchExpenses();
  initbalance();
}
```

---

### 4. **Menambah Saldo**
- Field untuk memasukkan nilai saldo dan tombol "Add".
- Fungsi `_setBalance()` meng-update saldo pengguna di database dan local state.

```dart
int newbalance = await _databaseService.updateUserBalance(balanceinp, widget.uid);
```

---

### 5. **Menambah Pengeluaran**
- Form input: judul dan jumlah pengeluaran.
- Fungsi `_addExpense()` akan:
  - Konversi jumlah ke bilangan negatif
  - Tambahkan pengeluaran ke database
  - Update saldo (karena berkurang)
  - Refresh daftar pengeluaran

---

### 6. **Mengedit Pengeluaran**
- `_editExpense(index)` menampilkan dialog popup untuk mengedit:
  - Judul (`title`)
  - Jumlah (`amount`)
- Perbedaan jumlah akan dihitung dan saldo disesuaikan.

```dart
int difference = (updatedAmount - oldAmount).toInt();
balance -= difference;
```

---

### 7. **Menghapus Pengeluaran**
- Fungsi `_deleteExpense(index)` akan:
  - Menghapus entri dari database
  - Menambahkan kembali jumlah yang dihapus ke saldo (karena jumlahnya negatif)

```dart
balance -= amount; // karena amount negatif, efeknya adalah saldo bertambah
```

---

### 8. **Tampilan UI**
- Desain UI menggunakan kombinasi `Card`, `TextField`, dan `ListView.builder`.
- Tampilan responsif dan bersih, dengan setiap entri pengeluaran ditampilkan dalam kartu terpisah.
- Fitur `edit` dan `delete` disediakan sebagai `IconButton` di tiap entri.

---

