import 'package:api_test/model/imat/order.dart';
import 'package:api_test/model/imat_data_handler.dart';
import 'package:api_test/pages/login_view.dart';
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
            final iMat = Provider.of<ImatDataHandler>(context, listen: false);
            
            // Check if user is logged in
            if (!iMat.isLoggedIn) {
              // User is not logged in, redirect to login page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginView(
                    redirectTo: '/checkout',
                  ),
                ),
              ).then((value) {
                // After login/signup check if the user is now logged in
                if (iMat.isLoggedIn) {
                  // Proceed to delivery step
                  setState(() {
                    currentStep = 1;
                  });
                } else {
                  // User canceled login/signup, stay on cart step
                  // Optionally show a message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Du måste logga in för att fortsätta till leveransinformation.'),
                      backgroundColor: AppTheme.primaryPurple,
                    ),
                  );
                }
              });
            } else {
              // User is already logged in, proceed to delivery step
              setState(() {
                currentStep = 1;
              });
            }
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
    // Get the user's customer information if they're logged in
    final iMat = Provider.of<ImatDataHandler>(context);
    final customer = iMat.getCustomer();
    final bool isGuestMode = !iMat.isLoggedIn;
    
    // Controllers for guest information form
    final firstNameController = TextEditingController(text: isGuestMode ? '' : customer.firstName);
    final lastNameController = TextEditingController(text: isGuestMode ? '' : customer.lastName);
    final phoneController = TextEditingController(text: isGuestMode ? '' : customer.phoneNumber);
    final mobilePhoneController = TextEditingController(text: isGuestMode ? '' : customer.mobilePhoneNumber);
    final emailController = TextEditingController(text: isGuestMode ? '' : customer.email);
    final addressController = TextEditingController(text: isGuestMode ? '' : customer.address);
    final postCodeController = TextEditingController(text: isGuestMode ? '' : customer.postCode);
    final postAddressController = TextEditingController(text: isGuestMode ? '' : customer.postAddress);

    return SingleChildScrollView(
      child: Center(
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
              'Leverans',
              style: AppTheme.headingMedium.copyWith(color: AppTheme.textPrimary),
            ),
            if (isGuestMode) 
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.headerGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: AppTheme.primaryPurple),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Du handlar som gäst. Vänligen fyll i alla uppgifter nedan.',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 32),
            // Show the customer's information
            Container(
              width: 500,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Leveransuppgifter',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // If guest mode, show editable form fields
                  if (isGuestMode) ... [
                    _buildInputField('Förnamn', firstNameController),
                    _buildInputField('Efternamn', lastNameController),
                    _buildInputField('Telefon', phoneController),
                    _buildInputField('Mobiltelefon', mobilePhoneController),
                    _buildInputField('E-post', emailController, keyboardType: TextInputType.emailAddress),
                    _buildInputField('Adress', addressController),
                    _buildInputField('Postnummer', postCodeController),
                    _buildInputField('Ort', postAddressController),
                  ] 
                  // If logged in, show read-only fields
                  else ... [
                    _buildInfoRow('Namn', '${customer.firstName} ${customer.lastName}'),
                    _buildInfoRow('Telefon', customer.phoneNumber),
                    _buildInfoRow('Mobiltelefon', customer.mobilePhoneNumber),
                    _buildInfoRow('E-post', customer.email),
                    _buildInfoRow('Adress', customer.address),
                    _buildInfoRow('Postnummer', customer.postCode),
                    _buildInfoRow('Ort', customer.postAddress),
                    const SizedBox(height: 16),
                    // Add an edit button for logged in users
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () {
                          // Navigate to account settings or delivery edit page
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Redigera adressuppgifter kommer snart'),
                              backgroundColor: AppTheme.primaryPurple,
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Redigera'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.primaryPurple,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
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
                    // Validate guest fields if in guest mode
                    if (isGuestMode) {
                      if (firstNameController.text.isEmpty ||
                          lastNameController.text.isEmpty ||
                          emailController.text.isEmpty ||
                          addressController.text.isEmpty ||
                          postCodeController.text.isEmpty ||
                          postAddressController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Vänligen fyll i alla obligatoriska fält'),
                            backgroundColor: AppTheme.primaryPurple,
                          ),
                        );
                        return;
                      }
                      
                      // Store guest information for later use in checkout
                      // This is a simplified example - in a real app, you would store this data
                      // in your state management solution
                      iMat.setGuestInformation(
                        firstName: firstNameController.text,
                        lastName: lastNameController.text,
                        phoneNumber: phoneController.text,
                        mobilePhoneNumber: mobilePhoneController.text,
                        email: emailController.text,
                        address: addressController.text,
                        postCode: postCodeController.text,
                        postAddress: postAddressController.text,
                      );
                    }
                    
                    setState(() {
                      currentStep = 2;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPurple,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Fortsätt'),
                ),
              ],
            ),
            const SizedBox(height: 32), // Add space at bottom for scrolling
          ],
        ),
      ),
    );
  }
  
  Widget _buildInputField(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }
  
  // The method is already defined in the file, but maybe it's defined after it's used.
  // Moving it to an earlier position in the class.
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
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
                onPressed: () async {
                  // Show loading indicator
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                  
                  // Place order
                  final iMat = Provider.of<ImatDataHandler>(context, listen: false);
                  final newOrder = await iMat.placeOrder();
                  
                  if (!mounted) return;
                  // Dismiss loading dialog
                  Navigator.pop(context);
                  
                  if (newOrder != null) {
                    setState(() {
                      _placedOrder = newOrder;
                      currentStep = 3;
                    });
                  } else {
                    // Show error
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Kunde inte slutföra ordern. Försök igen.'),
                        backgroundColor: AppTheme.primaryPurple,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPurple,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Bekräfta köp'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
