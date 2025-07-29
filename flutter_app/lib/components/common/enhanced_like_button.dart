/**
 * ENHANCED_LIKE_BUTTON.DART - BOUTON DE LIKE AVEC SYNCHRONISATION EN TEMPS RÉEL
 * 
 * FONCTIONNALITÉS :
 * - Compteurs de likes exacts synchronisés avec l'API
 * - Animation smooth lors des interactions
 * - Gestion d'authentification automatique
 * - Mise à jour automatique des compteurs
 * - Retry automatique en cas d'erreur
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../services/enhanced_likes_service.dart';
import '../../composables/use_auth_handler.dart';

class EnhancedLikeButton extends ConsumerStatefulWidget {
  final String type;
  final String itemId;
  final bool initialLiked;
  final int initialCount;
  final bool showCount;
  final String size;
  final String variant;
  final VoidCallback? onAuthRequired;
  final bool autoFetch; // Récupérer automatiquement les compteurs exacts

  const EnhancedLikeButton({
    Key? key,
    required this.type,
    required this.itemId,
    this.initialLiked = false,
    this.initialCount = 0,
    this.showCount = true,
    this.size = 'medium',
    this.variant = 'standard',
    this.onAuthRequired,
    this.autoFetch = true,
  }) : super(key: key);

  @override
  ConsumerState<EnhancedLikeButton> createState() => _EnhancedLikeButtonState();
}

class _EnhancedLikeButtonState extends ConsumerState<EnhancedLikeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Initialiser les données
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(enhancedLikesProvider.notifier).setInitialData(
        widget.type,
        widget.itemId,
        widget.initialLiked,
        widget.initialCount,
      );
      
      // Récupérer les compteurs exacts si demandé
      if (widget.autoFetch) {
        _fetchExactCounts();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchExactCounts() async {
    try {
      print('🔍 [EnhancedLikeButton] Récupération compteurs exacts pour ${widget.type}:${widget.itemId}');
      await ref.read(enhancedLikesProvider.notifier).fetchContentLikes(
        widget.type,
        widget.itemId,
      );
    } catch (e) {
      print('❌ [EnhancedLikeButton] Erreur récupération compteurs: $e');
    }
  }

  Future<void> _toggleLike() async {
    if (_isProcessing) return;
    
    final authState = ref.read(useAuthHandlerProvider);
    if (!authState.isAuthenticated) {
      print('🔐 [EnhancedLikeButton] Authentification requise');
      widget.onAuthRequired?.call();
      return;
    }

    setState(() => _isProcessing = true);
    
    try {
      print('❤️ [EnhancedLikeButton] Toggle like ${widget.type}:${widget.itemId}');
      
      // Animation immédiate pour la responsivité
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
      
      final success = await ref.read(enhancedLikesProvider.notifier).toggleLike(
        widget.type,
        widget.itemId,
      );
      
      if (success) {
        print('✅ [EnhancedLikeButton] Like toggled successfully');
        
        // Feedback haptic
        if (Theme.of(context).platform == TargetPlatform.iOS) {
          // HapticFeedback.lightImpact();
        }
        
        // Message de confirmation subtil
        if (mounted) {
          final likesState = ref.read(enhancedLikesProvider);
          final isNowLiked = likesState.isLiked(widget.type, widget.itemId);
          final count = likesState.getLikeCount(widget.type, widget.itemId);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isNowLiked 
                  ? '❤️ Ajouté aux favoris ($count likes)'
                  : '💔 Retiré des favoris ($count likes)',
              ),
              duration: const Duration(seconds: 2),
              backgroundColor: isNowLiked 
                ? const Color(0xFFE53E3E)
                : Colors.grey[600],
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      } else {
        throw Exception('Toggle failed');
      }
    } catch (e) {
      print('❌ [EnhancedLikeButton] Erreur toggle: $e');
      
      if (e.toString().contains('Authentification requise')) {
        widget.onAuthRequired?.call();
      } else {
        // Afficher erreur
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('❌ Erreur lors de la mise à jour du like'),
              duration: const Duration(seconds: 3),
              backgroundColor: Colors.red[600],
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              action: SnackBarAction(
                label: 'Réessayer',
                textColor: Colors.white,
                onPressed: _toggleLike,
              ),
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final likesState = ref.watch(enhancedLikesProvider);
    final isLiked = likesState.isLiked(widget.type, widget.itemId);
    final count = likesState.getLikeCount(widget.type, widget.itemId);
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: GestureDetector(
              onTap: _isProcessing ? null : _toggleLike,
              child: Container(
                padding: _getPadding(),
                decoration: _getDecoration(isLiked),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Icône principale
                        Icon(
                          isLiked ? LucideIcons.heart : LucideIcons.heart,
                          size: _getIconSize(),
                          color: _getIconColor(isLiked),
                        ),
                        
                        // Indicateur de chargement
                        if (_isProcessing)
                          SizedBox(
                            width: _getIconSize() * 1.5,
                            height: _getIconSize() * 1.5,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getIconColor(isLiked).withOpacity(0.5),
                              ),
                            ),
                          ),
                      ],
                    ),
                    
                    if (widget.showCount) ...[
                      const SizedBox(width: 6),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          '$count',
                          key: ValueKey(count),
                          style: TextStyle(
                            fontSize: _getFontSize(),
                            fontWeight: FontWeight.w600,
                            color: _getTextColor(isLiked),
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ),
                    ],
                    
                    // Indicateur de synchronisation
                    if (likesState.isSyncing)
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.grey[400]!,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  EdgeInsets _getPadding() {
    switch (widget.size) {
      case 'small':
        return const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
      case 'large':
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
      default: // medium
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case 'small':
        return 16;
      case 'large':
        return 26;
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
          boxShadow: isLiked ? [
            BoxShadow(
              color: const Color(0xFFE53E3E).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        );
      default: // standard
        return BoxDecoration(
          color: isLiked ? const Color(0xFFE53E3E).withOpacity(0.1) : Colors.transparent,
          border: Border.all(
            color: isLiked ? const Color(0xFFE53E3E) : Colors.grey[300]!,
            width: isLiked ? 2 : 1,
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
      return widget.variant == 'filled' ? Colors.white : const Color(0xFFE53E3E);
    }
    
    switch (widget.variant) {
      case 'filled':
        return Colors.grey[600]!;
      default:
        return const Color(0xFF4A5568);
    }
  }

  Color _getTextColor(bool isLiked) {
    if (isLiked) {
      return widget.variant == 'filled' ? Colors.white : const Color(0xFFE53E3E);
    }
    
    switch (widget.variant) {
      case 'filled':
        return Colors.grey[600]!;
      default:
        return const Color(0xFF4A5568);
    }
  }
}