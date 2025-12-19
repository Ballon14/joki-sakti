import 'package:flutter/material.dart';
import '../../config/theme.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.warmBeige,
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Contact Section
          const Text(
            'Contact Us',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.warmBrown,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildContactCard(
            icon: Icons.email_outlined,
            title: 'Email',
            subtitle: 'support@rotiku.com',
            onTap: () {
              // TODO: Open email app
            },
          ),
          _buildContactCard(
            icon: Icons.phone_outlined,
            title: 'Phone',
            subtitle: '+62 812-3456-7890',
            onTap: () {
              // TODO: Open phone dialer
            },
          ),
          _buildContactCard(
            icon: Icons.chat_outlined,
            title: 'WhatsApp',
            subtitle: 'Chat with us',
            onTap: () {
              // TODO: Open WhatsApp
            },
          ),

          const SizedBox(height: 32),

          // FAQs Section
          const Text(
            'Frequently Asked Questions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.warmBrown,
            ),
          ),
          const SizedBox(height: 16),

          _buildFAQItem(
            question: 'How do I place an order?',
            answer:
                'Browse products, add items to cart, then proceed to checkout and enter your delivery address.',
          ),
          _buildFAQItem(
            question: 'What payment methods are available?',
            answer:
                'We accept Cash on Delivery (COD) and Bank Transfer.',
          ),
          _buildFAQItem(
            question: 'How long is the delivery time?',
            answer:
                'Delivery typically takes 1-2 hours within the city area.',
          ),
          _buildFAQItem(
            question: 'Can I cancel my order?',
            answer:
                'You can cancel your order before it\'s processed. Please contact our support team.',
          ),
          _buildFAQItem(
            question: 'How do I track my order?',
            answer:
                'Go to the Orders tab to see your order history and current status.',
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard({
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
              Icon(icon, color: AppTheme.warmBrown, size: 32),
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
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.darkGray,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppTheme.darkGray),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQItem({
    required String question,
    required String answer,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            question,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                answer,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.darkGray,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
