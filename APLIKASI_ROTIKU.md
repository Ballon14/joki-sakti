# 📱 ROTIKU - Aplikasi Marketplace Roti

## 🍞 Deskripsi Aplikasi

**ROTIKU** adalah aplikasi e-commerce berbasis Flutter yang dirancang khusus untuk marketplace roti/bakery. Aplikasi ini memungkinkan pengguna untuk menjelajahi, memesan, dan melacak pesanan roti segar dari toko roti lokal secara digital. Dengan dukungan multi-platform (Android, iOS, Web), ROTIKU menyediakan pengalaman berbelanja roti yang modern dan mudah.

### Informasi Proyek

| Aspek | Detail |
|-------|--------|
| **Nama Aplikasi** | ROTIKU |
| **Tipe** | Bakery Marketplace |
| **Platform** | Android, iOS, Web |
| **Framework** | Flutter |
| **Backend** | Firebase (Auth, Firestore) |
| **Versi** | 1.0.0 |

---

## ✨ Fitur Utama

### Fitur Pengguna (Customer)

| Fitur | Deskripsi |
|-------|-----------|
| **Autentikasi** | Login/Register dengan Email & Password |
| **Katalog Produk** | Jelajahi produk roti dengan gambar dan harga |
| **Keranjang Belanja** | Tambah, hapus, dan kelola kuantitas produk |
| **Manajemen Stok** | Pelacakan ketersediaan stok real-time |
| **Checkout** | Pemesanan dengan alamat pengiriman & metode pembayaran |
| **Riwayat Pesanan** | Lihat pesanan sebelumnya dengan status tracking |
| **Profil Pengguna** | Kelola informasi akun pengguna |
| **Ubah Password** | Fitur keamanan untuk mengubah kata sandi |

### Fitur Admin

| Fitur | Deskripsi |
|-------|-----------|
| **Dashboard** | Statistik penjualan dan metrik real-time |
| **Manajemen Produk** | CRUD (Create, Read, Update, Delete) produk |
| **Manajemen Pesanan** | Update status pesanan |
| **Tracking Revenue** | Pemantauan pendapatan |
| **Role-based Access** | Kontrol akses berdasarkan peran |

---

## 🎯 Manfaat Pengembangan

### 1. Digitalisasi Bisnis Roti

- **Modernisasi**: Memudahkan toko roti tradisional masuk ke era digital
- **Jangkauan Luas**: Memperluas jangkauan pasar tanpa batasan geografis
- **Efisiensi Operasional**: Meningkatkan efisiensi dengan manajemen online

### 2. Kemudahan Pengguna

- **Akses 24/7**: Pelanggan dapat memesan roti kapan saja dan dimana saja
- **Real-time Tracking**: Tracking status pesanan secara real-time
- **Tanpa Antrian**: Menghindari antrian di toko fisik

### 3. Efisiensi Bisnis

- **Pengurangan Biaya**: Operasional lebih hemat (tidak perlu etalase besar)
- **Inventori Otomatis**: Manajemen stok secara otomatis
- **Data Terorganisir**: Penjualan tercatat dengan rapi

### 4. Keunggulan Teknologi

| Aspek | Keunggulan |
|-------|------------|
| **Multi-Platform** | Satu codebase untuk Android, iOS, dan Web |
| **Real-time Sync** | Data tersinkronisasi langsung dengan Firebase |
| **Offline Support** | Firestore mendukung cache offline |
| **Scalable** | Arsitektur mudah dikembangkan |

### 5. Pengalaman Pengguna Premium

- UI/UX bertema bakery yang hangat dan profesional
- Animasi halus dan transisi modern
- Loading states dan error handling yang baik

---

## 🧱 Widget yang Digunakan

### A. Widget Kustom (Custom Widgets)

#### 1. PrimaryButton

**Lokasi:** `lib/widgets/buttons/primary_button.dart`

```dart
PrimaryButton(
  text: 'Login',
  onPressed: () {},
  isLoading: false,
  isOutlined: false,
)
```

| Properti | Tipe | Fungsi |
|----------|------|--------|
| `text` | String | Teks yang ditampilkan pada tombol |
| `onPressed` | VoidCallback | Callback saat tombol ditekan |
| `isLoading` | bool | Menampilkan loading indicator saat proses |
| `isOutlined` | bool | Mode outlined button (tanpa fill) |

**Kegunaan:** Tombol utama aplikasi dengan gradient warna, loading state, dan shadow effect. Mendukung dua mode: filled (default) dan outlined.

---

#### 2. ProductCard

**Lokasi:** `lib/widgets/cards/product_card.dart`

```dart
ProductCard(
  product: product,
  onTap: () {},
  onAddToCart: () {},
)
```

| Properti | Tipe | Fungsi |
|----------|------|--------|
| `product` | Product | Data produk yang ditampilkan |
| `onTap` | VoidCallback | Callback saat card ditekan (navigasi ke detail) |
| `onAddToCart` | VoidCallback? | Callback untuk menambah ke keranjang |

**Fitur:**
- Cached network image dengan placeholder
- Status stok berwarna:
  - 🟢 Hijau: Tersedia
  - 🟡 Kuning: Hampir habis (≤5 item)
  - 🔴 Merah: Habis
- Format harga Rupiah Indonesia
- Overlay "OUT OF STOCK" jika stok habis
- Ikon add to cart yang responsif

---

### B. Widget Flutter Built-in

#### 1. Scaffold

```dart
Scaffold(
  appBar: AppBar(title: Text('ROTIKU')),
  body: Container(...),
  bottomNavigationBar: BottomNavigationBar(...),
)
```

**Fungsi:** Struktur dasar halaman dengan AppBar di atas, body di tengah, dan navigasi di bawah. Menyediakan framework visual standar Material Design.

---

#### 2. BottomNavigationBar

```dart
BottomNavigationBar(
  currentIndex: _currentIndex,
  onTap: (index) => setState(() => _currentIndex = index),
  items: [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
    BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Orders'),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
  ],
)
```

**Fungsi:** Navigasi tab di bagian bawah layar dengan 4 menu utama untuk navigasi antar halaman.

---

#### 3. GridView.builder

```dart
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2, // 3 untuk web
    crossAxisSpacing: 16,
    mainAxisSpacing: 20,
    childAspectRatio: 0.8,
  ),
  itemCount: products.length,
  itemBuilder: (context, index) => ProductCard(product: products[index]),
)
```

**Fungsi:** Menampilkan produk dalam format grid yang responsif. Menggunakan 2 kolom di mobile dan 3 kolom di web untuk optimalisasi tampilan.

---

#### 4. StreamBuilder

```dart
StreamBuilder<List<Product>>(
  stream: productService.getProducts(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();
    }
    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    }
    if (snapshot.hasData) {
      return GridView.builder(...);
    }
    return Text('No products');
  },
)
```

**Fungsi:** Mendengarkan stream data dari Firestore dan memperbarui UI secara real-time ketika data berubah.

---

#### 5. CachedNetworkImage

```dart
CachedNetworkImage(
  imageUrl: product.imageUrl,
  fit: BoxFit.cover,
  placeholder: (context, url) => Center(
    child: CircularProgressIndicator(),
  ),
  errorWidget: (context, url, error) => Icon(
    Icons.bakery_dining,
    size: 48,
  ),
)
```

**Fungsi:** Memuat gambar dari URL dengan sistem caching untuk meningkatkan performa. Menampilkan placeholder saat loading dan error widget jika gagal.

---

#### 6. Card

```dart
Card(
  elevation: 2,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
  child: Column(
    children: [
      Image(...),
      Text(...),
      Button(...),
    ],
  ),
)
```

**Fungsi:** Container dengan shadow dan rounded corners untuk menampilkan konten produk secara visual menarik.

---

#### 7. SnackBar

```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Produk ditambahkan ke keranjang'),
    backgroundColor: AppTheme.successGreen,
    duration: Duration(seconds: 2),
  ),
)
```

**Fungsi:** Notifikasi singkat di bagian bawah layar untuk memberikan feedback atas aksi pengguna (sukses, error, warning).

---

#### 8. Consumer (Provider)

```dart
Consumer<CartProvider?>(
  builder: (context, cart, child) {
    final itemCount = cart?.itemCount ?? 0;
    return Badge(
      label: Text('$itemCount'),
      child: Icon(Icons.shopping_cart),
    );
  },
)
```

**Fungsi:** Widget dari package Provider untuk state management. Membangun ulang UI secara otomatis ketika state berubah.

---

#### 9. Badge

```dart
Badge(
  label: Text('3'),
  child: Icon(Icons.shopping_cart),
)
```

**Fungsi:** Menampilkan indikator angka di atas icon, digunakan untuk menunjukkan jumlah item di keranjang.

---

#### 10. LayoutBuilder

```dart
LayoutBuilder(
  builder: (context, constraints) {
    final isWeb = constraints.maxWidth > 600;
    final crossAxisCount = isWeb ? 3 : 2;
    final aspectRatio = isWeb ? 0.85 : 0.8;
    
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: aspectRatio,
      ),
      ...
    );
  },
)
```

**Fungsi:** Membuat layout responsif berdasarkan ukuran layar. Menyesuaikan jumlah kolom dan aspect ratio untuk tampilan optimal di berbagai device.

---

#### 11. AppBar

```dart
AppBar(
  title: Row(
    children: [
      Icon(Icons.bakery_dining, color: AppTheme.warmBrown),
      SizedBox(width: 8),
      Text('ROTIKU'),
    ],
  ),
  backgroundColor: Colors.white,
  elevation: 2,
)
```

**Fungsi:** Bar navigasi di bagian atas layar yang menampilkan judul aplikasi, ikon, dan action buttons.

---

#### 12. ListView.builder

```dart
ListView.builder(
  itemCount: orders.length,
  itemBuilder: (context, index) {
    return OrderCard(order: orders[index]);
  },
)
```

**Fungsi:** Menampilkan daftar item secara efisien dengan lazy loading, cocok untuk daftar pesanan dan item keranjang.

---

### C. Widget Form & Input

| Widget | Fungsi |
|--------|--------|
| `TextField` | Input teks untuk email, password, alamat |
| `TextFormField` | Input dengan validasi form |
| `ElevatedButton` | Tombol submit utama |
| `OutlinedButton` | Tombol secondary/cancel |
| `IconButton` | Tombol dengan ikon saja |

---

### D. Widget Loading & Feedback

| Widget | Fungsi |
|--------|--------|
| `CircularProgressIndicator` | Loading spinner animasi |
| `Shimmer` | Skeleton loading placeholder |
| `SnackBar` | Notifikasi feedback singkat |
| `AlertDialog` | Dialog konfirmasi/peringatan |
| `LinearProgressIndicator` | Progress bar horizontal |

---

### E. Widget Layout

| Widget | Fungsi |
|--------|--------|
| `Container` | Wrapper dengan styling (padding, margin, decoration) |
| `Column` | Menyusun widget secara vertikal |
| `Row` | Menyusun widget secara horizontal |
| `Stack` | Menumpuk widget di atas satu sama lain |
| `Padding` | Menambahkan padding pada widget |
| `SizedBox` | Spacer dengan ukuran tetap |
| `Expanded` | Mengisi ruang yang tersedia |