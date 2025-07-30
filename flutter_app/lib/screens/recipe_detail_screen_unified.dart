import '../services/navigation_service.dart';
/**
 * RECIPE_DETAIL_SCREEN_UNIFIED.DART - VERSION UNIFIÉE DU DÉTAIL RECETTE
 * - Utilise les nouveaux composants unifiés
 * - Interface cohérente avec les autres types de contenu
 * - Pagination des commentaires intégrée
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

// Components unifiés
import '../components/common/accordion.dart';
import '../components/common/unified_content_header.dart';
import '../components/common/unified_video_player.dart';
import '../components/common/unified_comments_section.dart';
import '../components/common/unified_content_actions.dart';
import '../components/common/youtube_video_modal.dart';

// Services et composables
import '../services/offline_service.dart';
import '../services/image_service.dart';
import '../services/comments_service.dart';
import '../composables/use_comments.dart';
import '../composables/use_auth_handler.dart';
import '../services/share_service.dart';

class RecipeDetailScreenUnified extends ConsumerStatefulWidget {
  final String id;
  
  const RecipeDetailScreenUnified({super.key, required this.id});

  @override
  ConsumerState<RecipeDetailScreenUnified> createState() => _RecipeDetailScreenUnifiedState();
}

class _RecipeDetailScreenUnifiedState extends ConsumerState<RecipeDetailScreenUnified> with AutomaticKeepAliveClientMixin {
  // Données de la recette
  Map<String, dynamic>? _recipe;
  
  // États de chargement
  bool _loading = true;
  bool _userLiked = false;
  
  // Erreurs
  String? _error;
  bool _isOffline = false;

  // Services
  final OfflineService _offlineService = OfflineService();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadRecipe();
  }

  Future<void> _loadRecipe({bool forceRefresh = false}) async {
    try {
      setState(() => _loading = true);
      
      final result = await _offlineService.loadDetailWithOfflineSupport(
        endpoint: 'https://new.dinorapp.com/api/v1/recipes/${widget.id}',
        cacheKey: 'recipe_detail',
        id: widget.id,
      );
        
      if (result['success']) {
        setState(() {
          _recipe = result['data'];
          _loading = false;
          _isOffline = result['offline'] ?? false;
        });
        
        await _checkUserLike();
        
        if (result['offline'] == true) {
          _showOfflineIndicator();
        }
      } else {
        setState(() {
          _error = result['error'];
          _loading = false;
        });
      }
    } catch (error) {
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  Future<void> _checkUserLike() async {
    // TODO: Implémenter la vérification du like utilisateur
    setState(() => _userLiked = false);
  }

  void _showOfflineIndicator() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.wifi_off, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text('Mode hors ligne - Données en cache'),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 3),
      ),
    );
  }

  String _getDifficultyLabel(String difficulty) {
    const labels = {
      'beginner': 'Débutant',
      'easy': 'Facile',
      'medium': 'Intermédiaire',
      'hard': 'Difficile',
      'expert': 'Expert'
    };
    return labels[difficulty] ?? difficulty;
  }

  String _formatIngredientDisplay(dynamic ingredient) {
    if (ingredient == null) return '';
    
    String result = '';
    
    if (ingredient['quantity'] != null) {
      result += '${ingredient['quantity']} ';
    }
    
    if (ingredient['unit'] != null) {
      result += '${ingredient['unit']} ';
    }
    
    if (ingredient['name'] != null) {
      result += 'de ${ingredient['name']}';
    }
    
    if (ingredient['notes'] != null) {
      result += ' (${ingredient['notes']})';
    }
    
    if (ingredient['recommended_brand'] != null) {
      result += ' [${ingredient['recommended_brand']}]';
    }
    
    return result.trim();
  }

  String _formatInstructions(dynamic instructions) {
    if (instructions == null) return '';
    
    if (instructions is String) return instructions;
    
    if (instructions is List) {
      return instructions.asMap().entries.map((entry) {
        final index = entry.key;
        final instruction = entry.value;
        
        if (instruction is Map && instruction['step'] != null) {
          return '<div class="instruction-step"><h4>Étape ${index + 1}</h4><p>${instruction['step']}</p></div>';
        } else if (instruction is String) {
          return '<div class="instruction-step"><h4>Étape ${index + 1}</h4><p>$instruction</p></div>';
        }
        return '<div class="instruction-step"><p>$instruction</p></div>';
      }).join('');
    }
    
    return instructions.toString();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: _loading
        ? _buildLoadingState()
        : _error != null
          ? _buildErrorState()
          : _recipe == null
            ? _buildNotFoundState()
            : _buildRecipeContent(),
      floatingActionButton: _buildFloatingActionButtons(),
    );
  }

  Widget _buildFloatingActionButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          onPressed: () => NavigationService.pop(),
          heroTag: 'back_fab',
          backgroundColor: Colors.white,
          child: const Icon(LucideIcons.arrowLeft, color: Color(0xFF2D3748)),
        ),
        const SizedBox(height: 16),
        FloatingActionButton(
          onPressed: () {
            if (_recipe != null) {
              ref.read(shareServiceProvider).shareContent(
                type: 'recipe',
                id: widget.id,
                title: _recipe!['title'] ?? 'Recette',
                description: _recipe!['description'] ?? 'Découvrez cette délicieuse recette',
                shareUrl: 'https://new.dinorapp.com/recipe/${widget.id}',
                imageUrl: _recipe!['featured_image_url'],
              );
            }
          },
          heroTag: 'share_fab',
          backgroundColor: const Color(0xFFE53E3E),
          child: const Icon(LucideIcons.share2, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Chargement de la recette...',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.alertCircle,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Erreur lors du chargement',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Une erreur est survenue',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _loadRecipe(),
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotFoundState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.alertCircle,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Recette introuvable',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            'La recette demandée n\'existe pas ou a été supprimée.',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => NavigationService.pop(),
            child: const Text('Retour'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeContent() {
    return CustomScrollView(
      slivers: [
        // Hero Image avec composant unifié
        SliverToBoxAdapter(
          child: UnifiedContentHeader(
            imageUrl: _recipe!['featured_image_url'] ?? '',
            contentType: 'recipe',
            customOverlay: Positioned(
              bottom: 50, // Descendre les badges
              left: 16,
              right: 16,
              child: Row(
                children: [
                  if (_recipe!['difficulty'] != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4D03F).withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getDifficultyLabel(_recipe!['difficulty']),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (_recipe!['category'] != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _recipe!['category']['name'],
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),

        // Recipe Info
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recipe Stats avec composant unifié
                UnifiedContentStats(
                  stats: [
                    {
                      'icon': LucideIcons.clock,
                      'text': '${_recipe!['cooking_time'] ?? 0}min',
                    },
                    {
                      'icon': LucideIcons.users,
                      'text': '${_recipe!['servings'] ?? 0} pers.',
                    },
                    {
                      'icon': LucideIcons.heart,
                      'text': '${_recipe!['likes_count'] ?? 0}',
                    },
                    {
                      'icon': LucideIcons.messageCircle,
                      'text': '${_recipe!['comments_count'] ?? 0}',
                    },
                  ],
                ),
                const SizedBox(height: 16),
                
                // Indicateur hors ligne
                if (_isOffline) _buildOfflineIndicator(),
                if (_isOffline) const SizedBox(height: 16),
                
                const SizedBox(height: 24),

                // Description
                if (_recipe!['description'] != null) ...[
                  _buildSection(
                    'Description',
                    HtmlWidget(_recipe!['description']),
                  ),
                  const SizedBox(height: 24),
                ],

                // Summary Video avec composant unifié
                if (_recipe!['summary_video_url'] != null) ...[
                  _buildSection(
                    'Résumé en vidéo',
                    _buildVideoPlayerCard(
                      _recipe!['summary_video_url'],
                      'Voir le résumé en vidéo',
                      'Appuyez pour ouvrir',
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Main Video avec composant unifié
                if (_recipe!['video_url'] != null) ...[
                  _buildSection(
                    'Vidéo de la recette',
                    _buildVideoPlayerCard(
                      _recipe!['video_url'],
                      'Voir la recette en vidéo',
                      'Appuyez pour ouvrir',
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Recipe Sections
                _buildRecipeSections(),

                // Recipe Actions avec composant unifié
                const SizedBox(height: 24),
                UnifiedContentActions(
                  contentType: 'recipe',
                  contentId: widget.id,
                  title: _recipe!['title'] ?? 'Recette',
                  description: _recipe!['description'] ?? 'Découvrez cette délicieuse recette : ${_recipe!['title']}',
                  shareUrl: 'https://new.dinorapp.com/recipe/${widget.id}',
                  imageUrl: _recipe!['featured_image_url'],
                  initialLiked: _userLiked,
                  initialLikeCount: _recipe!['likes_count'] ?? 0,
                  onRefresh: () => _loadRecipe(forceRefresh: true),
                  isLoading: _loading,
                ),

                // Comments avec composant unifié
                const SizedBox(height: 24),
                UnifiedCommentsSection(
                  contentType: 'recipe',
                  contentId: widget.id,
                  contentTitle: _recipe!['title'] ?? 'Recette',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoPlayerCard(String videoUrl, String title, String subtitle) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => YouTubeVideoModal(
            isOpen: true,
            videoUrl: videoUrl,
            title: title,
            onClose: () => Navigator.of(context).pop(),
          ),
        );
      },
      child: UnifiedVideoPlayer(
        videoUrl: videoUrl,
        title: title,
        subtitle: subtitle,
      ),
    );
  }

  Widget _buildOfflineIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.wifi_off,
            size: 16,
            color: Colors.orange[700],
          ),
          const SizedBox(width: 8),
          Text(
            'Mode hors ligne - Données en cache',
            style: TextStyle(
              fontSize: 12,
              color: Colors.orange[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 16),
        content,
      ],
    );
  }

  Widget _buildRecipeSections() {
    return Column(
      children: [
        // Ingredients Accordion
        if (_recipe!['ingredients'] != null && (_recipe!['ingredients'] as List).isNotEmpty)
          Accordion(
            title: 'Ingrédients',
            initiallyOpen: true,
            child: Column(
              children: (_recipe!['ingredients'] as List).map((ingredient) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    _formatIngredientDisplay(ingredient),
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 16,
                      color: Color(0xFF4A5568),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

        // Instructions Accordion
        if (_recipe!['instructions'] != null)
          Accordion(
            title: 'Instructions',
            initiallyOpen: true,
            child: HtmlWidget(
              _formatInstructions(_recipe!['instructions']),
            ),
          ),
      ],
    );
  }
}