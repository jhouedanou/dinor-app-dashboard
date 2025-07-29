import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../services/navigation_service.dart';
import '../services/cache_service.dart';
import '../services/image_service.dart';
import '../components/common/comments_section.dart';
import '../components/common/auth_modal.dart';
import '../components/common/youtube_video_modal.dart';
import '../components/common/favorite_button.dart';

class SimpleRecipeDetailScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> arguments;

  const SimpleRecipeDetailScreen({Key? key, required this.arguments}) : super(key: key);

  @override
  ConsumerState<SimpleRecipeDetailScreen> createState() => _SimpleRecipeDetailScreenState();
}

class _SimpleRecipeDetailScreenState extends ConsumerState<SimpleRecipeDetailScreen> {
  Map<String, dynamic>? recipe;
  bool isLoading = true;
  String? error;
  bool isLiked = false;
  bool isFavorite = false;
  bool _showAuthModal = false;

  final CacheService _cacheService = CacheService();

  @override
  void initState() {
    super.initState();
    _loadRecipeDetail();
  }

  Future<void> _loadRecipeDetail() async {
    final recipeId = widget.arguments['id'] as String;
    
    try {
      // Vérifier d'abord le cache
      final cachedRecipe = await _cacheService.getCachedRecipeDetail(recipeId);
      if (cachedRecipe != null) {
        setState(() {
          recipe = cachedRecipe;
          isLoading = false;
        });
        return;
      }

      // Charger depuis l'API
      final response = await http.get(
        Uri.parse('https://new.dinorapp.com/api/v1/recipes/$recipeId'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final recipeData = data['data'] ?? data;
        
        // Mettre en cache
        await _cacheService.cacheRecipeDetail(recipeId, recipeData);
        
        setState(() {
          recipe = recipeData;
          isLoading = false;
          error = null;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          isLoading = false;
          error = 'Recette non trouvée';
        });
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [RecipeDetail] Erreur chargement: $e');
      setState(() {
        isLoading = false;
        error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          body: isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE53E3E)),
                  ),
                )
              : error != null
                  ? _buildErrorWidget()
                  : recipe != null
                      ? _buildRecipeDetail()
                      : const Center(child: Text('Recette non trouvée')),
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
              onAuthenticated: () => setState(() => _showAuthModal = false),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE53E3E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => NavigationService.pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Color(0xFFE53E3E),
              ),
              const SizedBox(height: 16),
              Text(
                error == 'Recette non trouvée' ? 'Recette non trouvée' : 'Erreur de chargement',
                style: const TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                error == 'Recette non trouvée' 
                    ? 'Cette recette n\'existe pas ou a été supprimée.'
                    : 'Impossible de charger les détails de la recette.',
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 16,
                  color: Color(0xFF718096),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadRecipeDetail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53E3E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeDetail() {
    return CustomScrollView(
      slivers: [
        // AppBar avec image hero
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          backgroundColor: const Color(0xFFE53E3E),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => NavigationService.pop(),
          ),
          actions: [
            FavoriteButton(
              type: 'recipe',
              itemId: recipe!['id'].toString(),
              initialFavorited: isFavorite,
              showCount: false,
              size: 24,
              onFavoriteChanged: (isFavorited) {
                setState(() {
                  isFavorite = isFavorited;
                });
              },
              onAuthRequired: () => setState(() => _showAuthModal = true),
            ),
            IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              onPressed: _shareRecipe,
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              children: [
                // Image de fond
                Positioned.fill(
                  child: ImageService.buildNetworkImage(
                    imageUrl: recipe!['featured_image_url'] ?? '',
                    contentType: 'recipe',
                    fit: BoxFit.cover,
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
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ),
                // Titre et description en bas
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe!['title'] ?? 'Sans titre',
                        style: const TextStyle(
                          fontFamily: 'OpenSans',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (recipe!['short_description'] != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          recipe!['short_description'],
                          style: const TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Contenu principal
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Statistiques
                _buildRecipeStats(),
                const SizedBox(height: 24),

                // Ingrédients
                if (recipe!['ingredients'] != null) ...[
                  _buildSection('Ingrédients', _buildIngredientsList()),
                  const SizedBox(height: 24),
                ],

                // Instructions
                if (recipe!['instructions'] != null) ...[
                  _buildSection('Instructions', _buildInstructionsList()),
                  const SizedBox(height: 24),
                ],

                // Vidéo
                if (recipe!['video_url'] != null) ...[
                  _buildSection('Vidéo', _buildVideoContainer()),
                  const SizedBox(height: 24),
                ],

                // Tags
                if (recipe!['tags'] != null) ...[
                  _buildSection('Tags', _buildTagsList()),
                  const SizedBox(height: 24),
                ],

                // Actions
                _buildActions(),
                const SizedBox(height: 24),

                // Section des commentaires
                CommentsSection(
                  contentType: 'recipe',
                  contentId: widget.arguments['id'] as String,
                  contentTitle: recipe!['title'] ?? 'Recette',
                  onAuthRequired: () => setState(() => _showAuthModal = true),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecipeStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
            Icons.schedule,
            'Temps total',
            '${recipe!['total_time'] ?? 0} min',
            const Color(0xFFE53E3E),
          ),
          _buildStatItem(
            Icons.trending_up,
            'Difficulté',
            _getDifficultyLabel(recipe!['difficulty']),
            _getDifficultyColor(recipe!['difficulty']),
          ),
          _buildStatItem(
            Icons.favorite,
            'Likes',
            '${recipe!['likes_count'] ?? 0}',
            const Color(0xFFE53E3E),
          ),
          _buildStatItem(
            Icons.comment,
            'Commentaires',
            '${recipe!['comments_count'] ?? 0}',
            const Color(0xFF38A169),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 12,
            color: Color(0xFF718096),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }

  Widget _buildIngredientsList() {
    final ingredients = recipe!['ingredients'];
    if (ingredients is! List) return const Text('Aucun ingrédient disponible');

    return Column(
      children: ingredients.asMap().entries.map((entry) {
        final index = entry.key;
        final ingredient = entry.value;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 6, right: 12),
                decoration: const BoxDecoration(
                  color: Color(0xFFE53E3E),
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Text(
                  _formatIngredient(ingredient),
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 16,
                    color: Color(0xFF4A5568),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _formatIngredient(dynamic ingredient) {
    if (ingredient == null) return '';
    
    // Si c'est déjà une chaîne, la retourner
    if (ingredient is String) return ingredient;
    
    // Si c'est un Map, le formater
    if (ingredient is Map) {
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
    
    return ingredient.toString();
  }

  Widget _buildInstructionsList() {
    final instructions = recipe!['instructions'];
    if (instructions is! List) return const Text('Aucune instruction disponible');

    return Column(
      children: instructions.asMap().entries.map((entry) {
        final index = entry.key;
        final instruction = entry.value;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(right: 12),
                decoration: const BoxDecoration(
                  color: Color(0xFFE53E3E),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  _formatInstruction(instruction),
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 16,
                    color: Color(0xFF4A5568),
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _formatInstruction(dynamic instruction) {
    if (instruction == null) return '';
    
    // Si c'est déjà une chaîne, la retourner
    if (instruction is String) return instruction;
    
    // Si c'est un Map avec une propriété 'step'
    if (instruction is Map && instruction['step'] != null) {
      return instruction['step'];
    }
    
    // Si c'est un Map avec une propriété 'instruction'
    if (instruction is Map && instruction['instruction'] != null) {
      return instruction['instruction'];
    }
    
    // Si c'est un Map avec une propriété 'text'
    if (instruction is Map && instruction['text'] != null) {
      return instruction['text'];
    }
    
    return instruction.toString();
  }

  Widget _buildVideoContainer() {
    final videoUrl = recipe!['video_url'];
    
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

  Widget _buildTagsList() {
    final tags = recipe!['tags'];
    if (tags == null) return const Text('Aucun tag disponible');

    final tagsList = tags is List ? tags : [tags];
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tagsList.map<Widget>((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF7FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Text(
            tag.toString(),
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 12,
              color: Color(0xFF4A5568),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _toggleLike,
            icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border),
            label: Text(isLiked ? 'Aimé' : 'J\'aime'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isLiked ? const Color(0xFFE53E3E) : Colors.white,
              foregroundColor: isLiked ? Colors.white : const Color(0xFFE53E3E),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: isLiked ? Colors.transparent : const Color(0xFFE53E3E),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _shareRecipe,
            icon: const Icon(Icons.share),
            label: const Text('Partager'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFE53E3E),
              side: const BorderSide(color: Color(0xFFE53E3E)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }


  void _toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });
    // TODO: Implémenter l'API pour les likes
  }

  void _shareRecipe() {
    if (recipe == null) return;
    
    final title = recipe!['title'] ?? 'Recette Dinor';
    final description = recipe!['short_description'] ?? recipe!['description'] ?? 'Découvrez cette délicieuse recette sur Dinor';
    final recipeId = widget.arguments['id'] as String;
    final url = 'https://new.dinor.app/recipes/$recipeId';
    
    final shareText = '$title\n\n$description\n\nDécouvrez plus de recettes sur Dinor:\n$url';
    
    Share.share(shareText, subject: title);
    print('📤 [RecipeDetail] Contenu partagé: $title');
  }

  void _openVideo(String videoUrl) {
    print('🎥 [RecipeDetail] _openVideo appelé avec URL: $videoUrl');
    
    if (videoUrl.isEmpty) {
      print('❌ [RecipeDetail] URL vidéo vide');
      _showSnackBar('URL de la vidéo non disponible', Colors.red);
      return;
    }
    
    print('🎬 [RecipeDetail] Ouverture vidéo intégrée');
    
    // Afficher la modal vidéo YouTube intégrée
    showDialog(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true,
      builder: (context) => YouTubeVideoModal(
        isOpen: true,
        videoUrl: videoUrl,
        title: recipe?['title'] ?? 'Vidéo de la recette',
        onClose: () {
          if (Navigator.of(context, rootNavigator: true).canPop()) {
            Navigator.of(context, rootNavigator: true).pop();
          }
        },
      ),
    );
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

  String _getDifficultyLabel(String? difficulty) {
    if (difficulty == null) return 'Non spécifiée';
    final labels = {
      'easy': 'Facile',
      'medium': 'Moyen',
      'hard': 'Difficile',
      'beginner': 'Débutant',
      'intermediate': 'Intermédiaire',
      'advanced': 'Avancé',
    };
    return labels[difficulty] ?? difficulty;
  }

  Color _getDifficultyColor(String? difficulty) {
    if (difficulty == null) return const Color(0xFF718096);
    final colors = {
      'easy': const Color(0xFF38A169),
      'medium': const Color(0xFFF4D03F),
      'hard': const Color(0xFFE53E3E),
      'beginner': const Color(0xFF38A169),
      'intermediate': const Color(0xFFF4D03F),
      'advanced': const Color(0xFFE53E3E),
    };
    return colors[difficulty] ?? const Color(0xFF718096);
  }
}