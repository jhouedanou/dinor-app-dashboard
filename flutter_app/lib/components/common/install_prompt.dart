/// INSTALL_PROMPT.DART - SIMULATION DE InstallPrompt.vue
/// 
/// En Flutter mobile, l'app est déjà "installée"
/// Mais on garde la cohérence pour le web Flutter
library;

import 'package:flutter/material.dart';

class InstallPrompt extends StatelessWidget {
  const InstallPrompt({super.key});

  @override
  Widget build(BuildContext context) {
    // En Flutter mobile, pas de prompt d'installation nécessaire
    // L'app est déjà installée par nature
    return const SizedBox.shrink();
  }
}