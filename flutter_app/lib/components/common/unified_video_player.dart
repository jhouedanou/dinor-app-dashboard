import 'package:flutter/material.dart';
import 'youtube_video_modal.dart';
import 'youtube_video_player.dart';

class UnifiedVideoPlayer extends StatelessWidget {
  final String videoUrl;
  final String title;
  final String subtitle;
  final double height;
  final VoidCallback? onTap;

  const UnifiedVideoPlayer({
    super.key,
    required this.videoUrl,
    this.title = 'Regarder la vidéo',
    this.subtitle = 'Appuyez pour ouvrir',
    this.height = 200,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final thumbnailUrl = YouTubeVideoPlayer.getThumbnailUrl(videoUrl, quality: 'hqdefault');
    
    return GestureDetector(
      onTap: onTap ?? () => _openVideo(context),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Thumbnail YouTube réel (chargement rapide depuis CDN Google)
            if (thumbnailUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  thumbnailUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF1A202C), Color(0xFF2D3748)],
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF1A202C), Color(0xFF2D3748)],
                        ),
                      ),
                    );
                  },
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1A202C), Color(0xFF2D3748)],
                  ),
                ),
              ),
            // Overlay sombre pour lisibilité
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.black.withOpacity(0.3),
              ),
            ),
            // Bouton play et texte centrés
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE53E3E).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 12,
                      color: Colors.white70,
                      shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openVideo(BuildContext context) {
    if (videoUrl.isEmpty) {
      if (context.mounted) {
        _showSnackBar(context, 'URL de la vidéo non disponible', Colors.red);
      }
      return;
    }
    
    // Afficher la modal vidéo YouTube intégrée
    showDialog(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true,
      builder: (context) => YouTubeVideoModal(
        isOpen: true,
        videoUrl: videoUrl,
        title: title,
        onClose: () {
          if (Navigator.of(context, rootNavigator: true).canPop()) {
            Navigator.of(context, rootNavigator: true).pop();
          }
        },
      ),
    );
  }
  

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}