import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import '../utils/populate_more_products.dart';

/// Script untuk menambahkan 20 products batch ke-2
/// Run dengan: flutter run lib/scripts/run_populate_more.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase initialized');
    
    // Add 20 more products
    await PopulateMoreProducts.addMoreProducts();
    
    debugPrint('\n✨ Done! Total sekarang ada 30 products. You can close this now.');
  } catch (e) {
    debugPrint('❌ Error: $e');
  }
}
