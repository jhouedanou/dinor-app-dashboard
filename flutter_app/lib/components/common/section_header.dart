/**
 * SECTION_HEADER.DART - Composant de titre avec cartouche
 * 
 * INSPIRATION PWA :
 * - Cartouche avec dégradé de couleur
 * - Typographie Open Sans bold
 * - Bouton "Voir tout" avec icône
 * - Style moderne avec ombre et border-radius
 */

import 'package:flutter/material.dart';
import '../../services/navigation_service.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String viewAllLink;
  final bool darkTheme;
  final Color? primaryColor;
  final Color? secondaryColor;

  const SectionHeader({
    Key? key,
    required this.title,
    required this.viewAllLink,
    this.darkTheme = false,
    this.primaryColor,
    this.secondaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Couleurs par défaut inspirées de la PWA
    final Color defaultPrimary = _getPrimaryColor();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Titre sans cartouche, avec couleur correspondante
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: primaryColor ?? defaultPrimary,
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Bouton "Voir tout" avec style moderne
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: (primaryColor ?? defaultPrimary).withValues(alpha: 0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextButton.icon(
              onPressed: () => NavigationService.pushNamed(viewAllLink),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: Icon(
                LucideIcons.chevronRight,
                size: 16,
                color: primaryColor ?? defaultPrimary,
              ),
              label: Text(
                'Voir tout',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: primaryColor ?? defaultPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPrimaryColor() {
    if (darkTheme) return Colors.white;
    
    // Couleurs spécifiques par type de contenu (inspirées PWA)
    switch (title.toLowerCase()) {
      case 'recettes':
        return const Color(0xFFE53E3E); // Rouge Dinor
      case 'astuces':
        return const Color(0xFFF4D03F); // Doré
      case 'événements':
        return const Color(0xFF6750A4); // Violet Material
      case 'dinor tv':
        return const Color(0xFF1A1A1A); // Noir pour Dinor TV
      default:
        return const Color(0xFFE53E3E); // Rouge par défaut
    }
  }

}