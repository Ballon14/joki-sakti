// Script to add sample products to Firestore
// Run: node add_products.js

const admin = require('firebase-admin');

// Initialize Firebase Admin
// Download service account key from Firebase Console:
// Project Settings > Service Accounts > Generate New Private Key
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://rotiku-9dd78-default-rtdb.asia-southeast1.firebasedatabase.app"
});

const db = admin.firestore();

const products = [
  {
    name: 'Roti Tawar Premium',
    description: 'Roti tawar lembut dengan kualitas premium, cocok untuk sandwich',
    price: 15000,
    imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=800',
    stock: 50,
    category: 'Bread',
  },
  {
    name: 'Croissant Mentega',
    description: 'Croissant renyah dengan lapisan mentega yang lezat',
    price: 12000,
    imageUrl: 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=800',
    stock: 30,
    category: 'Pastry',
  },
  {
    name: 'Roti Sourdough',
    description: 'Roti sourdough authentik dengan cita rasa unik',
    price: 25000,
    imageUrl: 'https://images.unsplash.com/photo-1549931319-a545dcf3bc73?w=800',
    stock: 20,
    category: 'Bread',
  },
  {
    name: 'Bagel Original',
    description: 'Bagel klasik dengan tekstur kenyal, sempurna untuk breakfast',
    price: 10000,
    imageUrl: 'https://images.unsplash.com/photo-1551106652-a5bcf4b29917?w=800',
    stock: 40,
    category: 'Bread',
  },
  {
    name: 'Baguette Prancis',
    description: 'Baguette authentik ala Prancis dengan kulit renyah',
    price: 18000,
    imageUrl: 'https://images.unsplash.com/photo-1549931319-5974c8574b2f?w=800',
    stock: 25,
    category: 'Bread',
  },
  {
    name: 'Donat Coklat',
    description: 'Donat empuk dengan topping coklat manis',
    price: 8000,
    imageUrl: 'https://images.unsplash.com/photo-1551024506-0bccd828d307?w=800',
    stock: 60,
    category: 'Pastry',
  },
];

async function addProducts() {
  try {
    console.log('🔥 Adding products to Firestore...\n');
    
    for (const product of products) {
      const docRef = await db.collection('products').add(product);
      console.log(`✅ Added: ${product.name} (ID: ${docRef.id})`);
    }
    
    console.log(`\n🎉 Successfully added ${products.length} products!`);
    process.exit(0);
  } catch (error) {
    console.error('❌ Error adding products:', error);
    process.exit(1);
  }
}

addProducts();
