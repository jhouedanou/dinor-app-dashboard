#!/bin/bash

# Script pour générer une application Flutter basée sur le dashboard Dinor
# Usage: ./generate_flutter_app.sh

echo "🚀 Génération de l'application Flutter Dinor Dashboard..."

# Nom de l'application
APP_NAME="dinor_dashboard_flutter"
BASE_URL="http://localhost:8000" # URL de l'API Laravel

# Créer le projet Flutter
echo "📱 Création du projet Flutter..."
flutter create $APP_NAME
cd $APP_NAME

# Ajouter les dépendances dans pubspec.yaml
echo "📦 Configuration des dépendances..."
cat > pubspec.yaml << EOF
name: dinor_dashboard_flutter
description: Application Flutter pour le dashboard Dinor
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: ">=3.0.0"

dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  provider: ^6.1.1
  shared_preferences: ^2.2.2
  cached_network_image: ^3.3.0
  flutter_staggered_animations: ^1.1.1
  pull_to_refresh: ^2.0.0
  shimmer: ^3.0.0
  intl: ^0.18.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
EOF

# Créer la structure des dossiers
echo "📁 Création de la structure des dossiers..."
mkdir -p lib/models
mkdir -p lib/services
mkdir -p lib/screens
mkdir -p lib/widgets
mkdir -p lib/providers
mkdir -p lib/utils

# Créer les modèles
echo "🔧 Création des modèles..."
cat > lib/models/recipe.dart << 'EOF'
class Recipe {
  final int id;
  final String title;
  final String? description;
  final String? shortDescription;
  final String difficulty;
  final int preparationTime;
  final int servings;
  final Category? category;
  final DateTime createdAt;

  Recipe({
    required this.id,
    required this.title,
    this.description,
    this.shortDescription,
    required this.difficulty,
    required this.preparationTime,
    required this.servings,
    this.category,
    required this.createdAt,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      shortDescription: json['short_description'],
      difficulty: json['difficulty'] ?? 'easy',
      preparationTime: json['preparation_time'] ?? 30,
      servings: json['servings'] ?? 4,
      category: json['category'] != null ? Category.fromJson(json['category']) : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class Category {
  final int id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(id: json['id'], name: json['name']);
  }
}
EOF

cat > lib/models/event.dart << 'EOF'
class Event {
  final int id;
  final String title;
  final String? description;
  final String? eventType;
  final DateTime? startDate;
  final String? location;
  final String? city;
  final bool isFree;
  final String? price;
  final String? currency;
  final Category? category;
  final DateTime createdAt;

  Event({
    required this.id,
    required this.title,
    this.description,
    this.eventType,
    this.startDate,
    this.location,
    this.city,
    required this.isFree,
    this.price,
    this.currency,
    this.category,
    required this.createdAt,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      eventType: json['event_type'],
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date']) : null,
      location: json['location'],
      city: json['city'],
      isFree: json['is_free'] ?? false,
      price: json['price'],
      currency: json['currency'],
      category: json['category'] != null ? Category.fromJson(json['category']) : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
EOF

# Créer le service API
echo "🌐 Création du service API..."
cat > lib/services/api_service.dart << 'EOF'
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';
import '../models/event.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api/v1';

  Future<Map<String, int>> getStats() async {
    try {
      final responses = await Future.wait([
        http.get(Uri.parse('$baseUrl/recipes?per_page=1')),
        http.get(Uri.parse('$baseUrl/events?per_page=1')),
        http.get(Uri.parse('$baseUrl/pages?per_page=1')),
        http.get(Uri.parse('$baseUrl/tips?per_page=1')),
      ]);

      final stats = <String, int>{};
      
      for (int i = 0; i < responses.length; i++) {
        if (responses[i].statusCode == 200) {
          final data = json.decode(responses[i].body);
          final count = data['pagination']?['total'] ?? 0;
          switch (i) {
            case 0: stats['recipes'] = count; break;
            case 1: stats['events'] = count; break;
            case 2: stats['pages'] = count; break;
            case 3: stats['tips'] = count; break;
          }
        }
      }
      
      stats['interactions'] = (stats['recipes'] ?? 0) * 15 + 
                             (stats['events'] ?? 0) * 8 + 
                             (stats['tips'] ?? 0) * 5;
      
      return stats;
    } catch (e) {
      return {'recipes': 8, 'events': 6, 'pages': 4, 'tips': 12, 'interactions': 156};
    }
  }

  Future<List<Recipe>> getRecipes({String? search, int? categoryId}) async {
    try {
      String url = '$baseUrl/recipes?per_page=12';
      if (search != null && search.isNotEmpty) {
        url += '&search=${Uri.encodeComponent(search)}';
      }
      if (categoryId != null) {
        url += '&category_id=$categoryId';
      }

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List).map((item) => Recipe.fromJson(item)).toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Event>> getEvents({String? search, String? type}) async {
    try {
      String url = '$baseUrl/events?per_page=10';
      if (search != null && search.isNotEmpty) {
        url += '&search=${Uri.encodeComponent(search)}';
      }
      if (type == 'upcoming') {
        url += '&upcoming=1';
      } else if (type == 'featured') {
        url += '&featured=1';
      }

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List).map((item) => Event.fromJson(item)).toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Category>> getCategories() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/recipes/categories/list'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List).map((item) => Category.fromJson(item)).toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
EOF

# Créer le provider principal
echo "🔄 Création du provider..."
cat > lib/providers/dashboard_provider.dart << 'EOF'
import 'package:flutter/foundation.dart';
import '../models/recipe.dart';
import '../models/event.dart';
import '../services/api_service.dart';

class DashboardProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  // État de chargement
  bool _isLoadingStats = false;
  bool _isLoadingRecipes = false;
  bool _isLoadingEvents = false;
  
  // Données
  Map<String, int> _stats = {};
  List<Recipe> _recipes = [];
  List<Event> _events = [];
  List<Category> _categories = [];
  
  // Filtres et recherche
  String _activeTab = 'recipes';
  String _searchTerm = '';
  int? _selectedCategoryId;
  String? _selectedEventType;

  // Getters
  bool get isLoadingStats => _isLoadingStats;
  bool get isLoadingRecipes => _isLoadingRecipes;
  bool get isLoadingEvents => _isLoadingEvents;
  Map<String, int> get stats => _stats;
  List<Recipe> get recipes => _recipes;
  List<Event> get events => _events;
  List<Category> get categories => _categories;
  String get activeTab => _activeTab;
  String get searchTerm => _searchTerm;

  void setActiveTab(String tab) {
    _activeTab = tab;
    notifyListeners();
  }

  void setSearchTerm(String term) {
    _searchTerm = term;
    notifyListeners();
  }

  void setSelectedCategory(int? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  void setSelectedEventType(String? type) {
    _selectedEventType = type;
    notifyListeners();
  }

  Future<void> loadStats() async {
    _isLoadingStats = true;
    notifyListeners();
    
    try {
      _stats = await _apiService.getStats();
    } catch (e) {
      debugPrint('Erreur chargement stats: $e');
    }
    
    _isLoadingStats = false;
    notifyListeners();
  }

  Future<void> loadRecipes() async {
    _isLoadingRecipes = true;
    notifyListeners();
    
    try {
      _recipes = await _apiService.getRecipes(
        search: _searchTerm.isEmpty ? null : _searchTerm,
        categoryId: _selectedCategoryId,
      );
    } catch (e) {
      debugPrint('Erreur chargement recettes: $e');
    }
    
    _isLoadingRecipes = false;
    notifyListeners();
  }

  Future<void> loadEvents() async {
    _isLoadingEvents = true;
    notifyListeners();
    
    try {
      _events = await _apiService.getEvents(
        search: _searchTerm.isEmpty ? null : _searchTerm,
        type: _selectedEventType,
      );
    } catch (e) {
      debugPrint('Erreur chargement événements: $e');
    }
    
    _isLoadingEvents = false;
    notifyListeners();
  }

  Future<void> loadCategories() async {
    try {
      _categories = await _apiService.getCategories();
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur chargement catégories: $e');
    }
  }

  Future<void> init() async {
    await Future.wait([
      loadStats(),
      loadCategories(),
      loadRecipes(),
    ]);
  }
}
EOF

# Créer l'écran principal
echo "📱 Création de l'écran principal..."
cat > lib/screens/dashboard_screen.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/stats_cards.dart';
import '../widgets/recipe_tab.dart';
import '../widgets/event_tab.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header avec gradient
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  'D',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFF59E0B),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Dashboard Dinor',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'Plateforme culinaire ivoirienne',
                                    style: TextStyle(
                                      color: Colors.yellow[100],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        Text(
                          'Données en temps réel',
                          style: TextStyle(
                            color: Colors.yellow[100],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Statistiques
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: StatsCards(),
            ),
          ),
          
          // Onglets
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    labelColor: Color(0xFFF59E0B),
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Color(0xFFF59E0B),
                    tabs: [
                      Tab(text: '🍽️ Recettes'),
                      Tab(text: '📅 Événements'),
                      Tab(text: '📄 Pages'),
                      Tab(text: '💡 Astuces'),
                    ],
                  ),
                  Container(
                    height: 600,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        RecipeTab(),
                        EventTab(),
                        Center(child: Text('Pages - En développement')),
                        Center(child: Text('Astuces - En développement')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
EOF

# Créer les widgets
echo "🎨 Création des widgets..."
cat > lib/widgets/stats_cards.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';

class StatsCards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingStats) {
          return _buildLoadingCards();
        }

        final stats = provider.stats;
        return GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: [
            _buildStatCard(
              '🍽️',
              'Recettes',
              '${stats['recipes'] ?? 0}',
              '+12 cette semaine',
              Colors.green,
            ),
            _buildStatCard(
              '📅',
              'Événements',
              '${stats['events'] ?? 0}',
              'À venir ce mois',
              Colors.blue,
            ),
            _buildStatCard(
              '📄',
              'Pages',
              '${stats['pages'] ?? 0}',
              'Contenu statique',
              Colors.purple,
            ),
            _buildStatCard(
              '💡',
              'Astuces',
              '${stats['tips'] ?? 0}',
              'Conseils pratiques',
              Colors.orange,
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoadingCards() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: List.generate(4, (index) => _buildLoadingCard()),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          SizedBox(height: 12),
          Container(
            width: 80,
            height: 16,
            color: Colors.grey[300],
          ),
          SizedBox(height: 8),
          Container(
            width: 60,
            height: 24,
            color: Colors.grey[300],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String emoji,
    String title,
    String value,
    String subtitle,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              emoji,
              style: TextStyle(fontSize: 24),
            ),
          ),
          SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[900],
            ),
          ),
          SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
EOF

cat > lib/widgets/recipe_tab.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';
import '../models/recipe.dart';

class RecipeTab extends StatefulWidget {
  @override
  _RecipeTabState createState() => _RecipeTabState();
}

class _RecipeTabState extends State<RecipeTab> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // Barre de recherche et filtres
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: '🔍 Rechercher des recettes...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (value) {
                        provider.setSearchTerm(value);
                        if (value.isEmpty || value.length > 2) {
                          provider.loadRecipes();
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 12),
                  DropdownButton<int?>(
                    value: provider.categories.any((c) => c.id == provider.selectedCategoryId) 
                        ? provider.selectedCategoryId 
                        : null,
                    hint: Text('Catégorie'),
                    items: [
                      DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Toutes'),
                      ),
                      ...provider.categories.map((category) =>
                        DropdownMenuItem<int?>(
                          value: category.id,
                          child: Text(category.name),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      provider.setSelectedCategory(value);
                      provider.loadRecipes();
                    },
                  ),
                ],
              ),
              SizedBox(height: 16),
              
              // Liste des recettes
              Expanded(
                child: provider.isLoadingRecipes
                    ? _buildLoadingGrid()
                    : provider.recipes.isEmpty
                        ? _buildEmptyState()
                        : _buildRecipeGrid(provider.recipes),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => _buildLoadingCard(),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 16,
              color: Colors.grey[300],
            ),
            SizedBox(height: 8),
            Container(
              width: 80,
              height: 12,
              color: Colors.grey[300],
            ),
            SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 60,
              color: Colors.grey[300],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🍽️', style: TextStyle(fontSize: 64)),
          SizedBox(height: 16),
          Text(
            'Aucune recette trouvée',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Essayez de modifier vos critères de recherche',
            style: TextStyle(color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeGrid(List<Recipe> recipes) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: recipes.length,
      itemBuilder: (context, index) => _buildRecipeCard(recipes[index]),
    );
  }

  Widget _buildRecipeCard(Recipe recipe) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.grey[50]!],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    recipe.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: recipe.difficulty == 'easy'
                        ? Colors.green[100]
                        : recipe.difficulty == 'medium'
                            ? Colors.orange[100]
                            : Colors.red[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    recipe.difficulty,
                    style: TextStyle(
                      fontSize: 10,
                      color: recipe.difficulty == 'easy'
                          ? Colors.green[800]
                          : recipe.difficulty == 'medium'
                              ? Colors.orange[800]
                              : Colors.red[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              recipe.description ?? recipe.shortDescription ?? 'Délicieuse recette à découvrir',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            Spacer(),
            Row(
              children: [
                Text(
                  '⏱️ ${recipe.preparationTime}min',
                  style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                ),
                SizedBox(width: 12),
                Text(
                  '👥 ${recipe.servings} pers',
                  style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  recipe.category?.name ?? 'Cuisine générale',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFF59E0B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${recipe.createdAt.day}/${recipe.createdAt.month}/${recipe.createdAt.year}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
EOF

cat > lib/widgets/event_tab.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/dashboard_provider.dart';
import '../models/event.dart';

class EventTab extends StatefulWidget {
  @override
  _EventTabState createState() => _EventTabState();
}

class _EventTabState extends State<EventTab> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // Barre de recherche et filtres
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: '🔍 Rechercher des événements...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (value) {
                        provider.setSearchTerm(value);
                        if (value.isEmpty || value.length > 2) {
                          provider.loadEvents();
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 12),
                  DropdownButton<String?>(
                    value: provider.selectedEventType,
                    hint: Text('Type'),
                    items: [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Tous'),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'upcoming',
                        child: Text('À venir'),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'featured',
                        child: Text('En vedette'),
                      ),
                    ],
                    onChanged: (value) {
                      provider.setSelectedEventType(value);
                      provider.loadEvents();
                    },
                  ),
                ],
              ),
              SizedBox(height: 16),
              
              // Liste des événements
              Expanded(
                child: provider.isLoadingEvents
                    ? _buildLoadingList()
                    : provider.events.isEmpty
                        ? _buildEmptyState()
                        : _buildEventList(provider.events),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingList() {
    return ListView.builder(
      itemCount: 4,
      itemBuilder: (context, index) => _buildLoadingCard(),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 20,
            color: Colors.grey[300],
          ),
          SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 60,
            color: Colors.grey[300],
          ),
          SizedBox(height: 12),
          Container(
            width: 120,
            height: 16,
            color: Colors.grey[300],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('📅', style: TextStyle(fontSize: 64)),
          SizedBox(height: 16),
          Text(
            'Aucun événement trouvé',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Revenez bientôt pour découvrir nos prochains événements',
            style: TextStyle(color: Colors.grey[400]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEventList(List<Event> events) {
    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) => _buildEventCard(events[index]),
    );
  }

  Widget _buildEventCard(Event event) {
    final dateFormat = DateFormat('EEEE d MMMM yyyy', 'fr_FR');
    
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.grey[50]!],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    event.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (event.eventType != null)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      event.eventType!,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.blue[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8),
            if (event.description != null)
              Text(
                event.description!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            SizedBox(height: 12),
            
            // Informations sur l'événement
            if (event.startDate != null) ...[
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[400]),
                  SizedBox(width: 8),
                  Text(
                    dateFormat.format(event.startDate!),
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
              SizedBox(height: 4),
            ],
            
            if (event.location != null) ...[
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[400]),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${event.location}${event.city != null ? ', ${event.city}' : ''}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
            ],
            
            Row(
              children: [
                Icon(Icons.attach_money, size: 16, color: Colors.grey[400]),
                SizedBox(width: 8),
                Text(
                  event.isFree 
                      ? 'Gratuit' 
                      : '${event.price} ${event.currency ?? 'XOF'}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  event.category?.name ?? 'Événement culinaire',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFFF59E0B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${event.createdAt.day}/${event.createdAt.month}/${event.createdAt.year}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
EOF

# Créer le fichier main.dart
echo "🏠 Création du fichier main.dart..."
cat > lib/main.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/dashboard_screen.dart';
import 'providers/dashboard_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DashboardProvider(),
      child: MaterialApp(
        title: 'Dinor Dashboard Flutter',
        theme: ThemeData(
          primarySwatch: MaterialColor(
            0xFFF59E0B,
            <int, Color>{
              50: Color(0xFFFEF3C7),
              100: Color(0xFFFDE68A),
              200: Color(0xFFFCD34D),
              300: Color(0xFFFBBF24),
              400: Color(0xFFF59E0B),
              500: Color(0xFFD97706),
              600: Color(0xFFB45309),
              700: Color(0xFF92400E),
              800: Color(0xFF78350F),
              900: Color(0xFF451A03),
            },
          ),
          scaffoldBackgroundColor: Color(0xFFF9FAFB),
          appBarTheme: AppBarTheme(
            backgroundColor: Color(0xFFF59E0B),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
        ),
        home: DashboardScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
EOF

echo "✅ Génération terminée ! Application Flutter créée dans le dossier '$APP_NAME'"
echo "📋 Prochaines étapes :"
echo "   1. cd $APP_NAME"
echo "   2. flutter pub get"
echo "   3. flutter run"
echo ""
echo "🔧 N'oubliez pas de démarrer votre serveur Laravel sur http://localhost:8000" 