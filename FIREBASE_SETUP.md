# Firebase Setup Guide untuk ROTIKU

## Langkah 1: Buat Project Firebase

1. Kunjungi [Firebase Console](https://console.firebase.google.com/)
2. Klik "Add project" atau "Tambah project"
3. Nama project: `rotiku` (atau nama lain sesuai keinginan)
4. Ikuti wizard setup hingga selesai

## Langkah 2: Setup Android App

1. Di Firebase Console, klik icon Android
2. Package name: `com.example.rotiku` (sesuaikan jika berbeda)
3. Download file `google-services.json`
4. Copy file ke folder: `android/app/google-services.json`

### Update android/build.gradle

Tambahkan di `buildscript > dependencies`:
```gradle
classpath 'com.google.gms:google-services:4.4.0'
```

### Update android/app/build.gradle

Tambahkan di bagian bawah file:
```gradle
apply plugin: 'com.google.firebase.gms-services'
```

Di bagian `defaultConfig`, pastikan ada:
```gradle
minSdkVersion 21
```

## Langkah 3: Aktifkan Authentication

1. Di Firebase Console, pilih "Authentication"
2. Klik "Get Started"
3. Pilih tab "Sign-in method"
4. Enable "Email/Password"
5. Simpan perubahan

## Langkah 4: Buat Firestore Database

1. Di Firebase Console, pilih "Firestore Database"
2. Klik "Create database"
3. Pilih mode "Start in test mode" (untuk development)
4. Pilih lokasi server (asia-southeast2 untuk Indonesia)
5. Klik "Enable"

### Security Rules untuk Development

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Products collection
    match /products/{productId} {
      allow read: if true;
      allow write: if false; // Only admin via console
    }
    
    // Orders collection  
    match /orders/{orderId} {
      allow read: if request.auth != null && resource.data.userId == request.auth.uid;
      allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
      allow update: if false; // Only admin via console
    }
  }
}
```

## Langkah 5: Tambahkan Sample Products

Di Firestore Console, buat collection `products` dengan dokumen:

### Contoh Produk 1
```
Document ID: (auto)
Fields:
- name: "Roti Tawar Premium"
- description: "Roti tawar lembut dengan kualitas premium, cocok untuk sandwich atau panggang"
- price: 15000
- imageUrl: "https://images.unsplash.com/photo-1509440159596-0249088772ff?w=800"
- stock: 50
- category: "Bread"
```

### Contoh Produk 2
```
Document ID: (auto)
Fields:
- name: "Croissant Mentega"
- description: "Croissant renyah dengan lapisan mentega yang lezat"
- price: 12000
- imageUrl: "https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=800"
- stock: 30
- category: "Pastry"
```

### Contoh Produk 3
```
Document ID: (auto)
Fields:
- name: "Roti Sourdough"
- description: "Roti sourdough authentik dengan cita rasa unik dan tekstur sempurna"
- price: 25000
- imageUrl: "https://images.unsplash.com/photo-1549931319-a545dcf3bc73?w=800"
- stock: 20
- category: "Bread"
```

### Contoh Produk 4
```
Document ID: (auto)
Fields:
- name: "Bagel Original"
- description: "Bagel klasik dengan tekstur kenyal, sempurna untuk breakfast"
- price: 10000
- imageUrl: "https://images.unsplash.com/photo-1551106652-a5bcf4b29917?w=800"
- stock: 40
- category: "Bread"
```

### Contoh Produk 5
```
Document ID: (auto)
Fields:
- name: "Baguette Prancis"
- description: "Baguette authentik ala Prancis dengan kulit renyah dan interior lembut"
- price: 18000
- imageUrl: "https://images.unsplash.com/photo-1549931319-5974c8574b2f?w=800"
- stock: 25
- category: "Bread"
```

### Contoh Produk 6
```
Document ID: (auto)
Fields:
- name: "Donat Coklat"
- description: "Donat empuk dengan topping coklat manis"
- price: 8000
- imageUrl: "https://images.unsplash.com/photo-1551024506-0bccd828d307?w=800"
- stock: 60
- category: "Pastry"
```

## Langkah 6: Test Aplikasi

1. Jalankan `flutter pub get`
2. Jalankan aplikasi: `flutter run`
3. Register akun baru
4. Coba browse produk
5. Tambahkan ke cart
6. Lakukan checkout

## Troubleshooting

### Error: "Default FirebaseApp is not initialized"
- Pastikan `google-services.json` ada di `android/app/`
- Pastikan sudah menambahkan plugin di `build.gradle`
- Clean dan rebuild: `flutter clean && flutter pub get`

### Error: "MinSdkVersion"
- Update `android/app/build.gradle` dengan `minSdkVersion 21`

### Produk tidak muncul
- Cek Firestore Rules apakah allow read untuk products
- Cek collection name harus persis "products"
- Cek field names harus sesuai dengan model

### Images tidak muncul
- Pastikan URL valid dan accessible
- Gunakan URL dari Unsplash atau upload ke Firebase Storage

## Tips Production

Untuk production:
1. Update Firestore Security Rules lebih ketat
2. Tambahkan admin panel untuk manage products
3. Gunakan Firebase Storage untuk images
4. Setup Firebase Cloud Functions untuk notifikasi
5. Implementasi payment gateway yang sebenarnya
