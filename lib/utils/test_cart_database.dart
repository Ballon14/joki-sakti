// Quick test script to verify Firestore connection and cart operations
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> testCartDatabase() async {
  print('🧪 ========== CART DATABASE TEST ==========');
  
  final firestore = FirebaseFirestore.instance;
  final testUserId = 'test_user_123';
  final testProductId = 'test_product_456';
  
  try {
    // Test 1: Save to database
    print('\n1️⃣ Testing SAVE to database...');
    await firestore
        .collection('users')
        .doc(testUserId)
        .collection('cart')
        .doc(testProductId)
        .set({
      'productId': testProductId,
      'quantity': 5,
      'addedAt': FieldValue.serverTimestamp(),
    });
    print('✅ SAVE successful!');
    
    // Test 2: Load from database
    print('\n2️⃣ Testing LOAD from database...');
    final snapshot = await firestore
        .collection('users')
        .doc(testUserId)
        .collection('cart')
        .get();
    
    print('✅ LOAD successful!');
    print('   Found ${snapshot.docs.length} items in cart');
    for (var doc in snapshot.docs) {
      print('   - ${doc.id}: ${doc.data()}');
    }
    
    // Test 3: Delete from database
    print('\n3️⃣ Testing DELETE from database...');
    await firestore
        .collection('users')
        .doc(testUserId)
        .collection('cart')
        .doc(testProductId)
        .delete();
    print('✅ DELETE successful!');
    
    print('\n🎉 All database tests PASSED!');
    print('✅ Database connection is working correctly');
    
  } catch (e) {
    print('\n❌ Database test FAILED!');
    print('Error: $e');
    print('\nPossible causes:');
    print('- Firestore not initialized');
    print('- No internet connection');
    print('- Security rules blocking access');
  }
  
  print('🧪 ========== TEST COMPLETE ==========\n');
}

// Call this after Firebase is initialized in main
// testCartDatabase();
