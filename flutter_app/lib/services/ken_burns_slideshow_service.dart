import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class KenBurnsSlideshowService {
  /// Images par défaut pour le diaporama
  static const List<String> _defaultImages = [
    'assets/images/01.jpg',
    'assets/images/02.jpg',
    'assets/images/03.jpg',
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
  final List<KenBurnsAnimation> _animations = [];
  
  @override
  void initState() {
    super.initState();
    
    print('🎬 [KenBurnsSlideshow] Initialisation du diaporama avec ${widget.images.length} images');
    print('🎬 [KenBurnsSlideshow] Durée totale: ${widget.totalDuration.inMilliseconds}ms');
    
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
      
      print('🧡 [KenBurnsSlideshow] Image ${i + 1}: ${widget.images[i]} - Scale: ${startScale.toStringAsFixed(2)} → ${endScale.toStringAsFixed(2)}');
      
      _animations.add(KenBurnsAnimation(
        startScale: startScale,
        endScale: endScale,
        startOffset: Offset(startX, startY),
        endOffset: Offset(endX, endY),
      ));
    }
  }
  
  void _startSlideshow() {
    print('🎬 [KenBurnsSlideshow] Démarrage du diaporama');
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
    final imageName = widget.images[nextIndex].split('/').last;
    print('🧡 [KenBurnsSlideshow] 🖼️ Changement vers image ${nextIndex + 1}/${widget.images.length}: $imageName');
    print('🧡 [KenBurnsSlideshow] Ancien index: $_currentImageIndex -> Nouveau index: $nextIndex');
    print('🧡 [KenBurnsSlideshow] Chemin complet image: ${widget.images[nextIndex]}');
    
    setState(() {
      _currentImageIndex = nextIndex;
    });
    
    // Redémarrer l'animation Ken Burns pour la nouvelle image
    _kenBurnsController.reset();
    _kenBurnsController.forward();
    
    print('🧡 [KenBurnsSlideshow] ✨ Animation Ken Burns redémarrée pour $imageName');
    print('🧡 [KenBurnsSlideshow] setState appelé, index actuel confirmé: $_currentImageIndex');
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
    // Utiliser IndexedStack pour forcer le changement d'images
    return IndexedStack(
      index: _currentImageIndex,
      children: widget.images.map((imagePath) {
        final currentIndex = widget.images.indexOf(imagePath);
        final animation = _animations[currentIndex];
        
        return AnimatedBuilder(
          animation: _kenBurnsController,
          builder: (context, child) {
            // N'animer que l'image actuellement visible
            if (currentIndex != _currentImageIndex) {
              return Container(); // Image invisible
            }
            
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
            
            print('🧡 [KenBurnsSlideshow] 🎭 Affichage image: $currentIndex, Path: $imagePath');
            
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
                      image: AssetImage(imagePath),
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Overlay léger pour la lisibilité
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.1),
                          Colors.black.withValues(alpha: 0.2),
                          Colors.black.withValues(alpha: 0.1),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
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