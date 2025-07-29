import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageService {
  static const String _baseUrl = 'https://new.dinorapp.com';
  
  // Images par défaut pour chaque type de contenu
  static const Map<String, String> _defaultImages = {
    'recipe': '$_baseUrl/images/default-recipe.jpg',
    'tip': '$_baseUrl/images/default-content.jpg', // Utiliser default-content.jpg pour les tips
    'event': '$_baseUrl/images/default-event.jpg',
    'dinor_tv': '$_baseUrl/images/default-video.jpg',
    'video': '$_baseUrl/images/default-video.jpg',
    'banner': '$_baseUrl/images/default-content.jpg', // Utiliser default-content.jpg pour les bannières
    'user': '$_baseUrl/images/default-content.jpg', // Utiliser default-content.jpg pour les utilisateurs
    'content': '$_baseUrl/images/default-content.jpg',
  };

  /// Obtenir l'URL d'image avec fallback vers l'image par défaut
  static String getImageUrl(String? imageUrl, String contentType) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      // Si l'URL est déjà complète, la retourner
      if (imageUrl.startsWith('http')) {
        return imageUrl;
      }
      
      // Si c'est un chemin relatif, le compléter avec l'URL de base
      if (imageUrl.startsWith('/')) {
        return '$_baseUrl$imageUrl';
      }
      
      // Sinon, ajouter le chemin vers les images
      return '$_baseUrl/images/$imageUrl';
    }
    
    // Retourner l'image par défaut pour le type de contenu
    return _defaultImages[contentType] ?? _defaultImages['content']!;
  }

  /// Obtenir l'URL d'image pour les recettes
  static String getRecipeImageUrl(dynamic recipe) {
    final imageUrl = recipe['featured_image_url'] ?? 
                    recipe['image_url'] ?? 
                    recipe['image'];
    return getImageUrl(imageUrl, 'recipe');
  }

  /// Obtenir l'URL d'image pour les astuces
  static String getTipImageUrl(dynamic tip) {
    final imageUrl = tip['featured_image_url'] ?? 
                    tip['image_url'] ?? 
                    tip['image'];
    return getImageUrl(imageUrl, 'tip');
  }

  /// Obtenir l'URL d'image pour les événements
  static String getEventImageUrl(dynamic event) {
    final imageUrl = event['image_url'] ?? 
                    event['featured_image_url'] ?? 
                    event['image'];
    return getImageUrl(imageUrl, 'event');
  }

  /// Obtenir l'URL d'image pour les vidéos
  static String getVideoImageUrl(dynamic video) {
    final imageUrl = video['thumbnail_url'] ?? 
                    video['image_url'] ?? 
                    video['featured_image_url'] ?? 
                    video['image'];
    return getImageUrl(imageUrl, 'video');
  }

  /// Obtenir l'URL d'image pour les bannières
  static String getBannerImageUrl(dynamic banner) {
    final imageUrl = banner['image_url'] ?? 
                    banner['featured_image_url'] ?? 
                    banner['image'];
    return getImageUrl(imageUrl, 'banner');
  }

  /// Obtenir l'URL d'image pour les utilisateurs
  static String getUserImageUrl(dynamic user) {
    final imageUrl = user['avatar_url'] ?? 
                    user['profile_image'] ?? 
                    user['image'];
    return getImageUrl(imageUrl, 'user');
  }

  /// Créer un widget Image.network avec gestion d'erreur
  static Widget buildNetworkImage({
    required String imageUrl,
    required String contentType,
    BoxFit fit = BoxFit.cover,
    double? width,
    double? height,
    BorderRadius? borderRadius,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    final url = getImageUrl(imageUrl, contentType);
    
    Widget imageWidget = Image.network(
      url,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ?? _buildDefaultErrorWidget(contentType);
      },
    );

    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  /// Créer un widget CachedNetworkImage avec gestion d'erreur
  static Widget buildCachedNetworkImage({
    required String imageUrl,
    required String contentType,
    BoxFit fit = BoxFit.cover,
    double? width,
    double? height,
    BorderRadius? borderRadius,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    final url = getImageUrl(imageUrl, contentType);
    
    Widget imageWidget = CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      width: width,
      height: height,
      placeholder: (context, url) => placeholder ?? _buildDefaultPlaceholder(),
      errorWidget: (context, url, error) => errorWidget ?? _buildDefaultErrorWidget(contentType),
    );

    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  /// Widget de placeholder par défaut
  static Widget _buildDefaultPlaceholder() {
    return Container(
      color: const Color(0xFFF4D03F),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2D3748)),
        ),
      ),
    );
  }

  /// Widget d'erreur par défaut selon le type de contenu
  static Widget _buildDefaultErrorWidget(String contentType) {
    IconData icon;
    Color color;
    
    switch (contentType) {
      case 'recipe':
        icon = Icons.restaurant;
        color = const Color(0xFFF4D03F);
        break;
      case 'tip':
        icon = Icons.lightbulb;
        color = const Color(0xFFF4D03F);
        break;
      case 'event':
        icon = Icons.event;
        color = const Color(0xFFF4D03F);
        break;
      case 'video':
      case 'dinor_tv':
        icon = Icons.play_circle;
        color = const Color(0xFFF4D03F);
        break;
      case 'banner':
        icon = Icons.image;
        color = const Color(0xFFF4D03F);
        break;
      case 'user':
        icon = Icons.person;
        color = const Color(0xFFF4D03F);
        break;
      default:
        icon = Icons.image;
        color = const Color(0xFFF4D03F);
    }
    
    return Container(
      color: color,
      child: Icon(
        icon,
        size: 48,
        color: const Color(0xFF2D3748),
      ),
    );
  }
} 