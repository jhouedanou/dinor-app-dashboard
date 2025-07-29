import '../services/navigation_service.dart';
/**
 * RECIPE_DETAIL_SCREEN.DART - CONVERSION FIDÈLE DE RecipeDetail.vue
 * 
 * FIDÉLITÉ VISUELLE :
 * - Hero image identique avec overlay et badges
 * - Recipe stats identiques : temps, personnes, likes, commentaires
 * - Accordions identiques : ingrédients, instructions, galerie, commentaires
 * - Vidéos embarquées : YouTube et Vimeo
 * - Couleurs identiques : #FFFFFF fond, #F4D03F doré, #FF6B35 orange
 * - Polices identiques : Roboto textes, Open Sans titres
 * 
 * FIDÉLITÉ FONCTIONNELLE :
 * - Setup() identique : composables pour données
 * - Handlers identiques : like, commentaire, partage
 * - AuthModal : même gestion d'authentification
 * - Refresh system : même système de rafraîchissement
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

// Components (équivalent des imports Vue)
import '../components/common/badge.dart' as dinor_badge;
import '../components/common/like_button.dart';
import '../components/common/auth_modal.dart';
import '../components/common/accordion.dart';
import '../components/common/image_lightbox.dart';
import '../components/common/share_modal.dart';
import '../components/dinor_icon.dart';

// Services et composables
import '../services/api_service.dart';
import '../services/offline_service.dart';
import '../services/image_service.dart';
import '../services/comments_service.dart';
import '../composables/use_comments.dart';
import '../composables/use_auth_handler.dart';
import '../composables/use_social_share.dart';

class RecipeDetailScreen extends ConsumerStatefulWidget {
  final String id;
  
  const RecipeDetailScreen({Key? key, required this.id}) : super(key: key);

  @override
  ConsumerState<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends ConsumerState<RecipeDetailScreen> with AutomaticKeepAliveClientMixin {
  // État identique au setup() Vue
  bool _showAuthModal = false;
  bool _showShareModal = false;
  bool _showLightbox = false;
  int _lightboxIndex = 0;
  
  // Données de la recette
  Map<String, dynamic>? _recipe;
  List<dynamic> _comments = [];
  
  // États de chargement
  bool _loading = true;
  bool _userLiked = false;
  bool _userFavorited = false;
  
  // Erreurs
  String? _error;
  bool _isOffline = false;

  // Commentaires
  final TextEditingController _commentController = TextEditingController();
  
  // Services
  final OfflineService _offlineService = OfflineService();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    
    print('🍳 [RecipeDetailScreen] Écran détail recette initialisé ID: ${widget.id}');
    _loadRecipe();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // REPRODUCTION EXACTE du chargement de données Vue avec support hors ligne
  Future<void> _loadRecipe({bool forceRefresh = false}) async {
    try {
      print('🔄 [RecipeDetailScreen] Chargement recette ID: ${widget.id}, ForceRefresh: $forceRefresh');
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
        
        // Charger les commentaires
        await _loadComments();
        await _checkUserLike();
        await _checkUserFavorite();
        
        // Afficher un indicateur si en mode hors ligne
        if (result['offline'] == true) {
          _showOfflineIndicator();
        }
        
        print('✅ [RecipeDetailScreen] Recette chargée avec succès');
      } else {
        setState(() {
          _error = result['error'];
          _loading = false;
        });
      }
    } catch (error) {
      print('❌ [RecipeDetailScreen] Erreur lors du chargement de la recette: $error');
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  Future<void> _loadComments() async {
    try {
      await ref.read(commentsServiceProvider.notifier).loadComments('recipe', widget.id);
      final commentsState = ref.read(commentsServiceProvider)[('recipe_${widget.id}')];
      if (commentsState != null) {
        setState(() => _comments = commentsState.comments.map((c) => c.toJson()).toList());
      }
    } catch (error) {
      print('❌ [RecipeDetailScreen] Erreur chargement commentaires: $error');
    }
  }

  Future<void> _checkUserLike() async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final data = await apiService.get('/likes/check', params: {
        'type': 'recipe',
        'id': widget.id
      });
      setState(() => _userLiked = data['success'] && data['is_liked']);
    } catch (error) {
      print('❌ [RecipeDetailScreen] Erreur vérification like: $error');
    }
  }

  Future<void> _checkUserFavorite() async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final data = await apiService.get('/favorites/check', params: {
        'type': 'recipe',
        'id': widget.id
      });
      setState(() => _userFavorited = data['success'] && data['is_favorited']);
    } catch (error) {
      print('❌ [RecipeDetailScreen] Erreur vérification favori: $error');
    }
  }

  void _showOfflineIndicator() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
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

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;
    
    try {
      print('📝 [RecipeDetailScreen] Envoi du commentaire pour Recipe: ${widget.id}');
      
      final success = await ref.read(commentsServiceProvider.notifier).addComment(
        'recipe', 
        widget.id, 
        _commentController.text.trim()
      );
      
      if (success) {
        _commentController.clear();
        await _loadComments(); // Recharger les commentaires
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Commentaire ajouté avec succès'),
              backgroundColor: Color(0xFF38A169),
              duration: Duration(seconds: 2),
            ),
          );
        }
        
        print('✅ [RecipeDetailScreen] Commentaire ajouté avec succès');
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur lors de l\'ajout du commentaire'),
              backgroundColor: Color(0xFFE53E3E),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (error) {
      print('❌ [RecipeDetailScreen] Erreur lors de l\'ajout du commentaire: $error');
      
      // Si erreur 401, demander connexion
      if (error.toString().contains('401') || error.toString().contains('connecté')) {
        setState(() => _showAuthModal = true);
      }
    }
  }

  Future<void> _deleteComment(String commentId) async {
    try {
      await ref.read(useCommentsProvider.notifier).deleteComment(commentId);
      await _loadComments(); // Recharger les commentaires
    } catch (error) {
      print('❌ [RecipeDetailScreen] Erreur suppression commentaire: $error');
    }
  }

  Future<void> _forceRefresh() async {
    print('🔄 [RecipeDetailScreen] Rechargement forcé demandé');
    setState(() => _loading = true);
    try {
      await _loadRecipe(forceRefresh: true);
      print('✅ [RecipeDetailScreen] Rechargement forcé terminé');
    } catch (error) {
      print('❌ [RecipeDetailScreen] Erreur lors du rechargement forcé: $error');
    }
  }

  void _goBack() {
    NavigationService.pop();
  }

  void _callShare() {
    if (_recipe == null) return;
    
    final shareData = {
      'title': _recipe!['title'],
      'text': _recipe!['description'] ?? 'Découvrez cette délicieuse recette : ${_recipe!['title']}',
      'url': 'https://new.dinor.app/recipe/${widget.id}',
      'image': _recipe!['featured_image_url'],
    };
    
    Share.share(
      '${shareData['title']}\n\n${shareData['text']}\n\n${shareData['url']}',
      subject: shareData['title'],
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

  String _formatDate(String date) {
    return DateTime.parse(date).toLocal().toString().split(' ')[0];
  }

  void _openVideo(String videoUrl) async {
    print('🎥 [RecipeDetail] _openVideo appelé avec URL: $videoUrl');
    
    if (videoUrl.isEmpty) {
      print('❌ [RecipeDetail] URL vidéo vide');
      _showSnackBar('URL de la vidéo non disponible', Colors.red);
      return;
    }
    
    // Convertir URL embed en URL normale pour YouTube externe
    final normalUrl = _convertEmbedToNormalUrl(videoUrl);
    print('🔄 [RecipeDetail] URL convertie: $normalUrl');
    
    try {
      final uri = Uri.parse(normalUrl);
      if (await canLaunchUrl(uri)) {
        print('📺 [RecipeDetail] Ouverture avec YouTube externe...');
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        print('✅ [RecipeDetail] Vidéo ouverte avec succès');
      } else {
        print('❌ [RecipeDetail] Impossible d\'ouvrir l\'URL');
        _showSnackBar('Impossible d\'ouvrir la vidéo', Colors.red);
      }
    } catch (e) {
      print('❌ [RecipeDetail] Erreur lors de l\'ouverture: $e');
      _showSnackBar('Erreur lors de l\'ouverture de la vidéo', Colors.red);
    }
  }
  
  String _convertEmbedToNormalUrl(String url) {
    // Si c'est une URL embed, la convertir en URL normale
    if (url.contains('/embed/')) {
      final regex = RegExp(r'/embed/([a-zA-Z0-9_-]+)');
      final match = regex.firstMatch(url);
      if (match != null) {
        final videoId = match.group(1);
        return 'https://www.youtube.com/watch?v=$videoId';
      }
    }
    
    // Si c'est déjà une URL normale, la retourner telle quelle
    return url;
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatIngredientDisplay(dynamic ingredient) {
    if (ingredient == null) return '';
    
    String result = '';
    
    // Ajouter la quantité si elle existe
    if (ingredient['quantity'] != null) {
      result += '${ingredient['quantity']} ';
    }
    
    // Ajouter l'unité si elle existe
    if (ingredient['unit'] != null) {
      result += '${ingredient['unit']} ';
    }
    
    // Ajouter le nom de l'ingrédient
    if (ingredient['name'] != null) {
      result += 'de ${ingredient['name']}';
    }
    
    // Ajouter les notes si elles existent
    if (ingredient['notes'] != null) {
      result += ' (${ingredient['notes']})';
    }
    
    // Ajouter la marque recommandée si elle existe
    if (ingredient['recommended_brand'] != null) {
      result += ' [${ingredient['recommended_brand']}]';
    }
    
    return result.trim();
  }

  String _formatInstructions(dynamic instructions) {
    if (instructions == null) return '';
    
    // Si c'est déjà une chaîne, la retourner
    if (instructions is String) return instructions;
    
    // Si c'est un array d'objets, les formater
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

  void _openGalleryModal(int index) {
    if (_recipe?['gallery_urls']?[index] != null) {
      setState(() {
        _lightboxIndex = index;
        _showLightbox = true;
      });
    }
  }
  
  void _closeLightbox() {
    setState(() => _showLightbox = false);
  }

  bool _canDeleteComment(dynamic comment) {
    // Logique pour vérifier si l'utilisateur peut supprimer le commentaire
    // À implémenter selon votre logique d'authentification
    return false;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFFFFFFF),
          body: _loading
            ? _buildLoadingState()
            : _error != null
              ? _buildErrorState()
              : _recipe == null
                ? _buildNotFoundState()
                : _buildRecipeContent(),
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
          Text(
            'La recette demandée n\'existe pas ou a été supprimée.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _goBack,
            child: const Text('Retour'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeContent() {
    return CustomScrollView(
      slivers: [
        // Hero Image
        SliverToBoxAdapter(
          child: _buildHeroImage(),
        ),

        // Recipe Info
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recipe Stats
                _buildRecipeStats(),
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

                // Summary Video
                if (_recipe!['summary_video_url'] != null) ...[
                  _buildSection(
                    'Résumé en vidéo',
                    _buildVideoContainer(_recipe!['summary_video_url']),
                  ),
                  const SizedBox(height: 24),
                ],

                // Main Video
                if (_recipe!['video_url'] != null) ...[
                  _buildSection(
                    'Vidéo de la recette',
                    _buildVideoContainer(_recipe!['video_url']),
                  ),
                  const SizedBox(height: 24),
                ],

                // Recipe Sections
                _buildRecipeSections(),

                // Recipe Header Actions
                const SizedBox(height: 24),
                _buildRecipeActions(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroImage() {
    return Stack(
      children: [
        SizedBox(
          height: 300,
          width: double.infinity,
          child: ImageService.buildCachedNetworkImage(
            imageUrl: _recipe!['featured_image_url'] ?? '',
            contentType: 'recipe',
            fit: BoxFit.cover,
          ),
        ),
        // Recipe Overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),
        ),
        // Recipe Badges
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Row(
            children: [
              if (_recipe!['difficulty'] != null)
                dinor_badge.Badge(
                  text: _getDifficultyLabel(_recipe!['difficulty']),
                  icon: 'restaurant',
                  variant: 'secondary',
                  size: 'medium',
                ),
              const SizedBox(width: 8),
              if (_recipe!['category'] != null)
                dinor_badge.Badge(
                  text: _recipe!['category']['name'],
                  icon: 'tag',
                  variant: 'neutral',
                  size: 'medium',
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecipeStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4D03F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            LucideIcons.clock,
            '${_recipe!['cooking_time'] ?? 0}min',
          ),
          _buildStatItem(
            LucideIcons.users,
            '${_recipe!['servings'] ?? 0} pers.',
          ),
          _buildStatItem(
            LucideIcons.heart,
            '${_recipe!['likes_count'] ?? 0}',
          ),
          _buildStatItem(
            LucideIcons.messageCircle,
            '${_recipe!['comments_count'] ?? 0}',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String text) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFF2D3748),
        ),
        const SizedBox(height: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2D3748),
          ),
        ),
      ],
    );
  }

  Widget _buildOfflineIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
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

  Widget _buildVideoContainer(String videoUrl) {
    return GestureDetector(
      onTap: () => _openVideo(videoUrl),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: const Color(0xFFF7FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Stack(
          children: [
            // Arrière-plan avec dégradé
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF1A202C).withOpacity(0.8),
                    const Color(0xFF2D3748).withOpacity(0.6),
                  ],
                ),
              ),
            ),
            // Contenu centré
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Regarder la vidéo',
                    style: TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Appuyez pour ouvrir',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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

        // Gallery Accordion
        if (_recipe!['gallery_urls'] != null && (_recipe!['gallery_urls'] as List).isNotEmpty)
          Accordion(
            title: 'Galerie photos',
            initiallyOpen: false,
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: (_recipe!['gallery_urls'] as List).length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _openGalleryModal(index),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: _recipe!['gallery_urls'][index],
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.error),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

        // Comments Accordion
        Accordion(
          title: 'Commentaires (${_comments.length})',
          initiallyOpen: false,
          child: _buildCommentsSection(),
        ),
      ],
    );
  }

  Widget _buildCommentsSection() {
    return Column(
      children: [
        // Add Comment Form
        _buildAddCommentForm(),
        const SizedBox(height: 16),

        // Comments List
        if (_comments.isNotEmpty)
          Column(
            children: _comments.map((comment) => _buildCommentItem(comment)).toList(),
          )
        else
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Aucun commentaire pour le moment.',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 16,
                color: Color(0xFF4A5568),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAddCommentForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info or auth prompt
          if (!ref.read(useAuthHandlerProvider).isAuthenticated) ...[
            const Text(
              'Connectez-vous pour laisser un commentaire',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 16,
                color: Color(0xFF4A5568),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => setState(() => _showAuthModal = true),
              child: const Text('Se connecter'),
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Connecté en tant que ${ref.read(useAuthHandlerProvider).userName}',
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 14,
                    color: Color(0xFF4A5568),
                  ),
                ),
                TextButton(
                  onPressed: () => ref.read(useAuthHandlerProvider.notifier).logout(),
                  child: const Text('Déconnexion'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Ajoutez votre commentaire...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _commentController.text.trim().isEmpty ? null : _addComment,
              child: const Text('Publier'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCommentItem(dynamic comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment['author_name'] ?? 'Anonyme',
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    Text(
                      _formatDate(comment['created_at']),
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14,
                        color: Color(0xFF4A5568),
                      ),
                    ),
                  ],
                ),
              ),
              if (_canDeleteComment(comment))
                IconButton(
                  onPressed: () => _deleteComment(comment['id'].toString()),
                  icon: const Icon(LucideIcons.trash2, size: 16),
                  tooltip: 'Supprimer le commentaire',
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment['content'] ?? '',
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 16,
              color: Color(0xFF4A5568),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeActions() {
    return Row(
      children: [
        // Like Button
        Expanded(
          child: LikeButton(
            type: 'recipe',
            itemId: widget.id,
            initialLiked: _userLiked,
            initialCount: _recipe!['likes_count'] ?? 0,
            showCount: true,
            size: 'medium',
            onAuthRequired: () => setState(() => _showAuthModal = true),
          ),
        ),
        const SizedBox(width: 12),

        // Refresh Button
        IconButton(
          onPressed: _loading ? null : _forceRefresh,
          icon: Icon(
            LucideIcons.refreshCw,
            size: 20,
            color: _loading ? Colors.grey : const Color(0xFF49454F),
          ),
          tooltip: 'Actualiser les données',
        ),

        // Share Button
        IconButton(
          onPressed: _callShare,
          icon: const Icon(
            LucideIcons.share,
            size: 20,
            color: Color(0xFF49454F),
          ),
          tooltip: 'Partager cette recette',
        ),
      ],
    );
  }
}