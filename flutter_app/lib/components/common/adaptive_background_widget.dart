import 'package:flutter/material.dart';
import '../../services/adaptive_background_service.dart';

/// Widget pour afficher des backgrounds adaptatifs avec transitions fluides
class AdaptiveBackgroundWidget extends StatefulWidget {
  final AdaptiveBackgroundService.ContentType contentType;
  final Widget child;
  final Duration transitionDuration;
  final bool enableParticles;
  final bool enableGradient;
  final double intensity; // Intensité de l'effet (0.0 à 1.0)

  const AdaptiveBackgroundWidget({
    super.key,
    required this.contentType,
    required this.child,
    this.transitionDuration = const Duration(milliseconds: 800),
    this.enableParticles = true,
    this.enableGradient = true,
    this.intensity = 1.0,
  });

  @override
  State<AdaptiveBackgroundWidget> createState() => _AdaptiveBackgroundWidgetState();
}

class _AdaptiveBackgroundWidgetState extends State<AdaptiveBackgroundWidget>
    with TickerProviderStateMixin {
  
  late AnimationController _backgroundController;
  late AnimationController _particlesController;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _particlesAnimation;
  
  AdaptiveBackgroundService.ContentType? _previousContentType;

  @override
  void initState() {
    super.initState();
    
    // Contrôleur pour l'animation du background
    _backgroundController = AnimationController(
      duration: widget.transitionDuration,
      vsync: this,
    );
    
    // Contrôleur pour l'animation des particules
    _particlesController = AnimationController(
      duration: Duration(milliseconds: (widget.transitionDuration.inMilliseconds * 1.5).round()),
      vsync: this,
    );
    
    // Animations avec courbes personnalisées
    _backgroundAnimation = CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOutCubic,
    );
    
    _particlesAnimation = CurvedAnimation(
      parent: _particlesController,
      curve: Curves.elasticOut,
    );
    
    // Démarrer l'animation initiale
    _backgroundController.forward();
    _particlesController.forward();
  }

  @override
  void didUpdateWidget(AdaptiveBackgroundWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Détecter les changements de type de contenu
    if (oldWidget.contentType != widget.contentType) {
      _previousContentType = oldWidget.contentType;
      _animateTransition();
    }
  }

  void _animateTransition() {
    print('🎨 [AdaptiveBackground] Transition: $_previousContentType → ${widget.contentType}');
    
    // Réinitialiser et relancer les animations
    _backgroundController.reset();
    _particlesController.reset();
    
    // Animation en cascade pour un effet plus fluide
    _backgroundController.forward();
    
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _particlesController.forward();
      }
    });
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _particlesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_backgroundAnimation, _particlesAnimation]),
      builder: (context, child) {
        return _buildAnimatedBackground();
      },
    );
  }

  Widget _buildAnimatedBackground() {
    final theme = AdaptiveBackgroundService.getTheme(widget.contentType);
    
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          // Background principal avec animation
          AnimatedBuilder(
            animation: _backgroundAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: 0.95 + (0.05 * _backgroundAnimation.value * widget.intensity),
                child: Container(
                  decoration: widget.enableGradient ? BoxDecoration(
                    gradient: LinearGradient(
                      colors: theme.gradientColors.map((color) => 
                        Color.lerp(Colors.grey.shade300, color, _backgroundAnimation.value * widget.intensity) ?? color
                      ).toList(),
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ) : null,
                ),
              );
            },
          ),
          
          // Couche de particules animées
          if (widget.enableParticles)
            AnimatedBuilder(
              animation: _particlesAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _particlesAnimation.value * widget.intensity * 0.8,
                  child: Transform.scale(
                    scale: _particlesAnimation.value,
                    child: _buildThematicParticles(theme),
                  ),
                );
              },
            ),
          
          // Overlay avec transition d'opacité
          AnimatedBuilder(
            animation: _backgroundAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(
                    alpha: theme.overlayOpacity * _backgroundAnimation.value * widget.intensity,
                  ),
                ),
              );
            },
          ),
          
          // Contenu principal
          widget.child,
        ],
      ),
    );
  }

  Widget _buildThematicParticles(BackgroundTheme theme) {
    return AdaptiveBackgroundService.buildAdaptiveBackground(
      contentType: widget.contentType,
      enableGradient: false, // On gère déjà le gradient
      enableParticles: true,
    );
  }
}

/// Widget simplifié pour les sections de contenu
class SectionBackground extends StatelessWidget {
  final AdaptiveBackgroundService.ContentType contentType;
  final Widget child;
  final bool reduced; // Version réduite pour les cartes

  const SectionBackground({
    super.key,
    required this.contentType,
    required this.child,
    this.reduced = false,
  });

  @override
  Widget build(BuildContext context) {
    if (reduced) {
      // Version simplifiée pour les cartes
      final theme = AdaptiveBackgroundService.getTheme(contentType);
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.primaryColor.withValues(alpha: 0.1),
              theme.secondaryColor.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: child,
      );
    }
    
    return AdaptiveBackgroundWidget(
      contentType: contentType,
      intensity: 0.7, // Intensité réduite pour ne pas surcharger
      child: child,
    );
  }
}
