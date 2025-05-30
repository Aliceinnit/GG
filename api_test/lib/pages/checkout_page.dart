import 'package:flutter/material.dart';
import 'package:api_test/widgets/checkout_wizard.dart';
import 'package:api_test/widgets/checkout_cart_summary.dart';
import 'package:api_test/app_theme.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  int currentStep = 0;
  
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
        return _buildConfirmationStep();
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
                onPressed: () {
                  setState(() {
                    currentStep = 3;
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

  Widget _buildConfirmationStep() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 64,
            color: AppTheme.primaryPurple,
          ),
          const SizedBox(height: 16),
          Text(
            'Bekräftelse - Kommer snart',
            style: AppTheme.headingMedium.copyWith(color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    currentStep = 2;
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
                  // Complete checkout
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPurple,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Slutför'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
