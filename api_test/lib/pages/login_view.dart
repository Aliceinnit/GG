import 'package:api_test/model/imat/user.dart';
import 'package:api_test/pages/account_view.dart';
import 'package:api_test/widgets/app_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/imat_data_handler.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
            child: SingleChildScrollView(
              child: _buildLoginCard(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginCard(BuildContext context) {
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
              'Logga in',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Ange din e-postadress och lösenord för att logga in.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),
            _buildLoginFields(),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _handleLogin(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3A2C4B),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Text(
                  'Logga in',
                  style: TextStyle(
                    color: Color(0xFFFFF0F5),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AccountView()),
                );
              },
              child: const Text(
                'Inte medlem än? Skapa konto här.',
                style: TextStyle(color: Color(0xFF3A2C4B)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(labelText: 'E-postadress'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _passwordController,
          decoration: const InputDecoration(labelText: 'Lösenord'),
          obscureText: true,
        ),
      ],
    );
  }

  Future<void> _handleLogin(BuildContext context) async {
    final user = User(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    final iMat = Provider.of<ImatDataHandler>(context, listen: false);
    iMat.setUser(user);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Inloggad som ${user.userName}")),
    );

    Navigator.pop(context);
  }
}