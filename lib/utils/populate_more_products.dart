import 'package:cloud_firestore/cloud_firestore.dart';

/// Script untuk menambahkan 20 products baru ke Firestore
/// Run sekali saja untuk menambahkan batch kedua
class PopulateMoreProducts {
  static Future<void> addMoreProducts() async {
    final firestore = FirebaseFirestore.instance;
    
    final products = [
      {
        'name': 'Roti Keju Parmesan',
        'description': 'Roti lembut dengan taburan keju parmesan di atas, gurih dan aromatik',
        'price': 17000,
        'imageUrl': 'https://images.unsplash.com/photo-1586985289688-ca3cf47d3e6e?w=800',
        'stock': 38,
        'category': 'Bread',
      },
      {
        'name': 'Danish Blueberry',
        'description': 'Danish pastry dengan filling blueberry segar, manis dan lezat',
        'price': 15000,
        'imageUrl': 'https://images.unsplash.com/photo-1618897996318-5a901fa6ca71?w=800',
        'stock': 25,
        'category': 'Pastry',
      },
      {
        'name': 'Roti Jagung Manis',
        'description': 'Roti lembut dengan topping jagung manis, favorit anak-anak',
        'price': 13000,
        'imageUrl': 'https://images.unsplash.com/photo-1589367920969-ab8e050bbb04?w=800',
        'stock': 42,
        'category': 'Bread',
      },
      {
        'name': 'Eclair Coklat Vanilla',
        'description': 'Eclair klasik dengan filling vanilla cream dan topping coklat glossy',
        'price': 16000,
        'imageUrl': 'https://images.unsplash.com/photo-1581781870027-04295c6de2af?w=800',
        'stock': 20,
        'category': 'Pastry',
      },
      {
        'name': 'Focaccia Rosemary',
        'description': 'Roti Italia dengan herbs rosemary dan olive oil, tekstur lembut beraroma',
        'price': 24000,
        'imageUrl': 'https://images.unsplash.com/photo-1571782742478-0816a4773a10?w=800',
        'stock': 18,
        'category': 'Bread',
      },
      {
        'name': 'Muffin Coklat Chip',
        'description': 'Muffin lembut dengan chocolate chips melimpah, cocok untuk snacking',
        'price': 11000,
        'imageUrl': 'https://images.unsplash.com/photo-1607958996333-41aef7caefaa?w=800',
        'stock': 50,
        'category': 'Cake',
      },
      {
        'name': 'Pretzel Garam',
        'description': 'Pretzel German authentik dengan taburan garam kasar, tekstur chewy',
        'price': 9000,
        'imageUrl': 'https://images.unsplash.com/photo-1590159082625-8c0d7652e4a9?w=800',
        'stock': 55,
        'category': 'Bread',
      },
      {
        'name': 'Red Velvet Cupcake',
        'description': 'Cupcake red velvet dengan cream cheese frosting yang creamy',
        'price': 18000,
        'imageUrl': 'https://images.unsplash.com/photo-1587668178277-295251f900ce?w=800',
        'stock': 36,
        'category': 'Cake',
      },
      {
        'name': 'Roti Abon Sapi',
        'description': 'Roti empuk dengan filling abon sapi premium, savory dan mengenyangkan',
        'price': 14000,
        'imageUrl': 'https://images.unsplash.com/photo-1606890737304-57a0ca8a5b62?w=800',
        'stock': 44,
        'category': 'Bread',
      },
      {
        'name': 'Puff Pastry Sosis',
        'description': 'Puff pastry renyah dengan sosis berkualitas, perfect untuk bekal',
        'price': 12000,
        'imageUrl': 'https://images.unsplash.com/photo-1562376552-0d160a2f238d?w=800',
        'stock': 40,
        'category': 'Pastry',
      },
      {
        'name': 'Banana Bread Walnut',
        'description': 'Banana bread moist dengan potongan walnut, manis alami dari pisang',
        'price': 19000,
        'imageUrl': 'https://images.unsplash.com/photo-1595741401726-1107c6e43e0e?w=800',
        'stock': 28,
        'category': 'Cake',
      },
      {
        'name': 'Donat Strawberry Glaze',
        'description': 'Donat lembut dengan glazing strawberry pink yang manis',
        'price': 9000,
        'imageUrl': 'https://images.unsplash.com/photo-1614707267537-b85aaf00c4b7?w=800',
        'stock': 58,
        'category': 'Pastry',
      },
      {
        'name': 'Ciabatta Bread',
        'description': 'Roti Italia dengan tekstur berlubang khas dan crust renyah',
        'price': 21000,
        'imageUrl': 'https://images.unsplash.com/photo-1549931319-a545dcf3bc73?w=800',
        'stock': 22,
        'category': 'Bread',
      },
      {
        'name': 'Cheesecake Blueberry Mini',
        'description': 'Mini cheesecake dengan topping blueberry compote, creamy dan segar',
        'price': 23000,
        'imageUrl': 'https://images.unsplash.com/photo-1533971592203-f820e6a881c9?w=800',
        'stock': 30,
        'category': 'Cake',
      },
      {
        'name': 'Roti Coklat Pisang',
        'description': 'Roti manis dengan kombinasi coklat dan pisang, double delight',
        'price': 15000,
        'imageUrl': 'https://images.unsplash.com/photo-1597181072234-0d0d50aee331?w=800',
        'stock': 46,
        'category': 'Bread',
      },
      {
        'name': 'Tart Buah Seasonal',
        'description': 'Tart dengan custard cream dan buah segar musiman, cantik dan lezat',
        'price': 26000,
        'imageUrl': 'https://images.unsplash.com/photo-1519915028121-7d3463d20b13?w=800',
        'stock': 16,
        'category': 'Cake',
      },
      {
        'name': 'Roti Srikaya Pandan',
        'description': 'Roti lembut dengan filling srikaya pandan tradisional, wangi dan manis',
        'price': 13000,
        'imageUrl': 'https://images.unsplash.com/photo-1612182062639-c148b55f4845?w=800',
        'stock': 40,
        'category': 'Bread',
      },
      {
        'name': 'Macaron Assorted',
        'description': 'Set macaron dengan 5 rasa berbeda, French delicacy yang elegant',
        'price': 35000,
        'imageUrl': 'https://images.unsplash.com/photo-1569864358642-9d1684040f43?w=800',
        'stock': 24,
        'category': 'Pastry',
      },
      {
        'name': 'Roti Ubi Ungu',
        'description': 'Roti sehat dengan filling ubi ungu alami, kaya antioksidan',
        'price': 14000,
        'imageUrl': 'https://images.unsplash.com/photo-1585507252242-11fe632c26e8?w=800',
        'stock': 34,
        'category': 'Bread',
      },
      {
        'name': 'Tiramisu Slice',
        'description': 'Potongan tiramisu klasik Italia dengan coffee dan mascarpone yang lembut',
        'price': 28000,
        'imageUrl': 'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?w=800',
        'stock': 20,
        'category': 'Cake',
      },
    ];

    print('🔥 Menambahkan ${products.length} products BARU ke Firestore...');
    
    for (var i = 0; i < products.length; i++) {
      final product = products[i];
      await firestore.collection('products').add(product);
      print('✅ Added: ${product['name']}');
    }
    
    print('🎉 Selesai! ${products.length} products BARU berhasil ditambahkan!');
  }
}
