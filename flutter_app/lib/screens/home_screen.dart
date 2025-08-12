import '../services/navigation_service.dart';
/**
 * HOME_SCREEN.DART - CONVERSION FIDÈLE DE Home.vue
 * 
 * FIDÉLITÉ VISUELLE :
 * - BannerSection identique : bannières avec gradients
 * - ContentCarousel identique : 4 derniers items par type
 * - Cartes identiques : recipe-card, tip-card, event-card, video-card
 * - Couleurs identiques : #FFFFFF fond, #F4D03F doré, #FF6B35 orange
 * - Polices identiques : Roboto textes, Open Sans titres
 * 
 * FIDÉLITÉ FONCTIONNELLE :
 * - Setup() identique : composables pour données
 * - Computed identiques : latestRecipes, latestTips, etc.
 * - Handlers identiques : handleRecipeClick, handleTipClick
 * - AuthModal : même gestion d'authentification
 * - Refresh system : même système de rafraîchissement
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

// Components (équivalent des imports Vue)
import '../components/common/banner_section.dart';
import '../components/common/content_carousel.dart';
import '../components/common/like_button.dart';
import '../components/common/auth_modal.dart';
import '../components/common/youtube_video_modal.dart';
import '../components/common/home_video_modal.dart';
import '../components/common/offline_indicator.dart';
import '../components/dinor_icon.dart';

// Services et composables
import '../services/api_service.dart';
import '../services/image_service.dart';
import '../services/analytics_service.dart';
import '../services/analytics_tracker.dart';
import '../services/swipeable_navigation_service.dart';
import '../composables/use_recipes.dart';
import '../composables/use_tips.dart';
import '../composables/use_events.dart';
import '../composables/use_dinor_tv.dart';
import '../composables/use_banners.dart';
import '../composables/use_auth_handler.dart';


class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with AutomaticKeepAliveClientMixin, AnalyticsScreenMixin {
  // État identique au setup() Vue
  bool _showAuthModal = false;
  String _authModalMessage = '';
  
  // Données des composables (équivalent useRecipes, useTips, etc.)
  List<Map<String, dynamic>> _latestRecipes = [];
  List<Map<String, dynamic>> _latestTips = [];
  List<Map<String, dynamic>> _latestEvents = [];
  List<Map<String, dynamic>> _latestVideos = [];
  List<Map<String, dynamic>> _banners = [];
  
  // États de chargement (équivalent loading refs Vue)
  bool _loadingRecipes = true;
  bool _loadingTips = true;
  bool _loadingEvents = true;
  bool _loadingVideos = true;
  bool _loadingBanners = true;
  
  // Erreurs (équivalent error refs Vue)
  String? _errorRecipes;
  String? _errorTips;
  String? _errorEvents;
  String? _errorVideos;
  String? _errorBanners;

  @override
  bool get wantKeepAlive => true;

  @override
  String get screenName => 'home';

  @override
  void initState() {
    super.initState();
    
    // Équivalent onMounted() Vue
    print('🚀 [HomeScreen] Écran d\'accueil initialisé');
    
    _loadAllData();
  }

  // REPRODUCTION EXACTE du chargement de données Vue
  Future<void> _loadAllData() async {
    print('🔄 [HomeScreen] Chargement de toutes les données...');
    
    // Charger toutes les données en parallèle (équivalent composables Vue)
    await Future.wait([
      _loadBanners(),
      _loadLatestRecipes(),
      _loadLatestTips(),
      _loadLatestEvents(),
      _loadLatestVideos(),
    ]);
    
    print('✅ [HomeScreen] Toutes les données chargées');
  }

  // IDENTIQUE à loadBannersForContentType('home', true) Vue
  Future<void> _loadBanners() async {
    setState(() {
      _loadingBanners = true;
      _errorBanners = null;
    });

    try {
      print('🎨 [HomeScreen] Chargement bannières pour type: home');
      // TODO: Implémenter le service de bannières
      // final data = await ApiService.instance.getBanners('home');
      
      setState(() {
        _banners = []; // TODO: data['data'] ?? []
        _loadingBanners = false;
      });
    } catch (error) {
      print('❌ [HomeScreen] Erreur chargement bannières: $error');
      setState(() {
        _errorBanners = error.toString();
        _loadingBanners = false;
      });
    }
  }

  // IDENTIQUE à useRecipes({ limit: 4, sort_by: 'created_at', sort_order: 'desc' }) Vue
  Future<void> _loadLatestRecipes() async {
    setState(() {
      _loadingRecipes = true;
      _errorRecipes = null;
    });

    try {
      print('🍳 [HomeScreen] Chargement des 4 dernières recettes');
      final apiService = ref.read(apiServiceProvider);
      final data = await apiService.get('/recipes', params: {
        'limit': '4',
        'sort_by': 'created_at',
        'sort_order': 'desc',
      });

      if (data['success'] == true) {
        setState(() {
          _latestRecipes = (data['data'] as List).cast<Map<String, dynamic>>().take(4).toList();
          _loadingRecipes = false;
        });
        print('✅ [HomeScreen] ${_latestRecipes.length} recettes chargées');
      }
    } catch (error) {
      print('❌ [HomeScreen] Erreur chargement recettes: $error');
      setState(() {
        _errorRecipes = error.toString();
        _loadingRecipes = false;
      });
    }
  }

  // IDENTIQUE à useTips({ limit: 4, sort_by: 'created_at', sort_order: 'desc' }) Vue
  Future<void> _loadLatestTips() async {
    setState(() {
      _loadingTips = true;
      _errorTips = null;
    });

    try {
      print('💡 [HomeScreen] Chargement des 4 dernières astuces');
      final apiService = ref.read(apiServiceProvider);
      final data = await apiService.get('/tips', params: {
        'limit': '4',
        'sort_by': 'created_at',
        'sort_order': 'desc',
      });

      if (data['success'] == true) {
        setState(() {
          _latestTips = (data['data'] as List).cast<Map<String, dynamic>>().take(4).toList();
          _loadingTips = false;
        });
        print('✅ [HomeScreen] ${_latestTips.length} astuces chargées');
      }
    } catch (error) {
      print('❌ [HomeScreen] Erreur chargement astuces: $error');
      setState(() {
        _errorTips = error.toString();
        _loadingTips = false;
      });
    }
  }

  // IDENTIQUE à useEvents({ limit: 4, sort_by: 'created_at', sort_order: 'desc' }) Vue
  Future<void> _loadLatestEvents() async {
    setState(() {
      _loadingEvents = true;
      _errorEvents = null;
    });

    try {
      print('📅 [HomeScreen] Chargement des 4 derniers événements');
      final apiService = ref.read(apiServiceProvider);
      final data = await apiService.get('/events', params: {
        'limit': '4',
        'sort_by': 'created_at',
        'sort_order': 'desc',
      });

      if (data['success'] == true) {
        setState(() {
          _latestEvents = (data['data'] as List).cast<Map<String, dynamic>>().take(4).toList();
          _loadingEvents = false;
        });
        print('✅ [HomeScreen] ${_latestEvents.length} événements chargés');
      }
    } catch (error) {
      print('❌ [HomeScreen] Erreur chargement événements: $error');
      setState(() {
        _errorEvents = error.toString();
        _loadingEvents = false;
      });
    }
  }

  // IDENTIQUE à useDinorTV({ limit: 4, sort_by: 'created_at', sort_order: 'desc' }) Vue
  Future<void> _loadLatestVideos() async {
    setState(() {
      _loadingVideos = true;
      _errorVideos = null;
    });

    try {
      print('📺 [HomeScreen] Chargement des 4 dernières vidéos');
      final apiService = ref.read(apiServiceProvider);
      final data = await apiService.get('/dinor-tv', params: {
        'limit': '4',
        'sort_by': 'created_at',
        'sort_order': 'desc',
      });

      if (data['success'] == true) {
        setState(() {
          _latestVideos = (data['data'] as List).cast<Map<String, dynamic>>().take(4).toList();
          _loadingVideos = false;
        });
        print('✅ [HomeScreen] ${_latestVideos.length} vidéos chargées');
      }
    } catch (error) {
      print('❌ [HomeScreen] Erreur chargement vidéos: $error');
      setState(() {
        _errorVideos = error.toString();
        _loadingVideos = false;
      });
    }
  }

  // IDENTIQUE à refreshAllData() Vue
  Future<void> _refreshAllData() async {
    print('🔄 [HomeScreen] Rafraîchissement global des données');
    await _loadAllData();
  }

  // REPRODUCTION EXACTE des handlers Vue
  void _handleRecipeClick(Map<String, dynamic> recipe) {
    // Analytics: contenu consulté
    AnalyticsService.logViewContent(
      contentType: 'recipe',
      contentId: recipe['id'].toString(),
      contentName: recipe['title'] ?? 'Recette',
    );
    
    // Tracking du clic sur la recette
    AnalyticsTracker.trackButtonClick(
      buttonName: 'recipe_card',
      screenName: 'home',
      additionalData: {
        'recipe_id': recipe['id'].toString(),
        'recipe_title': recipe['title'] ?? 'Recette',
      },
    );
    
    // Navigation vers le swipeable detail avec la liste des recettes
    SwipeableNavigationService.navigateFromCarousel(
      context: context,
      initialId: recipe['id'].toString(),
      contentType: 'recipe',
      carouselItems: _latestRecipes,
      carouselIndex: _latestRecipes.indexOf(recipe),
    );
  }

  void _handleTipClick(Map<String, dynamic> tip) {
    // Analytics: contenu consulté
    AnalyticsService.logViewContent(
      contentType: 'tip',
      contentId: tip['id'].toString(),
      contentName: tip['title'] ?? 'Astuce',
    );
    
    // Tracking du clic sur l'astuce
    AnalyticsTracker.trackButtonClick(
      buttonName: 'tip_card',
      screenName: 'home',
      additionalData: {
        'tip_id': tip['id'].toString(),
        'tip_title': tip['title'] ?? 'Astuce',
      },
    );
    
    // Navigation vers le swipeable detail avec la liste des astuces
    SwipeableNavigationService.navigateFromCarousel(
      context: context,
      initialId: tip['id'].toString(),
      contentType: 'tip',
      carouselItems: _latestTips,
      carouselIndex: _latestTips.indexOf(tip),
    );
  }

  void _handleEventClick(Map<String, dynamic> event) {
    // Analytics: contenu consulté
    AnalyticsService.logViewContent(
      contentType: 'event',
      contentId: event['id'].toString(),
      contentName: event['title'] ?? 'Événement',
    );
    
    // Tracking du clic sur l'événement
    AnalyticsTracker.trackButtonClick(
      buttonName: 'event_card',
      screenName: 'home',
      additionalData: {
        'event_id': event['id'].toString(),
        'event_title': event['title'] ?? 'Événement',
      },
    );
    
    // Navigation vers le swipeable detail avec la liste des événements
    SwipeableNavigationService.navigateFromCarousel(
      context: context,
      initialId: event['id'].toString(),
      contentType: 'event',
      carouselItems: _latestEvents,
      carouselIndex: _latestEvents.indexOf(event),
    );
  }

  void _handleVideoClick(Map<String, dynamic> video) {
    final videoUrl = video['video_url'] as String?;
    final title = video['title'] as String? ?? 'Vidéo Dinor TV';
    final description = video['description'] as String?;
    
    // Analytics: contenu consulté
    AnalyticsService.logViewContent(
      contentType: 'video',
      contentId: video['id'].toString(),
      contentName: title,
    );
    
    // Tracking du clic sur la vidéo
    AnalyticsTracker.trackButtonClick(
      buttonName: 'video_card',
      screenName: 'home',
      additionalData: {
        'video_id': video['id'].toString(),
        'video_title': title,
        'video_url': videoUrl,
      },
    );
    
    // Navigation vers le swipeable detail avec la liste des vidéos
    SwipeableNavigationService.navigateFromCarousel(
      context: context,
      initialId: video['id'].toString(),
      contentType: 'video',
      carouselItems: _latestVideos,
      carouselIndex: _latestVideos.indexOf(video),
    );
  }

  // IDENTIQUE à handleAuthError Vue
  void _handleAuthError() {
    setState(() {
      _authModalMessage = 'Vous devez vous connecter pour effectuer cette action';
      _displayAuthModal();
    });
  }

  void _handleAuthSuccess() {
    setState(() {
      _showAuthModal = false;
    });
  }

  // UTILITAIRES identiques à Vue

  String _getDifficultyLabel(String? difficulty) {
    const labels = {
      'beginner': 'Débutant',
      'intermediate': 'Intermédiaire',
      'advanced': 'Avancé',
      'easy': 'Facile',
      'medium': 'Moyen',
      'hard': 'Difficile'
    };
    return labels[difficulty] ?? (difficulty ?? '');
  }

  String _getStatusLabel(String? status) {
    const labels = {
      'active': 'Actif',
      'upcoming': 'À venir',
      'completed': 'Terminé',
      'cancelled': 'Annulé'
    };
    return labels[status] ?? (status ?? '');
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day} ${_getMonthAbbr(date.month)}';
    } catch (e) {
      return '';
    }
  }

  String _getMonthAbbr(int month) {
    const months = ['', 'jan', 'fév', 'mar', 'avr', 'mai', 'jun',
                   'jul', 'aoû', 'sep', 'oct', 'nov', 'déc'];
    return months[month];
  }

  String _getVideoThumbnail(String? videoUrl) {
    if (videoUrl == null) return ImageService.getImageUrl('', 'video');
    
    final youtubeMatch = RegExp(r'(?:youtube\.com\/watch\?v=|youtu\.be\/)([^&\n?#]+)').firstMatch(videoUrl);
    if (youtubeMatch != null) {
      return 'https://img.youtube.com/vi/${youtubeMatch.group(1)}/maxresdefault.jpg';
    }
    
    return ImageService.getImageUrl('', 'video');
  }

  String _formatDuration(int? seconds) {
    if (seconds == null) return '';
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF), // Fond blanc identique
      body: RefreshIndicator(
        onRefresh: _refreshAllData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Indicateur hors ligne pour macOS
              const OfflineIndicator(),
              
              // Zone de contenu principal - .content-area CSS identique
              Container(
                width: double.infinity,
                color: const Color(0xFFFFFFFF), // Grande zone blanche
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 20), // padding: 20px 16px
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bannières d'accueil - BannerSection identique
                    BannerSection(
                      type: 'home',
                      section: 'hero',
                      banners: _banners,

                    ),

                    const SizedBox(height: 32),

                    // Événements - d'abord
                    ContentCarousel(
                      title: 'Événements',
                      items: _latestEvents,
                      loading: _loadingEvents,
                      error: _errorEvents,
                      contentType: 'events',
                      viewAllLink: '/events',
                      onItemClick: _handleEventClick,
                      itemBuilder: _buildEventCard,
                    ),

                    const SizedBox(height: 32),

                    // Recettes
                    ContentCarousel(
                      title: 'Recettes',
                      items: _latestRecipes,
                      loading: _loadingRecipes,
                      error: _errorRecipes,
                      contentType: 'recipes',
                      viewAllLink: '/recipes',
                      onItemClick: _handleRecipeClick,
                      itemBuilder: _buildRecipeCard,
                    ),

                    const SizedBox(height: 32),

                    // Astuces
                    ContentCarousel(
                      title: 'Astuces',
                      items: _latestTips,
                      loading: _loadingTips,
                      error: _errorTips,
                      contentType: 'tips',
                      viewAllLink: '/tips',
                      onItemClick: _handleTipClick,
                      itemBuilder: _buildTipCard,
                    ),

                    // Dinor TV - 4 dernières vidéos - ContentCarousel identique
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF1a1a1a), Color(0xFF333333)], // Dégradé identique
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      child: ContentCarousel(
                        title: 'Dinor TV',
                        items: _latestVideos,
                        loading: _loadingVideos,
                        error: _errorVideos,
                        contentType: 'videos',
                        viewAllLink: '/dinor-tv',
                        onItemClick: _handleVideoClick,
                        itemBuilder: _buildVideoCard,
                        darkTheme: true, // Section sombre
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      
      // Auth Modal - AuthModal identique
      // Retiré du bottomSheet pour éviter les problèmes de contexte de navigation
    );
  }

  void _displayAuthModal() {
    // Vérifier que le contexte est prêt avant d'afficher la modale
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _showAuthModal) {
        showDialog(
          context: context,
          barrierDismissible: true,
          useRootNavigator: true,
          builder: (BuildContext context) {
            return AuthModal(
              isOpen: true,
              onClose: () {
                Navigator.of(context, rootNavigator: true).pop();
                setState(() => _showAuthModal = false);
              },
              onAuthenticated: () {
                Navigator.of(context, rootNavigator: true).pop();
                setState(() => _showAuthModal = false);
                _handleAuthSuccess();
              },
            );
          },
        );
      }
    });
  }

  // CONSTRUCTION DES CARTES - Styles CSS identiques

  Widget _buildRecipeCard(Map<String, dynamic> item) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF), // Fond blanc
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)), // Bordure gris clair
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 2),
            blurRadius: 8,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image avec overlay - .card-image CSS
          Container(
            height: 160, // height: 160px
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              image: DecorationImage(
                image: CachedNetworkImageProvider(
                  ImageService.getRecipeImageUrl(item)
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                // Overlay avec badges - .card-overlay CSS
                Positioned(
                  top: 8,
                  right: 8,
                  child: Row(
                    children: [
                      if (item['total_time'] != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(LucideIcons.clock, size: 12, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                '${item['total_time']}min',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(width: 8),
                      if (item['difficulty'] != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getDifficultyLabel(item['difficulty']),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Contenu - .card-content CSS
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre - h3 Open Sans
                Text(
                  item['title'] ?? '',
                  style: const TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 16),
                
                // Meta - .card-meta CSS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Like Button - identique Vue
                    LikeButton(
                      type: 'recipe',
                      itemId: item['id'].toString(),
                      initialLiked: item['is_liked'] ?? false,
                      initialCount: item['likes_count'] ?? 0,
                      showCount: true,
                      size: 'small',
                      variant: 'minimal',
                      onAuthRequired: _handleAuthError,
                    ),
                    
                    // Date
                    Text(
                      _formatDate(item['created_at']),
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12,
                        color: Color(0xFF4A5568),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard(Map<String, dynamic> item) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 2),
            blurRadius: 8,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icône avec gradient - .tip-icon CSS
          Container(
            height: 120,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF4D03F), Color(0xFFFF6B35)], // Dégradé doré vers orange
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: const Center(
              child: Icon(
                LucideIcons.lightbulb,
                size: 48,
                color: Colors.white, // Icône blanche sur fond coloré
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
                  item['title'] ?? '',
                  style: const TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 16),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (item['estimated_time'] != null)
                      Row(
                        children: [
                          const Icon(
                            LucideIcons.clock,
                            size: 16,
                            color: Color(0xFF8B7000), // Couleur dorée pour les icônes
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${item['estimated_time']}min',
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 12,
                              color: Color(0xFF4A5568),
                            ),
                          ),
                        ],
                      ),
                    
                    Text(
                      _formatDate(item['created_at']),
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12,
                        color: Color(0xFF4A5568),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> item) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 2),
            blurRadius: 8,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image avec status badge
          Container(
            height: 160,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              image: DecorationImage(
                image: CachedNetworkImageProvider(
                  ImageService.getEventImageUrl(item)
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(item['status']),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusLabel(item['status']),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Contenu
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'] ?? '',
                  style: const TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 16),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          LucideIcons.calendar,
                          size: 16,
                          color: Color(0xFF8B7000),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(item['start_date']),
                          style: const TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 12,
                            color: Color(0xFF4A5568),
                          ),
                        ),
                      ],
                    ),
                    
                    Text(
                      _formatDate(item['created_at']),
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12,
                        color: Color(0xFF4A5568),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCard(Map<String, dynamic> item) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 2),
            blurRadius: 8,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video thumbnail avec play button
          Container(
            height: 160,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              image: DecorationImage(
                image: CachedNetworkImageProvider(
                  item['thumbnail_url'] ?? _getVideoThumbnail(item['video_url'])
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
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
                
                // Play button
                const Center(
                  child: Icon(
                    LucideIcons.playCircle,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                
                // Live badge si applicable
                if (item['is_live'] == true)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF4444),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                // Duration badge
                if (item['duration'] != null)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _formatDuration(item['duration']),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Contenu
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'] ?? '',
                  style: const TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 16),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          LucideIcons.eye,
                          size: 16,
                          color: Color(0xFF8B7000),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${item['views_count'] ?? 0}',
                          style: const TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 12,
                            color: Color(0xFF4A5568),
                          ),
                        ),
                      ],
                    ),
                    
                    Text(
                      _formatDate(item['created_at']),
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12,
                        color: Color(0xFF4A5568),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'active':
        return const Color(0xFF4CAF50);
      case 'upcoming':
        return const Color(0xFF2196F3);
      case 'completed':
        return const Color(0xFF9E9E9E);
      case 'cancelled':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF4CAF50);
    }
  }
}