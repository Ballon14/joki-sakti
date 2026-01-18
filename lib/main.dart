import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'config/theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main/main_screen.dart';
import 'screens/admin/admin_main_screen.dart';
import 'services/auth_service.dart';
import 'providers/cart_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with generated options
  bool firebaseInitialized = false;
  String? firebaseError;

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseInitialized = true;
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    firebaseError = e.toString();
    debugPrint('⚠️ Firebase initialization failed: $e');
  }

  runApp(MyApp(
    firebaseInitialized: firebaseInitialized,
    firebaseError: firebaseError,
  ));
}

class MyApp extends StatelessWidget {
  final bool firebaseInitialized;
  final String? firebaseError;

  const MyApp({
    super.key,
    required this.firebaseInitialized,
    this.firebaseError,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Stream auth state
        StreamProvider<User?>(
          create: (_) => AuthService().authStateChanges,
          initialData: null,
        ),

        // Provide CartProvider with userId from auth state
        // FIXED: Use ChangeNotifierProxyProvider for ChangeNotifier classes
        ChangeNotifierProxyProvider<User?, CartProvider?>(
          create: (_) => null,
          update: (context, user, previousCart) {
            // User logged out - dispose cart
            if (user == null) {
              if (previousCart != null) {
                debugPrint('👋 User logged out - disposing CartProvider');
                previousCart.dispose();
              }
              return null;
            }

            // User logged in - create or update cart
            if (previousCart == null || previousCart.userId != user.uid) {
              // Dispose old cart if user changed
              if (previousCart != null && previousCart.userId != user.uid) {
                debugPrint('🔄 User changed - disposing old CartProvider');
                previousCart.dispose();
              }

              // Create new cart for this user
              debugPrint('🆕 Creating CartProvider for user: ${user.uid}');
              return CartProvider(userId: user.uid);
            }

            // Same user, keep existing cart
            return previousCart;
          },
        ),
      ],
      child: MaterialApp(
        title: 'ROTIKU',
        theme: AppTheme.theme,
        home: AuthWrapper(
          firebaseInitialized: firebaseInitialized,
          firebaseError: firebaseError,
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  final bool firebaseInitialized;
  final String? firebaseError;

  const AuthWrapper({
    super.key,
    required this.firebaseInitialized,
    this.firebaseError,
  });

  @override
  Widget build(BuildContext context) {
    // Check if Firebase is initialized before trying to use it
    if (!firebaseInitialized) {
      // Firebase not initialized - show error screen
      return Scaffold(
        appBar: AppBar(
          title: const Text('ROTIKU - Setup Required'),
          backgroundColor: Colors.red,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 80,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Firebase Connection Failed',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  if (firebaseError != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        'Error: $firebaseError',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red.shade900,
                          fontFamily: 'monospace',
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  const Text(
                    'Langkah troubleshooting:\n\n'
                    '1. Pastikan koneksi internet aktif\n'
                    '2. Verifikasi google-services.json ada di android/app/\n'
                    '3. Cek Firebase Console - project harus aktif\n'
                    '4. Jalankan: flutter clean && flutter pub get\n'
                    '5. Rebuild aplikasi',
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          // Restart the app - user needs to do this manually
                          // This button is just for UX
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Coba Lagi'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Firebase initialized - use role-based routing
    final authService = AuthService();

    return StreamBuilder(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final user = snapshot.data;

        if (user == null) {
          return const LoginScreen();
        }

        // User logged in - check role
        return FutureBuilder(
          future: authService.getUserData(user.uid),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final userData = userSnapshot.data;

            // Route based on user role
            if (userData?.isAdmin == true) {
              return const AdminMainScreen();
            }

            return const MainScreen();
          },
        );
      },
    );
  }
}
