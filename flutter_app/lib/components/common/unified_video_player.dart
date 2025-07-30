import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
    return GestureDetector(
      onTap: onTap ?? () => _openVideo(context),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFF7FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Stack(
          children: [
            // Arrière-plan avec dégradé
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF1A202C).withValues(alpha: 0.8),
                    const Color(0xFF2D3748).withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),
            // Contenu centré
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 12,
                      color: Colors.white70,
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

  Future<void> _openVideo(BuildContext context) async {
    if (videoUrl.isEmpty) {
      if (context.mounted) {
        _showSnackBar(context, 'URL de la vidéo non disponible', Colors.red);
      }
      return;
    }
    
    // Convertir URL embed en URL normale pour YouTube externe
    final normalUrl = _convertEmbedToNormalUrl(videoUrl);
    
    try {
      final uri = Uri.parse(normalUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          _showSnackBar(context, 'Impossible d\'ouvrir la vidéo', Colors.red);
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, 'Erreur lors de l\'ouverture de la vidéo', Colors.red);
      }
    }
  }
  
  String _convertEmbedToNormalUrl(String url) {
    // Si c'est une URL embed, la convertir en URL normale
    if (url.contains('/embed/')) {
      final regex = RegExp(r'/embed/([a-zA-Z0-9_-]+)');
      final match = regex.firstMatch(url);
      if (match != null) {
        final videoId = match.group(1);
        return 'https://www.youtube.com/watch?v=$videoId';
      }
    }
    
    // Si c'est déjà une URL normale, la retourner telle quelle
    return url;
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