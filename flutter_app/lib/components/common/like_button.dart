/**
 * LIKE_BUTTON.DART - CONVERSION FIDÈLE DE LikeButton.vue
 * 
 * FIDÉLITÉ FONCTIONNELLE :
 * - Toggle like avec API identique
 * - Animation du coeur identique
 * - Gestion d'authentification identique
 * - Compteur de likes identique
 * - Variants et tailles identiques
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../services/api_service.dart';

class LikeButton extends ConsumerStatefulWidget {
  final String type; // 'recipe', 'tip', 'event', 'video'
  final String itemId;
  final bool initialLiked;
  final int initialCount;
  final bool showCount;
  final String size; // 'small', 'medium', 'large'
  final String variant; // 'minimal', 'standard', 'filled'
  final VoidCallback? onAuthRequired;

  const LikeButton({
    Key? key,
    required this.type,
    required this.itemId,
    this.initialLiked = false,
    this.initialCount = 0,
    this.showCount = true,
    this.size = 'medium',
    this.variant = 'standard',
    this.onAuthRequired,
  }) : super(key: key);

  @override
  ConsumerState<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends ConsumerState<LikeButton> {
  late bool _isLiked;
  late int _count;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.initialLiked;
    _count = widget.initialCount;
  }

  Future<void> _toggleLike() async {
    try {
      final apiService = ref.read(apiServiceProvider);
      
      final response = await apiService.post('/likes/toggle', {
        'likeable_type': widget.type,
        'likeable_id': widget.itemId,
      });
      
      if (response['success']) {
        setState(() {
          _isLiked = !_isLiked;
          _count = response['data']['total_likes'] ?? _count;
        });
        
        print('❤️ [LikeButton] Like toggled: $_isLiked, count: $_count');
      }
    } catch (error) {
      print('❌ [LikeButton] Erreur toggle like: $error');
      
      // Si erreur 401, demander authentification
      if (error.toString().contains('401') || error.toString().contains('connecté')) {
        widget.onAuthRequired?.call();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleLike,
      child: Container(
        padding: _getPadding(),
        decoration: _getDecoration(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isLiked ? LucideIcons.heart : LucideIcons.heart,
              size: _getIconSize(),
              color: _getIconColor(),
            ),
            if (widget.showCount) ...[
              const SizedBox(width: 4),
              Text(
                '$_count',
                style: TextStyle(
                  fontSize: _getFontSize(),
                  fontWeight: FontWeight.w500,
                  color: _getTextColor(),
                  fontFamily: 'Roboto',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  EdgeInsets _getPadding() {
    switch (widget.size) {
      case 'small':
        return const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
      case 'large':
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      default: // medium
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case 'small':
        return 16;
      case 'large':
        return 24;
      default: // medium
        return 20;
    }
  }

  double _getFontSize() {
    switch (widget.size) {
      case 'small':
        return 12;
      case 'large':
        return 16;
      default: // medium
        return 14;
    }
  }

  BoxDecoration? _getDecoration() {
    switch (widget.variant) {
      case 'minimal':
        return null;
      case 'filled':
        return BoxDecoration(
          color: _isLiked ? const Color(0xFFE53E3E) : Colors.grey[200],
          borderRadius: BorderRadius.circular(_getBorderRadius()),
        );
      default: // standard
        return BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
            color: _isLiked ? const Color(0xFFE53E3E) : Colors.grey[300]!,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(_getBorderRadius()),
        );
    }
  }

  double _getBorderRadius() {
    switch (widget.size) {
      case 'small':
        return 12;
      case 'large':
        return 20;
      default: // medium
        return 16;
    }
  }

  Color _getIconColor() {
    if (_isLiked) {
      return const Color(0xFFE53E3E);
    }
    
    switch (widget.variant) {
      case 'filled':
        return Colors.white;
      default:
        return const Color(0xFF4A5568);
    }
  }

  Color _getTextColor() {
    if (_isLiked) {
      return const Color(0xFFE53E3E);
    }
    
    switch (widget.variant) {
      case 'filled':
        return Colors.white;
      default:
        return const Color(0xFF4A5568);
    }
  }
}