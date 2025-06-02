import 'package:api_test/pages/login_view.dart';
import 'package:flutter/material.dart';
import 'package:api_test/app_theme.dart';
import 'package:api_test/pages/favorites_view.dart';
import 'package:api_test/pages/history_view.dart';
import 'package:api_test/main.dart'; // Import main.dart to access navigatorKey
import 'package:provider/provider.dart'; // Add this import
import 'package:api_test/model/imat_data_handler.dart'; // Add this import

class AccountSidebar extends StatelessWidget {
  final VoidCallback onClose;
  final Animation<Offset> slideAnimation;

  const AccountSidebar({
    super.key,
    required this.onClose,
    required this.slideAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final imatDataHandler = Provider.of<ImatDataHandler>(context); // Access ImatDataHandler

    return Positioned(
      top: 64,
      right: 0,
      child: SlideTransition(
        position: slideAnimation,
        child: Container(
          width: 350,
          height: MediaQuery.of(context).size.height - 64,
          decoration: BoxDecoration(
            color: AppTheme.headerGreen,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(-5, 0),
              ),
              BoxShadow(
                color: AppTheme.primaryPurple.withOpacity(0.1),
                blurRadius: 30,
                offset: const Offset(-10, 0),
              ),
            ],
            border: Border.all(
              color: AppTheme.primaryPurple.withOpacity(0.1),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(AppTheme.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Mina sidor', style: AppTheme.headingMedium),
                  GestureDetector(
                    onTap: onClose,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryPurple,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.paddingMedium),
              // Account content
              Expanded(
                child: Column(
                  children: [
                    if (imatDataHandler.isLoggedIn)
                      _buildMenuItem(
                        icon: Icons.logout,
                        title: 'Logga ut',
                        onTap: () {
                          imatDataHandler.logout();
                          onClose(); // Close the sidebar
                          ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
                            SnackBar(
                              content: Text('Du har loggats ut.'),
                              backgroundColor: AppTheme.primaryPurple,
                            ),
                          );
                        },
                      )
                    else
                      _buildMenuItem(
                        icon: Icons.login,
                        title: 'Logga in',
                        onTap: () {
                          if (navigatorKey.currentState == null) {
                            print('navigatorKey.currentState is NULL in AccountSidebar for Logga in');
                            return;
                          }
                          navigatorKey.currentState!.push(
                            MaterialPageRoute(builder: (context) => const LoginView()),
                          );
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            onClose();
                          });
                        },
                      ),
                    _buildMenuItem(
                      icon: Icons.favorite,
                      title: 'Favoriter',
                      onTap: () {
                        if (navigatorKey.currentState == null) {
                          print('navigatorKey.currentState is NULL in AccountSidebar for Favoriter');
                          return;
                        }
                        navigatorKey.currentState!.push(
                          MaterialPageRoute(builder: (context) => const FavoritesView()),
                        );
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          onClose();
                        });
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.format_list_bulleted,
                      title: 'Mina inköp',
                      onTap: () {
                        if (navigatorKey.currentState == null) {
                          print('navigatorKey.currentState is NULL in AccountSidebar for Mina inköp');
                          return;
                        }
                        navigatorKey.currentState!.push(
                          MaterialPageRoute(builder: (context) => const HistoryView()),
                        );
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          onClose();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryPurple,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
