import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class KenBurnsSlideshowService {
  /// Images par défaut pour le diaporama
  static const List<String> _defaultImages = [
    'assets/images/pexels-rethaferguson-3622643.jpg',
    'assets/images/pexels-picha-6210449.jpg',
    'assets/images/pexels-saizstudio-17952746.jpg',
  ];
  
  /// Durée par image (3 secondes)
  static const Duration _imageDuration = Duration(seconds: 3);
  
  /// Durée de transition entre les images
  static const Duration _transitionDuration = Duration(milliseconds: 800);
}

/// Widget diaporama Ken Burns animé
class KenBurnsSlideshowWidget extends StatefulWidget {
  final Duration totalDuration;
  final List<String> images;
  
  const KenBurnsSlideshowWidget({
    super.key,
    required this.totalDuration,
    this.images = KenBurnsSlideshowService._defaultImages,
  });
  
  @override
  State<KenBurnsSlideshowWidget> createState() => _KenBurnsSlideshowWidgetState();
}

class _KenBurnsSlideshowWidgetState extends State<KenBurnsSlideshowWidget>
    with TickerProviderStateMixin {
  
  late PageController _pageController;
  late AnimationController _kenBurnsController;
  late AnimationController _fadeController;
  late Timer _timer;
  
  int _currentImageIndex = 0;
  List<KenBurnsAnimation> _animations = [];
  
  @override
  void initState() {
    super.initState();
    
    _pageController = PageController();
    
    // Animation Ken Burns pour chaque image (3 secondes)
    _kenBurnsController = AnimationController(
      duration: KenBurnsSlideshowService._imageDuration,
      vsync: this,
    );
    
    // Animation de fondu entre les images
    _fadeController = AnimationController(
      duration: KenBurnsSlideshowService._transitionDuration,
      vsync: this,
    );
    
    // Créer les animations Ken Burns pour chaque image
    _initializeAnimations();
    
    // Démarrer le diaporama
    _startSlideshow();
  }
  
  void _initializeAnimations() {
    final random = math.Random();
    
    for (int i = 0; i < widget.images.length; i++) {
      // Générer des paramètres aléatoires pour chaque image
      final startScale = 1.0 + random.nextDouble() * 0.3; // 1.0 - 1.3
      final endScale = startScale + 0.2 + random.nextDouble() * 0.3; // +0.2 à +0.5
      
      final startX = -0.1 + random.nextDouble() * 0.2; // -0.1 à 0.1
      final endX = -0.1 + random.nextDouble() * 0.2;
      
      final startY = -0.1 + random.nextDouble() * 0.2; // -0.1 à 0.1
      final endY = -0.1 + random.nextDouble() * 0.2;
      
      _animations.add(KenBurnsAnimation(
        startScale: startScale,
        endScale: endScale,
        startOffset: Offset(startX, startY),
        endOffset: Offset(endX, endY),
      ));
    }
  }
  
  void _startSlideshow() {
    _kenBurnsController.forward();
    
    // Timer pour changer d'image toutes les 3 secondes
    _timer = Timer.periodic(KenBurnsSlideshowService._imageDuration, (timer) {
      if (mounted) {
        _nextImage();
      } else {
        timer.cancel();
      }
    });
  }
  
  void _nextImage() {
    if (!mounted) return;
    
    final nextIndex = (_currentImageIndex + 1) % widget.images.length;
    
    setState(() {
      _currentImageIndex = nextIndex;
    });
    
    // Redémarrer l'animation Ken Burns pour la nouvelle image
    _kenBurnsController.reset();
    _kenBurnsController.forward();
  }
  
  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    _kenBurnsController.dispose();
    _fadeController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Image actuelle avec animation Ken Burns
        AnimatedBuilder(
          animation: _kenBurnsController,
          builder: (context, child) {
            final animation = _animations[_currentImageIndex];
            
            final scale = Tween<double>(
              begin: animation.startScale,
              end: animation.endScale,
            ).animate(CurvedAnimation(
              parent: _kenBurnsController,
              curve: Curves.easeInOut,
            )).value;
            
            final offset = Tween<Offset>(
              begin: animation.startOffset,
              end: animation.endOffset,
            ).animate(CurvedAnimation(
              parent: _kenBurnsController,
              curve: Curves.easeInOut,
            )).value;
            
            return Transform.scale(
              scale: scale,
              child: Transform.translate(
                offset: Offset(
                  offset.dx * MediaQuery.of(context).size.width * 0.1,
                  offset.dy * MediaQuery.of(context).size.height * 0.1,
                ),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(widget.images[_currentImageIndex]),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        
        // Overlay sombre pour améliorer la lisibilité du contenu
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.1),
                Colors.black.withValues(alpha: 0.3),
                Colors.black.withValues(alpha: 0.1),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
      ],
    );
  }
}

/// Classe pour définir les paramètres d'animation Ken Burns
class KenBurnsAnimation {
  final double startScale;
  final double endScale;
  final Offset startOffset;
  final Offset endOffset;
  
  const KenBurnsAnimation({
    required this.startScale,
    required this.endScale,
    required this.startOffset,
    required this.endOffset,
  });
}