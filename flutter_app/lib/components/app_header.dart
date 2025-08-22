import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/share_service.dart';
import '../styles/shadows.dart';
import '../styles/text_styles.dart';
import '../stores/header_state.dart';
import '../stores/notifications_store.dart';
import '../services/navigation_service.dart';
import '../services/permissions_service.dart';
import '../composables/use_auth_handler.dart';
import '../components/common/auth_modal.dart';

class AppHeader extends ConsumerStatefulWidget {
  final String title;
  final bool showFavorite;
  final String? favoriteType;
  final String? favoriteItemId;
  final bool initialFavorited;
  final bool showShare;
  final bool showNotifications;
  final bool showProfile;
  final String? backPath;
  final Function(Map<String, dynamic>)? onFavoriteUpdated;
  final VoidCallback? onShare;
  final VoidCallback? onBack;
  final VoidCallback? onAuthRequired;

  const AppHeader({
    super.key,
    required this.title,
    this.showFavorite = false,
    this.favoriteType,
    this.favoriteItemId,
    this.initialFavorited = false,
    this.showShare = false,
    this.showNotifications = true,
    this.showProfile = true,
    this.backPath,
    this.onFavoriteUpdated,
    this.onShare,
    this.onBack,
    this.onAuthRequired,
  });

  @override
  ConsumerState<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends ConsumerState<AppHeader> with RouteAware {
  String? _currentRouteName;

  @override
  void initState() {
    super.initState();
    // Détecter la route initiale
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateCurrentRoute();
    });
    
    // Écouter les changements de route avec ModalRoute
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startRouteListener();
    });
  }
  
  void _startRouteListener() {
    // Vérifier périodiquement les changements de route pour capturer les gestes système
    Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      final route = ModalRoute.of(context);
      final routeName = route?.settings.name ?? 'unknown';
      
      if (routeName != _currentRouteName) {
        print('🔄 [AppHeader] Changement route détecté: $_currentRouteName -> $routeName');
        _currentRouteName = routeName;
        
        // Le nettoyage du titre se fait maintenant dans les écrans de détail eux-mêmes
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) {
      NavigationService.routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    NavigationService.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush() {
    print('🚨 [AppHeader] didPush - nouvelle route');
    _updateCurrentRoute();
  }

  @override
  void didPop() {
    print('🚨 [AppHeader] didPop - retour navigation système');
    // Le nettoyage du titre se fait maintenant dans les écrans de détail eux-mêmes
  }

  @override
  void didPopNext() {
    print('🚨 [AppHeader] didPopNext - retour vers cette page');
    // Le nettoyage du titre se fait maintenant dans les écrans de détail eux-mêmes
  }

  void _updateCurrentRoute() {
    final route = ModalRoute.of(context);
    final routeName = route?.settings.name ?? 'unknown';
    
    print('🔍 [AppHeader] Route actuelle: $routeName (précédente: $_currentRouteName)');
    
    if (_currentRouteName != routeName) {
      _currentRouteName = routeName;
      _checkAndResetTitle();
    }
  }


  void _checkAndResetTitle() {
    final isDetailScreen = _isDetailRoute(_currentRouteName);
    final currentSubtitle = ref.read(headerSubtitleProvider);
    
    print('🔍 [AppHeader] Route: $_currentRouteName, IsDetail: $isDetailScreen, Subtitle: $currentSubtitle');
    
    // Réinitialiser le titre si on n'est pas sur un écran de détail
    if (!isDetailScreen && currentSubtitle != null) {
      print('🧹 [AppHeader] Nettoyage titre pour route non-détail');
      ref.read(headerSubtitleProvider.notifier).state = null;
    }
  }
  
  bool _isDetailRoute(String? routeName) {
    if (routeName == null) return false;
    return routeName.contains('-detail') || 
           routeName.contains('detail') ||
           routeName.endsWith('-detail') ||
           routeName == '/tip-detail' ||
           routeName == '/recipe-detail' ||
           routeName == '/video-detail' ||
           routeName == '/event-detail';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 72,
      decoration: const BoxDecoration(
        color: Color(0xFFE53E3E), // Fond rouge identique
        boxShadow: AppShadows.soft,
      ),
      // Force stable rendering on iOS
      clipBehavior: Clip.hardEdge,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Section gauche : Notifications
              SizedBox(
                width: 120, // Même largeur que la section droite pour centrer le logo
                child: widget.showNotifications
                    ? Consumer(
                        builder: (context, ref, _) {
                          return FutureBuilder<bool>(
                            future: PermissionsService.checkNotificationPermission(),
                            builder: (context, snapshot) {
                              final hasPermission = snapshot.data ?? false;
                              final summary = ref.watch(notificationsSummaryProvider);
                              final unread = summary.unreadCount;
                              
                              return Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  IconButton(
                                    onPressed: () => _handleNotificationsTap(context, ref),
                                    icon: Icon(
                                      hasPermission 
                                          ? Icons.notifications 
                                          : Icons.notifications_off_outlined,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                  // Badge de notifications non lues
                                  if (hasPermission && unread > 0)
                                    Positioned(
                                      right: 0,
                                      top: 2,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: Colors.orange,
                                          borderRadius: BorderRadius.circular(8),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 2,
                                              offset: const Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                        constraints: const BoxConstraints(minWidth: 16, minHeight: 14),
                                        child: Text(
                                          unread > 99 ? '99+' : '$unread',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  // Indicateur de statut permission
                                  if (!hasPermission)
                                    Positioned(
                                      right: 8,
                                      top: 8,
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: Colors.orange,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          );
                        },
                      )
                    : const SizedBox.shrink(),
              ),
              
              // Section centre : Logo ou Titre
              Expanded(
                child: Center(
                  child: Consumer(
                    builder: (context, ref, _) {
                      final subtitle = ref.watch(headerSubtitleProvider);
                      final hasTitle = subtitle != null && subtitle.isNotEmpty;
                      
                      print('💡 [AppHeader] Consumer - Subtitle: $subtitle');
                      print('💡 [AppHeader] Consumer - HasTitle: $hasTitle');
                      
                      // Vérifier si on est sur un écran de détail avec double vérification
                      final currentRoute = NavigationService.currentRoute;
                      final modalRoute = ModalRoute.of(context)?.settings.name;
                      final actualRoute = modalRoute ?? currentRoute;
                      final isOnDetailScreen = _isDetailRoute(actualRoute);
                      
                      print('🔍 [AppHeader] Current route from NavigationService: $currentRoute');
                      print('🔍 [AppHeader] Modal route: $modalRoute'); 
                      print('🔍 [AppHeader] Actual route: $actualRoute');
                      print('🔍 [AppHeader] Is on detail screen: $isOnDetailScreen');
                      
                      // Toujours afficher le logo monochrome comme demandé
                      print('🏠 [AppHeader] Affichage du logo Dinor monochrome');
                      return SvgPicture.asset(
                        'assets/images/LOGO_DINOR_monochrome.svg',
                        width: 32,
                        height: 20,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              // Section droite : Profil + Actions (favoris, partage)
              SizedBox(
                width: 120, // Espace pour plusieurs boutons
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Bouton favoris
                    if (widget.showFavorite)
                      IconButton(
                        onPressed: () {
                          // TODO: Implémenter la logique des favoris
                          print('⭐ [AppHeader] Toggle favorite');
                        },
                        icon: Icon(
                          widget.initialFavorited ? Icons.favorite : Icons.favorite_border,
                          color: widget.initialFavorited ? Colors.yellow : Colors.white,
                          size: 24,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    
                    // Bouton partage
                    if (widget.showShare)
                      IconButton(
                        onPressed: widget.onShare ?? () {
                          // Utiliser le partage natif
                          _shareContent(ref);
                        },
                        icon: const Icon(
                          Icons.share,
                          color: Colors.white,
                          size: 24,
                        ),
                        padding: EdgeInsets.zero,
                      ),

                    // Bouton profil
                    if (widget.showProfile)
                      IconButton(
                        onPressed: () => _handleProfileTap(context, ref),
                        icon: const Icon(
                          Icons.person_outline,
                          color: Colors.white,
                          size: 24,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _shareContent(WidgetRef ref) async {
    try {
      // Utiliser le partage natif via le service avec type et ID
      await ref.read(shareServiceProvider).shareContent(
        type: widget.favoriteType ?? 'app',
        id: widget.favoriteItemId ?? 'home',
        title: widget.title,
        description: 'Découvrez ${widget.title} sur Dinor',
        shareUrl: 'https://new.dinorapp.com',
      );
      
      // Appeler le callback de partage si fourni
      widget.onShare?.call();
      
      print('📤 [AppHeader] Partage natif réussi');
    } catch (error) {
      print('❌ [AppHeader] Erreur partage: $error');
    }
  }

  void _handleNotificationsTap(BuildContext context, WidgetRef ref) async {
    print('🔔 [AppHeader] Clic sur notifications');
    
    // 1. Vérifier les permissions de notifications
    final hasPermission = await PermissionsService.checkNotificationPermission();
    if (!hasPermission) {
      // Proposer d'activer les permissions
      await PermissionsService.showPermissionDialog(context);
      return;
    }
    
    // 2. Vérifier l'authentification
    final authState = ref.read(useAuthHandlerProvider);
    if (!authState.isAuthenticated) {
      _showAuthModal(context, () {
        NavigationService.pushNamed('/notifications');
      });
      return;
    }
    
    // 3. Navigation vers les notifications
    NavigationService.pushNamed('/notifications');
  }

  void _handleProfileTap(BuildContext context, WidgetRef ref) {
    print('👤 [AppHeader] Clic sur profil');
    
    // Vérifier l'authentification
    final authState = ref.read(useAuthHandlerProvider);
    if (!authState.isAuthenticated) {
      _showAuthModal(context, () {
        NavigationService.pushNamed('/profile');
      });
      return;
    }
    
    // Navigation vers le profil
    NavigationService.pushNamed('/profile');
  }

  void _showAuthModal(BuildContext context, VoidCallback onSuccess) {
    final navigatorContext = NavigationService.navigatorKey.currentContext;
    if (navigatorContext == null) {
      print('❌ [AppHeader] NavigatorContext not available');
      return;
    }
    
    showDialog(
      context: navigatorContext,
      barrierDismissible: true,
      useRootNavigator: true,
      builder: (BuildContext context) {
        return AuthModal(
          isOpen: true,
          onClose: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
          onAuthenticated: () {
            Navigator.of(context, rootNavigator: true).pop();
            onSuccess();
          },
        );
      },
    );
  }
} 