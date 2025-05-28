import 'package:flutter/material.dart';
import 'package:api_test/widgets/app_navigation_bar.dart';

class AccountView extends StatelessWidget {
  const AccountView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5), 
      body: Column(
        children: [
          const AppNavigationBar(),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: _buildFormCard(context),
            ),
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
            const Text(
              'Skapa ett konto',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Skriv in dina uppgifter för att skapa ett konto.',
              style: TextStyle(fontSize: 14),
            ),
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
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3A2C4B),
              ),
              child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Text(
                'Skapa konto',
                style: TextStyle(
                  color: Color(0xFFFFF0F5), 
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
  Widget _buildPersonalInfoColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        TextField(decoration: InputDecoration(labelText: 'Förnamn')),
        SizedBox(height: 12),
        TextField(decoration: InputDecoration(labelText: 'Efternamn')),
        SizedBox(height: 12),
        TextField(decoration: InputDecoration(labelText: 'E-postadress')),
        SizedBox(height: 12),
        TextField(decoration: InputDecoration(labelText: 'Lösenord')),
      ],
    );
  }

  Widget _buildPaymentInfoColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        TextField(decoration: InputDecoration(labelText: 'Adress')),
        SizedBox(height: 12),
        TextField(decoration: InputDecoration(labelText: 'Kortnummer')),
        SizedBox(height: 12),
        TextField(decoration: InputDecoration(labelText: 'CCV')),
        SizedBox(height: 12),
        TextField(decoration: InputDecoration(labelText: 'Utgångsdatum')),
      ],
    );
  }
  void _showAccount(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AccountView()),
    );
  }
}