import 'package:flutter/material.dart';

class AppTheme {
  // Spacing constants
  static const double paddingTiny = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingMediumSmall = 12.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingHuge = 32.0;

  // Color constants
  static const Color primaryPurple = Color(0xFF3E2A5E); // Icons and buttons
  static const Color headerGreen = Color(0xFFD2EBD8);   // Header and widget backgrounds
  static const Color buttonText = Colors.white;          // Text on buttons
  static const Color background = Colors.white;          // Overall background
  
  // Additional common colors
  static const Color textPrimary = Color(0xFF3E2A5E);    // Primary text color
  static const Color textSecondary = Color(0xFF666666);  // Secondary text color
  static const Color border = Color(0xFFE0E0E0);         // Border color
  static const Color error = Color(0xFFE53E3E);          // Error color
  static const Color success = Color(0xFF38A169);        // Success color

  // Color scheme for Material Design
  static ColorScheme colorScheme = ColorScheme.fromSeed(
    seedColor: primaryPurple,
    primary: primaryPurple,
    surface: background,
    background: background,
  );
  // Button styles
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryPurple,
    foregroundColor: buttonText,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: paddingLarge,
      vertical: paddingMedium,
    ),
  );

  // Outlined button style (for secondary actions)
  static ButtonStyle outlinedButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: primaryPurple,
    side: BorderSide(color: primaryPurple, width: 1),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: paddingLarge,
      vertical: paddingMedium,
    ),
  );

  // Text styles
  static const TextStyle headingLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    color: textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    color: textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    color: textSecondary,
  );

  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: buttonText,
  );
}
