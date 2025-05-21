import 'package:api_test/model/imat/customer.dart';
import 'package:api_test/model/imat_data_handler.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Simple widget to edit card information.
// It's probably better to use Form
class CustomerDetails extends StatefulWidget {
  const CustomerDetails({super.key});

  @override
  State<CustomerDetails> createState() => _CustomerDetailsState();
}

class _CustomerDetailsState extends State<CustomerDetails> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _mobileNumberController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;
  late final TextEditingController _postCodeController;
  late final TextEditingController _postAddressController;
  late final ImatDataHandler _imatDataHandler;

  @override
  void initState() {
    super.initState();

    _imatDataHandler = Provider.of<ImatDataHandler>(context, listen: false);
    Customer customer = _imatDataHandler.getCustomer();

    _firstNameController = TextEditingController(text: customer.firstName);
    _lastNameController = TextEditingController(text: customer.lastName);
    _mobileNumberController = TextEditingController(
      text: customer.mobilePhoneNumber,
    );
    _emailController = TextEditingController(text: customer.email);
    _addressController = TextEditingController(text: customer.address);
    _postCodeController = TextEditingController(text: customer.postCode);
    _postAddressController = TextEditingController(text: customer.postAddress);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _firstNameController,
          decoration: InputDecoration(labelText: 'Förnamn'),
        ),
        TextField(
          controller: _lastNameController,
          decoration: InputDecoration(labelText: 'Efternamn'),
        ),
        TextField(
          controller: _mobileNumberController,
          decoration: InputDecoration(labelText: 'Mobilnummer'),
        ),
        TextField(
          controller: _emailController,
          decoration: InputDecoration(labelText: 'E-post'),
        ),
        TextField(
          controller: _addressController,
          decoration: InputDecoration(labelText: 'Adress'),
        ),
        TextField(
          controller: _postCodeController,
          decoration: InputDecoration(labelText: 'Postnummer'),
        ),
        TextField(
          controller: _postAddressController,
          decoration: InputDecoration(labelText: 'Ort'),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(onPressed: _saveCustomer, child: Text('Spara')),
          ],
        ),
      ],
    );
  }

  _saveCustomer() {
    //var iMat = Provider.of<ImatDataHandler>(context, listen: false);
    Customer customer = _imatDataHandler.getCustomer();

    customer.firstName = _firstNameController.text;
    customer.lastName = _lastNameController.text;
    customer.mobilePhoneNumber = _mobileNumberController.text;
    customer.email = _emailController.text;
    customer.address = _addressController.text;
    customer.postCode = _postCodeController.text;
    customer.postAddress = _postAddressController.text;

    // This is needed to trigger updates to the server
    _imatDataHandler.setCustomer(customer);
  }
}
