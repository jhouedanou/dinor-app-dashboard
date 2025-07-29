/**
 * NAVIGATION_SERVICE.DART - SERVICE DE NAVIGATION AVEC GLOBALKEY
 * 
 * Remplacement de GoRouter par Navigator classique pour éviter les erreurs
 * de contexte modal avec des GlobalKey pour un accès sûr.
 */

import 'package:flutter/material.dart';
import '../screens/working_home_screen.dart';
import '../screens/simple_recipes_screen.dart';
import '../screens/simple_recipe_detail_screen.dart';
import '../screens/simple_tips_screen.dart';
import '../screens/simple_tip_detail_screen.dart';
import '../screens/simple_events_screen.dart';
import '../screens/simple_event_detail_screen.dart';
import '../screens/simple_dinor_tv_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/pages_list_screen.dart';
import '../screens/terms_of_service_screen.dart';
import '../screens/privacy_policy_screen.dart';
import '../screens/cookie_policy_screen.dart';
import '../screens/predictions_screen_simple.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  // Getter pour le contexte sûr
  static BuildContext? get context => navigatorKey.currentContext;
  
  // Routes définies
  static const String home = '/';
  static const String recipes = '/recipes';
  static const String recipeDetail = '/recipe-detail';
  static const String tips = '/tips';
  static const String tipDetail = '/tip-detail';
  static const String events = '/events';
  static const String eventDetail = '/event-detail';
  static const String dinorTv = '/dinor-tv';
  static const String profile = '/profile';
  static const String pages = '/pages';
  static const String terms = '/terms';
  static const String privacy = '/privacy';
  static const String cookies = '/cookies';
  static const String predictions = '/predictions';
  
  // Route actuelle
  static String _currentRoute = home;
  static String get currentRoute => _currentRoute;
  
  // Callbacks pour les changements de route
  static final List<Function(String)> _routeChangeListeners = [];
  
  static void addRouteChangeListener(Function(String) listener) {
    _routeChangeListeners.add(listener);
  }
  
  static void removeRouteChangeListener(Function(String) listener) {
    _routeChangeListeners.remove(listener);
  }
  
  static void _notifyRouteChange(String route) {
    _currentRoute = route;
    for (var listener in _routeChangeListeners) {
      listener(route);
    }
  }
  
  // Méthodes de navigation
  static Future<T?> pushNamed<T extends Object?>(String routeName, {Object? arguments}) {
    _notifyRouteChange(routeName);
    return navigatorKey.currentState!.pushNamed<T>(routeName, arguments: arguments);
  }
  
  static Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    Object? arguments,
    TO? result,
  }) {
    _notifyRouteChange(routeName);
    return navigatorKey.currentState!.pushReplacementNamed<T, TO>(
      routeName,
      arguments: arguments,
      result: result,
    );
  }
  
  static void pop<T extends Object?>([T? result]) {
    navigatorKey.currentState!.pop<T>(result);
    // Note: Nous ne pouvons pas facilement déterminer la route précédente ici
  }
  
  static Future<T?> pushNamedAndClearStack<T extends Object?>(String routeName, {Object? arguments}) {
    _notifyRouteChange(routeName);
    return navigatorKey.currentState!.pushNamedAndRemoveUntil<T>(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }
  
  static bool canPop() {
    return navigatorKey.currentState?.canPop() ?? false;
  }
  
  // Méthodes de navigation spécifiques
  static void goHome() {
    pushNamedAndClearStack(home);
  }
  
  static void goToRecipes() {
    pushNamed(recipes);
  }
  
  static void goToRecipeDetail(String id) {
    pushNamed(recipeDetail, arguments: {'id': id});
  }
  
  static void goToTips() {
    pushNamed(tips);
  }
  
  static void goToTipDetail(String id) {
    pushNamed(tipDetail, arguments: {'id': id});
  }
  
  static void goToEvents() {
    pushNamed(events);
  }
  
  static void goToEventDetail(String id) {
    pushNamed(eventDetail, arguments: {'id': id});
  }
  
  static void goToDinorTv() {
    pushNamed(dinorTv);
  }
  
  static void goToProfile() {
    pushNamed(profile);
  }
  
  static void goToPages() {
    pushNamed(pages);
  }
  
  static void goToTerms() {
    pushNamed(terms);
  }
  
  static void goToPrivacy() {
    pushNamed(privacy);
  }
  
  static void goToCookies() {
    pushNamed(cookies);
  }
  
  static void goToPredictions() {
    pushNamed(predictions);
  }
  
  // Générateur de routes
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    print('🧭 [NavigationService] Navigation vers: ${settings.name}');
    
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => const WorkingHomeScreen(),
          settings: settings,
        );
        
      case recipes:
        return MaterialPageRoute(
          builder: (_) => const SimpleRecipesScreen(),
          settings: settings,
        );
        
      case recipeDetail:
        final arguments = settings.arguments as Map<String, dynamic>?;
        if (arguments == null || arguments['id'] == null) return _errorRoute();
        return MaterialPageRoute(
          builder: (_) => SimpleRecipeDetailScreen(arguments: arguments),
          settings: settings,
        );
        
      case tips:
        return MaterialPageRoute(
          builder: (_) => const SimpleTipsScreen(),
          settings: settings,
        );
        
      case tipDetail:
        final arguments = settings.arguments as Map<String, dynamic>?;
        if (arguments == null || arguments['id'] == null) return _errorRoute();
        return MaterialPageRoute(
          builder: (_) => SimpleTipDetailScreen(id: arguments['id']),
          settings: settings,
        );
        
      case events:
        return MaterialPageRoute(
          builder: (_) => const SimpleEventsScreen(),
          settings: settings,
        );
        
      case eventDetail:
        final arguments = settings.arguments as Map<String, dynamic>?;
        if (arguments == null || arguments['id'] == null) return _errorRoute();
        return MaterialPageRoute(
          builder: (_) => SimpleEventDetailScreen(arguments: arguments),
          settings: settings,
        );
        
      case dinorTv:
        return MaterialPageRoute(
          builder: (_) => const SimpleDinorTVScreen(),
          settings: settings,
        );
        
      case profile:
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
          settings: settings,
        );
        
      case pages:
        return MaterialPageRoute(
          builder: (_) => const PagesListScreen(),
          settings: settings,
        );
        
      case terms:
        return MaterialPageRoute(
          builder: (_) => const TermsOfServiceScreen(),
          settings: settings,
        );
        
      case privacy:
        return MaterialPageRoute(
          builder: (_) => const PrivacyPolicyScreen(),
          settings: settings,
        );
        
      case cookies:
        return MaterialPageRoute(
          builder: (_) => const CookiePolicyScreen(),
          settings: settings,
        );
        
      case predictions:
        return MaterialPageRoute(
          builder: (_) => const PredictionsScreen(),
          settings: settings,
        );
        
      default:
        return _errorRoute();
    }
  }
  
  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
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
                onPressed: () => goHome(),
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
      ),
    );
  }
}