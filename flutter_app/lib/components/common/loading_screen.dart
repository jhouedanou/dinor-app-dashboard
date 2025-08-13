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
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  Timer? _timer;

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

    // Animations identiques à Vue
    _animationController = AnimationController(
      duration: Duration(milliseconds: widget.duration),
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFE53E3E),
                  Color(0xFFC53030),
                  Color(0xFFE53E3E)
                ], // Gradient rouge identique au PWA
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, 0.5, 1.0],
              ),
            ),
            child: Stack(
              children: [
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
}
