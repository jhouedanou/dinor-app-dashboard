/**
 * COVERFLOW_CAROUSEL.DART - Carousel avec effet 3D Coverflow
 * 
 * EFFET COVERFLOW :
 * - Rotation 3D des cartes sur les côtés
 * - Mise en évidence de la carte centrale
 * - Parallaxe et perspective
 * - Animation fluide au scroll
 */

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
    _pageController = PageController(viewportFraction: 0.8);
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
      padding: widget.darkTheme ? const EdgeInsets.all(20) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header avec cartouche
          SectionHeader(
            title: widget.title,
            viewAllLink: widget.viewAllLink,
            darkTheme: widget.darkTheme,
          ),
          
          const SizedBox(height: 20),
          
          // Contenu du coverflow
          _buildCarouselContent(),
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
      height: 280,
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
    // Calculer la transformation 3D basée sur la position
    double offset = (_currentPage - index).abs();
    double rotationY = (math.pi / 6) * offset.clamp(0, 1); // Rotation maximale de 30 degrés
    double scale = (1 - (offset * 0.3)).clamp(0.7, 1.0); // Échelle de 0.7 à 1.0
    double opacity = (1 - (offset * 0.5)).clamp(0.5, 1.0); // Opacité de 0.5 à 1.0

    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // Perspective
            ..rotateY(rotationY)
            ..scale(scale),
          child: Opacity(
            opacity: opacity,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2 * opacity),
                    blurRadius: 10 + (5 * offset),
                    offset: Offset(5 * offset, 5 + (5 * offset)),
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
}