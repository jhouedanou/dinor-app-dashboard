import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/navigation_service.dart';
import '../services/cache_service.dart';

class SimpleRecipeDetailScreen extends StatefulWidget {
  final Map<String, dynamic> arguments;

  const SimpleRecipeDetailScreen({Key? key, required this.arguments}) : super(key: key);

  @override
  State<SimpleRecipeDetailScreen> createState() => _SimpleRecipeDetailScreenState();
}

class _SimpleRecipeDetailScreenState extends State<SimpleRecipeDetailScreen> {
  Map<String, dynamic>? recipe;
  bool isLoading = true;
  String? error;
  bool isLiked = false;
  bool isFavorite = false;

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
    return Scaffold(
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
            IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: Colors.white,
              ),
              onPressed: _toggleFavorite,
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
                  child: Image.network(
                    recipe!['featured_image_url'] ?? 'https://via.placeholder.com/400x300',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFFE53E3E),
                        child: const Icon(
                          Icons.restaurant,
                          size: 64,
                          color: Colors.white,
                        ),
                      );
                    },
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
            padding: const EdgeInsets.all(16),
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
                  ingredient.toString(),
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
                  instruction.toString(),
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

  Widget _buildVideoContainer() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFC),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.play_circle_outline,
              size: 48,
              color: Color(0xFFCBD5E0),
            ),
            SizedBox(height: 8),
            Text(
              'Vidéo disponible',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 14,
                color: Color(0xFF718096),
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

  void _toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
    });
    // TODO: Implémenter l'API pour les favoris
  }

  void _toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });
    // TODO: Implémenter l'API pour les likes
  }

  void _shareRecipe() {
    // TODO: Implémenter le partage
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