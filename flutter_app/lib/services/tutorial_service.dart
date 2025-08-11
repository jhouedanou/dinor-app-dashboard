/**
 * TUTORIAL_SERVICE.DART - SERVICE POUR GÉRER LES TUTORIELS
 * 
 * FONCTIONNALITÉS :
 * - Gestion centralisée des tutoriels
 * - Différents types de tutoriels (première utilisation, nouvelles fonctionnalités, etc.)
 * - Conditions d'affichage intelligentes
 * - Persistence des préférences utilisateur
 */

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../components/common/app_tutorial.dart';

class TutorialService {
  static const String _firstLaunchKey = 'first_launch_completed';
  static const String _navigationTutorialKey = 'navigation_tutorial_shown';
  static const String _pagesTutorialKey = 'dynamic_pages_tutorial_shown';
  static const String _homePageTutorialKey = 'home_page_tutorial_shown';
  static const String _loginTutorialKey = 'login_tutorial_shown';

  // Vérifier si c'est le premier lancement
  static Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final hasCompleted = prefs.getBool(_firstLaunchKey) ?? false;
    return !hasCompleted;
  }

  // Marquer le premier lancement comme terminé
  static Future<void> markFirstLaunchComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstLaunchKey, true);
  }

  // Tutoriel principal de première utilisation
  static List<TutorialStep> getWelcomeTutorial() => [
    TutorialStep(
      title: '🍽️ Bienvenue sur Dinor !',
      description: 'Votre chef de poche vous souhaite la bienvenue ! Découvrez une expérience culinaire unique avec des milliers de recettes, astuces et bien plus.',
    ),
    TutorialStep(
      title: '🧭 Navigation simple',
      description: 'Utilisez la barre dorée en bas de l\'écran pour naviguer entre les sections : Accueil, Recettes, Astuces, Événements, DinorTV et votre Profil.',
    ),
    TutorialStep(
      title: '📱 Pages personnalisées',
      description: 'Découvrez des pages supplémentaires ajoutées spécialement pour vous ! Si vous en voyez plus de 6, faites défiler horizontalement la barre de navigation.',
    ),
    TutorialStep(
      title: '⭐ Vos favoris',
      description: 'Appuyez sur le cœur pour ajouter vos recettes, astuces et vidéos préférées à votre collection personnelle.',
    ),
    TutorialStep(
      title: '🤝 Partage facile',
      description: 'Partagez vos découvertes culinaires avec vos amis grâce au bouton de partage présent sur chaque contenu.',
    ),
    TutorialStep(
      title: '🚀 C\'est parti !',
      description: 'Vous êtes maintenant prêt à explorer l\'univers Dinor. Bon voyage culinaire et... bon appétit !',
    ),
  ];

  // Tutoriel spécifique pour les pages dynamiques
  static List<TutorialStep> getNavigationTutorial() => [
    TutorialStep(
      title: '📄 Nouvelles pages !',
      description: 'De nouvelles pages ont été ajoutées à votre application ! Elles apparaissent dans la barre de navigation en bas.',
    ),
    TutorialStep(
      title: '👆 Navigation tactile',
      description: 'Si vous voyez plus de 6 onglets, vous pouvez faire défiler horizontalement la barre de navigation pour accéder à toutes les pages.',
    ),
    TutorialStep(
      title: '🌐 Contenu externe',
      description: 'Certaines pages peuvent s\'ouvrir dans un navigateur externe ou dans une vue intégrée selon leur configuration.',
    ),
  ];

  // Tutoriel pour les fonctionnalités avancées
  static List<TutorialStep> getAdvancedFeaturesTutorial() => [
    TutorialStep(
      title: '🔍 Recherche intelligente',
      description: 'Utilisez la barre de recherche pour trouver rapidement vos recettes par ingrédients, type de plat ou difficulté.',
    ),
    TutorialStep(
      title: '🏆 Tournois culinaires',
      description: 'Participez aux tournois de pronostics et défis culinaires pour gagner des récompenses !',
    ),
    TutorialStep(
      title: '📺 Dinor TV',
      description: 'Regardez des vidéos exclusives, des tutoriels de chefs et des émissions culinaires en direct.',
    ),
  ];

  // Tutoriel pour la page d'accueil
  static List<TutorialStep> getHomePageTutorial() => [
    TutorialStep(
      title: '🏠 Page d\'accueil',
      description: 'Bienvenue sur votre tableau de bord ! Ici vous pouvez voir les dernières recettes, astuces et événements.',
    ),
    TutorialStep(
      title: '⭐ Contenus populaires',
      description: 'Découvrez les recettes et astuces les plus appréciées par la communauté Dinor.',
    ),
    TutorialStep(
      title: '🎯 Recommandations',
      description: 'Nous vous proposons du contenu personnalisé basé sur vos goûts et préférences culinaires.',
    ),
    TutorialStep(
      title: '🔍 Recherche rapide',
      description: 'Utilisez la barre de recherche en haut pour trouver instantanément ce que vous cherchez.',
    ),
  ];

  // Tutoriel pour la connexion/authentification
  static List<TutorialStep> getLoginTutorial() => [
    TutorialStep(
      title: '🔐 Connexion à votre compte',
      description: 'Connectez-vous pour accéder à toutes les fonctionnalités exclusives de Dinor !',
    ),
    TutorialStep(
      title: '👤 Profil personnalisé',
      description: 'Une fois connecté, vous pourrez personnaliser votre profil, sauvegarder vos favoris et suivre vos progrès.',
    ),
    TutorialStep(
      title: '💾 Sauvegarde automatique',
      description: 'Toutes vos recettes favorites, vos notes et vos préférences seront sauvegardées automatiquement.',
    ),
    TutorialStep(
      title: '🏆 Fonctionnalités premium',
      description: 'Accédez aux tournois, aux notifications personnalisées et aux contenus exclusifs.',
    ),
  ];

  // Afficher le tutoriel de bienvenue si nécessaire
  static Future<void> showWelcomeTutorialIfNeeded(BuildContext context) async {
    final isFirst = await isFirstLaunch();
    if (isFirst && context.mounted) {
      TutorialOverlay.show(
        context: context,
        steps: getWelcomeTutorial(),
        tutorialKey: 'welcome_tutorial',
        onComplete: () async {
          await markFirstLaunchComplete();
          print('✅ [TutorialService] Tutoriel de bienvenue terminé');
        },
      );
    }
  }

  // Afficher le tutoriel de navigation si de nouvelles pages sont détectées
  static Future<void> showNavigationTutorialIfNeeded(
    BuildContext context, 
    int currentPageCount
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final lastKnownPageCount = prefs.getInt('last_known_page_count') ?? 6;
    final hasShownTutorial = prefs.getBool(_navigationTutorialKey) ?? false;

    // Si on a plus de pages qu'avant et qu'on n'a pas encore montré le tutoriel
    if (currentPageCount > lastKnownPageCount && !hasShownTutorial && context.mounted) {
      TutorialOverlay.show(
        context: context,
        steps: getNavigationTutorial(),
        tutorialKey: 'navigation_tutorial',
        onComplete: () async {
          await prefs.setBool(_navigationTutorialKey, true);
          print('✅ [TutorialService] Tutoriel de navigation terminé');
        },
      );
    }

    // Sauvegarder le nombre actuel de pages
    await prefs.setInt('last_known_page_count', currentPageCount);
  }

  // Afficher le tutoriel de la page d'accueil si nécessaire
  static Future<void> showHomePageTutorialIfNeeded(BuildContext context) async {
    final hasShown = await hasTutorialBeenSeen(_homePageTutorialKey);
    if (!hasShown && context.mounted) {
      TutorialOverlay.show(
        context: context,
        steps: getHomePageTutorial(),
        tutorialKey: _homePageTutorialKey,
        onComplete: () async {
          await markTutorialAsSeen(_homePageTutorialKey);
          print('✅ [TutorialService] Tutoriel page d\'accueil terminé');
        },
      );
    }
  }

  // Afficher le tutoriel de connexion
  static Future<void> showLoginTutorial(BuildContext context) async {
    if (context.mounted) {
      TutorialOverlay.show(
        context: context,
        steps: getLoginTutorial(),
        tutorialKey: _loginTutorialKey,
        onComplete: () async {
          await markTutorialAsSeen(_loginTutorialKey);
          print('✅ [TutorialService] Tutoriel de connexion terminé');
        },
      );
    }
  }

  // Réinitialiser tous les tutoriels (pour le debug/test)
  static Future<void> resetAllTutorials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print('🔄 [TutorialService] Tous les tutoriels réinitialisés');
  }

  // Marquer un tutoriel spécifique comme vu
  static Future<void> markTutorialAsSeen(String tutorialKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tutorial_$tutorialKey', true);
  }

  // Vérifier si un tutoriel a été vu
  static Future<bool> hasTutorialBeenSeen(String tutorialKey) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('tutorial_$tutorialKey') ?? false;
  }

  // Afficher un tutoriel personnalisé
  static void showCustomTutorial(
    BuildContext context, {
    required String title,
    required String description,
    required String tutorialKey,
    VoidCallback? onComplete,
    IconData? icon,
  }) {
    final steps = [
      TutorialStep(
        title: title,
        description: description,
      )
    ];

    TutorialOverlay.show(
      context: context,
      steps: steps,
      tutorialKey: tutorialKey,
      onComplete: onComplete,
    );
  }

  // Obtenir des statistiques sur l'utilisation des tutoriels
  static Future<Map<String, bool>> getTutorialStatistics() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'first_launch_completed': prefs.getBool(_firstLaunchKey) ?? false,
      'navigation_tutorial_shown': prefs.getBool(_navigationTutorialKey) ?? false,
      'dynamic_pages_tutorial_shown': prefs.getBool(_pagesTutorialKey) ?? false,
      'welcome_tutorial_completed': prefs.getBool('tutorial_welcome_tutorial') ?? false,
    };
  }
}