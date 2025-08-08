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

// Components
import '../common/auth_modal.dart';


// Composables et stores
import '../../composables/use_auth_handler.dart';


class BottomNavigation extends ConsumerStatefulWidget {
  const BottomNavigation({Key? key}) : super(key: key);

  @override
  ConsumerState<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends ConsumerState<BottomNavigation> {
  bool _showAuthModal = false;
  String _authModalMessage = '';

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
        // Charger la dernière page depuis le système Pages dans WebEmbed
        NavigationService.pushNamed('/web-embed');
        break;

      case 'external_link':
        // Ouvrir dans un nouvel onglet (équivalent window.open())
        // En Flutter mobile, on utilise url_launcher
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

  // Gestion de l'authentification réussie
  void _onAuthSuccess() {
    setState(() => _showAuthModal = false);
    // Redirection vers le profil après authentification
    NavigationService.pushReplacementNamed('/profile');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Bottom Navigation Bar - REPRODUCTION EXACTE du CSS
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 80 + MediaQuery.of(context).padding.bottom, // Hauteur exacte + safe area
            decoration: const BoxDecoration(
              color: Color(0xFFF4D03F), // Fond doré identique
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
                height: 80, // Hauteur fixe de la navigation
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround, // justify-content: space-around
                  children: _menuItems.map((item) => _buildNavItem(item)).toList(),
                ),
              ),
            ),
          ),
        ),

        // Auth Modal - v-model="showAuthModal"
        // Retiré du Stack pour éviter les problèmes de contexte de navigation
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
  Widget _buildNavItem(Map<String, dynamic> item) {
    final isActive = _isActive(item);

    return Expanded(
      child: GestureDetector(
        onTap: () => _handleItemClick(item),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            // État hover et actif
            color: isActive
                ? const Color.fromRGBO(255, 107, 53, 0.1) // rgba(255, 107, 53, 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16), // border-radius: 16px
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icône - 24px identique
              Container(
                margin: const EdgeInsets.only(bottom: 4), // margin-bottom: 4px
                child: Icon(
                  item['icon'],
                  size: 24, // Taille exacte
                  color: isActive
                      ? const Color(0xFFFF6B35) // Orange accent pour l'item actif
                      : const Color.fromRGBO(0, 0, 0, 0.7), // Texte sombre sur fond doré
                ),
              ),

              // Label - Police Roboto identique
              Text(
                item['label'],
                style: TextStyle(
                  fontFamily: 'Roboto', // Police Roboto pour les textes
                  fontSize: 12, // font-size: 12px
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500, // font-weight
                  color: isActive
                      ? const Color(0xFFFF6B35) // Orange accent pour l'item actif
                      : const Color.fromRGBO(0, 0, 0, 0.7), // Texte sombre
                  height: 1.2, // line-height: 1.2
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),

              // Soulignement orange pour l'item actif - ::after CSS
              if (isActive)
                Container(
                  margin: const EdgeInsets.only(top: 4), // Équivalent bottom: 4px
                  width: 24, // width: 24px
                  height: 2, // height: 2px
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B35), // background: #FF6B35
                    borderRadius: BorderRadius.circular(1), // border-radius: 1px
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

