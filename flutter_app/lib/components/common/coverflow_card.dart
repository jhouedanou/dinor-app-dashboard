/**
 * COVERFLOW_CARD.DART - Carte optimisée pour l'effet coverflow 3D
 * 
 * CARACTÉRISTIQUES :
 * - Taille dynamique basée sur la position
 * - Effet 3D avec rotation et perspective
 * - Design moderne et élégant
 * - Support des images et contenus
 */

import 'package:flutter/material.dart';
import '../../services/image_service.dart';

class CoverflowCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap;
  final String contentType;
  final double scale;
  final double opacity;
  final bool isActive;

  const CoverflowCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.contentType,
    required this.scale,
    required this.opacity,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    // Calculer la taille dynamique basée sur l'échelle
    final baseWidth = 320.0; // Augmenté de 280 à 320
    final baseHeight = 320.0;
    final dynamicWidth = baseWidth * scale;
    final dynamicHeight = baseHeight * scale;

    return GestureDetector(
      onTap: onTap, // Rendre toute la carte cliquable
      child: Container(
        width: dynamicWidth,
        height: dynamicHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3 * opacity),
              blurRadius: isActive ? 25 : 15,
              offset: const Offset(0, 8),
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
          children: [
            // Image de fond
            Positioned.fill(
              child: _buildBackgroundImage(),
            ),
            
            // Gradient overlay pour la lisibilité
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.2),
                      Colors.black.withValues(alpha: 0.6),
                      Colors.black.withValues(alpha: 0.8),
                    ],
                    stops: const [0.0, 0.4, 0.7, 1.0],
                  ),
                ),
              ),
            ),
            
            // Contenu principal
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.all(20 * scale), // Padding adaptatif
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre principal
                    _buildTitle(),
                    
                    const SizedBox(height: 8),
                    
                    // Catégorie
                    _buildCategory(),
                    
                    const SizedBox(height: 12),
                    
                    // Informations supplémentaires
                    _buildAdditionalInfo(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildBackgroundImage() {
    String imageUrl = '';
    
    // Pour les vidéos Dinor TV, prioriser featured_image_url
    if (contentType == 'videos' || contentType == 'video') {
      imageUrl = item['featured_image_url']?.toString() ?? 
                 item['thumbnail_url']?.toString() ?? 
                 item['thumbnailUrl']?.toString() ?? 
                 item['banner_image_url']?.toString() ?? 
                 item['poster_image_url']?.toString() ?? 
                 item['thumbnail']?.toString() ?? 
                 item['image']?.toString() ?? 
                 item['image_url']?.toString() ?? 
                 '';
    } else {
      // Pour les autres types de contenu (recettes, astuces, événements)
      imageUrl = item['image_url']?.toString() ?? 
                 item['imageUrl']?.toString() ?? 
                 item['cover_image']?.toString() ?? 
                 item['featured_image_url']?.toString() ?? 
                 item['featured_image']?.toString() ?? 
                 '';
    }
    
    if (imageUrl.isNotEmpty) {
      return ImageService.buildCachedNetworkImage(
        imageUrl: imageUrl,
        contentType: contentType,
        fit: BoxFit.cover,
        errorWidget: _buildPlaceholderImage(),
      );
    } else {
      return _buildPlaceholderImage();
    }
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade300,
            Colors.purple.shade300,
            Colors.orange.shade300,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          _getTypeIcon(),
          size: 48 * scale, // Taille adaptative
          color: Colors.white.withValues(alpha: 0.8),
        ),
      ),
    );
  }

  IconData _getTypeIcon() {
    switch (contentType) {
      case 'recipe':
        return Icons.restaurant;
      case 'tip':
        return Icons.lightbulb;
      case 'event':
        return Icons.event;
      case 'video':
        return Icons.play_circle;
      default:
        return Icons.article;
    }
  }

  Widget _buildTitle() {
    String title = item['title']?.toString() ?? 
                   item['name']?.toString() ?? 
                   'Titre non disponible';

    return Text(
      title,
      style: TextStyle(
        fontFamily: 'OpenSans',
        fontSize: 18 * scale, // Taille adaptative
        fontWeight: FontWeight.w700,
        color: Colors.white,
        shadows: [
          Shadow(
            offset: const Offset(0, 2),
            blurRadius: 4,
            color: Colors.black.withValues(alpha: 0.8),
          ),
        ],
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildCategory() {
    String category = _getCategoryName();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 6 * scale),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        category,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12 * scale,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildAdditionalInfo() {
    // Informations adaptatives basées sur le type de contenu
    List<Widget> infoWidgets = [];
    
    if (contentType == 'recipe') {
      // Temps de préparation
      if (item['preparation_time'] != null) {
        infoWidgets.add(_buildInfoItem(Icons.schedule, '${item['preparation_time']}min'));
      }
      
      // Nombre de personnes
      if (item['servings'] != null) {
        infoWidgets.add(_buildInfoItem(Icons.person, '${item['servings']} pers.'));
      }
    }
    
    // Nombre de likes
    if (item['likes_count'] != null || item['likes'] != null) {
      int likes = item['likes_count'] ?? item['likes'] ?? 0;
      infoWidgets.add(_buildInfoItem(Icons.favorite, likes.toString()));
    }

    return Wrap(
      spacing: 8 * scale,
      runSpacing: 4 * scale,
      children: infoWidgets,
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14 * scale,
          color: Colors.white.withValues(alpha: 0.9),
        ),
        SizedBox(width: 4 * scale),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 12 * scale,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _getCategoryName() {
    // Gérer les différents formats de catégorie
    var categoryData = item['category'];
    
    if (categoryData is String) {
      return categoryData;
    } else if (categoryData is Map<String, dynamic>) {
      return categoryData['name']?.toString() ?? 'Catégorie';
    } else if (item['type'] != null) {
      return item['type'].toString();
    } else {
      return 'Catégorie';
    }
  }

  Widget _buildActionButton() {
    return Container(
      width: double.infinity,
      height: 36 * scale, // Hauteur adaptative
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18 * scale),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18 * scale),
          onTap: onTap,
          child: Center(
            child: Text(
              'Voir plus',
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 12 * scale,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
