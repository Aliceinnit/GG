import 'package:api_test/model/imat/user.dart';
import 'package:api_test/pages/account_view.dart';
import 'package:api_test/widgets/app_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/imat_data_handler.dart';
import 'package:api_test/app_theme.dart';

class LoginView extends StatefulWidget {
  final String? redirectTo;
  const LoginView({super.key, this.redirectTo});

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
          // Back Button
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 12.0, bottom: 4.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF3E2A5E)),
                label: const Text(
                  'Tillbaka',
                  style: TextStyle(
                    color: Color(0xFF3E2A5E),
                    fontSize: 20.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
          ),
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
          color: AppTheme.headerGreen, // Explicitly set to primary green
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
                backgroundColor: AppTheme.primaryPurple,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Logga in',
                style: TextStyle(
                  color: Colors.white, // Explicitly set to white
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AccountView(redirectTo: widget.redirectTo)),
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
    await iMat.setUser(user); // Ensure setUser completes before proceeding

    // Check if the widget is still mounted before showing SnackBar or navigating
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Inloggad som ${user.userName}"),
        backgroundColor: AppTheme.primaryPurple,
      ),
    );

    // Try to pop to return to the actual previous page first.
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      // If LoginView was the initial route (cannot pop) or if popping is not possible for other reasons,
      // navigate to the home page ('/') as a simple and safe fallback.
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }
  }
}