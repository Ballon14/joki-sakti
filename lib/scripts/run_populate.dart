import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import '../utils/populate_products.dart';

/// Script sementara untuk populate data
/// Run dengan: flutter run lib/scripts/run_populate.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase initialized');
    
    // Add products
    await PopulateProducts.addSampleProducts();
    
    debugPrint('\n✨ Done! You can close this now.');
  } catch (e) {
    debugPrint('❌ Error: $e');
  }
}
