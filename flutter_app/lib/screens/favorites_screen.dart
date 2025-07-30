import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../services/favorites_service.dart';
import '../composables/use_auth_handler.dart';
import '../components/common/favorite_button.dart';
import '../components/common/auth_modal.dart';
import 'dinor_tv_screen.dart';
import '../services/navigation_service.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  String _selectedFilter = 'all';
  bool _showAuthModal = false;

  final List<Map<String, dynamic>> _filterTabs = [
    {'key': 'all', 'label': 'Tout', 'icon': LucideIcons.grid},
    {'key': 'recipe', 'label': 'Recettes', 'icon': LucideIcons.utensils},
    {'key': 'tip', 'label': 'Astuces', 'icon': LucideIcons.lightbulb},
    {'key': 'event', 'label': 'Événements', 'icon': LucideIcons.calendar},
    {'key': 'dinor_tv', 'label': 'Vidéos', 'icon': LucideIcons.play},
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final authState = ref.read(useAuthHandlerProvider);
      if (authState.isAuthenticated) {
        ref.read(favoritesServiceProvider.notifier).loadFavorites(refresh: true);
      }
    });
  }

  List<Favorite> get _filteredFavorites {
    final favoritesState = ref.watch(favoritesServiceProvider);
    final favorites = favoritesState.favorites;
    
    if (_selectedFilter == 'all') return favorites;
    return favorites.where((favorite) => favorite.type == _selectedFilter).toList();
  }

  int _getFilterCount(String filterKey) {
    final favoritesState = ref.watch(favoritesServiceProvider);
    final favorites = favoritesState.favorites;
    
    if (filterKey == 'all') return favorites.length;
    return favorites.where((favorite) => favorite.type == filterKey).length;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(useAuthHandlerProvider);
    final favoritesState = ref.watch(favoritesServiceProvider);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          appBar: AppBar(
            title: const Text(
              'Mes Favoris',
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            backgroundColor: const Color(0xFFE53E3E),
            elevation: 0,
          ),
          body: _buildBody(authState, favoritesState),
        ),
        
        // Modal d'authentification
        if (_showAuthModal) ...[
          Positioned.fill(
            child: Container(
              color: Colors.black54,
              child: GestureDetector(
                onTap: () => setState(() => _showAuthModal = false),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          Positioned.fill(
            child: AuthModal(
              isOpen: _showAuthModal,
              onClose: () => setState(() => _showAuthModal = false),
              onAuthenticated: () async {
                setState(() => _showAuthModal = false);
                await ref.read(favoritesServiceProvider.notifier).loadFavorites(refresh: true);
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBody(dynamic authState, FavoritesState favoritesState) {
    if (favoritesState.isLoading) {
      return _buildLoadingState();
    }

    if (!authState.isAuthenticated) {
      return _buildAuthRequired();
    }

    if (favoritesState.error != null) {
      return _buildErrorState(favoritesState.error!);
    }

    return _buildFavoritesContent(favoritesState);
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE53E3E)),
          ),
          SizedBox(height: 16),
          Text(
            'Chargement de vos favoris...',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 16,
              color: Color(0xFF4A5568),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthRequired() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFE53E3E).withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                LucideIcons.heart,
                size: 48,
                color: Color(0xFFE53E3E),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Connexion requise',
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Connectez-vous pour voir vos contenus favoris',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 16,
                color: Color(0xFF4A5568),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => setState(() => _showAuthModal = true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53E3E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Se connecter'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              LucideIcons.alertCircle,
              size: 64,
              color: Color(0xFFE53E3E),
            ),
            const SizedBox(height: 16),
            const Text(
              'Erreur de chargement',
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 14,
                color: Color(0xFF4A5568),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => ref.read(favoritesServiceProvider.notifier).loadFavorites(refresh: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53E3E),
                foregroundColor: Colors.white,
              ),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesContent(FavoritesState favoritesState) {
    final totalFavorites = favoritesState.favorites.length;
    final filteredFavorites = _filteredFavorites;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(totalFavorites),
          const SizedBox(height: 24),

          // Filter Tabs
          if (totalFavorites > 0) ...[
            _buildFilterTabs(),
            const SizedBox(height: 24),
          ],

          // Content
          if (filteredFavorites.isNotEmpty)
            _buildFavoritesList(filteredFavorites)
          else
            _buildEmptyState(),
        ],
      ),
    );
  }

  Widget _buildHeader(int totalFavorites) {
    return Column(
      children: [
        const Text(
          'Mes Favoris',
          style: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$totalFavorites ${totalFavorites > 1 ? 'favoris' : 'favori'}',
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 16,
            color: Color(0xFF4A5568),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filterTabs.map((tab) {
          final isActive = _selectedFilter == tab['key'];
          final count = _getFilterCount(tab['key']);
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = tab['key']),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFFE53E3E) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive ? const Color(0xFFE53E3E) : const Color(0xFFE2E8F0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      tab['icon'],
                      size: 18,
                      color: isActive ? Colors.white : const Color(0xFF4A5568),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      tab['label'],
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isActive ? Colors.white : const Color(0xFF4A5568),
                      ),
                    ),
                    if (count > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isActive 
                              ? Colors.white.withOpacity(0.2)
                              : const Color(0xFFE53E3E).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          count.toString(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isActive ? Colors.white : const Color(0xFFE53E3E),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFavoritesList(List<Favorite> favorites) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final favorite = favorites[index];
        return _buildFavoriteItem(favorite);
      },
    );
  }

  Widget _buildFavoriteItem(Favorite favorite) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _goToContent(favorite),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 80,
                  height: 80,
                  child: Stack(
                    children: [
                      Image.network(
                        favorite.content['image'] ?? _getDefaultImage(favorite.type),
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFFF4D03F),
                            child: Icon(
                              _getTypeIcon(favorite.type),
                              color: const Color(0xFF2D3748),
                              size: 32,
                            ),
                          );
                        },
                      ),
                      Positioned(
                        top: 6,
                        left: 6,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE53E3E),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getTypeIcon(favorite.type),
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      favorite.content['title'] ?? 'Sans titre',
                      style: const TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3748),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getShortDescription(favorite.content['description']),
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14,
                        color: Color(0xFF4A5568),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          LucideIcons.clock,
                          size: 16,
                          color: Color(0xFF718096),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Ajouté ${_formatDate(favorite.favoritedAt)}',
                          style: const TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 12,
                            color: Color(0xFF718096),
                          ),
                        ),
                        const Spacer(),
                        if (favorite.content['likes_count'] != null &&
                            favorite.content['likes_count'] > 0) ...[
                          const Icon(
                            LucideIcons.thumbsUp,
                            size: 14,
                            color: Color(0xFF718096),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${favorite.content['likes_count']}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF718096),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Favorite Button
              FavoriteButton(
                type: favorite.type,
                itemId: favorite.content['id'].toString(),
                initialFavorited: true,
                initialCount: favorite.content['favorites_count'] ?? 0,
                showCount: false,
                size: 20,
                onFavoriteChanged: (isFavorited) {
                  if (!isFavorited) {
                    // Recharger les favoris pour mettre à jour la liste
                    ref.read(favoritesServiceProvider.notifier).loadFavorites(refresh: true);
                  }
                },
                onAuthRequired: () => setState(() => _showAuthModal = true),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              LucideIcons.heart,
              size: 64,
              color: const Color(0xFFCBD5E0),
            ),
            const SizedBox(height: 16),
            Text(
              _getEmptyTitle(),
              style: const TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getEmptyMessage(),
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 14,
                color: Color(0xFF4A5568),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53E3E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(_getExploreButtonText()),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Methods
  void _goToContent(Favorite favorite) {
    final contentId = favorite.content['id']?.toString();
    if (contentId == null) return;

    print('🔗 [FavoritesScreen] Navigation vers ${favorite.type}:$contentId');

    switch (favorite.type) {
      case 'recipe':
        NavigationService.pushNamed('/recipe-detail-unified/$contentId');
        break;
      case 'tip':
        NavigationService.pushNamed('/tip-detail-unified/$contentId');
        break;
      case 'event':
        NavigationService.pushNamed('/event-detail-unified/$contentId');
        break;
      case 'dinor_tv':
        NavigationService.pushNamed('/dinor-tv-screen');
        break;
      default:
        print('❌ [FavoritesScreen] Type de contenu non supporté: ${favorite.type}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Type de contenu non supporté: ${favorite.type}'),
            backgroundColor: Colors.red,
          ),
        );
    }
  }

  String _getShortDescription(String? description) {
    if (description == null || description.isEmpty) {
      return 'Aucune description disponible';
    }
    // Nettoyer les balises HTML
    final cleanText = description.replaceAll(RegExp(r'<[^>]*>'), '');
    return cleanText.length > 120 ? '${cleanText.substring(0, 120)}...' : cleanText;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'aujourd\'hui';
    } else if (difference.inDays == 1) {
      return 'hier';
    } else if (difference.inDays < 7) {
      return 'il y a ${difference.inDays} jours';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).ceil();
      return 'il y a $weeks semaine${weeks > 1 ? 's' : ''}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _getDefaultImage(String type) {
    final defaults = {
      'recipe': 'https://new.dinorapp.com/images/default-recipe.jpg',
      'tip': 'https://new.dinorapp.com/images/default-tip.jpg',
      'event': 'https://new.dinorapp.com/images/default-event.jpg',
      'dinor_tv': 'https://new.dinorapp.com/images/default-video.jpg',
    };
    return defaults[type] ?? 'https://new.dinorapp.com/images/default-content.jpg';
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'recipe':
        return LucideIcons.utensils;
      case 'tip':
        return LucideIcons.lightbulb;
      case 'event':
        return LucideIcons.calendar;
      case 'dinor_tv':
        return LucideIcons.play;
      default:
        return LucideIcons.file;
    }
  }

  String _getEmptyTitle() {
    final titles = {
      'all': 'Aucun favori',
      'recipe': 'Aucune recette favorite',
      'tip': 'Aucune astuce favorite',
      'event': 'Aucun événement favori',
      'dinor_tv': 'Aucune vidéo favorite',
    };
    return titles[_selectedFilter] ?? 'Aucun favori';
  }

  String _getEmptyMessage() {
    final messages = {
      'all': 'Ajoutez du contenu à vos favoris en cliquant sur l\'icône cœur',
      'recipe': 'Parcourez les recettes et ajoutez vos préférées aux favoris',
      'tip': 'Découvrez des astuces utiles et sauvegardez-les',
      'event': 'Trouvez des événements intéressants et ajoutez-les aux favoris',
      'dinor_tv': 'Regardez des vidéos et ajoutez vos préférées aux favoris',
    };
    return messages[_selectedFilter] ?? 'Commencez à explorer le contenu Dinor';
  }

  String _getExploreButtonText() {
    final texts = {
      'all': 'Explorer le contenu',
      'recipe': 'Voir les recettes',
      'tip': 'Voir les astuces',
      'event': 'Voir les événements',
      'dinor_tv': 'Voir les vidéos',
    };
    return texts[_selectedFilter] ?? 'Explorer';
  }

  void _navigateToContent(String type, String contentId) {
    switch (type) {
      case 'recipe':
        NavigationService.pushNamed('/recipe-detail-unified/$contentId');
        break;
      case 'tip':
        NavigationService.pushNamed('/tip-detail-unified/$contentId');
        break;
      case 'event':
        NavigationService.pushNamed('/event-detail-unified/$contentId');
        break;
      default:
        print('Navigation non supportée pour le type: $type');
    }
  }
}