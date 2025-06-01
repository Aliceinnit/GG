import 'package:api_test/model/imat/credit_card.dart';
import 'package:api_test/model/imat/customer.dart';
import 'package:api_test/model/imat_data_handler.dart';
import 'package:api_test/pages/login_view.dart';
import 'package:api_test/pages/main_view.dart';
import 'package:flutter/material.dart';
import 'package:api_test/widgets/app_navigation_bar.dart';
import 'package:provider/provider.dart';

class AccountView extends StatefulWidget {
  const AccountView({super.key});

  @override
  State<AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView> {
  // Personuppgifter
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _phoneNumber = TextEditingController();
  final _mobilePhoneNumber = TextEditingController();
  final _address = TextEditingController();
  final _postCode = TextEditingController();
  final _postAddress = TextEditingController();

  // Kortuppgifter
  final _cardType = TextEditingController();
  final _holdersName = TextEditingController();
  final _cardNumber = TextEditingController();
  final _validMonth = TextEditingController();
  final _validYear = TextEditingController();
  final _verificationCode = TextEditingController();

  @override
  void dispose() {
    // Glöm inte att rensa alla controllers
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _password.dispose();
    _phoneNumber.dispose();
    _mobilePhoneNumber.dispose();
    _address.dispose();
    _postCode.dispose();
    _postAddress.dispose();
    _cardType.dispose();
    _holdersName.dispose();
    _validMonth.dispose();
    _validYear.dispose();
    _cardNumber.dispose();
    _verificationCode.dispose();
    super.dispose();
  }

  void _createAccount(BuildContext context) async {
    final handler = Provider.of<ImatDataHandler>(context, listen: false);

    final customer = Customer(
      _firstName.text,
      _lastName.text,
      _email.text,
      _phoneNumber.text,
      _mobilePhoneNumber.text,
      _address.text,
      _postCode.text,
      _postAddress.text);

    final card = CreditCard(
      _cardType.text,
      _holdersName.text,
      int.parse(_validMonth.text),
      int.parse(_validYear.text),
      _cardNumber.text,
      int.parse(_verificationCode.text));

    handler.setCustomer(customer);
    handler.setCreditCard(card);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Konto skapat!')),
    );

    Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const MainView()),
                  (route) => false,
                );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      body: Column(
        children: [
          const AppNavigationBar(showSearchBar: false),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(child: _buildFormCard(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        width: 600,
        decoration: BoxDecoration(
          color: const Color(0xffd2ebd8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            const Text('Skapa ett konto',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Skriv in dina uppgifter för att skapa ett konto.'),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildPersonalInfoColumn()),
                const SizedBox(width: 16),
                Expanded(child: _buildPaymentInfoColumn()),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _createAccount(context),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3A2C4B)),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Text('Skapa konto',
                    style: TextStyle(
                        color: Color(0xFFFFF0F5), fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginView()),
                );
              },
              child: const Text(
                'Har du redan ett konto? Logga in här.',
                style: TextStyle(color: Color(0xFF3A2C4B)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(controller: _firstName, decoration: const InputDecoration(labelText: 'Förnamn')),
        const SizedBox(height: 12),
        TextField(controller: _lastName, decoration: const InputDecoration(labelText: 'Efternamn')),
        const SizedBox(height: 12),
        TextField(controller: _email, decoration: const InputDecoration(labelText: 'E-postadress')),
        const SizedBox(height: 12),
        TextField(controller: _password, decoration: const InputDecoration(labelText: 'Lösenord'), obscureText: true),
        const SizedBox(height: 12),
        TextField(controller: _phoneNumber, decoration: const InputDecoration(labelText: 'Telefon')),
        const SizedBox(height: 12),
        TextField(controller: _mobilePhoneNumber, decoration: const InputDecoration(labelText: 'Mobil')),
        const SizedBox(height: 12),
        TextField(controller: _address, decoration: const InputDecoration(labelText: 'Adress')),
        const SizedBox(height: 12),
        TextField(controller: _postCode, decoration: const InputDecoration(labelText: 'Postnummer')),
        const SizedBox(height: 12),
        TextField(controller: _postAddress, decoration: const InputDecoration(labelText: 'Postort')),
      ],
    );
  }

  Widget _buildPaymentInfoColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(controller: _cardType, decoration: const InputDecoration(labelText: 'Korttyp')),
        const SizedBox(height: 12),
        TextField(controller: _holdersName, decoration: const InputDecoration(labelText: 'Kortinnehavare')),
        const SizedBox(height: 12),
        TextField(controller: _cardNumber, decoration: const InputDecoration(labelText: 'Kortnummer')),
        const SizedBox(height: 12),
        TextField(controller: _validMonth, decoration: const InputDecoration(labelText: 'Giltig månad')),
        const SizedBox(height: 12),
        TextField(controller: _validYear, decoration: const InputDecoration(labelText: 'Giltigt år')),
        const SizedBox(height: 12),
        TextField(controller: _verificationCode, decoration: const InputDecoration(labelText: 'CCV'), obscureText: true),
      ],
    );
  }
}