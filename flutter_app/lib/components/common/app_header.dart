/**
 * APP_HEADER.DART - CONVERSION FIDÈLE DE AppHeader.vue
 * 
 * FIDÉLITÉ VISUELLE :
 * - Header fixed 80px identique
 * - Titre dynamique Open Sans
 * - Boutons back/favorite/share identiques
 * - Couleurs et ombres identiques
 */

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../dinor_icon.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final bool showFavorite;
  final String? favoriteType;
  final String? favoriteItemId;
  final bool initialFavorited;
  final bool showShare;
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
    this.backPath,
    this.onFavoriteUpdated,
    this.onShare,
    this.onBack,
    this.onAuthRequired,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80, // Hauteur fixe identique CSS
      decoration: const BoxDecoration(
        color: Color(0xFFF4D03F), // Fond doré identique
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 2),
            blurRadius: 4,
            color: Color.fromRGBO(0, 0, 0, 0.1),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Bouton retour - si backPath fourni
              if (backPath != null)
                IconButton(
                  onPressed: onBack ?? () => context.go(backPath!),
                  icon: const DinorIcon(
                    name: 'arrow-left',
                    size: 24,
                    color: Color(0xFF2D3748), // Couleur foncée sur fond doré
                  ),
                  padding: EdgeInsets.zero,
                ),
              
              // Titre - Open Sans identique
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D3748), // Couleur foncée pour contraste
                  ),
                  textAlign: backPath != null ? TextAlign.left : TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              // Actions - boutons favoris et partage
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Bouton favori
                  if (showFavorite)
                    IconButton(
                      onPressed: () {
                        // TODO: Implémenter toggle favori
                        print('❤️ [AppHeader] Toggle favori: $favoriteType $favoriteItemId');
                      },
                      icon: DinorIcon(
                        name: 'heart',
                        size: 24,
                        color: initialFavorited
                            ? const Color(0xFFE53E3E) // Rouge si favori
                            : const Color(0xFF2D3748), // Foncé sinon
                        filled: initialFavorited,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  
                  // Bouton partage
                  if (showShare)
                    IconButton(
                      onPressed: onShare,
                      icon: const DinorIcon(
                        name: 'share2',
                        size: 24,
                        color: Color(0xFF2D3748),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}