/**
 * BANNER_SECTION.DART - CONVERSION FIDÈLE DE BannerSection.vue
 * 
 * FIDÉLITÉ VISUELLE :
 * - Bannières avec gradients identiques
 * - Overlay text avec contraste parfait
 * - Boutons hero avec styles identiques
 * - Animation et transitions identiques
 */

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BannerSection extends StatelessWidget {
  final String type;
  final String section;
  final List<dynamic> banners;
  final bool loading;
  final String? error;

  const BannerSection({
    Key? key,
    required this.type,
    required this.section,
    required this.banners,
    this.loading = false,
    this.error,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (error != null || banners.isEmpty) {
      return const SizedBox.shrink();
    }

    // Pour l'instant, afficher la première bannière
    final banner = banners.first;

    return Container(
      height: 300,
      margin: const EdgeInsets.only(bottom: 32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: banner['background_image_url'] != null
            ? DecorationImage(
                image: CachedNetworkImageProvider(banner['background_image_url']),
                fit: BoxFit.cover,
              )
            : null,
        gradient: banner['background_image_url'] == null
            ? const LinearGradient(
                colors: [Color(0xFFF4D03F), Color(0xFFFF6B35)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
      ),
      child: Stack(
        children: [
          // Overlay pour assurer la lisibilité du texte
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),
          
          // Contenu de la bannière
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (banner['title'] != null)
                    Text(
                      banner['title'],
                      style: const TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(2, 2),
                            blurRadius: 4,
                            color: Colors.black38,
                          ),
                        ],
                      ),
                    ),
                  
                  if (banner['description'] != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      banner['description'],
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(1, 1),
                            blurRadius: 2,
                            color: Colors.black38,
                          ),
                        ],
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  
                  if (banner['action_text'] != null) ...[
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Gérer l'action de la bannière
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B35),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 4,
                      ),
                      child: Text(
                        banner['action_text'],
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}