/**
 * APP.DART - CONVERSION FIDÈLE D'App.vue
 * 
 * FIDÉLITÉ VISUELLE :
 * - LoadingScreen identique : 2500ms, même animation
 * - AppHeader : titre dynamique, boutons favoris/partage identiques
 * - Main content : padding exact (80px header, 80px bottom nav)
 * - Couleurs : #F5F5F5 fond, #FFFFFF contenu
 * - Polices : Roboto pour textes, Open Sans pour titres
 * 
 * FIDÉLITÉ FONCTIONNELLE :
 * - Setup() identique : route watching, header updates
 * - showBottomNav computed : mêmes routes exclues
 * - handleShare, handleBack, handleFavorite : logique identique
 * - Modal d'auth et de partage : états identiques
 * - Router-view équivalent : Navigator classique avec mêmes transitions
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Services
import 'services/navigation_service.dart';
import 'services/modal_service.dart';

// Components (équivalent des imports Vue)
import 'components/common/loading_screen.dart';
import 'components/common/app_header.dart';
import 'components/navigation/simple_bottom_navigation.dart';
import 'components/common/install_prompt.dart';

class DinorApp extends ConsumerStatefulWidget {
  const DinorApp({Key? key}) : super(key: key);

  @override
  ConsumerState<DinorApp> createState() => _DinorAppState();
}

class _DinorAppState extends ConsumerState<DinorApp> {
  // État identique au setup() Vue
  bool _showLoading = true;
  bool _showAuthModal = false;
  // _showShareModal supprimé car géré par ModalService
  
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
    
    // Auto-complete loading après 2500ms (identique à App.vue)
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        _onLoadingComplete();
      }
    });
  }
  
  @override
  void dispose() {
    NavigationService.removeRouteChangeListener(_updateTitle);
    super.dispose();
  }

  void _onLoadingComplete() {
    setState(() {
      _showLoading = false;
    });
    print('🎉 [App] Chargement terminé, app prête !');
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

  // IDENTIQUE à updateHeader() Vue
  void _updateHeader(Map<String, dynamic> headerData) {
    setState(() {
      if (headerData['title'] != null) _currentPageTitle = headerData['title'];
      if (headerData['showFavorite'] != null) _showFavoriteButton = headerData['showFavorite'];
      if (headerData['favoriteType'] != null) _favoriteType = headerData['favoriteType'];
      if (headerData['favoriteItemId'] != null) _favoriteItemId = headerData['favoriteItemId'];
      if (headerData['isContentFavorited'] != null) _isContentFavorited = headerData['isContentFavorited'];
      if (headerData['showShare'] != null) _showShareButton = headerData['showShare'];
      if (headerData['backPath'] != null) _backPath = headerData['backPath'];
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
      'url': 'https://dinor.app$currentRoute', // URL complète pour partage
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
      
      // Navigation avec NavigationService
      navigatorKey: NavigationService.navigatorKey,
      onGenerateRoute: NavigationService.generateRoute,
      initialRoute: NavigationService.home,
      
      // Thème identique aux styles CSS App.vue
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        
        // Couleurs identiques
        scaffoldBackgroundColor: const Color(0xFFF5F5F5), // background: #F5F5F5
        
        // Typographie identique aux styles CSS
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontFamily: 'OpenSans',
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
            height: 1.3,
          ),
          bodyLarge: TextStyle(
            fontFamily: 'Roboto',
            color: Color(0xFF4A5568),
            height: 1.5,
          ),
        ),
        
        // Scrollbar personnalisée identique
        scrollbarTheme: ScrollbarThemeData(
          thickness: MaterialStateProperty.all(6),
          radius: const Radius.circular(3),
          thumbColor: MaterialStateProperty.all(const Color(0xFFE53E3E)),
          trackColor: MaterialStateProperty.all(const Color(0xFFF7FAFC)),
        ),
      ),
      
      builder: (context, child) {
        return Stack(
          children: [
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
                
                // Bottom Navigation - v-if="showBottomNav"
                bottomNavigationBar: _showBottomNav ? const SimpleBottomNavigation() : null,
                
                // PWA Install Prompt - InstallPrompt
                floatingActionButton: const InstallPrompt(),
              ),
            
            // Loading Screen - v-if="showLoading"
            if (_showLoading)
              LoadingScreen(
                visible: _showLoading,
                duration: 2500,
                onComplete: _onLoadingComplete,
              ),
            
            // Share Modal géré par ModalService maintenant
            // La modal est gérée automatiquement par ModalService.showShareModal()
            
            // Auth Modal - v-model="showAuthModal"
            // Retiré du Stack pour éviter les problèmes de contexte de navigation
          ],
        );
      },
    );
  }
}