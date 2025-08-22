/// APP_TUTORIAL.DART - TUTORIEL DE PREMIÈRE UTILISATION
/// 
/// FONCTIONNALITÉS :
/// - Tutorial interactif avec overlays
/// - Spotlight sur les éléments importants
/// - Navigation avec boutons suivant/précédent
/// - Sauvegarde de l'état dans SharedPreferences
/// - Design Material moderne
library;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lucide_icons/lucide_icons.dart';

class TutorialStep {
  final String title;
  final String description;
  final String? buttonText;
  final VoidCallback? onNext;
  final GlobalKey? targetKey;
  final Alignment targetAlignment;
  final String? imagePath;

  TutorialStep({
    required this.title,
    required this.description,
    this.buttonText,
    this.onNext,
    this.targetKey,
    this.targetAlignment = Alignment.center,
    this.imagePath,
  });
}

class AppTutorial extends StatefulWidget {
  final List<TutorialStep> steps;
  final VoidCallback? onComplete;
  final String tutorialKey;

  const AppTutorial({
    super.key,
    required this.steps,
    required this.tutorialKey,
    this.onComplete,
  });

  @override
  State<AppTutorial> createState() => _AppTutorialState();

  // Méthode statique pour vérifier si le tutoriel a déjà été vu
  static Future<bool> shouldShowTutorial(String tutorialKey) async {
    final prefs = await SharedPreferences.getInstance();
    final hasBeenSeen = prefs.getBool('tutorial_$tutorialKey') ?? false;
    return !hasBeenSeen;
  }

  // Méthode statique pour marquer le tutoriel comme terminé
  static Future<void> markTutorialComplete(String tutorialKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tutorial_$tutorialKey', true);
  }
}

class _AppTutorialState extends State<AppTutorial>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < widget.steps.length - 1) {
      setState(() {
        _currentStep++;
      });
      _animationController.reset();
      _animationController.forward();
      
      // Appeler la callback de l'étape si elle existe
      widget.steps[_currentStep].onNext?.call();
    } else {
      _completeTutorial();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _animationController.reset();
      _animationController.forward();
    }
  }

  void _completeTutorial() async {
    await AppTutorial.markTutorialComplete(widget.tutorialKey);
    if (mounted) {
      Navigator.of(context).pop();
      widget.onComplete?.call();
    }
  }

  void _skipTutorial() async {
    await AppTutorial.markTutorialComplete(widget.tutorialKey);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Widget _buildSpotlight(TutorialStep step) {
    if (step.targetKey == null) return Container();

    // Trouver la position du widget cible
    final RenderBox? renderBox = step.targetKey!.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return Container();

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    return Positioned(
      left: position.dx - 20,
      top: position.dy - 20,
      child: Container(
        width: size.width + 40,
        height: size.height + 40,
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFFFF6B35),
            width: 3,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF6B35).withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = widget.steps[_currentStep];
    final isLastStep = _currentStep == widget.steps.length - 1;

    return Material(
      color: Colors.black.withOpacity(0.85),
      child: Stack(
        children: [
          // Background overlay
          GestureDetector(
            onTap: () {}, // Empêcher la fermeture par tap
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.transparent,
            ),
          ),

          // Spotlight sur l'élément cible
          _buildSpotlight(currentStep),

          // Contenu principal du tutoriel
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    
                    // Card principale du tutoriel
                    AnimatedBuilder(
                      animation: _fadeAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Opacity(
                            opacity: _fadeAnimation.value,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Image si disponible
                                  if (currentStep.imagePath != null)
                                    Center(
                                      child: Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF4D03F).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(50),
                                        ),
                                        child: const Icon(
                                          LucideIcons.zap,
                                          size: 50,
                                          color: Color(0xFFFF6B35),
                                        ),
                                      ),
                                    ),
                                  
                                  if (currentStep.imagePath != null)
                                    const SizedBox(height: 20),

                                  // Titre
                                  Text(
                                    currentStep.title,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 12),

                                  // Description
                                  Text(
                                    currentStep.description,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black54,
                                      height: 1.5,
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 24),

                                  // Indicateurs de progression
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(
                                      widget.steps.length,
                                      (index) => Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 4),
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: index == _currentStep
                                              ? const Color(0xFFFF6B35)
                                              : Colors.grey.withOpacity(0.3),
                                        ),
                                      ),
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 24),

                                  // Boutons
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Bouton Passer
                                      TextButton(
                                        onPressed: _skipTutorial,
                                        child: const Text(
                                          'Passer',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),

                                      Row(
                                        children: [
                                          // Bouton Précédent
                                          if (_currentStep > 0)
                                            TextButton.icon(
                                              onPressed: _previousStep,
                                              icon: const Icon(
                                                LucideIcons.chevronLeft,
                                                size: 16,
                                              ),
                                              label: const Text('Précédent'),
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.grey,
                                              ),
                                            ),
                                          
                                          if (_currentStep > 0)
                                            const SizedBox(width: 12),

                                          // Bouton Suivant/Terminer
                                          ElevatedButton.icon(
                                            onPressed: _nextStep,
                                            icon: Icon(
                                              isLastStep
                                                  ? LucideIcons.check
                                                  : LucideIcons.chevronRight,
                                              size: 16,
                                            ),
                                            label: Text(
                                              isLastStep ? 'Terminer' : 'Suivant',
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFFFF6B35),
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 24,
                                                vertical: 12,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(25),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget helper pour créer facilement un tutoriel
class TutorialOverlay {
  static void show({
    required BuildContext context,
    required List<TutorialStep> steps,
    required String tutorialKey,
    VoidCallback? onComplete,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AppTutorial(
        steps: steps,
        tutorialKey: tutorialKey,
        onComplete: onComplete,
      ),
    );
  }

  // Tutoriel par défaut pour l'application Dinor
  static List<TutorialStep> get defaultSteps => [
    TutorialStep(
      title: 'Bienvenue sur Dinor !',
      description: 'Découvrez votre nouvelle application culinaire. Nous allons vous faire un tour rapide des fonctionnalités.',
      imagePath: 'welcome',
    ),
    TutorialStep(
      title: 'Navigation intuitive',
      description: 'Utilisez la barre de navigation en bas pour accéder aux recettes, astuces, événements et plus encore.',
    ),
    TutorialStep(
      title: 'Pages personnalisées',
      description: 'Si vous voyez plus de 6 onglets, vous pouvez faire défiler horizontalement pour accéder aux pages supplémentaires.',
    ),
    TutorialStep(
      title: 'Contenu riche',
      description: 'Explorez des milliers de recettes, regardez DinorTV, participez aux événements et découvrez nos astuces culinaires.',
    ),
    TutorialStep(
      title: 'C\'est parti !',
      description: 'Vous êtes maintenant prêt à explorer Dinor. Bon appétit !',
    ),
  ];

  // Afficher le tutoriel par défaut si pas encore vu
  static Future<void> showIfNeeded(BuildContext context, {VoidCallback? onComplete}) async {
    final shouldShow = await AppTutorial.shouldShowTutorial('main_tutorial');
    if (shouldShow && context.mounted) {
      show(
        context: context,
        steps: defaultSteps,
        tutorialKey: 'main_tutorial',
        onComplete: onComplete,
      );
    }
  }
}