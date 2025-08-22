import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import '../services/navigation_service.dart';
import '../services/cache_service.dart';
import '../services/offline_service.dart';
import '../services/image_service.dart';
import '../services/tutorial_service.dart';
import '../components/app_header.dart';
import '../components/common/home_video_modal.dart';
import '../components/common/content_carousel.dart';
import '../components/common/enhanced_3d_carousel.dart';
import '../components/common/content_item_card.dart';
import 'cache_management_screen.dart';

class WorkingHomeScreen extends StatefulWidget {
  const WorkingHomeScreen({super.key});

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
  final OfflineService _offlineService = OfflineService();

  // Helper pour tronquer le contenu HTML pour les cartes
  String _stripHtmlAndTruncate(String htmlContent, int maxLength) {
    // Supprimer les balises HTML de base
    String text = htmlContent
        .replaceAll(RegExp(r'<[^>]*>'), '') // Supprimer toutes les balises HTML
        .replaceAll(RegExp(r'\s+'), ' ') // Normaliser les espaces
        .trim();

    // Tronquer si nécessaire
    if (text.length > maxLength) {
      text = '${text.substring(0, maxLength)}...';
    }

    return text;
  }

  @override
  void initState() {
    super.initState();
    _loadAllData();
    
    // Afficher le tutoriel de la page d'accueil si nécessaire (désactivé temporairement)
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (mounted) {
    //     TutorialService.showHomePageTutorialIfNeeded(context);
    //   }
    // });
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
      final result = await _offlineService.loadDataWithOfflineSupport(
        endpoint: 'https://new.dinorapp.com/api/v1/recipes',
        cacheKey: 'home_recipes',
        params: {'limit': '4'},
      );

      if (result['success']) {
        final data = result['data'];
        final newRecipes = data['data'] is List ? data['data'] : [data['data']];

        setState(() {
          recipes = newRecipes;
          isLoadingRecipes = false;
          errorRecipes = null;
        });

        // Afficher un indicateur si en mode hors ligne
        if (result['offline'] == true) {
          _showOfflineIndicator();
        }
      } else {
        setState(() {
          isLoadingRecipes = false;
          errorRecipes = result['error'];
        });
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
      final result = await _offlineService.loadDataWithOfflineSupport(
        endpoint: 'https://new.dinorapp.com/api/v1/tips',
        cacheKey: 'home_tips',
        params: {'limit': '4'},
      );

      if (result['success']) {
        final data = result['data'];
        final newTips = data['data'] is List ? data['data'] : [data['data']];

        setState(() {
          tips = newTips;
          isLoadingTips = false;
          errorTips = null;
        });

        // Afficher un indicateur si en mode hors ligne
        if (result['offline'] == true) {
          _showOfflineIndicator();
        }
      } else {
        setState(() {
          isLoadingTips = false;
          errorTips = result['error'];
        });
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
      final result = await _offlineService.loadDataWithOfflineSupport(
        endpoint: 'https://new.dinorapp.com/api/v1/events',
        cacheKey: 'home_events',
        params: {'limit': '4'},
      );

      if (result['success']) {
        final data = result['data'];
        final newEvents = data['data'] is List ? data['data'] : [data['data']];

        setState(() {
          events = newEvents;
          isLoadingEvents = false;
          errorEvents = null;
        });

        // Afficher un indicateur si en mode hors ligne
        if (result['offline'] == true) {
          _showOfflineIndicator();
        }
      } else {
        setState(() {
          isLoadingEvents = false;
          errorEvents = result['error'];
        });
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
      final result = await _offlineService.loadDataWithOfflineSupport(
        endpoint: 'https://new.dinorapp.com/api/v1/dinor-tv',
        cacheKey: 'home_videos',
        params: {'limit': '4'},
      );

      if (result['success']) {
        final data = result['data'];
        final newVideos = data['data'] is List ? data['data'] : [data['data']];

        // Debug : vérifier les champs de miniatures disponibles
        if (newVideos.isNotEmpty) {
          print('🎬 [Home] Premier élément vidéo récupéré:');
          final firstVideo = newVideos.first;
          print('  - ID: ${firstVideo['id']}');
          print('  - Title: ${firstVideo['title']}');
          print('  - thumbnail: ${firstVideo['thumbnail']}');
          print('  - thumbnail_url: ${firstVideo['thumbnail_url']}');
          print('  - featured_image_url: ${firstVideo['featured_image_url']}');
          print('  - banner_image_url: ${firstVideo['banner_image_url']}');
          print('  - poster_image_url: ${firstVideo['poster_image_url']}');
          print('  - image: ${firstVideo['image']}');
          print('  - image_url: ${firstVideo['image_url']}');
          print('  - Tous les champs: ${firstVideo.keys.toList()}');
        }

        setState(() {
          videos = newVideos;
          isLoadingVideos = false;
          errorVideos = null;
        });

        // Afficher un indicateur si en mode hors ligne
        if (result['offline'] == true) {
          _showOfflineIndicator();
        }
      } else {
        setState(() {
          isLoadingVideos = false;
          errorVideos = result['error'];
        });
      }
    } catch (e) {
      print('❌ [Home] Erreur chargement vidéos: $e');
      setState(() {
        isLoadingVideos = false;
        errorVideos = e.toString();
      });
    }
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

  void _handleRecipeClick(Map<String, dynamic> recipe) {
    NavigationService.goToRecipeDetail(recipe['id'].toString());
  }

  void _handleTipClick(Map<String, dynamic> tip) {
    NavigationService.pushNamed('/tip-detail-unified/${tip['id']}');
  }

  void _handleEventClick(Map<String, dynamic> event) {
    NavigationService.pushNamed('/event-detail-unified/${event['id']}');
  }

  void _handleVideoClick(Map<String, dynamic> video) {
    _openVideo(video);
  }

  void _openVideo(Map<String, dynamic> video) {
    final videoUrl = video['video_url'] as String?;
    final title = video['title'] as String? ?? 'Vidéo Dinor TV';
    final description = video['description'] as String?;

    if (videoUrl != null && videoUrl.isNotEmpty) {
      print('🎬 [WorkingHome] Ouverture vidéo intégrée: $title');
      print('🎬 [WorkingHome] URL: $videoUrl');

      // Afficher la modal vidéo optimisée pour la page d'accueil
      showDialog(
        context: context,
        barrierDismissible: true,
        useRootNavigator: true,
        builder: (context) => HomeVideoModal(
          isOpen: true,
          videoUrl: videoUrl,
          title: title,
          description: description,
          onClose: () {
            if (Navigator.of(context, rootNavigator: true).canPop()) {
              Navigator.of(context, rootNavigator: true).pop();
            }
          },
        ),
      );
    } else {
      print('⚠️ [WorkingHome] URL vidéo manquante pour: $title');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('URL de vidéo non disponible'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Fond gris clair comme avant
      body: Column(
        children: [
          // Contenu principal avec pull-to-refresh
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadAllData,
              color: const Color(0xFFE53E3E),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // En-tête de bienvenue
                    _buildWelcomeHeader(),
                    const SizedBox(height: 24),



                    // Événements - Format Carousel plat
                    Builder(
                      builder: (context) {
                        print('🏠 [WorkingHomeScreen] Affichage Enhanced3DCarousel Événements');
                        print('🏠 [WorkingHomeScreen] Événements - items: ${events.length}, loading: $isLoadingEvents, error: $errorEvents');
                        return Enhanced3DCarousel(
                          title: 'Événements',
                          items: events.take(4).toList(),
                          loading: isLoadingEvents,
                          error: errorEvents,
                          contentType: 'events',
                          viewAllLink: '/events',
                          onItemClick: _handleEventClick,
                          cardHeight: 250,
                          cardWidth: 300,
                          flatLayout: true, // Layout plat comme dans les images
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Recettes - Format Carousel plat
                    Enhanced3DCarousel(
                      title: 'Recettes',
                      items: recipes.take(4).toList(),
                      loading: isLoadingRecipes,
                      error: errorRecipes,
                      contentType: 'recipes',
                      viewAllLink: '/recipes',
                      onItemClick: _handleRecipeClick,
                      cardHeight: 250,
                      cardWidth: 300,
                      flatLayout: true, // Layout plat comme dans les images
                    ),
                    const SizedBox(height: 24),

                    // Astuces - Format Carousel plat
                    Enhanced3DCarousel(
                      title: 'Astuces',
                      items: tips.take(4).toList(),
                      loading: isLoadingTips,
                      error: errorTips,
                      contentType: 'tips',
                      viewAllLink: '/tips',
                      onItemClick: _handleTipClick,
                      cardHeight: 250,
                      cardWidth: 300,
                      flatLayout: true, // Layout plat comme dans les images
                    ),
                    const SizedBox(height: 16),

                    // Dinor TV - Format Carousel plat
                    Enhanced3DCarousel(
                      title: 'Dinor TV',
                      items: videos.take(4).toList(),
                      loading: isLoadingVideos,
                      error: errorVideos,
                      contentType: 'videos', // Type corrigé pour la détection dans CoverflowCard
                      viewAllLink: '/dinor-tv',
                      onItemClick: _handleVideoClick,
                      darkTheme: false,
                      cardHeight: 250,
                      cardWidth: 300,
                      flatLayout: true, // Layout plat comme dans les images
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return const SizedBox.shrink();
  }


}
