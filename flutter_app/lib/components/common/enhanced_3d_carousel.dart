/// ENHANCED_3D_CAROUSEL.DART - Carousel 3D avec visibilité améliorée
/// 
/// CARACTÉRISTIQUES :
/// - Visibilité claire de tous les éléments
/// - Effet 3D avec profondeur et perspective
/// - Navigation intuitive avec boutons circulaires
/// - Design moderne inspiré des applications de voyage
/// - Cartes avec overlay text et boutons d'action
library;

import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'section_header.dart';
import 'coverflow_card.dart';

class Enhanced3DCarousel extends StatefulWidget {
  final String title;
  final List<dynamic> items;
  final bool loading;
  final String? error;
  final String contentType;
  final String viewAllLink;
  final Function(Map<String, dynamic>) onItemClick;
  final Widget Function(Map<String, dynamic>)? itemBuilder;
  final bool darkTheme;
  final double cardHeight;
  final double cardWidth;
  final bool flatLayout; // Nouvel option pour layout plat

  const Enhanced3DCarousel({
    super.key,
    required this.title,
    required this.items,
    this.loading = false,
    this.error,
    required this.contentType,
    required this.viewAllLink,
    required this.onItemClick,
    this.itemBuilder,
    this.darkTheme = false,
    this.cardHeight = 280,
    this.cardWidth = 280,
    this.flatLayout = false, // Par défaut: effet 3D
  });

  @override
  State<Enhanced3DCarousel> createState() => _Enhanced3DCarouselState();
}

class _Enhanced3DCarouselState extends State<Enhanced3DCarousel>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  double _currentPage = 0;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: widget.flatLayout ? 0.75 : 0.7, // Réduit pour voir plus d'éléments
      initialPage: 0,
    );
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? 0;
        _currentIndex = _currentPage.round();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.darkTheme ? const EdgeInsets.all(16) : const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          SectionHeader(
            title: widget.title,
            viewAllLink: widget.viewAllLink,
            darkTheme: widget.darkTheme,
          ),
          
          const SizedBox(height: 20),
          
          // Contenu du carousel sans navigation
          _buildCarouselContent(),
          
          // Indicateurs de progression
          if (widget.items.isNotEmpty && widget.items.length > 1)
            _buildProgressIndicators(),
        ],
      ),
    );
  }

  Widget _buildCarouselContent() {
    if (widget.loading) {
      return SizedBox(
        height: widget.cardHeight + 80,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (widget.error != null) {
      return SizedBox(
        height: widget.cardHeight + 80,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: widget.darkTheme ? Colors.white : Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Erreur lors du chargement',
                style: TextStyle(
                  color: widget.darkTheme ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (widget.items.isEmpty) {
      return SizedBox(
        height: widget.cardHeight + 80,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline,
                size: 48,
                color: widget.darkTheme ? Colors.grey[600] : Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                'Aucun contenu disponible',
                style: TextStyle(
                  color: widget.darkTheme ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: widget.cardHeight + 80, // Augmenté pour accommoder les cartes de différentes tailles
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          return _build3DCard(index);
        },
      ),
    );
  }

  Widget _build3DCard(int index) {
    double offset = _currentPage - index;
    double absOffset = offset.abs();
    
    final themePlatform = Theme.of(context).platform;
    final isIOS = themePlatform == TargetPlatform.iOS;

    if (widget.flatLayout) {
      // Layout plat comme dans les images
      double scale = (1 - (absOffset * 0.1)).clamp(0.9, 1.0); // Échelle minimale
      double opacity = (1 - (absOffset * 0.3)).clamp(0.7, 1.0); // Opacité douce
      final shadowOpacity = isIOS ? 0.1 : 0.15;
      
      return AnimatedBuilder(
        animation: _pageController,
        builder: (context, child) {
          return Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: opacity,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8), // Marges réduites
                width: widget.cardWidth,
                height: widget.cardHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(shadowOpacity),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: widget.itemBuilder != null
                      ? widget.itemBuilder!(widget.items[index])
                      : CoverflowCard(
                          item: widget.items[index],
                          onTap: () => widget.onItemClick(widget.items[index]),
                          contentType: widget.contentType,
                          scale: scale,
                          opacity: opacity,
                          isActive: absOffset < 0.1,
                        ),
                ),
              ),
            ),
          );
        },
      );
    }
    
    // Layout 3D existant
    double rotationY = (math.pi / 4) * offset.clamp(-1, 1);
    double scale = (1 - (absOffset * 0.25)).clamp(0.6, 1.0);
    double opacity = (1 - (absOffset * 0.2)).clamp(0.6, 1.0);
    double translateZ = -absOffset * 120;
    double translateX = offset * 40;
    double dynamicWidth = widget.cardWidth * scale;
    double dynamicHeight = widget.cardHeight * scale;

    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..translate(translateX, 0.0, translateZ)
            ..rotateY(rotationY)
            ..scale(scale),
          child: Opacity(
            opacity: opacity,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
              width: dynamicWidth,
              height: dynamicHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity((isIOS ? 0.18 : 0.25) * opacity),
                    blurRadius: 20 + (15 * absOffset),
                    offset: Offset(
                      10 * offset.sign * absOffset,
                      10 + (10 * absOffset)
                    ),
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: widget.itemBuilder != null
                    ? widget.itemBuilder!(widget.items[index])
                    : CoverflowCard(
                        item: widget.items[index],
                        onTap: () => widget.onItemClick(widget.items[index]),
                        contentType: widget.contentType,
                        scale: scale,
                        opacity: opacity,
                        isActive: absOffset < 0.1,
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Boutons de navigation circulaires améliorés
  List<Widget> _buildNavigationButtons() {
    return [
      // Bouton précédent
      Positioned(
        left: 20,
        top: 0,
        bottom: 0,
        child: Center(
          child: AnimatedOpacity(
            opacity: _currentPage > 0 ? 1.0 : 0.4,
            duration: const Duration(milliseconds: 200),
            child: _buildCircularNavigationButton(
              icon: Icons.chevron_left,
              onPressed: _currentPage > 0 ? _previousPage : null,
            ),
          ),
        ),
      ),
      // Bouton suivant
      Positioned(
        right: 20,
        top: 0,
        bottom: 0,
        child: Center(
          child: AnimatedOpacity(
            opacity: _currentPage < widget.items.length - 1 ? 1.0 : 0.4,
            duration: const Duration(milliseconds: 200),
            child: _buildCircularNavigationButton(
              icon: Icons.chevron_right,
              onPressed: _currentPage < widget.items.length - 1 ? _nextPage : null,
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildCircularNavigationButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(isIOS ? 0.92 : 0.95),
            Colors.white.withOpacity(isIOS ? 0.82 : 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isIOS ? 0.12 : 0.15),
            blurRadius: 15,
            offset: const Offset(0, 6),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onPressed,
          child: Center(
            child: Icon(
              icon,
              color: Colors.black87,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }

  // Indicateurs de progression améliorés
  Widget _buildProgressIndicators() {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(widget.items.length, (index) {
          bool isActive = index == _currentIndex;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            margin: const EdgeInsets.symmetric(horizontal: 6),
            width: isActive ? 36 : 14,
            height: 14,
            decoration: BoxDecoration(
              gradient: isActive 
                ? LinearGradient(
                    colors: [
                      (widget.darkTheme ? Colors.white : Colors.red.shade500)
                          .withOpacity(isIOS ? 0.9 : 1.0),
                      (widget.darkTheme ? Colors.grey.shade300 : Colors.red.shade700)
                          .withOpacity(isIOS ? 0.9 : 1.0),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
              color: !isActive 
                ? (widget.darkTheme
                    ? Colors.white.withOpacity(isIOS ? 0.22 : 0.3)
                    : Colors.grey.shade400)
                : null,
              borderRadius: BorderRadius.circular(7),
              boxShadow: isActive ? [
                BoxShadow(
                  color: (widget.darkTheme ? Colors.white : Colors.red.shade500)
                      .withOpacity(isIOS ? 0.32 : 0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ] : null,
            ),
          );
        }),
      ),
    );
  }

  // Navigation functions
  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.animateToPage(
        (_currentPage - 1).round(),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _nextPage() {
    if (_currentPage < widget.items.length - 1) {
      _pageController.animateToPage(
        (_currentPage + 1).round(),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }
}
