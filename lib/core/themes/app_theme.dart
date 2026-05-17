import 'package:flutter/material.dart';

class AppTheme {
  // Primary Color: #4F46B8 (Indigo)
  // Secondary Color: #7C3AED (Purple)

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF4F46B8),
      secondary: const Color(0xFF7C3AED),
      brightness: Brightness.light,
    ),
    fontFamily: 'Inter', // Fallback to system font
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF4F46B8),
      secondary: const Color(0xFF7C3AED),
      brightness: Brightness.dark,
    ),
    fontFamily: 'Inter',
  );
}
