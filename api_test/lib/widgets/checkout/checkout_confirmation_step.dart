import 'package:api_test/app_theme.dart';
// import 'package:api_test/pages/history_view.dart'; // Not directly used for navigation here
import 'package:api_test/pages/main_view.dart'; // Used for navigation
import 'package:flutter/material.dart';
import 'package:api_test/model/imat/order.dart'; // Import Order

class CheckoutConfirmationStep extends StatelessWidget {
  final Order placedOrder; // Added: to receive the placed order
  final VoidCallback? onContinueShopping;
  final VoidCallback? onViewOrders;
  
  const CheckoutConfirmationStep({
    super.key,
    required this.placedOrder, // Made placedOrder required
    this.onContinueShopping,
    this.onViewOrders,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: AppTheme.headerGreen,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 30,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success animation container
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 50,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Success title
              const Text(
                'Tack för din beställning!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryPurple,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              
              // Order confirmation message
              Text(
                'Din order har mottagits och behandlas nu. Du kommer få en bekräftelse via e-post inom kort.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.primaryPurple,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              // Order details card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPurple.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          color: AppTheme.primaryPurple,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Ordernummer',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryPurple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          // '#${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}', // Old client-side generation
                          '#${placedOrder.orderNumber}', // Use orderNumber from the placedOrder object
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryPurple,
                            letterSpacing: 1,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Copy to clipboard
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryPurple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.copy,
                                  size: 14,
                                  color: AppTheme.primaryPurple,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Kopiera',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.primaryPurple,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Information cards
              _buildInfoCard(
                'Leverans',
                'Du får en bekräftelse när din order är på väg',
                Icons.local_shipping_outlined,
                AppTheme.primaryPurple,
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                'Support',
                'Kontakta oss om du har frågor om din beställning',
                Icons.support_agent_outlined,
                AppTheme.primaryPurple,
              ),
              const SizedBox(height: 32),
              
              // Action buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onContinueShopping ?? () => Navigator.popUntil(context, (route) => route.isFirst), // Go to main view
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Fortsätt handla',
                        style: AppTheme.headingMedium.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: onViewOrders ?? () => Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MainView(initialTabIndex: 2, expandHistoryOrders: true) // Navigate to MainView, history tab, expand orders
                            ),
                            (Route<dynamic> route) => false, // Remove all previous routes
                          ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.primaryPurple),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        // 'Mina beställningar', // Old text
                        'Mina ordrar', // New text
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryPurple,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String description, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryPurple,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.primaryPurple,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
