import 'package:api_test/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:api_test/model/imat_data_handler.dart';

class CheckoutDeliveryStep extends StatefulWidget {
  final String selectedDeliveryMethod;
  final Function(String) onDeliveryMethodChanged;
  final VoidCallback? onNext;
  final VoidCallback? onBack;
  
  const CheckoutDeliveryStep({
    super.key,
    required this.selectedDeliveryMethod,
    required this.onDeliveryMethodChanged,
    this.onNext,
    this.onBack,
  });

  @override
  State<CheckoutDeliveryStep> createState() => _CheckoutDeliveryStepState();
}

class _CheckoutDeliveryStepState extends State<CheckoutDeliveryStep> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  String _selectedTimeSlot = '';

  @override
  void initState() {
    super.initState();    // Pre-fill address from customer data if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final iMat = Provider.of<ImatDataHandler>(context, listen: false);
      final customer = iMat.getCustomer();
      _addressController.text = customer.address;
      _postalCodeController.text = customer.postCode;
      _cityController.text = customer.postAddress;
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    _postalCodeController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.headerGreen,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'Leveransadress & Tidpunkt',
                      style: AppTheme.headingLarge,
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          _buildAddressInput(),
                          const SizedBox(height: 24),
                          _buildDeliveryTimeSlots(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildNavigationButtons(),
        ],
      ),
    );
  }
  Widget _buildAddressInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.headerGreen,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.background),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 20,
                color: AppTheme.primaryPurple,
              ),
              const SizedBox(width: 8),
              const Text(
                'Leveransadress',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _addressController,
            decoration: InputDecoration(
              labelText: 'Gatuadress',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppTheme.primaryPurple),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppTheme.primaryPurple),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: TextField(
                  controller: _postalCodeController,
                  decoration: InputDecoration(
                    labelText: 'Postnummer',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppTheme.primaryPurple),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppTheme.primaryPurple),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _cityController,
                  decoration: InputDecoration(
                    labelText: 'Stad',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppTheme.primaryPurple),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppTheme.primaryPurple),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryTimeSlots() {
    final timeSlots = [
      '09:00 - 12:00',
      '12:00 - 15:00',
      '15:00 - 18:00',
      '18:00 - 21:00',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.headerGreen,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.background),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.schedule_outlined,
                size: 20,
                color: AppTheme.primaryPurple,
              ),
              const SizedBox(width: 8),
              const Text(
                'Välj leveranstid',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: timeSlots.map((timeSlot) {
              bool isSelected = _selectedTimeSlot == timeSlot;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTimeSlot = timeSlot;
                      widget.onDeliveryMethodChanged('Hemleverans - $timeSlot');
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryPurple.withOpacity(0.1) : AppTheme.background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? AppTheme.primaryPurple : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: isSelected ? AppTheme.primaryPurple: Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          timeSlot,
                          style: TextStyle(
                            fontSize: 18, // Increased from 14 to 18
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? AppTheme.primaryPurple : Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: AppTheme.primaryPurple,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  Widget _buildNavigationButtons() {
    bool isAddressValid = _addressController.text.isNotEmpty && 
                          _postalCodeController.text.isNotEmpty && 
                          _cityController.text.isNotEmpty;
    bool isTimeSlotSelected = _selectedTimeSlot.isNotEmpty;
    bool canProceed = isAddressValid && isTimeSlotSelected;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: widget.onBack,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.primaryPurple),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Tillbaka',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryPurple,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: canProceed ? widget.onNext : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                disabledBackgroundColor: Color.fromARGB(255, 201, 184, 227),
              ),
              child: const Text(
                'Fortsätt till betalning',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
