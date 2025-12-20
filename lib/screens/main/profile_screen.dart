import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../services/auth_service.dart';
import '../../models/user.dart';
import '../../providers/cart_provider.dart';
import '../auth/login_screen.dart';
import '../profile/account_info_screen.dart';
import '../profile/help_support_screen.dart';
import '../profile/saved_addresses_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final currentUser = authService.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          automaticallyImplyLeading: false,
        ),
        body: const Center(
          child: Text('Please login'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<UserModel?>(
        future: authService.getUserData(currentUser.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final user = snapshot.data;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Profile Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: AppTheme.warmBeige,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppTheme.softOrange,
                        child: Text(
                          (user?.name ?? 'U')[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user?.name ?? 'User',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.warmBrown,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? currentUser.email ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.darkGray,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Menu Items
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _buildMenuItem(
                        icon: Icons.person_outline,
                        title: 'Account Information',
                        subtitle: 'Manage your account details',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AccountInfoScreen(),
                            ),
                          );
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.location_on_outlined,
                        title: 'Saved Addresses',
                        subtitle: 'Manage delivery addresses',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SavedAddressesScreen(),
                            ),
                          );
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.help_outline,
                        title: 'Help & Support',
                        subtitle: 'Get help with your orders',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HelpSupportScreen(),
                            ),
                          );
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.info_outline,
                        title: 'About ROTIKU',
                        subtitle: 'Version 1.0.0',
                        onTap: () {
                          showAboutDialog(
                            context: context,
                            applicationName: 'ROTIKU',
                            applicationVersion: '1.0.0',
                            applicationIcon: const Icon(
                              Icons.bakery_dining,
                              size: 48,
                              color: AppTheme.warmBrown,
                            ),
                            children: [
                              const Text(
                                'Fresh bread marketplace app. Order your favorite bread with ease!',
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Logout Button
                      Card(
                        color: AppTheme.errorRed.withOpacity(0.1),
                        child: InkWell(
                          onTap: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Logout'),
                                content: const Text(
                                  'Are you sure you want to logout?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: const Text(
                                      'Logout',
                                      style: TextStyle(
                                        color: AppTheme.errorRed,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true && context.mounted) {
                              // Clear cart before logout
                              final cartProvider = Provider.of<CartProvider>(
                                context,
                                listen: false,
                              );
                              cartProvider.reset();
                              
                              await authService.signOut();
                              if (context.mounted) {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (_) => const LoginScreen(),
                                  ),
                                  (route) => false,
                                );
                              }
                            }
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: const Padding(
                            padding: EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.logout,
                                  color: AppTheme.errorRed,
                                ),
                                SizedBox(width: 16),
                                Text(
                                  'Logout',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.errorRed,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                color: AppTheme.warmBrown,
                size: 28,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.warmBrown,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.darkGray,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppTheme.darkGray,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
