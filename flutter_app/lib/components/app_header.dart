import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/share_service.dart';

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
      width: double.infinity,
      height: 80,
      decoration: const BoxDecoration(
        color: Color(0xFFE53E3E), // Fond rouge identique
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Bouton retour si nécessaire
              if (backPath != null)
                IconButton(
                  onPressed: onBack ?? () {
                    // Navigation de retour
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 24,
                  ),
                  padding: EdgeInsets.zero,
                ),
              
              // Titre centré
              Expanded(
                child: Center(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              
              // Actions à droite (favoris et partage)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Bouton favoris
                  if (showFavorite)
                    IconButton(
                      onPressed: () {
                        // TODO: Implémenter la logique des favoris
                        print('⭐ [AppHeader] Toggle favorite');
                      },
                      icon: Icon(
                        initialFavorited ? Icons.favorite : Icons.favorite_border,
                        color: initialFavorited ? Colors.yellow : Colors.white,
                        size: 24,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  
                  // Bouton partage
                  if (showShare)
                    IconButton(
                      onPressed: onShare ?? () {
                        // Utiliser le partage natif
                        _shareContent();
                      },
                      icon: const Icon(
                        Icons.share,
                        color: Colors.white,
                        size: 24,
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

  void _shareContent() async {
    try {
      // Utiliser le partage natif via le service avec type et ID
      await ShareService.shareContent(
        title: title,
        text: 'Découvrez $title sur Dinor',
        url: 'https://dinor.app',
        type: favoriteType,
        id: favoriteItemId,
        platform: 'native',
      );
      
      // Appeler le callback de partage si fourni
      onShare?.call();
      
      print('📤 [AppHeader] Partage natif réussi');
    } catch (error) {
      print('❌ [AppHeader] Erreur partage: $error');
    }
  }
} 