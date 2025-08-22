/// CONTENT_GALLERY_GRID.DART - Nouveau composant en mosaïque pour l'accueil
/// 
/// CARACTÉRISTIQUES :
/// - Layout en grille/mosaïque sans margins
/// - Cards avec images en arrière-plan
/// - Texte blanc avec ombres
/// - Gradient overlay
/// - Responsive avec colonnes adaptatives
library;

import 'package:flutter/material.dart';
import '../../services/navigation_service.dart';
import 'package:lucide_icons/lucide_icons.dart';
import './content_item_card.dart';

class ContentGalleryGrid extends StatelessWidget {
  final String title;
  final List<dynamic> items;
  final bool loading;
  final String? error;
  final String contentType;
  final String viewAllLink;
  final Function(Map<String, dynamic>) onItemClick;
  final bool darkTheme;
  final int? maxItems; // Limite pour l'affichage sur accueil

  const ContentGalleryGrid({
    super.key,
    required this.title,
    required this.items,
    this.loading = false,
    this.error,
    required this.contentType,
    required this.viewAllLink,
    required this.onItemClick,
    this.darkTheme = false,
    this.maxItems,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: darkTheme ? const EdgeInsets.all(8) : const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: darkTheme ? Colors.white : const Color(0xFF2D3748),
                  ),
                ),
                
                TextButton.icon(
                  onPressed: () => NavigationService.pushNamed(viewAllLink),
                  icon: Icon(
                    LucideIcons.chevronRight,
                    size: 16,
                    color: darkTheme ? Colors.white : const Color(0xFF6750A4),
                  ),
                  label: Text(
                    'Voir tout',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: darkTheme ? Colors.white : const Color(0xFF6750A4),
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Grille de contenu
          _buildGridContent(),
        ],
      ),
    );
  }

  Widget _buildGridContent() {
    // État de chargement
    if (loading) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: darkTheme ? Colors.white : const Color(0xFF6750A4),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Chargement...',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  color: darkTheme ? Colors.white70 : const Color(0xFF4A5568),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // État d'erreur
    if (error != null) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.alertCircle,
                size: 32,
                color: darkTheme ? Colors.white70 : const Color(0xFFF44336),
              ),
              const SizedBox(height: 16),
              Text(
                'Erreur de chargement',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  color: darkTheme ? Colors.white70 : const Color(0xFF4A5568),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // État vide
    if (items.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getEmptyIcon(),
                size: 32,
                color: darkTheme ? Colors.white70 : const Color(0xFF9E9E9E),
              ),
              const SizedBox(height: 16),
              Text(
                'Aucun contenu disponible',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  color: darkTheme ? Colors.white70 : const Color(0xFF4A5568),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Limiter le nombre d'items si spécifié
    final displayItems = maxItems != null 
      ? items.take(maxItems!).toList() 
      : items;

    // Grille responsive avec gapless design
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculer le nombre de colonnes basé sur la largeur
        int crossAxisCount;
        if (constraints.maxWidth >= 1200) {
          crossAxisCount = 4; // Desktop: 4 colonnes
        } else if (constraints.maxWidth >= 768) {
          crossAxisCount = 3; // Tablette: 3 colonnes
        } else {
          crossAxisCount = 1; // Mobile: 1 colonne
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: darkTheme ? 0 : 8), // Pas de padding pour darkTheme (Dinor TV)
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.8, // Cards légèrement plus hautes que larges
            crossAxisSpacing: 8, // Gap minimal entre colonnes
            mainAxisSpacing: 8, // Gap minimal entre lignes
          ),
          itemCount: displayItems.length,
          itemBuilder: (context, index) {
            final item = displayItems[index];
            return ContentItemCard(
              contentType: contentType,
              item: item,
              onTap: () => onItemClick(item),
              compact: true, // Mode compact pour la grille
            );
          },
        );
      },
    );
  }

  IconData _getEmptyIcon() {
    switch (contentType) {
      case 'recipes':
        return LucideIcons.chefHat;
      case 'tips':
        return LucideIcons.lightbulb;
      case 'events':
        return LucideIcons.calendar;
      case 'videos':
        return LucideIcons.play;
      default:
        return LucideIcons.fileText;
    }
  }
}