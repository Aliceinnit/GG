import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:api_test/app_theme.dart';
import 'package:api_test/model/imat_data_handler.dart';
import 'package:api_test/widgets/checkout/checkout_cart_step.dart';
import 'package:api_test/widgets/checkout/checkout_delivery_step.dart';
import 'package:api_test/widgets/checkout/checkout_payment_step.dart';
import 'package:api_test/widgets/checkout/checkout_overview_step.dart';
import 'package:api_test/widgets/checkout/checkout_confirmation_step.dart';

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
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            if (currentStep < 4) _buildStepIndicator(),
            Expanded(
              child: _buildCurrentStep(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              currentStep < stepTitles.length ? stepTitles[currentStep] : '',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.close,
                size: 20,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: List.generate(4, (index) { // Only show 4 steps in indicator
          bool isActive = index == currentStep;
          bool isCompleted = index < currentStep;
          
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
              height: 4,
              decoration: BoxDecoration(
                color: isActive || isCompleted ? Colors.deepPurple : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
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
            context.read<ImatDataHandler>().placeOrder();
            setState(() {
              currentStep = 4;
            });
          },
          onBack: () {
            setState(() {
              currentStep = 2;
            });
          },
        );
      case 4:
        return CheckoutConfirmationStep(
          onContinueShopping: () => Navigator.pop(context),
          onViewOrders: () => Navigator.pop(context),
        );
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
