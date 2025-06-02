import 'package:api_test/app_theme.dart';
import 'package:api_test/model/imat/order.dart'; // Import Order model
import 'package:api_test/pages/login_view.dart'; // Add import for LoginView
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
  bool isGuestCheckout = false; // Track if user is checking out as guest

  final List<String> stepTitles = [
    'Kundvagn',
    'Leverans', 
    'Betalning',
    'Översikt',
    'Bekräftelse'
  ];
  
  // Method to check if user is logged in and show dialog if not
  Future<bool> _checkLoginForDelivery() async {
    final imatDataHandler = Provider.of<ImatDataHandler>(context, listen: false);
    
    if (!imatDataHandler.isLoggedIn) {
      // User is not logged in, show dialog
      String? result = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: AppTheme.headerGreen, // Changed background to primary green
            title: const Text('Logga in för att fortsätta'),
            content: const Text('Du behöver logga in för att fortsätta med din beställning eller handla som gäst.'),
            actions: <Widget>[
              TextButton(
                child: const Text('Avbryt'),
                onPressed: () {
                  Navigator.of(context).pop('cancel'); // Don't continue
                },
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.background,
                  foregroundColor: AppTheme.primaryPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: const Text(
                  'Handla som gäst',
                  style: TextStyle(
                    fontSize: 16, 
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop('guest'); // Continue as guest
                },
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: const Text(
                  'Logga in',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop('login'); // Continue to login
                },
              ),
            ],
          );
        },
      );

      // Based on the dialog result
      if (result == 'login') {
        if (mounted) {
          // Navigate to login page
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const LoginView(),
            ),
          );
          
          // Check if now logged in after returning from login page
          return imatDataHandler.isLoggedIn;
        }
      } else if (result == 'guest') {
        // Proceed as guest
        setState(() {
          isGuestCheckout = true; // Mark as guest checkout
        });
        return true;
      }
      return false; // Don't proceed if dialog was dismissed or canceled
    }
    
    return true; // Already logged in, proceed
  }
  
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
          onNext: () async {
            // Check login before proceeding to delivery step
            bool canProceed = await _checkLoginForDelivery();
            if (canProceed && mounted) {
              setState(() {
                currentStep = 1;
              });
            }
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
          isGuest: isGuestCheckout,
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
          onNext: () async {
            // Check login before proceeding to delivery step
            bool canProceed = await _checkLoginForDelivery();
            if (canProceed && mounted) {
              setState(() {
                currentStep = 1;
              });
            }
          },
        );
    }
  }
}
