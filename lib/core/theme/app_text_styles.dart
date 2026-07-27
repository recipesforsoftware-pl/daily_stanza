import 'package:flutter/material.dart';

class AppTextStyles {
  AppTextStyles._();

  // Display/poem — Literata serif
  static const String _serif = 'Literata';
  // UI — Plus Jakarta Sans
  static const String _sans = 'PlusJakartaSans';

  // Display sizes (Literata)
  static const TextStyle displayLarge = TextStyle(
    fontFamily: _serif,
    fontSize: 36,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: -0.5,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: _serif,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: -0.3,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: _serif,
    fontSize: 22,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );

  // Poem body — Literata, generous line height
  static const TextStyle poemBody = TextStyle(
    fontFamily: _serif,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.75,
  );

  static const TextStyle poemTitle = TextStyle(
    fontFamily: _serif,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle poemAuthor = TextStyle(
    fontFamily: _serif,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
    height: 1.5,
  );

  // UI sizes (Plus Jakarta Sans)
  static const TextStyle headlineSmall = TextStyle(
    fontFamily: _sans,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: _sans,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _sans,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _sans,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: _sans,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle labelLarge = TextStyle(
    fontFamily: _sans,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: _sans,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );
}
