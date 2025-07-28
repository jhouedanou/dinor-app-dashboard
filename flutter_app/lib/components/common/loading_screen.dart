/**
 * LOADING_SCREEN.DART - CONVERSION FIDÈLE DE LoadingScreen.vue
 * 
 * FIDÉLITÉ VISUELLE :
 * - Full screen loading identique
 * - Animation 2500ms identique
 * - Logo et texte identiques
 * - Gradient de fond identique
 */

import 'package:flutter/material.dart';
import 'dart:async';

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
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // Animations identiques à Vue
    _animationController = AnimationController(
      duration: Duration(milliseconds: widget.duration),
      vsync: this,
    );

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
                colors: [Color(0xFFE53E3E), Color(0xFFC53030), Color(0xFFE53E3E)], // Gradient rouge identique au PWA
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, 0.5, 1.0],
              ),
            ),
            child: Center(
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo Dinor (SVG-style similaire au PWA)
                    Container(
                      height: 80,
                      child: const Text(
                        'DINOR',
                        style: TextStyle(
                          fontFamily: 'OpenSans',
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 2,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 0),
                              blurRadius: 20,
                              color: Colors.white,
                            ),
                            Shadow(
                              offset: Offset(0, 2),
                              blurRadius: 10,
                              color: Colors.black26,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Texte de chargement dynamique (similaire au PWA)
                    const Text(
                      'Dinor se prépare...',
                      style: TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 2),
                            blurRadius: 10,
                            color: Colors.black26,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Sous-texte
                    const Text(
                      'Chargement de l\'application',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16,
                        color: Color(0xFFFFFFFF), // Blanc avec transparence
                        shadows: [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 5,
                            color: Colors.black26,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 48),

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
                                        colors: [Color(0xFFF4D03F), Color(0xFFF7DC6F), Color(0xFFF4D03F)],
                                      ),
                                      borderRadius: BorderRadius.circular(3),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFF4D03F).withOpacity(0.5),
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
          ),
        );
      },
    );
  }
}