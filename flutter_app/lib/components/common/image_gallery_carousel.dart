import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'image_lightbox.dart';

class ImageGalleryCarousel extends StatefulWidget {
  final List<String> images;
  final String title;
  final double height;
  final bool showIndicators;
  final bool showLightbox;

  const ImageGalleryCarousel({
    super.key,
    required this.images,
    this.title = 'Galerie photos',
    this.height = 200,
    this.showIndicators = true,
    this.showLightbox = true,
  });

  @override
  State<ImageGalleryCarousel> createState() => _ImageGalleryCarouselState();
}

class _ImageGalleryCarouselState extends State<ImageGalleryCarousel> {
  late PageController _pageController;
  int _currentIndex = 0;
  bool _showLightbox = false;
  int _lightboxIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openLightbox(int index) {
    if (widget.showLightbox) {
      setState(() {
        _lightboxIndex = index;
        _showLightbox = true;
      });
    }
  }

  void _closeLightbox() {
    setState(() {
      _showLightbox = false;
    });
  }

  void _nextLightboxImage() {
    setState(() {
      _lightboxIndex = (_lightboxIndex + 1) % widget.images.length;
    });
  }

  void _previousLightboxImage() {
    setState(() {
      _lightboxIndex = (_lightboxIndex - 1 + widget.images.length) % widget.images.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre
            if (widget.title.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.image,
                      color: const Color(0xFFE53E3E),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53E3E).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${widget.images.length}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFE53E3E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Carousel
            SizedBox(
              height: widget.height,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemCount: widget.images.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => _openLightbox(index),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                CachedNetworkImage(
                                  imageUrl: widget.images[index],
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: const Color(0xFFF7FAFC),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE53E3E)),
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    color: const Color(0xFFF7FAFC),
                                    child: const Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          LucideIcons.imageOff,
                                          size: 32,
                                          color: Color(0xFFCBD5E0),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Image non disponible',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF718096),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                
                                // Overlay avec icône de zoom
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Icon(
                                      LucideIcons.zoomIn,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  // Boutons de navigation
                  if (widget.images.length > 1) ...[
                    // Bouton précédent
                    Positioned(
                      left: 8,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: GestureDetector(
                          onTap: () {
                            if (_currentIndex > 0) {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              LucideIcons.chevronLeft,
                              color: _currentIndex > 0 ? Colors.white : Colors.white.withOpacity(0.5),
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Bouton suivant
                    Positioned(
                      right: 8,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: GestureDetector(
                          onTap: () {
                            if (_currentIndex < widget.images.length - 1) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              LucideIcons.chevronRight,
                              color: _currentIndex < widget.images.length - 1 ? Colors.white : Colors.white.withOpacity(0.5),
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Indicateurs de pagination
            if (widget.showIndicators && widget.images.length > 1)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: widget.images.asMap().entries.map((entry) {
                    int index = entry.key;
                    return GestureDetector(
                      onTap: () {
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        width: _currentIndex == index ? 24 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: _currentIndex == index
                              ? const Color(0xFFE53E3E)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),

        // Lightbox
        if (_showLightbox)
          ImageLightbox(
            images: widget.images,
            title: widget.title,
            isOpen: _showLightbox,
            initialIndex: _lightboxIndex,
            onClose: _closeLightbox,
          ),
      ],
    );
  }
} 