import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../services/favorites_service.dart';
import '../../composables/use_auth_handler.dart';

class FavoriteButton extends ConsumerStatefulWidget {
  final String type;
  final String itemId;
  final bool initialFavorited;
  final int initialCount;
  final bool showCount;
  final double size;
  final String variant;
  final Function(bool)? onFavoriteChanged;
  final VoidCallback? onAuthRequired;

  const FavoriteButton({
    Key? key,
    required this.type,
    required this.itemId,
    this.initialFavorited = false,
    this.initialCount = 0,
    this.showCount = true,
    this.size = 24.0,
    this.variant = 'default',
    this.onFavoriteChanged,
    this.onAuthRequired,
  }) : super(key: key);

  @override
  ConsumerState<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends ConsumerState<FavoriteButton>
    with SingleTickerProviderStateMixin {
  bool _isFavorited = false;
  int _favoritesCount = 0;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _isFavorited = widget.initialFavorited;
    _favoritesCount = widget.initialCount;
    
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

    _loadFavoriteStatus();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(FavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialFavorited != widget.initialFavorited) {
      setState(() {
        _isFavorited = widget.initialFavorited;
      });
    }
    if (oldWidget.initialCount != widget.initialCount) {
      setState(() {
        _favoritesCount = widget.initialCount;
      });
    }
  }

  Future<void> _loadFavoriteStatus() async {
    final authState = ref.read(useAuthHandlerProvider);
    if (!authState.isAuthenticated) {
      setState(() {
        _isFavorited = false;
      });
      return;
    }

    try {
      final favoritesService = ref.read(favoritesServiceProvider.notifier);
      final isFavorited = await favoritesService.checkFavorite(widget.type, widget.itemId);
      
      if (mounted) {
        setState(() {
          _isFavorited = isFavorited;
        });
      }
    } catch (error) {
      print('❌ [FavoriteButton] Erreur vérification statut favori: $error');
    }
  }

  Future<void> _toggleFavorite() async {
    print('🌟 [FavoriteButton] Clic détecté sur bouton favori');
    print('   - Type: ${widget.type}');
    print('   - ItemId: ${widget.itemId}');
    
    final authState = ref.read(useAuthHandlerProvider);
    if (!authState.isAuthenticated) {
      print('🔒 [FavoriteButton] Utilisateur non connecté');
      widget.onAuthRequired?.call();
      return;
    }

    if (_isLoading) {
      print('⏳ [FavoriteButton] Déjà en cours de chargement');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final previousState = _isFavorited;
    final previousCount = _favoritesCount;

    // Mise à jour optimiste
    setState(() {
      _isFavorited = !_isFavorited;
      _favoritesCount += _isFavorited ? 1 : -1;
    });

    // Animation
    if (_isFavorited) {
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
    }

    try {
      final favoritesService = ref.read(favoritesServiceProvider.notifier);
      bool success = false;
      
      if (_isFavorited) {
        success = await favoritesService.addFavorite(widget.type, widget.itemId);
      } else {
        // Pour supprimer, on doit d'abord trouver l'ID du favori
        final favoritesState = ref.read(favoritesServiceProvider);
        final favorite = favoritesState.favorites.firstWhere(
          (f) => f.type == widget.type && f.content['id'].toString() == widget.itemId,
          orElse: () => throw Exception('Favori non trouvé'),
        );
        success = await favoritesService.removeFavorite(favorite.id);
      }

      if (!success) {
        throw Exception('Échec de la mise à jour des favoris');
      }

      // Notifier le parent du changement
      widget.onFavoriteChanged?.call(_isFavorited);

      print('✅ [FavoriteButton] Toggle réussi: ${_isFavorited ? "ajouté" : "supprimé"}');
      
    } catch (error) {
      print('❌ [FavoriteButton] Erreur toggle: $error');
      
      // Annuler la mise à jour optimiste
      setState(() {
        _isFavorited = previousState;
        _favoritesCount = previousCount;
      });

      // Vérifier si c'est une erreur d'authentification
      if (error.toString().contains('401') || error.toString().contains('Authentication')) {
        print('🔒 [FavoriteButton] Erreur d\'authentification détectée');
        widget.onAuthRequired?.call();
      } else {
        // Afficher un message d'erreur pour les autres types d'erreurs
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${error.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatCount(int count) {
    if (count < 1000) return count.toString();
    if (count < 1000000) return '${(count / 1000).toStringAsFixed(1)}k';
    return '${(count / 1000000).toStringAsFixed(1)}M';
  }

  Color get _buttonColor {
    if (_isFavorited) {
      return const Color(0xFFE53E3E); // Rouge Dinor
    }
    return const Color(0xFF718096); // Gris
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isLoading ? null : _toggleFavorite,
        borderRadius: BorderRadius.circular(widget.variant == 'compact' ? 16 : 24),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _isFavorited ? _scaleAnimation.value : 1.0,
              child: Container(
                padding: _getPadding(),
                decoration: _getDecoration(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isLoading) ...[
                      SizedBox(
                        width: widget.size * 0.8,
                        height: widget.size * 0.8,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(_buttonColor),
                        ),
                      ),
                    ] else ...[
                      Icon(
                        _isFavorited ? LucideIcons.heart : LucideIcons.heart,
                        size: widget.size,
                        color: _buttonColor,
                      ),
                    ],
                    
                    if (widget.showCount && _favoritesCount > 0) ...[
                      const SizedBox(width: 6),
                      Text(
                        _formatCount(_favoritesCount),
                        style: TextStyle(
                          fontSize: widget.size * 0.5,
                          fontWeight: FontWeight.w500,
                          color: _buttonColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  EdgeInsets _getPadding() {
    switch (widget.variant) {
      case 'compact':
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case 'minimal':
        return const EdgeInsets.all(4);
      default:
        return const EdgeInsets.all(8);
    }
  }

  BoxDecoration? _getDecoration() {
    switch (widget.variant) {
      case 'compact':
        return BoxDecoration(
          color: const Color(0xFFF7FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1,
          ),
        );
      default:
        return null;
    }
  }
}