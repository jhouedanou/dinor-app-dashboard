import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../services/image_service.dart';
import '../../styles/shadows.dart';

class ContentItemCard extends StatelessWidget {
  final String contentType;
  final Map<String, dynamic> item;
  final VoidCallback onTap;
  final bool compact;

  const ContentItemCard({
    super.key,
    required this.contentType,
    required this.item,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: compact ? 180 : 240, // Hauteur fixe pour effet mosaïque
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              // Image de fond
              Positioned.fill(
                child: _getImageUrl().isNotEmpty
                  ? ImageService.buildCachedNetworkImage(
                      imageUrl: _getImageUrl(),
                      contentType: contentType,
                      fit: BoxFit.cover,
                      errorWidget: Container(
                        color: const Color(0xFFF7FAFC),
                        child: Center(
                          child: Image.asset(
                            'assets/icons/app_icon.png',
                            width: 80,
                            height: 80,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    )
                  : Container(
                      color: const Color(0xFFF7FAFC),
                      child: Center(
                        child: Image.asset(
                          'assets/icons/app_icon.png',
                          width: 80,
                          height: 80,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
              ),
              
              // Gradient overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.7),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
              
              // Contenu texte
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Titre principal
                      Text(
                        _getTitle(),
                        style: TextStyle(
                          fontFamily: 'OpenSans',
                          fontSize: compact ? 16 : 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: const Offset(0, 1),
                              blurRadius: 3,
                              color: Colors.black.withOpacity(0.8),
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Badge de type au-dessus
                      Row(
                        children: [
                          _buildOverlayTypeBadge(),
                        ],
                      ),
                      
                      const SizedBox(height: 6),
                      
                      // Stats en dessous (durée, likes, etc.)
                      Row(
                        children: _buildOverlayStats(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFullCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image
        _buildImage(),
        
        // Contenu
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre
              Text(
                _getTitle(),
                style: const TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              
              // Description
              if (_getDescription().isNotEmpty) ...[
                if (contentType == 'tip')
                  Html(
                    data: _getDescription(),
                    style: {
                      "body": Style(
                        fontFamily: 'Roboto',
                        fontSize: FontSize(14),
                        color: const Color(0xFF4A5568),
                        lineHeight: const LineHeight(1.4),
                        maxLines: 3,
                        textOverflow: TextOverflow.ellipsis,
                      ),
                    },
                  )
                else
                  Text(
                    _getDescription(),
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 14,
                      color: Color(0xFF4A5568),
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 12),
              ],
              
              // Statistiques
              _buildStats(),
              
              // Tags/Badges
              if (_getTags().isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildTags(),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image en arrière-plan - même principe que le mode complet mais plus petite
        Container(
          height: 120, // Hauteur réduite pour le mode compact
          width: double.infinity,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            color: Color(0xFFF7FAFC),
          ),
          child: Stack(
            children: [
                             ClipRRect(
                 borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                 child: _getImageUrl().isNotEmpty
                   ? SizedBox(
                       width: double.infinity,
                       height: double.infinity,
                       child: ImageService.buildCachedNetworkImage(
                         imageUrl: _getImageUrl(),
                         contentType: contentType,
                         fit: BoxFit.contain,
                         errorWidget: Container(
                           color: const Color(0xFFF7FAFC),
                           child: Center(
                             child: Image.asset(
                               'assets/icons/app_icon.png',
                               width: 40,
                               height: 40,
                               fit: BoxFit.contain,
                             ),
                           ),
                         ),
                       ),
                     )
                   : SizedBox(
                       width: double.infinity,
                       height: double.infinity,
                       child: Center(
                         child: Image.asset(
                           'assets/icons/app_icon.png',
                           width: 40,
                           height: 40,
                           fit: BoxFit.contain,
                         ),
                       ),
                     ),
               ),
              
              // Overlay avec badge de type (optionnel)
              Positioned(
                top: 8,
                left: 8,
                child: _buildTypeBadge(),
              ),
            ],
          ),
        ),
        
        // Contenu sous l'image
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getTitle(),
                style: const TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 14, // Taille réduite pour le mode compact
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 4),
              
              // Description courte
              if (_getDescription().isNotEmpty) ...[
                Text(
                  _getDescription(),
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 12, // Taille réduite pour le mode compact
                    color: Color(0xFF4A5568),
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
              ],
              
              // Statistiques compactes
              _buildCompactStats(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImage() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        color: Color(0xFFF7FAFC),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: ImageService.buildCachedNetworkImage(
                imageUrl: _getImageUrl(),
                contentType: contentType,
                fit: BoxFit.contain,
              ),
            ),
          ),
          
          // Overlay avec badge de type
          Positioned(
            top: 12,
            left: 12,
            child: _buildTypeBadge(),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeBadge() {
    IconData icon;
    String label;
    Color color;

    switch (contentType) {
      case 'recipe':
      case 'recipes':
        icon = LucideIcons.chefHat;
        label = _getRecipeCategoryLabel();
        color = const Color(0xFF38A169);
        break;
      case 'tip':
      case 'tips':
        icon = LucideIcons.lightbulb;
        label = _getTipCategoryLabel();
        color = const Color(0xFF3182CE);
        break;
      case 'event':
      case 'events':
        icon = LucideIcons.calendar;
        label = _getEventDateRange();
        color = const Color(0xFFE53E3E);
        break;
      case 'video':
      case 'videos':
        icon = LucideIcons.play;
        label = _getVideoCategoryLabel();
        color = const Color(0xFF6B46C1);
        break;
      default:
        icon = LucideIcons.fileText;
        label = 'Contenu';
        color = const Color(0xFF718096);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        // Likes
        _buildStatItem(
          LucideIcons.heart,
          '${item['likes_count'] ?? 0}',
          const Color(0xFFE53E3E),
        ),
        const SizedBox(width: 16),
        
        // Comments
        _buildStatItem(
          LucideIcons.messageCircle,
          '${item['comments_count'] ?? 0}',
          const Color(0xFF3182CE),
        ),
        
        // Stats spécifiques par type
        ..._getSpecificStats(),
      ],
    );
  }

  Widget _buildCompactStats() {
    final stats = <Widget>[];
    
    // Likes
    if (item['likes_count'] != null) {
      stats.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              LucideIcons.heart,
              size: 12,
              color: Color(0xFFE53E3E),
            ),
            const SizedBox(width: 2),
            Text(
              '${item['likes_count']}',
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF4A5568),
              ),
            ),
          ],
        ),
      );
    }
    
    // Temps de préparation/lecture
    String? timeText;
    if (contentType == 'recipe' && item['total_time'] != null) {
      timeText = '${item['total_time']}min';
    } else if (contentType == 'tip' && item['estimated_time'] != null) {
      timeText = '${item['estimated_time']}min';
    }
    
    if (timeText != null) {
      if (stats.isNotEmpty) stats.add(const SizedBox(width: 8));
      stats.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              LucideIcons.clock,
              size: 12,
              color: Color(0xFF4A5568),
            ),
            const SizedBox(width: 2),
            Text(
              timeText,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF4A5568),
              ),
            ),
          ],
        ),
      );
    }
    
    return Row(
      children: stats,
    );
  }

  Widget _buildStatItem(IconData icon, String value, Color color, {bool compact = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: compact ? 12 : 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: compact ? 10 : 12,
            color: const Color(0xFF718096),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  List<Widget> _getSpecificStats() {
    switch (contentType) {
      case 'recipe':
        return [
          if (item['cooking_time'] != null) ...[
            const SizedBox(width: 16),
            _buildStatItem(
              LucideIcons.clock,
              '${item['cooking_time']}min',
              const Color(0xFF38A169),
            ),
          ],
          if (item['servings'] != null) ...[
            const SizedBox(width: 16),
            _buildStatItem(
              LucideIcons.users,
              '${item['servings']} pers.',
              const Color(0xFFF4D03F),
            ),
          ],
        ];
      case 'event':
        return [
          if (item['date'] != null) ...[
            const SizedBox(width: 16),
            _buildStatItem(
              LucideIcons.calendar,
              _formatDate(item['date']),
              const Color(0xFF38A169),
            ),
          ],
        ];
      default:
        return [];
    }
  }

  Widget _buildTags() {
    final tags = _getTags();
    if (tags.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: tags.take(3).map((tag) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF7FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Text(
          tag,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 10,
            color: Color(0xFF4A5568),
            fontWeight: FontWeight.w500,
          ),
        ),
      )).toList(),
    );
  }

  String _getTitle() {
    return item['title']?.toString() ?? 'Sans titre';
  }

  String _getDescription() {
    return item['description']?.toString() ?? 
           item['short_description']?.toString() ?? 
           item['content']?.toString() ?? 
           '';
  }

  String _getImageUrl() {
    final url = item['featured_image_url']?.toString() ?? 
                item['image']?.toString() ?? 
                item['thumbnail']?.toString() ?? 
                '';
    // Retourner une chaîne vide si l'URL n'est pas valide
    if (url.isEmpty || url == 'null' || url == 'undefined') {
      return '';
    }
    return url;
  }

  List<String> _getTags() {
    final tags = <String>[];
    
    // Ajouter les tags
    if (item['tags'] != null) {
      if (item['tags'] is List) {
        for (var tag in item['tags']) {
          if (tag is String && tag.isNotEmpty) {
            tags.add(tag);
          }
        }
      } else if (item['tags'] is String && item['tags'].isNotEmpty) {
        tags.add(item['tags']);
      }
    }
    
    // Ajouter la catégorie
    if (item['category'] != null) {
      String categoryName = item['category'] is String 
          ? item['category'] 
          : item['category']['name']?.toString() ?? '';
      if (categoryName.isNotEmpty) {
        tags.insert(0, categoryName);
      }
    }
    
    return tags;
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}';
    } catch (e) {
      return dateString;
    }
  }

  // Méthode pour obtenir l'icône selon le type de contenu
  IconData _getTypeIcon() {
    switch (contentType) {
      case 'recipe':
      case 'recipes':
        return LucideIcons.chefHat;
      case 'tip':
      case 'tips':
        return LucideIcons.lightbulb;
      case 'event':
      case 'events':
        return LucideIcons.calendar;
      case 'video':
      case 'videos':
        return LucideIcons.play;
      default:
        return LucideIcons.fileText;
    }
  }

  // Méthode pour obtenir la plage de dates pour les événements
  String _getEventDateRange() {
    if (contentType != 'event' && contentType != 'events') return 'Événement';
    
    // Essayer différents champs possibles pour la date de début
    final possibleStartDateFields = [
      'date', 'start_date', 'event_date', 'scheduled_date', 
      'datetime', 'event_datetime', 'start_datetime', 'begins_at'
    ];
    
    // Essayer différents champs possibles pour la date de fin
    final possibleEndDateFields = [
      'end_date', 'finish_date', 'event_end_date', 'end_datetime', 
      'event_end_datetime', 'ends_at', 'until'
    ];
    
    String? startDate;
    String? endDate;
    
    // Chercher la date de début
    for (final field in possibleStartDateFields) {
      final value = item[field];
      if (value != null && value.toString().isNotEmpty) {
        startDate = _formatDateShort(value.toString());
        break;
      }
    }
    
    // Chercher la date de fin
    for (final field in possibleEndDateFields) {
      final value = item[field];
      if (value != null && value.toString().isNotEmpty) {
        endDate = _formatDateShort(value.toString());
        break;
      }
    }
    
    // Construire le label en fonction des dates trouvées
    if (startDate != null && endDate != null && startDate != endDate) {
      return '$startDate-$endDate';
    } else if (startDate != null) {
      return startDate;
    } else {
      return 'Événement';
    }
  }

  // Méthodes pour obtenir les labels des badges avec catégories
  String _getRecipeCategoryLabel() {
    String categoryName = '';
    if (item['category'] != null) {
      if (item['category'] is String) {
        categoryName = item['category'];
      } else if (item['category'] is Map && item['category']['name'] != null) {
        categoryName = item['category']['name'].toString();
      }
    }
    return categoryName.isNotEmpty ? categoryName : 'Recette';
  }
  
  String _getTipCategoryLabel() {
    String categoryName = '';
    if (item['category'] != null) {
      if (item['category'] is String) {
        categoryName = item['category'];
      } else if (item['category'] is Map && item['category']['name'] != null) {
        categoryName = item['category']['name'].toString();
      }
    }
    return categoryName.isNotEmpty ? categoryName : 'Astuce';
  }
  
  String _getVideoCategoryLabel() {
    String categoryName = '';
    if (item['category'] != null) {
      if (item['category'] is String) {
        categoryName = item['category'];
      } else if (item['category'] is Map && item['category']['name'] != null) {
        categoryName = item['category']['name'].toString();
      }
    }
    return categoryName.isNotEmpty ? categoryName : 'Vidéo';
  }

  // Méthode pour formater une date courte (ex: "15/03/2024")
  String _formatDateShort(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      // Si ce n'est pas parsable comme DateTime ISO, essayer d'autres formats
      try {
        // Essayer format dd/mm/yyyy
        final parts = dateString.split('/');
        if (parts.length >= 3) {
          return '${parts[0].padLeft(2, '0')}/${parts[1].padLeft(2, '0')}/${parts[2]}';
        } else if (parts.length >= 2) {
          return '${parts[0].padLeft(2, '0')}/${parts[1].padLeft(2, '0')}/${DateTime.now().year}';
        }
      } catch (e) {
        // Essayer format yyyy-mm-dd
        final parts = dateString.split('-');
        if (parts.length >= 3) {
          return '${parts[2].padLeft(2, '0')}/${parts[1].padLeft(2, '0')}/${parts[0]}';
        }
      }
      return dateString.length > 10 ? dateString.substring(0, 10) : dateString;
    }
  }

  // Nouveaux méthodes pour le layout overlay

  List<Widget> _buildOverlayStats() {
    final stats = <Widget>[];
    
    switch (contentType) {
      case 'recipe':
        if (item['cooking_time'] != null) {
          stats.add(_buildOverlayStat(LucideIcons.clock, '${item['cooking_time']}min'));
        }
        if (item['servings'] != null) {
          stats.add(const SizedBox(width: 12));
          stats.add(_buildOverlayStat(LucideIcons.users, '${item['servings']} pers.'));
        }
        break;
        
      case 'event':
        if (item['date'] != null) {
          stats.add(_buildOverlayStat(LucideIcons.calendar, _formatDate(item['date'])));
        }
        break;
        
      case 'tip':
        if (item['likes_count'] != null) {
          stats.add(_buildOverlayStat(LucideIcons.heart, '${item['likes_count']}'));
        }
        break;
    }
    
    // Ajouter les likes/commentaires si disponibles
    if (item['likes_count'] != null && contentType != 'tip') {
      if (stats.isNotEmpty) stats.add(const SizedBox(width: 12));
      stats.add(_buildOverlayStat(LucideIcons.heart, '${item['likes_count']}'));
    }
    
    return stats;
  }

  Widget _buildOverlayStat(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.white,
          shadows: [
            Shadow(
              offset: const Offset(0, 1),
              blurRadius: 2,
              color: Colors.black.withOpacity(0.8),
            ),
          ],
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            shadows: [
              Shadow(
                offset: const Offset(0, 1),
                blurRadius: 2,
                color: Colors.black.withOpacity(0.8),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverlayTypeBadge() {
    IconData icon;
    String label;

    switch (contentType) {
      case 'recipe':
      case 'recipes':
        icon = LucideIcons.chefHat;
        label = _getRecipeCategoryLabel();
        break;
      case 'tip':
      case 'tips':
        icon = LucideIcons.lightbulb;
        label = _getTipCategoryLabel();
        break;
      case 'event':
      case 'events':
        icon = LucideIcons.calendar;
        label = _getEventDateRange();
        break;
      case 'video':
      case 'videos':
        icon = LucideIcons.play;
        label = _getVideoCategoryLabel();
        break;
      default:
        icon = LucideIcons.fileText;
        label = 'Contenu';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: Colors.white,
            shadows: [
              Shadow(
                offset: const Offset(0, 1),
                blurRadius: 2,
                color: Colors.black.withOpacity(0.8),
              ),
            ],
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              shadows: [
                Shadow(
                  offset: const Offset(0, 1),
                  blurRadius: 2,
                  color: Colors.black.withOpacity(0.8),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 