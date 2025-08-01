import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/share_service.dart';
import '../services/navigation_service.dart';
import '../services/permissions_service.dart';
import '../composables/use_auth_handler.dart';
import '../components/common/auth_modal.dart';

class AppHeader extends ConsumerWidget {
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
    Key? key,
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
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      height: 80,
      decoration: const BoxDecoration(
        color: Color(0xFFE53E3E), // Fond rouge identique
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Section gauche : Notifications
              SizedBox(
                width: 120, // Même largeur que la section droite pour centrer le logo
                child: showNotifications
                    ? FutureBuilder<bool>(
                        future: PermissionsService.checkNotificationPermission(),
                        builder: (context, snapshot) {
                          final hasPermission = snapshot.data ?? false;
                          return Stack(
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
                              // Indicateur de statut
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
                      )
                    : const SizedBox.shrink(),
              ),
              
              // Section centre : Logo Dinor
              Expanded(
                child: Center(
                  child: SvgPicture.asset(
                    'assets/images/LOGO_DINOR_monochrome.svg',
                    width: 32,
                    height: 20,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
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
                    if (showFavorite)
                      IconButton(
                        onPressed: () {
                          // TODO: Implémenter la logique des favoris
                          print('⭐ [AppHeader] Toggle favorite');
                        },
                        icon: Icon(
                          initialFavorited ? Icons.favorite : Icons.favorite_border,
                          color: initialFavorited ? Colors.yellow : Colors.white,
                          size: 24,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    
                    // Bouton partage
                    if (showShare)
                      IconButton(
                        onPressed: onShare ?? () {
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
                    if (showProfile)
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
        type: favoriteType ?? 'app',
        id: favoriteItemId ?? 'home',
        title: title,
        description: 'Découvrez $title sur Dinor',
        shareUrl: 'https://new.dinorapp.com',
      );
      
      // Appeler le callback de partage si fourni
      onShare?.call();
      
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