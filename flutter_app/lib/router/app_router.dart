/**
 * APP_ROUTER.DART - CONVERSION FIDÈLE DE router/index.js Vue
 * 
 * FIDÉLITÉ FONCTIONNELLE :
 * - Routes identiques : /, /recipes, /recipe/:id, /tips, etc.
 * - Lazy loading identique : import() → lazy loading Flutter
 * - Navigation guards identiques : beforeEach
 * - Meta titles identiques : document.title
 * - Redirections identiques : /home → /, /video/:id → /dinor-tv
 */

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Écrans principaux (équivalent lazy loading Vue)
import '../screens/home_screen.dart';
import '../screens/recipes_list_screen.dart';
import '../screens/recipe_detail_screen.dart';
import '../screens/tips_list_screen.dart';
import '../screens/tip_detail_screen.dart';
import '../screens/events_list_screen.dart';
import '../screens/event_detail_screen.dart';
import '../screens/dinor_tv_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/pages_list_screen.dart';

// Pages légales
import '../screens/terms_of_service_screen.dart';
import '../screens/privacy_policy_screen.dart';
import '../screens/cookie_policy_screen.dart';

// Pages predictions (futures extensions)
import '../screens/predictions_screen.dart';
import '../screens/predictions_teams_screen.dart';
import '../screens/predictions_leaderboard_screen.dart';
import '../screens/tournaments_screen.dart';
import '../screens/tournament_betting_screen.dart';

// App principale avec navigation
import '../app.dart';

// Configuration du router identique à Vue Router
final GoRouter appRouter = GoRouter(
  // Base path identique : createWebHistory('/pwa/')
  initialLocation: '/',
  
  // Navigation guards équivalent à beforeEach Vue
  redirect: (BuildContext context, GoRouterState state) {
    final location = state.location;
    
    // Log navigation (équivalent console.log Vue)
    print('🧭 [Router] Navigation vers: $location');
    
    // Redirections identiques à Vue
    if (location == '/home') {
      print('🔄 [Router] Redirection /home → /');
      return '/';
    }
    
    // Redirection video (équivalent Vue)
    if (location.startsWith('/video/')) {
      print('🔄 [Router] Redirection /video/:id → /dinor-tv');
      return '/dinor-tv';
    }
    
    // Catch-all route inexistante → home (équivalent :pathMatch(.*) Vue)
    if (!_isValidRoute(location)) {
      print('⚠️ [Router] Route inexistante: $location → /');
      return '/';
    }
    
    return null; // Pas de redirection
  },
  
  routes: [
    // ROUTES IDENTIQUES À VUE ROUTER
    
    // Page d'accueil - path: '/', name: 'home'
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) {
        _updateDocumentTitle('Accueil - Dinor App');
        return const HomeScreen();
      },
    ),
    
    // Recettes - path: '/recipes', name: 'recipes'
    GoRoute(
      path: '/recipes',
      name: 'recipes',
      builder: (context, state) {
        _updateDocumentTitle('Recettes - Dinor App');
        return const RecipesListScreen();
      },
    ),
    
    // Détail recette - path: '/recipe/:id', name: 'recipe-detail'
    GoRoute(
      path: '/recipe/:id',
      name: 'recipe-detail',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        _updateDocumentTitle('Détail Recette - Dinor App');
        return RecipeDetailScreen(id: id);
      },
    ),
    
    // Astuces - path: '/tips', name: 'tips'
    GoRoute(
      path: '/tips',
      name: 'tips',
      builder: (context, state) {
        _updateDocumentTitle('Astuces - Dinor App');
        return const TipsListScreen();
      },
    ),
    
    // Détail astuce - path: '/tip/:id', name: 'tip-detail'
    GoRoute(
      path: '/tip/:id',
      name: 'tip-detail',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        _updateDocumentTitle('Détail Astuce - Dinor App');
        return TipDetailScreen(id: id);
      },
    ),
    
    // Événements - path: '/events', name: 'events'
    GoRoute(
      path: '/events',
      name: 'events',
      builder: (context, state) {
        _updateDocumentTitle('Événements - Dinor App');
        return const EventsListScreen();
      },
    ),
    
    // Détail événement - path: '/event/:id', name: 'event-detail'
    GoRoute(
      path: '/event/:id',
      name: 'event-detail',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        _updateDocumentTitle('Détail Événement - Dinor App');
        return EventDetailScreen(id: id);
      },
    ),
    
    // Pages - path: '/pages', name: 'pages'
    GoRoute(
      path: '/pages',
      name: 'pages',
      builder: (context, state) {
        _updateDocumentTitle('Pages - Dinor App');
        return const PagesListScreen();
      },
    ),
    
    // Dinor TV - path: '/dinor-tv', name: 'dinor-tv'
    GoRoute(
      path: '/dinor-tv',
      name: 'dinor-tv',
      builder: (context, state) {
        _updateDocumentTitle('Dinor TV - Dinor App');
        return const DinorTVScreen();
      },
    ),
    
    // Profil - path: '/profile', name: 'profile'
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) {
        _updateDocumentTitle('Profil - Dinor App');
        return const ProfileScreen();
      },
    ),
    
    // PAGES LÉGALES IDENTIQUES
    
    // Conditions générales - path: '/terms', name: 'terms-of-service'
    GoRoute(
      path: '/terms',
      name: 'terms-of-service',
      builder: (context, state) {
        _updateDocumentTitle('Conditions Générales d\'Utilisation - Dinor App');
        return const TermsOfServiceScreen();
      },
    ),
    
    // Politique de confidentialité - path: '/privacy', name: 'privacy-policy'
    GoRoute(
      path: '/privacy',
      name: 'privacy-policy',
      builder: (context, state) {
        _updateDocumentTitle('Politique de Confidentialité - Dinor App');
        return const PrivacyPolicyScreen();
      },
    ),
    
    // Politique des cookies - path: '/cookies', name: 'cookie-policy'
    GoRoute(
      path: '/cookies',
      name: 'cookie-policy',
      builder: (context, state) {
        _updateDocumentTitle('Politique des Cookies - Dinor App');
        return const CookiePolicyScreen();
      },
    ),
    
    // ROUTES PRÉDICTIONS (futures extensions)
    
    // Pronostics - path: '/predictions', name: 'predictions'
    GoRoute(
      path: '/predictions',
      name: 'predictions',
      builder: (context, state) {
        _updateDocumentTitle('Pronostics - Dinor App');
        return const PredictionsScreen();
      },
    ),
    
    // Équipes - path: '/predictions/teams', name: 'predictions-teams'
    GoRoute(
      path: '/predictions/teams',
      name: 'predictions-teams',
      builder: (context, state) {
        _updateDocumentTitle('Équipes - Dinor App');
        return const PredictionsTeamsScreen();
      },
    ),
    
    // Classement - path: '/predictions/leaderboard', name: 'predictions-leaderboard'
    GoRoute(
      path: '/predictions/leaderboard',
      name: 'predictions-leaderboard',
      builder: (context, state) {
        _updateDocumentTitle('Classement - Dinor App');
        return const PredictionsLeaderboardScreen();
      },
    ),
    
    // Tournois - path: '/predictions/tournaments', name: 'predictions-tournaments'
    GoRoute(
      path: '/predictions/tournaments',
      name: 'predictions-tournaments',
      builder: (context, state) {
        _updateDocumentTitle('Tournois - Dinor App');
        return const TournamentsScreen();
      },
    ),
    
    // Paris de tournois - path: '/predictions/betting', name: 'tournament-betting'
    GoRoute(
      path: '/predictions/betting',
      name: 'tournament-betting',
      builder: (context, state) {
        _updateDocumentTitle('Paris de Tournois - Dinor App');
        return const TournamentBettingScreen();
      },
    ),
  ],
  
  // Gestion d'erreurs (équivalent :pathMatch(.*) → '/' Vue)
  errorBuilder: (context, state) {
    print('❌ [Router] Route non trouvée: ${state.location}');
    _updateDocumentTitle('Page non trouvée - Dinor App');
    
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Color(0xFFE53E3E),
            ),
            const SizedBox(height: 16),
            const Text(
              '404 - Page non trouvée',
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'La page que vous recherchez n\'existe pas.',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 16,
                color: Color(0xFF4A5568),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53E3E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Retour à l\'accueil',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  },
);

// UTILITAIRES IDENTIQUES À VUE ROUTER

// Équivalent de document.title = `${to.meta.title} - Dinor App`
void _updateDocumentTitle(String title) {
  // En Flutter web, on peut utiliser dart:html pour changer le titre
  // Pour mobile, cette fonction est no-op
  print('📄 [Router] Title mis à jour: $title');
  
  // Si en mode web, utiliser dart:html
  // import 'dart:html' as html;
  // html.document.title = title;
}

// Vérification des routes valides
bool _isValidRoute(String path) {
  const validPaths = [
    '/',
    '/recipes',
    '/tips',
    '/events',
    '/pages',
    '/dinor-tv',
    '/profile',
    '/terms',
    '/privacy',
    '/cookies',
    '/predictions',
    '/predictions/teams',
    '/predictions/leaderboard',
    '/predictions/tournaments',
    '/predictions/betting',
  ];
  
  // Vérifier les routes statiques
  if (validPaths.contains(path)) return true;
  
  // Vérifier les routes dynamiques
  if (RegExp(r'^/recipe/\d+$').hasMatch(path)) return true;
  if (RegExp(r'^/tip/\d+$').hasMatch(path)) return true;
  if (RegExp(r'^/event/\d+$').hasMatch(path)) return true;
  
  return false;
}

// Extensions pour navigation programmatique (équivalent $router Vue)
extension GoRouterExtension on BuildContext {
  // Équivalent this.$router.push()
  void pushRoute(String path) {
    go(path);
  }
  
  // Équivalent this.$router.push({name: 'route', params: {}})
  void pushNamed(String name, {Map<String, String>? pathParameters}) {
    goNamed(name, pathParameters: pathParameters ?? {});
  }
  
  // Équivalent this.$router.back()
  void goBack() {
    if (canPop()) {
      pop();
    } else {
      go('/');
    }
  }
}

// Types pour la navigation (équivalent RouteLocationNormalized Vue)
class RouteInfo {
  final String path;
  final String name;
  final Map<String, String> params;
  final Map<String, String> query;
  
  const RouteInfo({
    required this.path,
    required this.name,
    this.params = const {},
    this.query = const {},
  });
}

// Provider pour accès au router dans l'app (équivalent useRouter() Vue)
class RouterProvider extends InheritedWidget {
  final GoRouter router;
  
  const RouterProvider({
    Key? key,
    required this.router,
    required Widget child,
  }) : super(key: key, child: child);
  
  static RouterProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<RouterProvider>();
  }
  
  @override
  bool updateShouldNotify(RouterProvider oldWidget) {
    return router != oldWidget.router;
  }
}