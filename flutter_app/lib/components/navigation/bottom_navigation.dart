/**
 * BOTTOM_NAVIGATION.DART - CONVERSION FIDÈLE DE BottomNavigation.vue
 * 
 * FIDÉLITÉ VISUELLE :
 * - Position : absolute bottom (0, 0, 0) → positioned bottom
 * - Couleur : #F4D03F (fond doré) identique
 * - Hauteur : 80px exacte + safe area insets
 * - 6 onglets : même layout flex space-around
 * - État actif : #FF6B35 (orange) + soulignement 24px
 * - Police : Roboto 12px/500 pour labels
 * - Icônes : 24px Lucide identiques
 * 
 * FIDÉLITÉ FONCTIONNELLE :
 * - isActive() : même logique route matching
 * - handleItemClick() : authentification profil + navigation
 * - AuthModal : même comportement
 * - Menu statique : 6 items identiques (home, recipes, tips, events, dinor-tv, profile)
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/navigation_service.dart';
import '../../styles/shadows.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

// Components
import '../common/auth_modal.dart';

// Composables et stores
import '../../composables/use_auth_handler.dart';
import '../../composables/use_pages.dart';
import '../../services/tutorial_service.dart';


class BottomNavigation extends ConsumerStatefulWidget {
  const BottomNavigation({Key? key}) : super(key: key);

  @override
  ConsumerState<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends ConsumerState<BottomNavigation> {
  bool _showAuthModal = false;
  String _authModalMessage = '';
  bool _showScrollTooltip = true;

  @override
  void initState() {
    super.initState();
    // Charger les pages au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(usePagesProvider.notifier).loadPages();
    });
  }

  // Surveiller les changements de pages pour afficher le tutoriel si nécessaire
  void _checkForNavigationTutorial(List<PageModel> pages) {
    final totalItems = _menuItems.length + pages.length;
    if (totalItems > 6) {
      // Attendre un peu que l'interface soit stable
      Future.delayed(const Duration(milliseconds: 2000), () {
        if (mounted) {
          TutorialService.showNavigationTutorialIfNeeded(context, totalItems);
        }
      });
    }
  }

  // Menu statique identique à BottomNavigation.vue
  final List<Map<String, dynamic>> _menuItems = [
    {
      'name': 'all',
      'path': '/',
      'icon': LucideIcons.home,
      'label': 'Accueil',
      'action_type': 'route'
    },
    {
      'name': 'recipes',
      'path': '/recipes',
      'icon': LucideIcons.chefHat,
      'label': 'Recettes',
      'action_type': 'route'
    },
    {
      'name': 'tips',
      'path': '/tips',
      'icon': LucideIcons.lightbulb,
      'label': 'Astuces',
      'action_type': 'route'
    },
    {
      'name': 'events',
      'path': '/events',
      'icon': LucideIcons.calendar,
      'label': 'Événements',
      'action_type': 'route'
    },
    {
      'name': 'dinor-tv',
      'path': '/dinor-tv',
      'icon': LucideIcons.playCircle,
      'label': 'DinorTV',
      'action_type': 'route'
    },
    {
      'name': 'profile',
      'path': '/profile',
      'icon': LucideIcons.user,
      'label': 'Profil',
      'action_type': 'route'
    },
  ];

  // REPRODUCTION EXACTE de handleItemClick() Vue
  void _handleItemClick(Map<String, dynamic> item) {
    // Vérifier l'authentification pour le profil
    if (item['name'] == 'profile') {
      final authStore = ref.read(useAuthHandlerProvider);
      if (!authStore.isAuthenticated) {
        _authModalMessage = 'Vous devez vous connecter pour accéder à votre profil';
        _displayAuthModal();
        return; // Le modal d'auth s'ouvrira automatiquement
      }
    }

    switch (item['action_type']) {
      case 'route':
        // Navigation interne standard
        if (item['path'] != null) {
          if (item['path'] == '/') {
            NavigationService.pushNamedAndClearStack('/');
          } else {
            NavigationService.pushNamed(item['path']);
          }
        }
        break;

      case 'web_embed':
        // Ouvrir la page dans une webview intégrée
        if (item['url'] != null) {
          _openPageInWebView(item['url'], item['label']);
        }
        break;

      case 'external_link':
        // Ouvrir dans un navigateur externe
        if (item['url'] != null) {
          _launchURL(item['url']);
        }
        break;

      default:
        // Type d'action non géré - Fallback vers navigation route si définie
        if (item['path'] != null) {
          if (item['path'] == '/') {
            NavigationService.pushNamedAndClearStack('/');
          } else {
            NavigationService.pushNamed(item['path']);
          }
        }
    }
  }

  // IDENTIQUE à isActive() Vue
  bool _isActive(Map<String, dynamic> item) {
    final currentRoute = NavigationService.currentRoute;

    // Pour les routes normales
    if (item['action_type'] == 'route' && item['path'] != null) {
      return currentRoute == item['path'] ||
          (item['path'] != '/' && currentRoute.startsWith(item['path']));
    }

    // Pour web_embed, vérifier si nous sommes sur /web-embed
    if (item['action_type'] == 'web_embed') {
      return currentRoute == '/web-embed';
    }

    return false;
  }

  // Ouvrir une page dans une WebView intégrée
  void _openPageInWebView(String url, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(title),
            backgroundColor: const Color(0xFFF4D03F),
            foregroundColor: Colors.black,
          ),
          body: WebViewWidget(
            controller: WebViewController()
              ..setJavaScriptMode(JavaScriptMode.unrestricted)
              ..loadRequest(Uri.parse(url)),
          ),
        ),
      ),
    );
  }

  // Ouvrir une URL dans le navigateur externe
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      print('❌ Impossible d\'ouvrir l\'URL: $url');
    }
  }

  // Gestion de l'authentification réussie
  void _onAuthSuccess() {
    setState(() => _showAuthModal = false);
    // Redirection vers le profil après authentification
    NavigationService.pushReplacementNamed('/profile');
  }

  @override
  Widget build(BuildContext context) {
    final pagesState = ref.watch(usePagesProvider);
    final navigationPages = ref.watch(navigationPagesProvider);
    
    // Vérifier si on doit afficher le tutoriel de navigation
    if (navigationPages.isNotEmpty) {
      _checkForNavigationTutorial(navigationPages);
    }
    
    // Combiner les éléments de menu statiques avec les pages dynamiques
    final allMenuItems = [
      ..._menuItems,
      // Ajouter les pages depuis le dashboard Filament
      ...navigationPages.map((page) => {
        'name': 'page_${page.id}',
        'path': '/page/${page.id}',
        'icon': LucideIcons.globe,
        'label': page.title,
        'action_type': page.isExternal ? 'external_link' : 'web_embed',
        'url': page.url,
      }).toList(),
    ];

    return Stack(
      children: [
        // Bottom Navigation Bar avec support du défilement horizontal
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 80 + MediaQuery.of(context).padding.bottom,
            decoration: const BoxDecoration(
              color: Color(0xFFF4D03F),
              border: Border(
                top: BorderSide(
                  color: Color.fromRGBO(0, 0, 0, 0.1),
                  width: 1,
                ),
              ),
              boxShadow: AppShadows.softTop,
            ),
            child: SafeArea(
              child: Container(
                height: 80,
                child: Stack(
                  children: [
                    // Navigation scrollable
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: allMenuItems.map((item) => 
                          Container(
                            width: allMenuItems.length > 6 ? 70 : null,
                            child: _buildNavItem(item, isCompact: allMenuItems.length > 6),
                          )
                        ).toList(),
                      ),
                    ),
                    
                    // Tooltip pour indiquer le défilement (si overflow)
                    if (allMenuItems.length > 6 && _showScrollTooltip)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: GestureDetector(
                          onTap: () => setState(() => _showScrollTooltip = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.swap_horiz,
                                  size: 12,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'Faites défiler →',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  LucideIcons.x,
                                  size: 10,
                                  color: Colors.white70,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
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
                print('🔐 [BottomNav] Fermeture de la modal d\'authentification');
                Navigator.of(context, rootNavigator: true).pop();
                setState(() => _showAuthModal = false);
              },
              onAuthenticated: () {
                print('✅ [BottomNav] Utilisateur authentifié, fermeture de la modal');
                Navigator.of(context, rootNavigator: true).pop();
                setState(() => _showAuthModal = false);
                _onAuthSuccess();
              },
            );
          },
        );
      }
    });
  }

  // Construction d'un item de navigation - STYLES CSS IDENTIQUES
  Widget _buildNavItem(Map<String, dynamic> item, {bool isCompact = false}) {
    final isActive = _isActive(item);

    return GestureDetector(
      onTap: () => _handleItemClick(item),
      child: Container(
        width: isCompact ? 70 : null,
        padding: EdgeInsets.symmetric(
          vertical: 8, 
          horizontal: isCompact ? 2 : 4,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? const Color.fromRGBO(255, 107, 53, 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icône - taille adaptée selon le mode
            Container(
              margin: const EdgeInsets.only(bottom: 4),
              child: Icon(
                item['icon'],
                size: isCompact ? 18 : 24, // Icônes plus petites en mode compact
                color: isActive
                    ? const Color(0xFFFF6B35)
                    : const Color.fromRGBO(0, 0, 0, 0.7),
              ),
            ),

            // Label - taille adaptée selon le mode
            Text(
              item['label'],
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: isCompact ? 9 : 12, // Texte plus petit en mode compact
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive
                    ? const Color(0xFFFF6B35)
                    : const Color.fromRGBO(0, 0, 0, 0.7),
                height: 1.2,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),

            // Soulignement orange pour l'item actif
            if (isActive)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: isCompact ? 16 : 24, // Soulignement plus petit en mode compact
                height: 2,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B35),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

