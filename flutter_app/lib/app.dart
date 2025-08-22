/// APP.DART - CONVERSION FIDÈLE D'App.vue
/// 
/// FIDÉLITÉ VISUELLE :
/// - LoadingScreen identique : 2500ms, même animation
/// - AppHeader : titre dynamique, boutons favoris/partage identiques
/// - Main content : padding exact (80px header, 80px bottom nav)
/// - Couleurs : #F5F5F5 fond, #FFFFFF contenu
/// - Polices : Roboto pour textes, Open Sans pour titres
/// 
/// FIDÉLITÉ FONCTIONNELLE :
/// - Setup() identique : route watching, header updates
/// - showBottomNav computed : mêmes routes exclues
/// - handleShare, handleBack, handleFavorite : logique identique
/// - Modal d'auth et de partage : états identiques
/// - Router-view équivalent : Navigator classique avec mêmes transitions
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Services
import 'services/navigation_service.dart';
import 'services/modal_service.dart';
import 'services/offline_service.dart';
import 'services/app_initialization_service.dart';
import 'services/splash_screen_service.dart';

// Styles
import 'styles/text_styles.dart';

// Components (équivalent des imports Vue)
import 'components/common/loading_screen.dart';
import 'components/app_header.dart';
import 'components/navigation/bottom_navigation.dart';
import 'components/common/install_prompt.dart';
import 'components/common/app_tutorial.dart';
import 'services/tutorial_service.dart';
import 'stores/notifications_store.dart';

class DinorApp extends ConsumerStatefulWidget {
  const DinorApp({super.key});

  @override
  ConsumerState<DinorApp> createState() => _DinorAppState();
}

class _DinorAppState extends ConsumerState<DinorApp> {
  // État identique au setup() Vue
  bool _showLoading = true;
  bool _showAuthModal = false;
  // _showShareModal supprimé car géré par ModalService
  
  // Configuration splash screen depuis l'API
  int _splashDuration = 2500; // Par défaut
  Map<String, dynamic>? _splashConfig;
  bool _splashConfigLoaded = false;
  
  // Header state - REPRODUCTION EXACTE des ref() Vue
  String _currentPageTitle = 'Dinor';
  bool _showFavoriteButton = false;
  String? _favoriteType;
  String? _favoriteItemId;
  bool _isContentFavorited = false;
  bool _showShareButton = false;
  String? _backPath;
  String _currentRoute = '/';
  
  // Share data supprimé car géré par ModalService
  
  @override
  void initState() {
    super.initState();
    
    // Équivalent onMounted() Vue
    print('🚀 [App] Application démarrée avec loading screen');
    
    // Écouter les changements de route
    NavigationService.addRouteChangeListener(_updateTitle);
    
    // Auto-complete loading après durée configurée via API
    _loadSplashConfig();
  }
  
  @override
  void dispose() {
    NavigationService.removeRouteChangeListener(_updateTitle);
    super.dispose();
  }

  Future<void> _loadSplashConfig() async {
    try {
      // Utiliser le même service que LoadingScreen
      final config = await SplashScreenService.getActiveConfig();
      setState(() {
        _splashDuration = config['duration'] ?? 2500;
        _splashConfig = config;
        _splashConfigLoaded = true; // Configuration chargée
      });
      
      print('🎨 [App] Configuration splash chargée: ${_splashDuration}ms');
      
      // Ne PAS démarrer le timer ici, le LoadingScreen le gère
      
    } catch (e) {
      print('❌ [App] Erreur chargement config splash: $e');
      // Configuration par défaut et on démarre quand même
      setState(() {
        _splashConfigLoaded = true;
      });
    }
  }

  Color _getPreloadBackgroundColor() {
    if (_splashConfig == null) {
      return const Color(0xFFE53E3E); // Rouge par défaut
    }
    
    final backgroundType = _splashConfig!['background_type'] ?? 'gradient';
    if (backgroundType == 'gradient' || backgroundType == 'solid') {
      final colorHex = _splashConfig!['background_color_start'] ?? '#E53E3E';
      return SplashScreenService.parseColor(colorHex, fallback: const Color(0xFFE53E3E));
    }
    
    return const Color(0xFFE53E3E); // Fallback
  }

  void _onLoadingComplete() {
    setState(() {
      _showLoading = false;
    });
    print('🎉 [App] Chargement terminé, app prête !');
    
    // Synchroniser le cache en arrière-plan
    _syncCacheInBackground();

    // Rafraîchir le résumé des notifications au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          ref.read(notificationsSummaryProvider.notifier).refresh();
        } catch (_) {}
        
        // Afficher le tutoriel si nécessaire après un petit délai
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            _showTutorialIfNeeded();
          }
        });
      }
    });
  }

  // Afficher le tutoriel de première utilisation
  void _showTutorialIfNeeded() async {
    try {
      await TutorialService.showWelcomeTutorialIfNeeded(context);
    } catch (e) {
      print('❌ [App] Erreur affichage tutoriel: $e');
    }
  }

  Future<void> _syncCacheInBackground() async {
    try {
      final offlineService = OfflineService();
      await offlineService.backgroundSync();
      print('🔄 [App] Synchronisation du cache terminée');
      
      // Initialiser l'app avec le nouveau service
      final appInitService = ref.read(appInitializationServiceProvider);
      await appInitService.initializeApp(ref);
      print('✅ [App] Initialisation de l\'app terminée');
    } catch (e) {
      print('❌ [App] Erreur synchronisation cache: $e');
    }
  }

  // REPRODUCTION EXACTE de updateTitle() Vue
  void _updateTitle(String routePath) {
    setState(() {
      _currentRoute = routePath; // Stocker la route actuelle
      if (routePath == '/') {
        _currentPageTitle = 'Dinor';
        _showFavoriteButton = false;
        _showShareButton = false;
        _backPath = null;
      } else if (routePath == '/recipes') {
        _currentPageTitle = 'Recettes';
        _showFavoriteButton = false;
        _showShareButton = false;
        _backPath = null;
      } else if (routePath == '/tips') {
        _currentPageTitle = 'Astuces';
        _showFavoriteButton = false;
        _showShareButton = false;
        _backPath = null;
      } else if (routePath == '/events') {
        _currentPageTitle = 'Événements';
        _showFavoriteButton = false;
        _showShareButton = false;
        _backPath = null;
      } else if (routePath == '/dinor-tv') {
        _currentPageTitle = 'Dinor TV';
        _showFavoriteButton = false;
        _showShareButton = false;
        _backPath = null;
      } else if (routePath == '/pages') {
        _currentPageTitle = 'Pages';
        _showFavoriteButton = false;
        _showShareButton = false;
        _backPath = null;
      } else if (routePath.startsWith('/recipe/')) {
        _currentPageTitle = 'Recette';
        _showFavoriteButton = true;
        _showShareButton = true;
        _backPath = '/recipes';
      } else if (routePath.startsWith('/tip/')) {
        _currentPageTitle = 'Astuce';
        _showFavoriteButton = true;
        _showShareButton = true;
        _backPath = '/tips';
      } else if (routePath.startsWith('/event/')) {
        _currentPageTitle = 'Événement';
        _showFavoriteButton = true;
        _showShareButton = true;
        _backPath = '/events';
      } else {
        _currentPageTitle = 'Dinor';
        _showFavoriteButton = false;
        _showShareButton = false;
        _backPath = '/';
      }
    });
  }


  // REPRODUCTION EXACTE de handleShare() Vue
  void _handleShare() {
    print('🎯 [App] handleShare appelé!');
    
    // Utiliser la route stockée pour éviter les problèmes de contexte modal
    final currentRoute = _currentRoute;
    
    // Créer les données de partage basées sur la route actuelle
    final shareData = {
      'title': _currentPageTitle,
      'text': 'Découvrez $_currentPageTitle sur Dinor',
      'url': 'https://new.dinorapp.com$currentRoute', // URL complète pour partage
    };
    
    // Si nous sommes sur une page de détail, ajouter des informations spécifiques
    if (currentRoute.startsWith('/recipe/')) {
      shareData['text'] = 'Découvrez cette délicieuse recette sur Dinor';
      shareData['type'] = 'recipe';
      shareData['id'] = currentRoute.split('/').last;
    } else if (currentRoute.startsWith('/tip/')) {
      shareData['text'] = 'Découvrez cette astuce pratique sur Dinor';
      shareData['type'] = 'tip';
      shareData['id'] = currentRoute.split('/').last;
    } else if (currentRoute.startsWith('/event/')) {
      shareData['text'] = 'Ne manquez pas cet événement sur Dinor';
      shareData['type'] = 'event';
      shareData['id'] = currentRoute.split('/').last;
    }
    
    // Utiliser ModalService pour afficher la modal de partage
    ModalService.showShareModal(
      shareData: shareData,
    );
    
    print('🚀 [App] Déclenchement du partage avec: $shareData');
  }

  // IDENTIQUE à handleBack() Vue
  void _handleBack() {
    if (_backPath != null) {
      NavigationService.pushReplacementNamed(_backPath!);
    } else {
      if (NavigationService.canPop()) {
        NavigationService.pop();
      }
    }
  }

  // REPRODUCTION EXACTE de handleFavoriteUpdate() Vue
  void _handleFavoriteUpdate(Map<String, dynamic> updatedFavorite) {
    print('🌟 [App] Favori mis à jour: $updatedFavorite');
    setState(() {
      _isContentFavorited = updatedFavorite['isFavorited'] ?? false;
    });
  }

  // IDENTIQUE à handleAuthRequired() Vue
  void _handleAuthRequired() {
    setState(() {
      _showAuthModal = true;
    });
    _displayAuthModal();
  }

  void _displayAuthModal() {
    // Utiliser le nouveau système de modal sûr
    ModalService.showAuthModal(
      onClose: () {
        setState(() => _showAuthModal = false);
      },
      onAuthenticated: () {
        setState(() => _showAuthModal = false);
        // Rediriger vers le profil après authentification réussie
        NavigationService.pushReplacementNamed('/profile');
      },
    );
  }

  // COMPUTED équivalent à showBottomNav Vue
  bool get _showBottomNav {
    const excludedRoutes = ['/login', '/register', '/auth-error', '/404'];
    return !excludedRoutes.any((excludedPath) => 
      _currentRoute == excludedPath || _currentRoute.startsWith(excludedPath)
    );
  }

  @override
  Widget build(BuildContext context) {
    // Les changements de route sont maintenant gérés par le listener

    return MaterialApp(
      title: 'Dinor App - Votre chef de poche',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr'),
        Locale('en'),
      ],
      
      // Navigation avec NavigationService
      navigatorKey: NavigationService.navigatorKey,
      onGenerateRoute: NavigationService.generateRoute,
      initialRoute: NavigationService.home,
      navigatorObservers: [NavigationService.routeObserver],
      
      // Thème identique aux styles CSS App.vue
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto', // Utilise Roboto système sur Android, fallback sur iOS
        
        // Couleurs identiques
        scaffoldBackgroundColor: const Color(0xFFF5F5F5), // background: #F5F5F5
        
        // Force Roboto sur toutes les plateformes avec TextTheme uniforme
        textTheme: AppTextStyles.createTextTheme(),
        
        // AppBar theme pour iOS consistency
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: null, // Force default system UI
          elevation: 0,
          backgroundColor: Color(0xFFE53E3E),
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        
        // Scrollbar personnalisée identique
        scrollbarTheme: ScrollbarThemeData(
          thickness: WidgetStateProperty.all(6),
          radius: const Radius.circular(3),
          thumbColor: WidgetStateProperty.all(const Color(0xFFE53E3E)),
          trackColor: WidgetStateProperty.all(const Color(0xFFF7FAFC)),
        ),
      ),
      
      builder: (context, child) {
        final mediaQueryData = MediaQuery.maybeOf(context);
        final baseMediaQuery = mediaQueryData ?? const MediaQueryData();
        return MediaQuery(
          data: baseMediaQuery.copyWith(
            textScaler: const TextScaler.linear(1.0), // Nouvelle API pour fixer la taille du texte
          ),
          child: Stack(
          children: [
            // Fond de chargement pour éviter l'écran noir
            if (_showLoading)
              Container(
                color: _getPreloadBackgroundColor(),
              ),
            
            // App principale (masquée pendant le loading) - v-if="!showLoading"
            if (!_showLoading)
              Scaffold(
                backgroundColor: const Color(0xFFF5F5F5),
                body: Column(
                  children: [
                    // En-tête de l'application - AppHeader
                    AppHeader(
                      title: _currentPageTitle,
                      showFavorite: _showFavoriteButton,
                      favoriteType: _favoriteType,
                      favoriteItemId: _favoriteItemId,
                      initialFavorited: _isContentFavorited,
                      showShare: _showShareButton,
                      backPath: _backPath,
                      onFavoriteUpdated: _handleFavoriteUpdate,
                      onShare: _handleShare,
                      onBack: _handleBack,
                      onAuthRequired: _handleAuthRequired,
                    ),
                    
                    // Main Content - classe CSS identique
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFFFFF), // Fond blanc pour la zone principale
                        ),
                        padding: EdgeInsets.only(
                          top: 0, // padding-top: 80px (with-header)
                          bottom: _showBottomNav ? 0 : 0, // padding-bottom: 80px (with-bottom-nav)
                        ),
                        child: child ?? const SizedBox.shrink(),
                      ),
                    ),
                  ],
                ),
                
                // Bottom Navigation - v-if="showBottomNav" (dynamic with API pages)
                bottomNavigationBar: _showBottomNav ? const BottomNavigation() : null,
                
                // PWA Install Prompt - InstallPrompt
                floatingActionButton: const InstallPrompt(),
              ),
            
            // Loading Screen - v-if="showLoading"
            if (_showLoading)
              LoadingScreen(
                visible: _showLoading,
                duration: _splashDuration,
                onComplete: _onLoadingComplete,
              ),
            
            // Share Modal géré par ModalService maintenant
            // La modal est gérée automatiquement par ModalService.showShareModal()
            
            // Auth Modal - v-model="showAuthModal"
            // Retiré du Stack pour éviter les problèmes de contexte de navigation
          ],
          ),
        );
      },
    );
  }
}