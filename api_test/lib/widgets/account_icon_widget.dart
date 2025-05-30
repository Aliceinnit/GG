import 'package:flutter/material.dart';
import 'package:api_test/app_theme.dart';

class AccountIconWidget extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool showNotificationBadge;
  final int notificationCount;

  const AccountIconWidget({
    super.key,
    this.onPressed,
    this.showNotificationBadge = false,
    this.notificationCount = 0,
  });
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: onPressed,
              child: Icon(
                Icons.person,
                color: AppTheme.primaryPurple,
                size: 40,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Mina sidor',
              style: TextStyle(
                color: AppTheme.primaryPurple,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        if (showNotificationBadge && notificationCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
              child: Text(
                notificationCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
