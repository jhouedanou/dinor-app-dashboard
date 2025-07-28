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
 * - Router-view équivalent : GoRouter avec mêmes transitions
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Components (équivalent des imports Vue)
import 'components/common/loading_screen.dart';
import 'components/common/app_header.dart';
import 'components/navigation/bottom_navigation.dart';
import 'components/common/install_prompt.dart';
import 'components/common/share_modal.dart';
import 'components/common/auth_modal.dart';

// Stores et composables (remplace les imports Vue)


import 'router/app_router.dart';

class DinorApp extends ConsumerStatefulWidget {
  const DinorApp({Key? key}) : super(key: key);

  @override
  ConsumerState<DinorApp> createState() => _DinorAppState();
}

class _DinorAppState extends ConsumerState<DinorApp> {
  // État identique au setup() Vue
  bool _showLoading = true;
  bool _showAuthModal = false;
  bool _showShareModal = false;
  
  // Header state - REPRODUCTION EXACTE des ref() Vue
  String _currentPageTitle = 'Dinor';
  bool _showFavoriteButton = false;
  String? _favoriteType;
  String? _favoriteItemId;
  bool _isContentFavorited = false;
  bool _showShareButton = false;
  String? _backPath;
  
  // Share data - équivalent currentShareData ref()
  Map<String, dynamic> _currentShareData = {};
  
  @override
  void initState() {
    super.initState();
    
    // Équivalent onMounted() Vue
    print('🚀 [App] Application démarrée avec loading screen');
    
    // Auto-complete loading après 2500ms (identique à App.vue)
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        _onLoadingComplete();
      }
    });
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
    
    final currentRoute = GoRouterState.of(context).uri.path;
    
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
    
    // Stocker les données de partage pour le modal
    setState(() {
      _currentShareData = shareData;
      _showShareModal = true;
    });
    
    print('🚀 [App] Déclenchement du partage avec: $shareData');
  }

  // IDENTIQUE à handleBack() Vue
  void _handleBack() {
    if (_backPath != null) {
      context.go(_backPath!);
    } else {
      if (context.canPop()) {
        context.pop();
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
    print('🔒 [App] Authentification requise');
    setState(() {
      _showAuthModal = true;
    });
  }

  // COMPUTED équivalent à showBottomNav Vue
  bool get _showBottomNav {
    final currentRoute = GoRouterState.of(context).uri.path;
    const excludedRoutes = ['/login', '/register', '/auth-error', '/404'];
    return !excludedRoutes.any((excludedPath) => 
      currentRoute == excludedPath || currentRoute.startsWith(excludedPath)
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Dinor App',
      debugShowCheckedModeBanner: false,
      
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
      
      routerConfig: appRouter,
      
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
                          top: 80, // padding-top: 80px (with-header)
                          bottom: _showBottomNav ? 80 : 0, // padding-bottom: 80px (with-bottom-nav)
                        ),
                        child: child ?? const SizedBox.shrink(),
                      ),
                    ),
                  ],
                ),
                
                // Bottom Navigation - v-if="showBottomNav"
                bottomNavigationBar: _showBottomNav ? const BottomNavigation() : null,
                
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
            
            // Share Modal - v-model="showShareModal"
            if (_showShareModal)
              ShareModal(
                isOpen: _showShareModal,
                shareData: _currentShareData,
                onClose: () => setState(() => _showShareModal = false),
              ),
            
            // Auth Modal - v-model="showAuthModal"
            if (_showAuthModal)
              AuthModal(
                isOpen: _showAuthModal,
                onClose: () => setState(() => _showAuthModal = false),
              ),
          ],
        );
      },
    );
  }
}