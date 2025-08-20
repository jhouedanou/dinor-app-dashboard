/**
 * LOADING_SCREEN.DART - CONVERSION FIDÈLE DE LoadingScreen.vue
 * 
 * FIDÉLITÉ VISUELLE :
 * - Full screen loading identique
 * - Animation 2500ms identique
 * - Logo et texte identiques
 * - Gradient de fond identique
 * - Animation avec bulles et icônes de cuisine
 */

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import 'dart:math' as math;
import '../../services/splash_screen_service.dart';

class LoadingScreen extends StatefulWidget {
  final bool visible;
  final int duration;
  final VoidCallback? onComplete;

  const LoadingScreen({
    Key? key,
    required this.visible,
    this.duration = 2500,
    this.onComplete,
  }) : super(key: key);

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _bubbleController;
  late AnimationController _iconController;
  late AnimationController _kenBurnsController; // Pour l'animation Ken Burns
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _kenBurnsScale; // Zoom Ken Burns
  late Animation<Offset> _kenBurnsPan; // Panoramique Ken Burns
  Timer? _timer;
  
  // Configuration du splash screen depuis l'API
  Map<String, dynamic>? _config;
  bool _configLoaded = false;

  // Icônes de cuisine pour l'animation
  final List<IconData> _cookingIcons = [
    Icons.restaurant,
    Icons.kitchen,
    Icons.local_dining,
    Icons.fastfood,
    Icons.cake,
    Icons.coffee,
    Icons.wine_bar,
    Icons.icecream,
    Icons.egg_alt,
    Icons.set_meal,
  ];

  @override
  void initState() {
    super.initState();

    // Charger la configuration depuis l'API
    _loadConfiguration();
  }

  void _loadConfiguration() async {
    try {
      final config = await SplashScreenService.getActiveConfig();
      setState(() {
        _config = config;
        _configLoaded = true;
      });
      
      // Initialiser les animations avec la configuration chargée
      _initializeAnimations();
      
      if (widget.visible) {
        _startLoading();
      }
    } catch (e) {
      print('❌ [LoadingScreen] Erreur chargement config: $e');
      // Utiliser la configuration par défaut en cas d'erreur
      _configLoaded = true;
      _initializeAnimations();
      if (widget.visible) {
        _startLoading();
      }
    }
  }

  void _initializeAnimations() {
    final duration = _config?['duration'] ?? widget.duration;
    
    // Animations identiques à Vue mais avec durée configurable
    _animationController = AnimationController(
      duration: Duration(milliseconds: duration),
      vsync: this,
    );

    // Animation des bulles
    _bubbleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    // Animation des icônes
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    // Animation Ken Burns (zoom + panoramique lent)
    _kenBurnsController = AnimationController(
      duration: Duration(milliseconds: duration), // Durée complète du splash
      vsync: this,
    );

    // Zoom Ken Burns : de 1.0 à 1.3 (30% d'agrandissement)
    _kenBurnsScale = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _kenBurnsController,
      curve: Curves.easeInOut,
    ));

    // Panoramique Ken Burns : de centre-haut à centre-bas
    _kenBurnsPan = Tween<Offset>(
      begin: const Offset(0, -0.1), // Léger décalage vers le haut
      end: const Offset(0, 0.1),    // Léger décalage vers le bas
    ).animate(CurvedAnimation(
      parent: _kenBurnsController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.8, 1.0, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    if (widget.visible) {
      _startLoading();
    }
  }

  void _startLoading() {
    _animationController.forward();
    
    // Démarrer l'animation Ken Burns
    _kenBurnsController.forward();

    // Timer identique à Vue : 2500ms
    _timer = Timer(Duration(milliseconds: widget.duration), () {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    _bubbleController.dispose();
    _iconController.dispose();
    _kenBurnsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) return const SizedBox.shrink();
    
    // Afficher un splash screen avec couleur par défaut si la config n'est pas encore chargée
    if (!_configLoaded) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE53E3E), Color(0xFFC53030), Color(0xFFE53E3E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Center(
          child: SvgPicture.asset(
            'assets/images/LOGO_DINOR_monochrome.svg',
            colorFilter: const ColorFilter.mode(
              Colors.white,
              BlendMode.srcIn,
            ),
            height: 80,
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: Stack(
              children: [
                // Image de fond avec animation Ken Burns (si applicable)
                _buildAnimatedBackground(),
                
                // Contenu par-dessus
                // Bulles animées en arrière-plan
                ...List.generate(8, (index) => _buildBubble(index)),

                // Icônes de cuisine flottantes
                ...List.generate(6, (index) => _buildFloatingIcon(index)),

                // Contenu principal centré
                Center(
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo Dinor SVG inversé (blanc sur fond rouge)
                        Container(
                          height: 80,
                          child: SvgPicture.asset(
                            'assets/images/LOGO_DINOR_monochrome.svg',
                            colorFilter: const ColorFilter.mode(
                              Colors.white, // Logo blanc inversé
                              BlendMode.srcIn,
                            ),
                            height: 80,
                          ),
                        ),

                        const SizedBox(height: 80),

                        // Barre de progression (similaire au PWA)
                        Column(
                          children: [
                            Container(
                              width: 300,
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Stack(
                                children: [
                                  // Barre de progression animée
                                  AnimatedBuilder(
                                    animation: _animationController,
                                    builder: (context, child) {
                                      return Container(
                                        width: 300 * _animationController.value,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFFF4D03F),
                                              Color(0xFFF7DC6F),
                                              Color(0xFFF4D03F)
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(3),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFFF4D03F)
                                                  .withOpacity(0.5),
                                              blurRadius: 10,
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Pourcentage
                            AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, child) {
                                return Text(
                                  '${(_animationController.value * 100).round()}%',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        offset: Offset(0, 1),
                                        blurRadius: 3,
                                        color: Colors.black26,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Construit le fond avec animation Ken Burns pour les images
  Widget _buildAnimatedBackground() {
    final backgroundType = _config?['background_type'] ?? 'gradient';
    
    if (backgroundType == 'image') {
      final imageUrl = _config?['background_image_url'];
      if (imageUrl != null && imageUrl.isNotEmpty) {
        return AnimatedBuilder(
          animation: _kenBurnsController,
          builder: (context, child) {
            return Transform.scale(
              scale: _kenBurnsScale.value,
              child: Transform.translate(
                offset: Offset(
                  _kenBurnsPan.value.dx * MediaQuery.of(context).size.width * 0.1,
                  _kenBurnsPan.value.dy * MediaQuery.of(context).size.height * 0.1,
                ),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }
    }
    
    // Fallback vers décoration gradient/couleur
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: _buildBackgroundDecoration(),
    );
  }

  Widget _buildBubble(int index) {
    return AnimatedBuilder(
      animation: _bubbleController,
      builder: (context, child) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        // Position aléatoire mais déterministe basée sur l'index
        final random = math.Random(index);
        final x = random.nextDouble() * screenWidth;
        final y = screenHeight + 50; // Commence en bas

        // Animation de montée
        final progress = (_bubbleController.value + index * 0.1) % 1.0;
        final currentY = y - (progress * (screenHeight + 100));

        // Taille et opacité variables
        final size = 20.0 + random.nextDouble() * 30.0;
        final opacity = (1.0 - progress) * 0.6;

        return Positioned(
          left: x,
          top: currentY,
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingIcon(int index) {
    return AnimatedBuilder(
      animation: _iconController,
      builder: (context, child) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        // Position aléatoire mais déterministe
        final random = math.Random(index);
        final x = random.nextDouble() * screenWidth;
        final y = random.nextDouble() * screenHeight;

        // Animation de flottement
        final progress = (_iconController.value + index * 0.2) % 1.0;
        final offsetY = math.sin(progress * 2 * math.pi) * 20;
        final rotation = progress * 2 * math.pi;
        final scale = 0.8 + math.sin(progress * 4 * math.pi) * 0.2;

        final iconIndex = index % _cookingIcons.length;

        return Positioned(
          left: x,
          top: y + offsetY,
          child: Transform.rotate(
            angle: rotation,
            child: Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: 0.4,
                child: Icon(
                  _cookingIcons[iconIndex],
                  color: Colors.white.withOpacity(0.6),
                  size: 24,
                  shadows: [
                    Shadow(
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                      color: Colors.black.withOpacity(0.3),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Construit la décoration de fond basée sur la configuration API
  BoxDecoration _buildBackgroundDecoration() {
    final backgroundType = _config?['background_type'] ?? 'gradient';
    
    switch (backgroundType) {
      case 'solid':
        final color = SplashScreenService.parseColor(
          _config?['background_color_start'] ?? '#E53E3E',
          fallback: const Color(0xFFE53E3E),
        );
        return BoxDecoration(color: color);
        
      case 'image':
        final imageUrl = _config?['background_image_url'];
        if (imageUrl != null && imageUrl.isNotEmpty) {
          return BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
            ),
          );
        }
        // Fallback au gradient si pas d'image
        return _buildGradientDecoration();
        
      case 'gradient':
      default:
        return _buildGradientDecoration();
    }
  }

  /// Construit la décoration gradient
  BoxDecoration _buildGradientDecoration() {
    final startColor = SplashScreenService.parseColor(
      _config?['background_color_start'] ?? '#E53E3E',
      fallback: const Color(0xFFE53E3E),
    );
    final endColor = SplashScreenService.parseColor(
      _config?['background_color_end'] ?? '#C53030',
      fallback: const Color(0xFFC53030),
    );
    final direction = _config?['background_gradient_direction'] ?? 'top_left';
    
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [startColor, endColor, startColor],
        begin: SplashScreenService.getGradientAlignment(direction, true),
        end: SplashScreenService.getGradientAlignment(direction, false),
        stops: const [0.0, 0.5, 1.0],
      ),
    );
  }
}
