import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/navigation_service.dart';
import '../services/cache_service.dart';

class WorkingHomeScreen extends StatefulWidget {
  const WorkingHomeScreen({Key? key}) : super(key: key);

  @override
  State<WorkingHomeScreen> createState() => _WorkingHomeScreenState();
}

class _WorkingHomeScreenState extends State<WorkingHomeScreen> {
  List<dynamic> recipes = [];
  List<dynamic> tips = [];
  List<dynamic> events = [];
  List<dynamic> videos = [];
  
  bool isLoadingRecipes = true;
  bool isLoadingTips = true;
  bool isLoadingEvents = true;
  bool isLoadingVideos = true;
  
  String? errorRecipes;
  String? errorTips;
  String? errorEvents;
  String? errorVideos;

  final CacheService _cacheService = CacheService();

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      _loadRecipes(),
      _loadTips(),
      _loadEvents(),
      _loadVideos(),
    ]);
  }

  Future<void> _loadRecipes() async {
    try {
      // Vérifier d'abord le cache
      final cachedRecipes = await _cacheService.getCachedRecipes();
      if (cachedRecipes != null) {
        setState(() {
          recipes = cachedRecipes.take(4).toList();
          isLoadingRecipes = false;
        });
      }

      // Charger depuis l'API
      final response = await http.get(
        Uri.parse('https://new.dinorapp.com/api/v1/recipes?limit=4'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newRecipes = data['data'] is List ? data['data'] : [data['data']];
        
        // Mettre en cache
        await _cacheService.cacheRecipes(newRecipes);
        await _cacheService.updateCacheTimestamp();
        
        setState(() {
          recipes = newRecipes;
          isLoadingRecipes = false;
          errorRecipes = null;
        });
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [Home] Erreur chargement recettes: $e');
      setState(() {
        isLoadingRecipes = false;
        errorRecipes = e.toString();
      });
    }
  }

  Future<void> _loadTips() async {
    try {
      // Vérifier d'abord le cache
      final cachedTips = await _cacheService.getCachedTips();
      if (cachedTips != null) {
        setState(() {
          tips = cachedTips.take(4).toList();
          isLoadingTips = false;
        });
      }

      // Charger depuis l'API
      final response = await http.get(
        Uri.parse('https://new.dinorapp.com/api/v1/tips?limit=4'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newTips = data['data'] is List ? data['data'] : [data['data']];
        
        // Mettre en cache
        await _cacheService.cacheTips(newTips);
        
        setState(() {
          tips = newTips;
          isLoadingTips = false;
          errorTips = null;
        });
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [Home] Erreur chargement astuces: $e');
      setState(() {
        isLoadingTips = false;
        errorTips = e.toString();
      });
    }
  }

  Future<void> _loadEvents() async {
    try {
      // Vérifier d'abord le cache
      final cachedEvents = await _cacheService.getCachedEvents();
      if (cachedEvents != null) {
        setState(() {
          events = cachedEvents.take(4).toList();
          isLoadingEvents = false;
        });
      }

      // Charger depuis l'API
      final response = await http.get(
        Uri.parse('https://new.dinorapp.com/api/v1/events?limit=4'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newEvents = data['data'] is List ? data['data'] : [data['data']];
        
        // Mettre en cache
        await _cacheService.cacheEvents(newEvents);
        
        setState(() {
          events = newEvents;
          isLoadingEvents = false;
          errorEvents = null;
        });
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [Home] Erreur chargement événements: $e');
      setState(() {
        isLoadingEvents = false;
        errorEvents = e.toString();
      });
    }
  }

  Future<void> _loadVideos() async {
    try {
      // Charger depuis l'API
      final response = await http.get(
        Uri.parse('https://new.dinorapp.com/api/v1/dinor-tv?limit=4'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newVideos = data['data'] is List ? data['data'] : [data['data']];
        
        setState(() {
          videos = newVideos;
          isLoadingVideos = false;
          errorVideos = null;
        });
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [Home] Erreur chargement vidéos: $e');
      setState(() {
        isLoadingVideos = false;
        errorVideos = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: RefreshIndicator(
        onRefresh: _loadAllData,
        color: const Color(0xFFE53E3E),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête
              _buildHeader(),
              const SizedBox(height: 24),

              // Recettes
              _buildSection(
                'Dernières Recettes',
                '/recipes',
                recipes,
                isLoadingRecipes,
                errorRecipes,
                _buildRecipeCard,
                Icons.restaurant,
                const Color(0xFFE53E3E),
              ),
              const SizedBox(height: 24),

              // Astuces
              _buildSection(
                'Dernières Astuces',
                '/tips',
                tips,
                isLoadingTips,
                errorTips,
                _buildTipCard,
                Icons.lightbulb,
                const Color(0xFFF4D03F),
              ),
              const SizedBox(height: 24),

              // Événements
              _buildSection(
                'Derniers Événements',
                '/events',
                events,
                isLoadingEvents,
                errorEvents,
                _buildEventCard,
                Icons.event,
                const Color(0xFF38A169),
              ),
              const SizedBox(height: 24),

              // Vidéos
              _buildSection(
                'Dernières Vidéos Dinor TV',
                '/dinor-tv',
                videos,
                isLoadingVideos,
                errorVideos,
                _buildVideoCard,
                Icons.play_circle,
                const Color(0xFF9B59B6),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE53E3E), Color(0xFFC53030)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bienvenue sur Dinor',
            style: TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Découvrez nos recettes, astuces et événements',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    String title,
    String route,
    List<dynamic> items,
    bool isLoading,
    String? error,
    Widget Function(Map<String, dynamic>) cardBuilder,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête de section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () => NavigationService.pushNamed(route),
              child: Text(
                'Voir tout',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Contenu
        if (isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE53E3E)),
              ),
            ),
          )
        else if (error != null)
          _buildErrorWidget(error)
        else if (items.isEmpty)
          _buildEmptyWidget()
        else
          SizedBox(
            height: 280,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 280,
                  margin: const EdgeInsets.only(right: 16),
                  child: cardBuilder(items[index]),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildRecipeCard(Map<String, dynamic> recipe) {
    return Container(
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
        onTap: () {
          NavigationService.pushNamed('/recipe-detail', arguments: {'id': recipe['id'].toString()});
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  recipe['featured_image_url'] ?? 'https://via.placeholder.com/300x200',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFFF7FAFC),
                      child: const Icon(
                        Icons.restaurant,
                        size: 48,
                        color: Color(0xFFCBD5E0),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Contenu
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe['title'] ?? 'Sans titre',
                    style: const TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3748),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  if (recipe['short_description'] != null) ...[
                    Text(
                      recipe['short_description'],
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14,
                        color: Color(0xFF718096),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                  ],
                  Row(
                    children: [
                      if (recipe['total_time'] != null) ...[
                        const Icon(Icons.schedule, size: 16, color: Color(0xFF718096)),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe['total_time']} min',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF718096),
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      if (recipe['likes_count'] != null) ...[
                        const Icon(Icons.favorite, size: 16, color: Color(0xFFE53E3E)),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe['likes_count']}',
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
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard(Map<String, dynamic> tip) {
    return Container(
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
        onTap: () {
          NavigationService.pushNamed('/tip-detail', arguments: {'id': tip['id'].toString()});
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icône d'astuce
            Container(
              height: 120,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF4D03F), Color(0xFFFF6B35)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: const Center(
                child: Icon(
                  Icons.lightbulb,
                  size: 48,
                  color: Colors.white,
                ),
              ),
            ),

            // Contenu
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tip['title'] ?? 'Sans titre',
                    style: const TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3748),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  if (tip['content'] != null) ...[
                    Text(
                      tip['content'],
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14,
                        color: Color(0xFF718096),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                  ],
                  Row(
                    children: [
                      if (tip['estimated_time'] != null) ...[
                        const Icon(Icons.schedule, size: 16, color: Color(0xFF718096)),
                        const SizedBox(width: 4),
                        Text(
                          '${tip['estimated_time']} min',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF718096),
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      if (tip['likes_count'] != null) ...[
                        const Icon(Icons.favorite, size: 16, color: Color(0xFFE53E3E)),
                        const SizedBox(width: 4),
                        Text(
                          '${tip['likes_count']}',
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
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    return Container(
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
        onTap: () {
          NavigationService.pushNamed('/event-detail', arguments: {'id': event['id'].toString()});
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  event['image_url'] ?? 'https://via.placeholder.com/300x200',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFFF7FAFC),
                      child: const Icon(
                        Icons.event,
                        size: 48,
                        color: Color(0xFFCBD5E0),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Contenu
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event['title'] ?? 'Sans titre',
                    style: const TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3748),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  if (event['short_description'] != null) ...[
                    Text(
                      event['short_description'],
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14,
                        color: Color(0xFF718096),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                  ],
                  Row(
                    children: [
                      if (event['start_date'] != null) ...[
                        const Icon(Icons.calendar_today, size: 16, color: Color(0xFFE53E3E)),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(event['start_date']),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF718096),
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      if (event['likes_count'] != null) ...[
                        const Icon(Icons.favorite, size: 16, color: Color(0xFFE53E3E)),
                        const SizedBox(width: 4),
                        Text(
                          '${event['likes_count']}',
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
          ],
        ),
      ),
    );
  }

  Widget _buildVideoCard(Map<String, dynamic> video) {
    return Container(
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
        onTap: () {
          // Navigation vers la vidéo
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail avec overlay
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  children: [
                    Image.network(
                      video['thumbnail_url'] ?? 'https://via.placeholder.com/300x200',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFFF7FAFC),
                          child: const Icon(
                            Icons.play_circle,
                            size: 48,
                            color: Color(0xFFCBD5E0),
                          ),
                        );
                      },
                    ),
                    Container(
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
                    const Center(
                      child: Icon(
                        Icons.play_circle_outline,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Contenu
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video['title'] ?? 'Sans titre',
                    style: const TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3748),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  if (video['description'] != null) ...[
                    Text(
                      video['description'],
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14,
                        color: Color(0xFF718096),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                  ],
                  Row(
                    children: [
                      if (video['views_count'] != null) ...[
                        const Icon(Icons.visibility, size: 16, color: Color(0xFF718096)),
                        const SizedBox(width: 4),
                        Text(
                          '${video['views_count']}',
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
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE53E3E).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            size: 32,
            color: Color(0xFFE53E3E),
          ),
          const SizedBox(height: 8),
          Text(
            'Erreur de chargement',
            style: const TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            error,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 12,
              color: Color(0xFF718096),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.inbox_outlined,
            size: 32,
            color: Color(0xFFCBD5E0),
          ),
          const SizedBox(height: 8),
          Text(
            'Aucun contenu disponible',
            style: const TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}