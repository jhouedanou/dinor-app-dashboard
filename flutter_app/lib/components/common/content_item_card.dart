import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../services/image_service.dart';

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
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: compact ? _buildCompactCard() : _buildFullCard(),
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
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Image compacte
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xFFF7FAFC),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: ImageService.buildCachedNetworkImage(
                imageUrl: _getImageUrl(),
                contentType: contentType,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Contenu
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getTitle(),
                  style: const TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (_getDescription().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    _getDescription(),
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 12,
                      color: Color(0xFF718096),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                _buildCompactStats(),
              ],
            ),
          ),
          
          // Flèche
          const Icon(
            LucideIcons.chevronRight,
            size: 20,
            color: Color(0xFF718096),
          ),
        ],
      ),
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
            child: ImageService.buildCachedNetworkImage(
              imageUrl: _getImageUrl(),
              contentType: contentType,
              fit: BoxFit.cover,
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
        icon = LucideIcons.chefHat;
        label = 'Recette';
        color = const Color(0xFF38A169);
        break;
      case 'tip':
        icon = LucideIcons.lightbulb;
        label = 'Astuce';
        color = const Color(0xFF3182CE);
        break;
      case 'event':
        icon = LucideIcons.calendar;
        label = 'Événement';
        color = const Color(0xFFE53E3E);
        break;
      default:
        icon = LucideIcons.fileText;
        label = 'Contenu';
        color = const Color(0xFF718096);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.9),
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
    return Row(
      children: [
        _buildStatItem(
          LucideIcons.heart,
          '${item['likes_count'] ?? 0}',
          const Color(0xFFE53E3E),
          compact: true,
        ),
        const SizedBox(width: 12),
        _buildStatItem(
          LucideIcons.messageCircle,
          '${item['comments_count'] ?? 0}',
          const Color(0xFF3182CE),
          compact: true,
        ),
      ],
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
    return item['featured_image_url']?.toString() ?? 
           item['image']?.toString() ?? 
           item['thumbnail']?.toString() ?? 
           '';
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
} 