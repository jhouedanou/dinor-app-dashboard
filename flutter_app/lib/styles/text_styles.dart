import 'package:flutter/material.dart';

/// Styles de texte uniformes pour garantir la cohérence sur toutes les plateformes
class AppTextStyles {
  // Police uniforme - Roboto partout, avec fallbacks appropriés
  static const String _fontFamily = 'Roboto';
  
  // Fallbacks pour compatibilité cross-platform
  static const List<String> _fontFallbacks = [
    'Roboto',
    'Helvetica',
    'Arial', 
    'sans-serif'
  ];

  // Styles de base avec police uniforme
  static const TextStyle heading1 = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFallbacks,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: Color(0xFF2D3748),
    height: 1.3,
    decoration: TextDecoration.none,
  );

  static const TextStyle heading2 = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFallbacks,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: Color(0xFF2D3748),
    height: 1.3,
    decoration: TextDecoration.none,
  );

  static const TextStyle heading3 = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFallbacks,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Color(0xFF2D3748),
    height: 1.3,
    decoration: TextDecoration.none,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFallbacks,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Color(0xFF4A5568),
    height: 1.5,
    decoration: TextDecoration.none,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFallbacks,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Color(0xFF4A5568),
    height: 1.5,
    decoration: TextDecoration.none,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFallbacks,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Color(0xFF4A5568),
    height: 1.5,
    decoration: TextDecoration.none,
  );

  // Styles spéciaux pour l'AppHeader
  static const TextStyle headerTitle = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFallbacks,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    height: 1.2,
    decoration: TextDecoration.none,
  );

  // Style pour les cartes
  static const TextStyle cardTitle = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFallbacks,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Color(0xFF2D3748),
    height: 1.3,
    decoration: TextDecoration.none,
  );

  static const TextStyle cardDescription = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFallbacks,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Color(0xFF4A5568),
    height: 1.4,
    decoration: TextDecoration.none,
  );

  // Méthode helper pour créer un TextTheme uniforme
  static TextTheme createTextTheme() {
    return const TextTheme(
      displayLarge: heading1,
      displayMedium: heading2,
      displaySmall: heading3,
      headlineLarge: heading1,
      headlineMedium: heading2,
      headlineSmall: heading3,
      titleLarge: heading2,
      titleMedium: heading3,
      titleSmall: bodyLarge,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
      labelLarge: bodyMedium,
      labelMedium: bodySmall,
      labelSmall: bodySmall,
    ).apply(
      fontFamily: _fontFamily,
      fontFamilyFallback: _fontFallbacks,
    );
  }
}