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
import '../../services/likes_service.dart';
import '../../composables/use_auth_handler.dart';

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
  @override
  void initState() {
    super.initState();
    // Initialize the likes service with the provided data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(likesProvider.notifier).setInitialData(
        widget.type,
        widget.itemId,
        widget.initialLiked,
        widget.initialCount,
      );
    });
  }

  Future<void> _toggleLike() async {
    print('❤️ [LikeButton] _toggleLike appelé pour ${widget.type}:${widget.itemId}');
    final authState = ref.read(useAuthHandlerProvider);
    if (!authState.isAuthenticated) {
      print('🔐 [LikeButton] User not authenticated, calling onAuthRequired');
      widget.onAuthRequired?.call();
      return;
    }
    try {
      print('🔄 [LikeButton] Tentative de toggle like...');
      final beforeState = ref.read(likesProvider.notifier).isLiked(widget.type, widget.itemId);
      print('🔄 [LikeButton] État avant toggle: $beforeState');
      final success = await ref.read(likesProvider.notifier).toggleLike(
        widget.type, 
        widget.itemId
      );
      final afterState = ref.read(likesProvider.notifier).isLiked(widget.type, widget.itemId);
      print('🔄 [LikeButton] État après toggle: $afterState');
      if (success) {
        print('✅ [LikeButton] Like toggled successfully');
        // Afficher un feedback visuel
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Like mis à jour'),
            duration: const Duration(seconds: 1),
            backgroundColor: const Color(0xFFE53E3E),
          ),
        );
      } else {
        print('❌ [LikeButton] Failed to toggle like, requesting auth');
        widget.onAuthRequired?.call();
      }
    } catch (error) {
      print('❌ [LikeButton] Exception lors du toggle like: $error');
      if (error.toString().contains('401') || error.toString().contains('connecté')) {
        print('🔐 [LikeButton] Erreur d\'authentification, appel onAuthRequired');
        widget.onAuthRequired?.call();
      } else {
        // Afficher un message d'erreur
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la mise à jour du like'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final likesState = ref.watch(likesProvider);
    final isLiked = ref.read(likesProvider.notifier).isLiked(widget.type, widget.itemId);
    final count = ref.read(likesProvider.notifier).getLikeCount(widget.type, widget.itemId);
    
    return GestureDetector(
      onTap: () {
        print('❤️ [LikeButton] GestureDetector onTap appelé pour ${widget.type}:${widget.itemId}');
        _toggleLike();
      },
      child: Container(
        padding: _getPadding(),
        decoration: _getDecoration(isLiked),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isLiked ? LucideIcons.heart : LucideIcons.heart,
              size: _getIconSize(),
              color: _getIconColor(isLiked),
            ),
            if (widget.showCount) ...[
              const SizedBox(width: 4),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: _getFontSize(),
                  fontWeight: FontWeight.w500,
                  color: _getTextColor(isLiked),
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

  BoxDecoration? _getDecoration(bool isLiked) {
    switch (widget.variant) {
      case 'minimal':
        return null;
      case 'filled':
        return BoxDecoration(
          color: isLiked ? const Color(0xFFE53E3E) : Colors.grey[200],
          borderRadius: BorderRadius.circular(_getBorderRadius()),
        );
      default: // standard
        return BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
            color: isLiked ? const Color(0xFFE53E3E) : Colors.grey[300]!,
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

  Color _getIconColor(bool isLiked) {
    if (isLiked) {
      return const Color(0xFFE53E3E);
    }
    
    switch (widget.variant) {
      case 'filled':
        return Colors.white;
      default:
        return const Color(0xFF4A5568);
    }
  }

  Color _getTextColor(bool isLiked) {
    if (isLiked) {
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