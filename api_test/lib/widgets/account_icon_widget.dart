import 'package:flutter/material.dart';
import 'package:api_test/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:api_test/widgets/account_overlay_provider.dart';

class AccountIconWidget extends StatelessWidget {
  final bool showNotificationBadge;
  final int notificationCount;
  final bool isHovered;

  const AccountIconWidget({
    super.key,
    this.showNotificationBadge = false,
    this.notificationCount = 0,
    this.isHovered = false,
  });

  @override
  Widget build(BuildContext context) {
    final accountProvider = Provider.of<AccountOverlayProvider>(context, listen: false);

    return GestureDetector(
      onTap: () {
        // Always show the account sidebar
        accountProvider.showAccount();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingSmall, vertical: 1), // Reduced horizontal padding
        decoration: isHovered
            ? BoxDecoration(
                color: Colors.grey.withOpacity(0.15),
                borderRadius: BorderRadius.circular(30.0),
              )
            : null,
        child: Column( // Changed from Stack to Column for simpler layout
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center, // Center items vertically
          children: [
            Stack( // Stack for icon and badge
              alignment: Alignment.topRight,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4), // Add some padding to push icon down for badge
                  child: Icon(
                    Icons.person,
                    color: AppTheme.primaryPurple,
                    size: 36, // Reduced from 38
                  ),
                ),
                if (showNotificationBadge && notificationCount > 0)
                  Container(
                    padding: const EdgeInsets.all(3), 
                    decoration: BoxDecoration(
                      color: Colors.red, 
                      shape: BoxShape.circle, 
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18, // Reduced from 19
                      minHeight: 18, // Reduced from 19
                    ),
                    child: Text(
                      notificationCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11, // Reduced from 12
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
            // const SizedBox(height: 1), 
            Text(
              'Mina sidor', // Changed text to "Mina sidor"
              style: TextStyle(
                color: AppTheme.primaryPurple,
                fontSize: 14, // Reduced from 16
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis, 
            ),
          ],
        ),
      ),
    );
  }
}
