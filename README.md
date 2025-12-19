# ROTIKU - Bakery Marketplace App

A Flutter-based mobile application for ordering fresh bread from local bakeries.

## Features

- **User Authentication**: Email and password-based login/registration
- **Product Catalog**: Browse fresh bread products with images and prices
- **Shopping Cart**: Add, remove, and manage product quantities
- **Stock Management**: Real-time stock availability tracking
- **Order Placement**: Checkout with delivery address and payment method
- **Order History**: View past and ongoing orders with status tracking
- **User Profile**: Manage account information

## Tech Stack

- Flutter
- Firebase Authentication
- Cloud Firestore
- Provider (State Management)
- Google Fonts (Nunito)
- Cached Network Image

## Getting Started

### Prerequisites

- Flutter SDK (3.4.3 or higher)
- Firebase project setup
- Android Studio / VS Code with Flutter extensions

### Firebase Setup

1. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Enable Authentication (Email/Password)
3. Create Firestore Database
4. Download `google-services.json` (Android) and place in `android/app/`
5. Download `GoogleService-Info.plist` (iOS) and place in `ios/Runner/`

### Firestore Structure

```
users/
  {userId}/
    - email: string
    - name: string
    - phoneNumber: string (optional)
    - address: string (optional)

products/
  {productId}/
    - name: string
    - description: string
    - price: number
    - imageUrl: string
    - stock: number
    - category: string

orders/
  {orderId}/
    - userId: string
    - items: array
    - totalAmount: number
    - deliveryAddress: string
    - paymentMethod: string
    - status: string
    - createdAt: timestamp
```

### Installation

1. Clone the repository
```bash
git clone <repository-url>
cd rotiku
```

2. Install dependencies
```bash
flutter pub get
```

3. Configure Firebase
   - Add your Firebase configuration files
   - Update Firebase project ID if needed

4. Run the app
```bash
flutter run
```

## Adding Sample Products

You can add sample products to Firestore manually or use the Firebase Console. Example product:

```json
{
  "name": "French Baguette",
  "description": "Crispy French baguette with a golden crust and soft interior",
  "price": 15000,
  "imageUrl": "https://example.com/baguette.jpg",
  "stock": 50,
  "category": "Bread"
}
```

## App Structure

```
lib/
├── config/
│   └── theme.dart
├── models/
│   ├── product.dart
│   ├── cart_item.dart
│   ├── order.dart
│   └── user.dart
├── providers/
│   └── cart_provider.dart
├── services/
│   ├── auth_service.dart
│   ├── product_service.dart
│   └── order_service.dart
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── main/
│   │   ├── main_screen.dart
│   │   ├── home_screen.dart
│   │   ├── cart_screen.dart
│   │   ├── orders_screen.dart
│   │   └── profile_screen.dart
│   ├── product/
│   │   └── product_detail_screen.dart
│   └── checkout/
│       └── checkout_screen.dart
├── widgets/
│   ├── buttons/
│   │   └── primary_button.dart
│   └── cards/
│       └── product_card.dart
└── main.dart
```

## Design

The app follows a warm, friendly bakery theme with:
- Warm brown and soft orange color palette
- Nunito font family for readability
- Clean, modern card-based UI
- Smooth animations and transitions

## License

This project is private and not licensed for public use.
