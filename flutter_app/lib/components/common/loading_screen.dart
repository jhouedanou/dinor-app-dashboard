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
                colors: [Color(0xFFF4D03F), Color(0xFFFF6B35)], // Dégradé doré-orange
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo Dinor
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            offset: const Offset(0, 4),
                            blurRadius: 20,
                            color: Colors.black.withOpacity(0.2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'D',
                          style: TextStyle(
                            fontFamily: 'OpenSans',
                            fontSize: 48,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFE53E3E), // Rouge Dinor
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Nom de l'app
                    const Text(
                      'Dinor',
                      style: TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 2,
                        shadows: [
                          Shadow(
                            offset: Offset(2, 2),
                            blurRadius: 4,
                            color: Colors.black26,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Slogan
                    const Text(
                      'Votre compagnon culinaire',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(1, 1),
                            blurRadius: 2,
                            color: Colors.black26,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Indicateur de chargement
                    const SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
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