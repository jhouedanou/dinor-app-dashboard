import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/navigation_service.dart';

class SimpleRecipeDetailScreen extends StatefulWidget {
  final String id;
  
  const SimpleRecipeDetailScreen({Key? key, required this.id}) : super(key: key);

  @override
  State<SimpleRecipeDetailScreen> createState() => _SimpleRecipeDetailScreenState();
}

class _SimpleRecipeDetailScreenState extends State<SimpleRecipeDetailScreen> {
  Map<String, dynamic>? recipe;
  bool isLoading = true;
  String? error;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadRecipe();
  }

  Future<void> _loadRecipe() async {
    try {
      print('🔄 [RecipeDetail] Chargement de la recette ${widget.id}...');
      
      final response = await http.get(
        Uri.parse('https://new.dinorapp.com/api/v1/recipes/${widget.id}'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print('📡 [RecipeDetail] Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ [RecipeDetail] Data reçue: ${data.toString().substring(0, 100)}...');
        
        setState(() {
          recipe = data['data'];
          isLoading = false;
          error = null;
        });
        
        print('📋 [RecipeDetail] Recette chargée: ${recipe?['title']}');
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [RecipeDetail] Erreur: $e');
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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F5F5),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE53E3E)),
              ),
              SizedBox(height: 16),
              Text(
                'Chargement de la recette...',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 16,
                  color: Color(0xFF4A5568),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (error != null || recipe == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: const Text('Erreur'),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3748)),
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
                const Text(
                  'Recette introuvable',
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error ?? 'Cette recette n\'existe pas ou plus.',
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 14,
                    color: Color(0xFF4A5568),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => NavigationService.pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53E3E),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Retour'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final title = recipe!['title'] ?? recipe!['name'] ?? 'Recette';
    final description = recipe!['description'] ?? recipe!['excerpt'] ?? '';
    final imageUrl = recipe!['image'] ?? recipe!['featured_image'] ?? recipe!['thumbnail'];
    final ingredients = recipe!['ingredients'] ?? [];
    final instructions = recipe!['instructions'] ?? recipe!['content'] ?? '';
    final cookTime = recipe!['cook_time'] ?? recipe!['duration'] ?? '30 min';
    final difficulty = recipe!['difficulty'] ?? 'Facile';
    final servings = recipe!['servings'] ?? recipe!['portions'] ?? '4';

    return CustomScrollView(
      slivers: [
        // App Bar avec image
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3748)),
              onPressed: () => NavigationService.pop(),
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? const Color(0xFFE53E3E) : const Color(0xFF2D3748),
                ),
                onPressed: () {
                  setState(() {
                    isFavorite = !isFavorite;
                  });
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.share, color: Color(0xFF2D3748)),
                onPressed: () {
                  // TODO: Implémenter le partage
                },
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: imageUrl != null
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFFF7FAFC),
                        child: const Center(
                          child: Icon(
                            Icons.restaurant,
                            size: 64,
                            color: Color(0xFFE53E3E),
                          ),
                        ),
                      );
                    },
                  )
                : Container(
                    color: const Color(0xFFF7FAFC),
                    child: const Center(
                      child: Icon(
                        Icons.restaurant,
                        size: 64,
                        color: Color(0xFFE53E3E),
                      ),
                    ),
                  ),
          ),
        ),
        
        // Contenu
        SliverToBoxAdapter(
          child: Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre et description
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'OpenSans',
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2D3748),
                          height: 1.2,
                        ),
                      ),
                      if (description.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          description,
                          style: const TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 16,
                            color: Color(0xFF4A5568),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Informations rapides
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7FAFC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoItem(Icons.access_time, 'Temps', cookTime),
                      _buildInfoItem(Icons.restaurant, 'Portions', servings.toString()),
                      _buildInfoItem(Icons.trending_up, 'Difficulté', difficulty),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Ingrédients
                if (ingredients.isNotEmpty) ...[
                  _buildSection(
                    'Ingrédients',
                    Icons.shopping_cart,
                    _buildIngredientsList(ingredients),
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Instructions
                if (instructions.isNotEmpty) ...[
                  _buildSection(
                    'Préparation',
                    Icons.list_alt,
                    _buildInstructions(instructions),
                  ),
                ],
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: const Color(0xFFE53E3E),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 12,
            color: Color(0xFF718096),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 14,
            color: Color(0xFF2D3748),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, IconData icon, Widget content) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 24,
                color: const Color(0xFFE53E3E),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  Widget _buildIngredientsList(List<dynamic> ingredients) {
    return Column(
      children: ingredients.map((ingredient) {
        final text = ingredient is String ? ingredient : ingredient['name'] ?? ingredient.toString();
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFFE53E3E),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 14,
                    color: Color(0xFF2D3748),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInstructions(String instructions) {
    // Si c'est du HTML, on le nettoie basiquement
    String cleanText = instructions
        .replaceAll(RegExp(r'<[^>]*>'), '') // Supprimer les balises HTML
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .trim();
    
    // Diviser en étapes si numérotées
    List<String> steps = cleanText.split(RegExp(r'\d+\.\s*')).where((s) => s.trim().isNotEmpty).toList();
    
    if (steps.length > 1) {
      return Column(
        children: steps.asMap().entries.map((entry) {
          int index = entry.key;
          String step = entry.value.trim();
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53E3E),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    step,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 14,
                      color: Color(0xFF2D3748),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Text(
          cleanText,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 14,
            color: Color(0xFF2D3748),
            height: 1.5,
          ),
        ),
      );
    }
  }
}