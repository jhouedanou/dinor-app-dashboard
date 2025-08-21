import 'package:flutter/material.dart';

/// Service pour gérer les backgrounds adaptatifs selon le contenu
class AdaptiveBackgroundService {
  /// Types de contenu supportés
  enum ContentType {
    events,
    recipes, 
    tips,
    videos,
    home,
  }

  /// Configuration d'un thème de background
  static const Map<ContentType, BackgroundTheme> _themes = {
    ContentType.home: BackgroundTheme(
      primaryColor: Color(0xFFE53E3E),
      secondaryColor: Color(0xFFC53030),
      accentColor: Color(0xFFFF6B6B),
      gradientColors: [Color(0xFFE53E3E), Color(0xFFC53030), Color(0xFFE53E3E)],
      overlayOpacity: 0.15,
      description: 'Thème d\'accueil chaleureux',
    ),
    ContentType.events: BackgroundTheme(
      primaryColor: Color(0xFF2B6CB0),
      secondaryColor: Color(0xFF1A365D),
      accentColor: Color(0xFF4299E1),
      gradientColors: [Color(0xFF2B6CB0), Color(0xFF1A365D), Color(0xFF2B6CB0)],
      overlayOpacity: 0.12,
      description: 'Thème événements sportifs',
    ),
    ContentType.recipes: BackgroundTheme(
      primaryColor: Color(0xFF38A169),
      secondaryColor: Color(0xFF1A202C),
      accentColor: Color(0xFF68D391),
      gradientColors: [Color(0xFF38A169), Color(0xFF1A202C), Color(0xFF38A169)],
      overlayOpacity: 0.18,
      description: 'Thème recettes naturel',
    ),
    ContentType.tips: BackgroundTheme(
      primaryColor: Color(0xFFD69E2E),
      secondaryColor: Color(0xFF744210),
      accentColor: Color(0xFFF6E05E),
      gradientColors: [Color(0xFFD69E2E), Color(0xFF744210), Color(0xFFD69E2E)],
      overlayOpacity: 0.14,
      description: 'Thème astuces énergisant',
    ),
    ContentType.videos: BackgroundTheme(
      primaryColor: Color(0xFF805AD5),
      secondaryColor: Color(0xFF44337A),
      accentColor: Color(0xFFB794F6),
      gradientColors: [Color(0xFF805AD5), Color(0xFF44337A), Color(0xFF805AD5)],
      overlayOpacity: 0.16,
      description: 'Thème vidéos créatif',
    ),
  };

  /// Obtenir le thème pour un type de contenu
  static BackgroundTheme getTheme(ContentType contentType) {
    return _themes[contentType] ?? _themes[ContentType.home]!;
  }

  /// Construire un background animé adaptatif
  static Widget buildAdaptiveBackground({
    required ContentType contentType,
    Widget? child,
    Duration transitionDuration = const Duration(milliseconds: 800),
    bool enableParticles = true,
    bool enableGradient = true,
  }) {
    final theme = getTheme(contentType);
    
    return AnimatedContainer(
      duration: transitionDuration,
      curve: Curves.easeInOut,
      decoration: enableGradient ? BoxDecoration(
        gradient: LinearGradient(
          colors: theme.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.5, 1.0],
        ),
      ) : null,
      child: Stack(
        children: [
          // Particules flottantes selon le thème
          if (enableParticles) _buildParticleLayer(theme, contentType),
          
          // Overlay de couleur
          Container(
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: theme.overlayOpacity),
            ),
          ),
          
          // Contenu principal
          if (child != null) child,
        ],
      ),
    );
  }

  /// Construire la couche de particules thématiques
  static Widget _buildParticleLayer(BackgroundTheme theme, ContentType contentType) {
    switch (contentType) {
      case ContentType.events:
        return _buildSportsParticles(theme);
      case ContentType.recipes:
        return _buildCookingParticles(theme);
      case ContentType.tips:
        return _buildEnergyParticles(theme);
      case ContentType.videos:
        return _buildMediaParticles(theme);
      case ContentType.home:
      default:
        return _buildHomeParticles(theme);
    }
  }

  /// Particules pour le thème d'accueil
  static Widget _buildHomeParticles(BackgroundTheme theme) {
    return Stack(
      children: List.generate(8, (index) {
        return Positioned(
          left: (index * 50.0) % 300,
          top: (index * 80.0) % 500,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 2000 + (index * 200)),
            curve: Curves.easeInOut,
            width: 20 + (index % 3) * 10,
            height: 20 + (index % 3) * 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.accentColor.withValues(alpha: 0.2),
              boxShadow: [
                BoxShadow(
                  color: theme.accentColor.withValues(alpha: 0.1),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  /// Particules pour le thème événements sportifs
  static Widget _buildSportsParticles(BackgroundTheme theme) {
    return Stack(
      children: List.generate(6, (index) {
        return Positioned(
          left: (index * 70.0) % 350,
          top: (index * 90.0) % 600,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 1500 + (index * 300)),
            curve: Curves.easeInOut,
            width: 25 + (index % 4) * 8,
            height: 25 + (index % 4) * 8,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(8),
              color: theme.accentColor.withValues(alpha: 0.15),
              border: Border.all(
                color: theme.accentColor.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
          ),
        );
      }),
    );
  }

  /// Particules pour le thème recettes
  static Widget _buildCookingParticles(BackgroundTheme theme) {
    return Stack(
      children: List.generate(10, (index) {
        return Positioned(
          left: (index * 40.0) % 280,
          top: (index * 60.0) % 450,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 2500 + (index * 150)),
            curve: Curves.easeInOut,
            width: 15 + (index % 5) * 6,
            height: 15 + (index % 5) * 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.accentColor.withValues(alpha: 0.25),
              gradient: RadialGradient(
                colors: [
                  theme.accentColor.withValues(alpha: 0.3),
                  theme.accentColor.withValues(alpha: 0.1),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  /// Particules pour le thème astuces
  static Widget _buildEnergyParticles(BackgroundTheme theme) {
    return Stack(
      children: List.generate(12, (index) {
        return Positioned(
          left: (index * 35.0) % 320,
          top: (index * 55.0) % 480,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 1200 + (index * 100)),
            curve: Curves.bounceInOut,
            width: 12 + (index % 3) * 8,
            height: 12 + (index % 3) * 8,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(4),
              color: theme.accentColor.withValues(alpha: 0.2),
              boxShadow: [
                BoxShadow(
                  color: theme.accentColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  /// Particules pour le thème vidéos
  static Widget _buildMediaParticles(BackgroundTheme theme) {
    return Stack(
      children: List.generate(7, (index) {
        return Positioned(
          left: (index * 60.0) % 340,
          top: (index * 85.0) % 520,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 1800 + (index * 250)),
            curve: Curves.elasticInOut,
            width: 30 + (index % 4) * 10,
            height: 18 + (index % 4) * 6,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(12),
              color: theme.accentColor.withValues(alpha: 0.18),
              border: Border.all(
                color: theme.accentColor.withValues(alpha: 0.4),
                width: 2,
              ),
            ),
          ),
        );
      }),
    );
  }
}

/// Configuration d'un thème de background
class BackgroundTheme {
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final List<Color> gradientColors;
  final double overlayOpacity;
  final String description;

  const BackgroundTheme({
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.gradientColors,
    required this.overlayOpacity,
    required this.description,
  });
}
