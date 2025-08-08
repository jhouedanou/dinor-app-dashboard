import 'package:flutter/material.dart';

class AppShadows {
  // Ombre douce par défaut (référence) : faible opacité, léger flou, décalage bas
  static const List<BoxShadow> soft = [
    BoxShadow(
      color: Color(0x14000000), // Noir 8% d'opacité
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  // Variante pour barres supérieures (ex: bottom nav avec ombre vers le haut)
  static const List<BoxShadow> softTop = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 6,
      offset: Offset(0, -2),
    ),
  ];
}


