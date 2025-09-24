/// COVERFLOW_CAROUSEL.DART - Carousel avec effet 3D Coverflow
/// 
/// EFFET COVERFLOW :
/// - Rotation 3D des cartes sur les côtés
/// - Mise en évidence de la carte centrale
/// - Parallaxe et perspective
/// - Animation fluide au scroll
library;

import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'section_header.dart';

class CoverflowCarousel extends StatefulWidget {
  final String title;
  final List<dynamic> items;
  final bool loading;
  final String? error;
  final String contentType;
  final String viewAllLink;
  final Function(Map<String, dynamic>) onItemClick;
  final Widget Function(Map<String, dynamic>) itemBuilder;
  final bool darkTheme;

  const CoverflowCarousel({
    super.key,
    required this.title,
    required this.items,
    this.loading = false,
    this.error,
    required this.contentType,
    required this.viewAllLink,
    required this.onItemClick,
    required this.itemBuilder,
    this.darkTheme = false,
  });

  @override
  State<CoverflowCarousel> createState() => _CoverflowCarouselState();
}

class _CoverflowCarouselState extends State<CoverflowCarousel> {
  late PageController _pageController;
  double _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.6); // Réduit pour voir plus d'éléments
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.darkTheme ? const EdgeInsets.all(8) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header avec cartouche
          SectionHeader(
            title: widget.title,
            viewAllLink: widget.viewAllLink,
            darkTheme: widget.darkTheme,
          ),
          
          const SizedBox(height: 8),
          
          // Contenu du coverflow avec navigation
          Stack(
            children: [
              _buildCarouselContent(),
              // Boutons de navigation
              if (widget.items.isNotEmpty && widget.items.length > 1) ...
              _buildNavigationButtons(),
            ],
          ),
          
          // Indicateurs de progression
          if (widget.items.isNotEmpty && widget.items.length > 1)
            _buildProgressIndicators(),
        ],
      ),
    );
  }

  Widget _buildCarouselContent() {
    if (widget.loading) {
      return const SizedBox(
        height: 280,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (widget.error != null) {
      return SizedBox(
        height: 280,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
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
        height: 280,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.info_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Aucun contenu disponible',
                style: TextStyle(
                  color: widget.darkTheme ? Colors.white : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 320, // Augmenté pour accommoder le nouveau design
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          return _buildCoverflowItem(index);
        },
      ),
    );
  }

  Widget _buildCoverflowItem(int index) {
    // Calculer la transformation 3D basée sur la position - Style Swiper 3D
    double offset = _currentPage - index;
    double absOffset = offset.abs();
    
    // Rotation Y plus prononcée pour l'effet 3D
    double rotationY = (math.pi / 4) * offset.clamp(-1, 1); // -45° à +45°
    
    // Échelle progressive pour créer la profondeur
    double scale = (1 - (absOffset * 0.15)).clamp(0.7, 1.0);
    
    // Opacité pour accentuer la profondeur
    double opacity = (1 - (absOffset * 0.2)).clamp(0.6, 1.0);
    
    // Translation Z pour l'effet de profondeur
    double translateZ = -absOffset * 100;
    
    // Translation X pour l'espacement latéral
    double translateX = offset * 60;

    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0008) // Perspective réduite pour plus de réalisme
            ..translate(translateX, 0.0, translateZ)
            ..rotateY(rotationY)
            ..scale(scale),
          child: Opacity(
            opacity: opacity,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 10), // Marges minimales pour plus de visibilité
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 15 + (10 * absOffset),
                    offset: Offset(8 * offset.sign * absOffset, 8 + (8 * absOffset)),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: GestureDetector(
                  onTap: () => widget.onItemClick(widget.items[index]),
                  child: widget.itemBuilder(widget.items[index]),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Boutons de navigation
  List<Widget> _buildNavigationButtons() {
    return [
      // Bouton précédent - Style amélioré
      Positioned(
        left: 15,
        top: 0,
        bottom: 0,
        child: Center(
          child: AnimatedOpacity(
            opacity: _currentPage > 0 ? 1.0 : 0.3,
            duration: const Duration(milliseconds: 200),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.white, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 12,
                    offset: Offset(0, 4),
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.chevron_left, 
                  color: Colors.black87, 
                  size: 28,
                ),
                onPressed: _currentPage > 0 ? _previousPage : null,
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
      ),
      // Bouton suivant - Style amélioré
      Positioned(
        right: 15,
        top: 0,
        bottom: 0,
        child: Center(
          child: AnimatedOpacity(
            opacity: _currentPage < widget.items.length - 1 ? 1.0 : 0.3,
            duration: const Duration(milliseconds: 200),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.white, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.chevron_right, 
                  color: Colors.black87, 
                  size: 28,
                ),
                onPressed: _currentPage < widget.items.length - 1 ? _nextPage : null,
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
      ),
    ];
  }

  // Indicateurs de progression - Style amélioré
  Widget _buildProgressIndicators() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(widget.items.length, (index) {
          bool isActive = index == _currentPage.round();
          return AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 32 : 12,
            height: 12,
            decoration: BoxDecoration(
              gradient: isActive 
                ? LinearGradient(
                    colors: [
                      widget.darkTheme ? Colors.white : Colors.blue.shade600,
                      widget.darkTheme ? Colors.grey.shade300 : Colors.blue.shade800,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
              color: !isActive 
                ? (widget.darkTheme ? Colors.white : Colors.grey.shade400)
                : null,
              borderRadius: BorderRadius.circular(6),
              boxShadow: isActive ? [
                BoxShadow(
                  color: (widget.darkTheme ? Colors.white : Colors.blue.shade600),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
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
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextPage() {
    if (_currentPage < widget.items.length - 1) {
      _pageController.animateToPage(
        (_currentPage + 1).round(),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
}