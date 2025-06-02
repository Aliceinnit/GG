import 'package:flutter/material.dart';

class AppTheme {
  static const double paddingTiny = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingMediumSmall = 12.0;
  static const double paddingMedium = 18.0;
  static const double paddingLarge = 28.0;
  static const double paddingHuge = 32.0;

  static const Color primaryPurple = Color(0xFF3E2A5E);
  static const Color headerGreen = Color(0xFFD2EBD8);
  static const Color buttonText = Color.fromRGBO(255, 255, 255, 1);
  static const Color background = Color(0xFFFAE8ED);
  
  static const Color textPrimary = Color(0xFF3E2A5E);
  static const Color textSecondary = Color(0xFF666666);
  static const Color border = Color(0xFFE0E0E0);
  static const Color error = Color(0xFFE53E3E);
  static const Color success = Color(0xFF38A169);

  static ColorScheme colorScheme = ColorScheme.fromSeed(
    seedColor: primaryPurple,
    primary: primaryPurple,
    surface: Color(0xFFD2EBD8),
    background: Color(0xFFD2EBD8),
  );

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

  static const TextStyle headingLarge = TextStyle(
    fontSize: 28.0,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.w600,
    color: Color(0xFF3E2A5E),
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 20.0,
    color: textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 18.0,
    color: textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 16.0,
    color: textSecondary,
  );

  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    color: buttonText,
  );
}
