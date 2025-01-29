import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get purpleTheme {
    return ThemeData(
      primaryColor: Colors.purple.shade300,
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.purple,
      ).copyWith(
        secondary: Colors.deepPurpleAccent.shade400,
      ),
      scaffoldBackgroundColor: Colors.purple.shade50,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.purple.shade300,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple.shade300,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textTheme: TextTheme(
        headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.purple),
        headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.purple),
        headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.purple),
        bodyMedium: TextStyle(fontSize: 18, color: Colors.purple.shade900),
        bodyLarge: TextStyle(fontSize: 24, color: Colors.purple.shade900),
        bodySmall: TextStyle(fontSize: 14, color: Colors.purple.shade900),
      ),
    );
  }
}