import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ImageLightbox extends StatefulWidget {
  final List<String> images;
  final String title;
  final int initialIndex;
  final bool isOpen;
  final VoidCallback onClose;

  const ImageLightbox({
    Key? key,
    required this.images,
    required this.title,
    required this.initialIndex,
    required this.isOpen,
    required this.onClose,
  }) : super(key: key);

  @override
  State<ImageLightbox> createState() => _ImageLightboxState();
}

class _ImageLightboxState extends State<ImageLightbox> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isOpen) return const SizedBox.shrink();

    return Dialog(
      backgroundColor: Colors.black,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            // Image Viewer
            PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: widget.images.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    // Zoom functionality could be added here
                  },
                  child: Center(
                    child: CachedNetworkImage(
                      imageUrl: widget.images[index],
                      fit: BoxFit.contain,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[900],
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[900],
                        child: const Center(
                          child: Icon(
                            LucideIcons.image,
                            size: 64,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            // Header
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              fontFamily: 'OpenSans',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${_currentIndex + 1} / ${widget.images.length}',
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: widget.onClose,
                      icon: const Icon(
                        LucideIcons.x,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Navigation Buttons
            if (widget.images.length > 1) ...[
              // Previous Button
              if (_currentIndex > 0)
                Positioned(
                  left: 16,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: IconButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          LucideIcons.chevronLeft,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),

              // Next Button
              if (_currentIndex < widget.images.length - 1)
                Positioned(
                  right: 16,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: IconButton(
                      onPressed: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          LucideIcons.chevronRight,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
            ],

            // Bottom Indicators
            if (widget.images.length > 1)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: widget.images.asMap().entries.map((entry) {
                      final index = entry.key;
                      return Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index == _currentIndex
                              ? Colors.white
                              : Colors.white.withOpacity(0.3),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
} 