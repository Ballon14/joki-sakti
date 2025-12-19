import 'package:cloud_firestore/cloud_firestore.dart';

/// Script untuk menambahkan sample products ke Firestore
/// Run sekali saja, kemudian hapus file ini
class PopulateProducts {
  static Future<void> addSampleProducts() async {
    final firestore = FirebaseFirestore.instance;
    
    final products = [
      {
        'name': 'Roti Tawar Premium',
        'description': 'Roti tawar lembut dengan kualitas premium, cocok untuk sandwich atau panggang',
        'price': 15000,
        'imageUrl': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=800',
        'stock': 50,
        'category': 'Bread',
      },
      {
        'name': 'Croissant Mentega',
        'description': 'Croissant renyah dengan lapisan mentega yang lezat',
        'price': 12000,
        'imageUrl': 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=800',
        'stock': 30,
        'category': 'Pastry',
      },
      {
        'name': 'Roti Sourdough',
        'description': 'Roti sourdough authentik dengan cita rasa unik dan tekstur sempurna',
        'price': 25000,
        'imageUrl': 'https://images.unsplash.com/photo-1549931319-a545dcf3bc73?w=800',
        'stock': 20,
        'category': 'Bread',
      },
      {
        'name': 'Bagel Original',
        'description': 'Bagel klasik dengan tekstur kenyal, sempurna untuk breakfast',
        'price': 10000,
        'imageUrl': 'https://images.unsplash.com/photo-1551106652-a5bcf4b29917?w=800',
        'stock': 40,
        'category': 'Bread',
      },
      {
        'name': 'Baguette Prancis',
        'description': 'Baguette authentik ala Prancis dengan kulit renyah dan interior lembut',
        'price': 18000,
        'imageUrl': 'https://images.unsplash.com/photo-1549931319-5974c8574b2f?w=800',
        'stock': 25,
        'category': 'Bread',
      },
      {
        'name': 'Donat Coklat',
        'description': 'Donat empuk dengan topping coklat manis',
        'price': 8000,
        'imageUrl': 'https://images.unsplash.com/photo-1551024506-0bccd828d307?w=800',
        'stock': 60,
        'category': 'Pastry',
      },
    ];

    print('🔥 Menambahkan ${products.length} products ke Firestore...');
    
    for (var i = 0; i < products.length; i++) {
      final product = products[i];
      await firestore.collection('products').add(product);
      print('✅ Added: ${product['name']}');
    }
    
    print('🎉 Selesai! ${products.length} products berhasil ditambahkan!');
  }
}
