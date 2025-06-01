import 'package:api_test/app_theme.dart';
import 'package:api_test/model/imat/order.dart'; // Import Order model
import 'package:api_test/widgets/app_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:api_test/model/imat_data_handler.dart';
import 'package:api_test/widgets/checkout/checkout_cart_step.dart';
import 'package:api_test/widgets/checkout/checkout_delivery_step.dart';
import 'package:api_test/widgets/checkout/checkout_payment_step.dart';
import 'package:api_test/widgets/checkout/checkout_overview_step.dart';
import 'package:api_test/widgets/checkout/checkout_confirmation_step.dart';
import 'package:api_test/widgets/checkout/checkout_step_indicator.dart';

class CheckoutFlow extends StatefulWidget {
  const CheckoutFlow({super.key});

  @override
  State<CheckoutFlow> createState() => _CheckoutFlowState();
}

class _CheckoutFlowState extends State<CheckoutFlow> {
  int currentStep = 0;
  String selectedDeliveryMethod = 'Hemleverans';
  String selectedPaymentMethod = 'Kortbetalning';
  bool acceptTerms = false;
  Order? _placedOrder; // Add state variable for the placed order

  final List<String> stepTitles = [
    'Kundvagn',
    'Leverans', 
    'Betalning',
    'Översikt',
    'Bekräftelse'
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            AppNavigationBar(showSearchBar: false,),
            if (currentStep < 4) CheckoutStepIndicator(
              currentStep: currentStep,
              stepTitles: stepTitles,
            ),
            Expanded(
              child: _buildCurrentStep(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (currentStep) {
      case 0:
        return CheckoutCartStep(
          onNext: () {
            setState(() {
              currentStep = 1;
            });
          },
        );
      case 1:
        return CheckoutDeliveryStep(
          selectedDeliveryMethod: selectedDeliveryMethod,
          onDeliveryMethodChanged: (method) {
            setState(() {
              selectedDeliveryMethod = method;
            });
          },
          onNext: () {
            setState(() {
              currentStep = 2;
            });
          },
          onBack: () {
            setState(() {
              currentStep = 0;
            });
          },
        );
      case 2:
        return CheckoutPaymentStep(
          selectedPaymentMethod: selectedPaymentMethod,
          onPaymentMethodChanged: (method) {
            setState(() {
              selectedPaymentMethod = method;
            });
          },
          onNext: () {
            setState(() {
              currentStep = 3;
            });
          },
          onBack: () {
            setState(() {
              currentStep = 1;
            });
          },
        );
      case 3:
        return CheckoutOverviewStep(
          selectedDeliveryMethod: selectedDeliveryMethod,
          selectedPaymentMethod: selectedPaymentMethod,
          acceptTerms: acceptTerms,
          onTermsChanged: (value) {
            setState(() {
              acceptTerms = value;
            });
          },
          onPlaceOrder: () async {
            // Place the order
            final newOrder = await context.read<ImatDataHandler>().placeOrder(); // Call and get the order
            print("CheckoutFlow: placeOrder returned orderNumber: ${newOrder?.orderNumber}"); // Added log
            if (mounted) { // Added mounted check
              setState(() {
                _placedOrder = newOrder; // Store the placed order
                currentStep = 4;
              });
            }
          },
          onBack: () {
            setState(() {
              currentStep = 2;
            });
          },
        );
      case 4:
        // return CheckoutConfirmationStep( // Old call
        //   onContinueShopping: () => Navigator.pop(context),
        //   onViewOrders: () => Navigator.pop(context),
        // );
        if (_placedOrder != null) {
          return CheckoutConfirmationStep(
            placedOrder: _placedOrder!, // Pass the placed order
            onContinueShopping: () => Navigator.popUntil(context, (route) => route.isFirst), // Go to main view
            // onViewOrders will use its default navigation to MainView with history tab
          );
        } else {
          // If _placedOrder is null, show a loading indicator or an error message.
          // This case should ideally not be reached if placeOrder is successful and returns an order.
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Väntar på orderbekräftelse..."),
              ],
            ),
          );
        }
      default:
        return CheckoutCartStep(
          onNext: () {
            setState(() {
              currentStep = 1;
            });
          },
        );
    }
  }
}
