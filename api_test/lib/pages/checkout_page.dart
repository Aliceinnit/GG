import 'package:api_test/model/imat/order.dart';
import 'package:api_test/model/imat_data_handler.dart';
import 'package:api_test/pages/main_view.dart';
import 'package:api_test/widgets/checkout/checkout_confirmation_step.dart';
import 'package:flutter/material.dart';
import 'package:api_test/widgets/checkout_wizard.dart';
import 'package:api_test/widgets/checkout_cart_summary.dart';
import 'package:api_test/app_theme.dart';
import 'package:provider/provider.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  int currentStep = 0;
  Order? _placedOrder; // To store the newly placed order

  final List<String> stepTitles = [
    'Varukorg',
    'Leverans',
    'Betalning',
    'Bekräftelse'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppTheme.headerGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Checkout',
          style: AppTheme.headingLarge.copyWith(color: AppTheme.textPrimary),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Checkout wizard
          Container(
            color: AppTheme.headerGreen,
            child: CheckoutWizard(currentStep: currentStep),
          ),
          
          // Content area
          Expanded(
            child: _buildCurrentStep(),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (currentStep) {
      case 0:
        return CheckoutCartSummary(
          onNext: () {
            setState(() {
              currentStep = 1;
            });
          },
        );
      case 1:
        return _buildDeliveryStep();
      case 2:
        return _buildPaymentStep();
      case 3:
        // return _buildConfirmationStep(); // Original call
        if (_placedOrder != null) {
          return CheckoutConfirmationStep(
            placedOrder: _placedOrder!,
            onContinueShopping: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            // onViewOrders is handled by the CheckoutConfirmationStep's default if null
          );
        } else {
          // Show loading or error if order isn't placed yet, or if something went wrong
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Behandlar beställning..."),
              ],
            ),
          );
        }
      default:
        return CheckoutCartSummary(
          onNext: () {
            setState(() {
              currentStep = 1;
            });
          },
        );
    }
  }

  Widget _buildDeliveryStep() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.local_shipping_outlined,
            size: 64,
            color: AppTheme.primaryPurple,
          ),
          const SizedBox(height: 16),
          Text(
            'Leverans - Kommer snart',
            style: AppTheme.headingMedium.copyWith(color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    currentStep = 0;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: AppTheme.textPrimary,
                ),
                child: const Text('Tillbaka'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    currentStep = 2;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPurple,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Nästa'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStep() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.payment_outlined,
            size: 64,
            color: AppTheme.primaryPurple,
          ),
          const SizedBox(height: 16),
          Text(
            'Betalning - Kommer snart',
            style: AppTheme.headingMedium.copyWith(color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    currentStep = 1;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: AppTheme.textPrimary,
                ),
                child: const Text('Tillbaka'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () async { // Make onPressed async
                  final iMat = Provider.of<ImatDataHandler>(context, listen: false);
                  Order? newOrder = await iMat.placeOrder(); // Call placeOrder

                  if (newOrder != null) {
                    setState(() {
                      _placedOrder = newOrder;
                      currentStep = 3; // Move to confirmation
                    });
                  } else {
                    // Handle error: order placement failed or no order data returned
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Kunde inte slutföra beställningen. Försök igen.')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPurple,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Nästa'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationStep() {
    // This method is now effectively replaced by the logic in _buildCurrentStep for case 3,
    // which directly uses CheckoutConfirmationStep with the _placedOrder.
    // Keeping it for structure but it won't be directly called if _placedOrder logic is primary.
    if (_placedOrder != null) {
      return CheckoutConfirmationStep(
        placedOrder: _placedOrder!,
        onContinueShopping: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        // onViewOrders is handled by CheckoutConfirmationStep's default
      );
    }
    // Fallback if somehow called directly without _placedOrder being set (should not happen with current logic)
    return const Center(
      child: Text("Väntar på orderbekräftelse..."),
    );
  }
}
