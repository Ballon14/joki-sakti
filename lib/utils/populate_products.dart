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
        'description': 'Croissant renyah dengan lapisan mentega yang lezat, sempurna untuk sarapan',
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
        'description': 'Bagel klasik dengan tekstur kenyal, sempurna untuk breakfast dengan cream cheese',
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
        'description': 'Donat empuk dengan topping coklat manis yang menggoda selera',
        'price': 8000,
        'imageUrl': 'https://images.unsplash.com/photo-1551024506-0bccd828d307?w=800',
        'stock': 60,
        'category': 'Pastry',
      },
      {
        'name': 'Roti Gandum Multigrain',
        'description': 'Roti gandum sehat dengan biji-bijian pilihan, kaya serat dan nutrisi',
        'price': 20000,
        'imageUrl': 'https://images.unsplash.com/photo-1586444248902-2f64eddc13df?w=800',
        'stock': 35,
        'category': 'Bread',
      },
      {
        'name': 'Pain au Chocolat',
        'description': 'Pastry berlapis dengan coklat premium di dalamnya, favorit untuk breakfast',
        'price': 14000,
        'imageUrl': 'https://images.unsplash.com/photo-1623334044303-241021148842?w=800',
        'stock': 28,
        'category': 'Pastry',
      },
      {
        'name': 'Roti Kismis Cinnamon',
        'description': 'Roti manis dengan kismis dan aroma cinnamon yang harum, lembut dan manis',
        'price': 16000,
        'imageUrl': 'https://images.unsplash.com/photo-1608198093002-ad4e0d9a491d?w=800',
        'stock': 32,
        'category': 'Bread',
      },
      {
        'name': 'Brownies Coklat Kacang',
        'description': 'Brownies coklat fudgy dengan topping kacang almond, tekstur lembut dan rich',
        'price': 22000,
        'imageUrl': 'https://images.unsplash.com/photo-1607920591413-4ec007e70023?w=800',
        'stock': 45,
        'category': 'Cake',
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
