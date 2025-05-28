import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:api_test/app_theme.dart';
import 'package:api_test/model/imat_data_handler.dart';
import 'package:api_test/model/imat/shopping_item.dart';
import 'package:api_test/model/imat/customer.dart';
import 'package:api_test/model/imat/credit_card.dart';

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
      backgroundColor: const Color(0xFFFCEEF4),
      body: Column(
        children: [
          const SizedBox(height: AppTheme.paddingLarge),
          _buildHeader(),
          const SizedBox(height: AppTheme.paddingMedium),
          _buildStepIndicator(),
          const SizedBox(height: AppTheme.paddingMedium),
          Expanded(
            child: _buildCurrentStep(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingMedium),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Text(
              "iMat",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.deepPurple),
            ),
          ),
          Text(
            stepTitles[currentStep],
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.paddingMedium),
      child: Row(
        children: List.generate(stepTitles.length, (index) {
          bool isActive = index == currentStep;
          bool isCompleted = index < currentStep;
          
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isActive ? Colors.deepPurple : isCompleted ? Colors.green : Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isCompleted ? Icons.check : Icons.circle,
                      color: isActive || isCompleted ? Colors.white : Colors.grey[600],
                      size: 16,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stepTitles[index],
                      style: TextStyle(
                        color: isActive || isCompleted ? Colors.white : Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
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
        return _buildCartStep();
      case 1:
        return _buildDeliveryStep();
      case 2:
        return _buildPaymentStep();
      case 3:
        return _buildOverviewStep();
      case 4:
        return _buildConfirmationStep();
      default:
        return _buildCartStep();
    }
  }

  Widget _buildCartStep() {
    return Consumer<ImatDataHandler>(
      builder: (context, iMat, child) {
        var items = iMat.getShoppingCart().items;
        
        if (items.isEmpty) {
          return _buildEmptyCart();
        }

        return Container(
          margin: const EdgeInsets.all(AppTheme.paddingMedium),
          padding: const EdgeInsets.all(AppTheme.paddingMedium),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Din kundvagn',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppTheme.paddingMedium),
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return _buildCartItem(items[index], iMat);
                  },
                ),
              ),
              const Divider(),
              _buildCartTotal(iMat),
              const SizedBox(height: AppTheme.paddingMedium),
              _buildNavigationButtons(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          Text(
            'Din kundvagn är tom',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppTheme.paddingSmall),
          Text(
            'Lägg till produkter för att fortsätta',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: AppTheme.paddingLarge),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Tillbaka till shopping'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(ShoppingItem item, ImatDataHandler iMat) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.paddingSmall),
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF7F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.shopping_bag, color: Colors.grey),
          ),
          const SizedBox(width: AppTheme.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  '${item.product.price.toStringAsFixed(2)} kr/${item.product.unit}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  if (item.amount > 1) {
                    iMat.shoppingCartUpdate(item, delta: -1);
                  } else {
                    iMat.shoppingCartRemove(item);
                  }
                },
                icon: const Icon(Icons.remove_circle_outline),
                color: Colors.deepPurple,
              ),
              Text(
                item.amount.toStringAsFixed(0),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              IconButton(
                onPressed: () {
                  iMat.shoppingCartUpdate(item, delta: 1);
                },
                icon: const Icon(Icons.add_circle_outline),
                color: Colors.deepPurple,
              ),
            ],
          ),
          Text(
            '${(item.product.price * item.amount).toStringAsFixed(2)} kr',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildCartTotal(ImatDataHandler iMat) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Totalt:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          '${iMat.shoppingCartTotal().toStringAsFixed(2)} kr',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildDeliveryStep() {
    return Container(
      margin: const EdgeInsets.all(AppTheme.paddingMedium),
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Leveransalternativ',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          Expanded(
            child: Column(
              children: [
                _buildDeliveryOption(
                  'Hemleverans',
                  'Leverans till din adress',
                  '49 kr',
                  Icons.home_outlined,
                ),
                _buildDeliveryOption(
                  'Hämta i butik',
                  'Hämta dina varor i närmaste butik',
                  'Gratis',
                  Icons.store_outlined,
                ),
                _buildDeliveryOption(
                  'Paketombud',
                  'Hämta på närmaste paketombud',
                  '29 kr',
                  Icons.local_shipping_outlined,
                ),
                const SizedBox(height: AppTheme.paddingLarge),
                Consumer<ImatDataHandler>(
                  builder: (context, iMat, child) {
                    return _buildCustomerInfo(iMat.getCustomer());
                  },
                ),
              ],
            ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildDeliveryOption(String title, String description, String price, IconData icon) {
    bool isSelected = selectedDeliveryMethod == title;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDeliveryMethod = title;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.paddingSmall),
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple.withOpacity(0.1) : const Color(0xFFFAF7F9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.deepPurple : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.deepPurple : Colors.grey[600],
              size: 32,
            ),
            const SizedBox(width: AppTheme.paddingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.deepPurple : Colors.black,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              price,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.deepPurple : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfo(Customer customer) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF7F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Leveransadress',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppTheme.paddingSmall),
          Text('${customer.firstName} ${customer.lastName}'),
          Text(customer.address),
          Text('${customer.postCode} ${customer.postAddress}'),
          Text(customer.phoneNumber),
        ],
      ),
    );
  }

  Widget _buildPaymentStep() {
    return Container(
      margin: const EdgeInsets.all(AppTheme.paddingMedium),
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Betalningsmetod',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          Expanded(
            child: Column(
              children: [
                _buildPaymentOption(
                  'Kortbetalning',
                  'Betala med kort',
                  Icons.credit_card,
                ),
                _buildPaymentOption(
                  'Swish',
                  'Betala med Swish',
                  Icons.phone_android,
                ),
                _buildPaymentOption(
                  'Faktura',
                  'Betala efter leverans',
                  Icons.receipt_long,
                ),
                const SizedBox(height: AppTheme.paddingLarge),
                if (selectedPaymentMethod == 'Kortbetalning')
                  Consumer<ImatDataHandler>(
                    builder: (context, iMat, child) {
                      return _buildCreditCardInfo(iMat.getCreditCard());
                    },
                  ),
              ],
            ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String title, String description, IconData icon) {
    bool isSelected = selectedPaymentMethod == title;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPaymentMethod = title;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.paddingSmall),
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple.withOpacity(0.1) : const Color(0xFFFAF7F9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.deepPurple : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.deepPurple : Colors.grey[600],
              size: 32,
            ),
            const SizedBox(width: AppTheme.paddingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.deepPurple : Colors.black,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditCardInfo(CreditCard creditCard) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF7F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kortinformation',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppTheme.paddingSmall),
          Text('${creditCard.cardType}'),
          Text('**** **** **** ${creditCard.cardNumber.substring(creditCard.cardNumber.length - 4)}'),
          Text('${creditCard.validMonth}/${creditCard.validYear}'),
          Text(creditCard.holdersName),
        ],
      ),
    );
  }

  Widget _buildOverviewStep() {
    return Consumer<ImatDataHandler>(
      builder: (context, iMat, child) {
        var items = iMat.getShoppingCart().items;
        double deliveryFee = selectedDeliveryMethod == 'Hämta i butik' ? 0.0 : 
                           selectedDeliveryMethod == 'Paketombud' ? 29.0 : 49.0;
        double total = iMat.shoppingCartTotal() + deliveryFee;

        return Container(
          margin: const EdgeInsets.all(AppTheme.paddingMedium),
          padding: const EdgeInsets.all(AppTheme.paddingMedium),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Översikt av din beställning',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppTheme.paddingMedium),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Order items
                      const Text(
                        'Dina varor',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: AppTheme.paddingSmall),
                      ...items.map((item) => Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text('${item.product.name} x ${item.amount.toStringAsFixed(0)}'),
                            ),
                            Text('${(item.product.price * item.amount).toStringAsFixed(2)} kr'),
                          ],
                        ),
                      )).toList(),
                      
                      const Divider(),
                      
                      // Delivery
                      const Text(
                        'Leverans',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: AppTheme.paddingSmall),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(selectedDeliveryMethod),
                          Text('${deliveryFee.toStringAsFixed(2)} kr'),
                        ],
                      ),
                      
                      const Divider(),
                      
                      // Payment
                      const Text(
                        'Betalning',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: AppTheme.paddingSmall),
                      Text(selectedPaymentMethod),
                      
                      const Divider(),
                      
                      // Total
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Totalt att betala:',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${total.toStringAsFixed(2)} kr',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: AppTheme.paddingMedium),
                      
                      // Terms and conditions
                      Row(
                        children: [
                          Checkbox(
                            value: acceptTerms,
                            onChanged: (value) {
                              setState(() {
                                acceptTerms = value ?? false;
                              });
                            },
                            activeColor: Colors.deepPurple,
                          ),
                          const Expanded(
                            child: Text(
                              'Jag accepterar villkoren för köpet',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              _buildNavigationButtons(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildConfirmationStep() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(AppTheme.paddingMedium),
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 80,
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            const Text(
              'Tack för din beställning!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.paddingSmall),
            const Text(
              'Din order har mottagits och behandlas nu.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            Text(
              'Du kommer få en bekräftelse via e-post inom kort.',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.paddingLarge),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.deepPurple),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Fortsätt handla',
                    style: TextStyle(color: Colors.deepPurple),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to order history or my account
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Mina beställningar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (currentStep > 0)
          OutlinedButton(
            onPressed: () {
              setState(() {
                currentStep--;
              });
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.deepPurple),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Tillbaka',
              style: TextStyle(color: Colors.deepPurple),
            ),
          )
        else
          const SizedBox(),
        
        if (currentStep < stepTitles.length - 1)
          ElevatedButton(
            onPressed: _canProceed() ? () {
              setState(() {
                currentStep++;
              });
            } : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(currentStep == stepTitles.length - 2 ? 'Slutför köp' : 'Fortsätt'),
          )
        else if (currentStep == stepTitles.length - 2) // Overview step
          Consumer<ImatDataHandler>(
            builder: (context, iMat, child) {
              return ElevatedButton(
                onPressed: acceptTerms ? () async {
                  iMat.placeOrder();
                  setState(() {
                    currentStep++;
                  });
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Slutför köp'),
              );
            },
          ),
      ],
    );
  }

  bool _canProceed() {
    switch (currentStep) {
      case 0: // Cart step
        return context.read<ImatDataHandler>().getShoppingCart().items.isNotEmpty;
      case 1: // Delivery step
        return selectedDeliveryMethod.isNotEmpty;
      case 2: // Payment step
        return selectedPaymentMethod.isNotEmpty;
      case 3: // Overview step
        return acceptTerms;
      default:
        return true;
    }
  }
}
