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
import '../../stores/auth_store.dart';

class LikeButton extends ConsumerStatefulWidget {
  final String type;
  final String itemId;
  final bool initialLiked;
  final int initialCount;
  final bool showCount;
  final String size; // small, medium, large
  final String variant; // minimal, filled
  final VoidCallback? onAuthRequired;

  const LikeButton({
    Key? key,
    required this.type,
    required this.itemId,
    this.initialLiked = false,
    this.initialCount = 0,
    this.showCount = true,
    this.size = 'medium',
    this.variant = 'filled',
    this.onAuthRequired,
  }) : super(key: key);

  @override
  ConsumerState<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends ConsumerState<LikeButton>
    with SingleTickerProviderStateMixin {
  late bool _isLiked;
  late int _likeCount;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.initialLiked;
    _likeCount = widget.initialCount;

    // Animation identique à Vue (scale + couleur)
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // REPRODUCTION EXACTE de toggleLike() Vue
  Future<void> _toggleLike() async {
    final authStore = ref.read(authStoreProvider);

    // Vérifier l'authentification (identique Vue)
    if (!authStore.isAuthenticated) {
      print('🔒 [LikeButton] Authentification requise pour liker');
      widget.onAuthRequired?.call();
      return;
    }

    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    // Animation immédiate (optimistic update identique Vue)
    final previousLiked = _isLiked;
    final previousCount = _likeCount;

    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });

    // Animation du coeur
    if (_isLiked) {
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
    }

    try {
      print('❤️ [LikeButton] Toggle like: ${widget.type} ${widget.itemId}');

      final data = await ApiService.instance.toggleLike(widget.type, widget.itemId);

      if (data['success'] == true) {
        // Mise à jour avec les données serveur (identique Vue)
        final serverLiked = data['data']?['is_liked'] ?? _isLiked;
        final serverCount = data['data']?['total_likes'] ?? _likeCount;

        setState(() {
          _isLiked = serverLiked;
          _likeCount = serverCount;
        });

        print('✅ [LikeButton] Like mis à jour: liked=$serverLiked, count=$serverCount');

        // Émettre événement global (équivalent window.dispatchEvent Vue)
        // TODO: Implémenter système d'événements global si nécessaire
      } else {
        throw Exception(data['message'] ?? 'Erreur lors du toggle like');
      }
    } catch (error) {
      print('❌ [LikeButton] Erreur toggle like: $error');

      // Rollback en cas d'erreur (identique Vue)
      setState(() {
        _isLiked = previousLiked;
        _likeCount = previousCount;
      });

      // Afficher erreur à l'utilisateur
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la mise à jour du like'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconSize = _getIconSize();
    final textSize = _getTextSize();
    
    return GestureDetector(
      onTap: _isLoading ? null : _toggleLike,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icône coeur avec animation
                Icon(
                  _isLiked ? LucideIcons.heart : LucideIcons.heart,
                  size: iconSize,
                  color: _isLiked
                      ? const Color(0xFFE53E3E) // Rouge like identique
                      : (widget.variant == 'minimal'
                          ? const Color(0xFF8B7000) // Doré minimal
                          : const Color(0xFF4A5568)), // Gris par défaut
                ),

                // Compteur si demandé
                if (widget.showCount) ...[
                  const SizedBox(width: 4),
                  Text(
                    '$_likeCount',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: textSize,
                      fontWeight: FontWeight.w500,
                      color: _isLiked
                          ? const Color(0xFFE53E3E)
                          : const Color(0xFF4A5568),
                    ),
                  ),
                ],

                // Loading indicator
                if (_isLoading) ...[
                  const SizedBox(width: 8),
                  SizedBox(
                    width: iconSize * 0.8,
                    height: iconSize * 0.8,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFFE53E3E),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  double _getIconSize() {
    switch (widget.size) {
      case 'small':
        return 16;
      case 'medium':
        return 20;
      case 'large':
        return 24;
      default:
        return 20;
    }
  }

  double _getTextSize() {
    switch (widget.size) {
      case 'small':
        return 12;
      case 'medium':
        return 14;
      case 'large':
        return 16;
      default:
        return 14;
    }
  }
}