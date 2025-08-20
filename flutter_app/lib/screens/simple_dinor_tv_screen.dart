import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/navigation_service.dart';
import '../components/common/youtube_video_modal.dart';
import '../components/common/unified_content_list.dart';

class SimpleDinorTVScreen extends StatefulWidget {
  const SimpleDinorTVScreen({super.key});

  @override
  State<SimpleDinorTVScreen> createState() => _SimpleDinorTVScreenState();
}

class _SimpleDinorTVScreenState extends State<SimpleDinorTVScreen> {
  
  void _openVideo(Map<String, dynamic> video) {
    // Chercher une URL de vidéo dans différents champs possibles
    String? videoUrl = video['video_url'] ?? video['youtube_url'] ?? video['url'];
    
    if (videoUrl == null || videoUrl.isEmpty) {
      _showSnackBar('Aucune URL de vidéo disponible', Colors.red);
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
        title: video['title'] ?? 'Vidéo Dinor TV',
        onClose: () {
          if (Navigator.of(context, rootNavigator: true).canPop()) {
            Navigator.of(context, rootNavigator: true).pop();
          }
        },
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildVideoCard(Map<String, dynamic> video) {
    final title = video['title'] ?? video['name'] ?? 'Vidéo sans titre';
    final description = video['description'] ?? video['excerpt'] ?? 'Aucune description';
    final imageUrl = video['image'] ?? 
                     video['thumbnail'] ?? 
                     video['thumbnail_url'] ?? 
                     video['image_url'] ?? 
                     video['featured_image'] ?? 
                     video['featured_image_url'];
    final duration = video['duration'] ?? video['length'] ?? '5:00';
    
    return GestureDetector(
      onTap: () => _openVideo(video),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail avec bouton play
            Stack(
              children: [
                Container(
                  height: 200,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                    color: Color(0xFFF7FAFC),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: imageUrl != null 
                      ? Image.network(
                          imageUrl,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildDefaultThumbnail();
                          },
                        )
                      : _buildDefaultThumbnail(),
                  ),
                ),
                // Bouton play overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.play_circle_fill,
                        size: 64,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // Durée
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      duration,
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Contenu
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3748),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 14,
                      color: Color(0xFF4A5568),
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.play_circle_outline,
                        size: 16,
                        color: Color(0xFF718096),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        video['views'] != null ? '${video['views']} vues' : 'Nouveau',
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 12,
                          color: Color(0xFF718096),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3182CE).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Vidéo',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF3182CE),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultThumbnail() {
    return Container(
      height: 200,
      color: const Color(0xFFF7FAFC),
      child: const Center(
        child: Icon(
          Icons.play_circle,
          size: 48,
          color: Color(0xFF3182CE),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // Header personnalisé sans espace superflu
          Container(
            color: Colors.white,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
              left: 16,
              right: 16,
              bottom: 0,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3748)),
                  onPressed: () => NavigationService.pop(),
                ),
                Expanded(
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/images/LOGO_DINOR_monochrome.svg',
                      width: 32,
                      height: 32,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF2D3748),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 48), // Pour équilibrer le bouton retour
              ],
            ),
          ),
          // Body avec UnifiedContentList
          Expanded(
            child: UnifiedContentList(
              contentType: 'video',
              apiEndpoint: 'https://new.dinorapp.com/api/v1/dinor-tv',
              itemsPerPage: 3,
              enableSearch: true,
              enableFilters: true,
              useGridView: false,
              enableInfiniteScroll: true,
              itemBuilder: _buildVideoCard,
              titleExtractor: (item) => item['title']?.toString() ?? '',
              imageExtractor: (item) => item['image']?.toString() ?? 
                                      item['thumbnail']?.toString() ?? 
                                      item['featured_image_url']?.toString() ?? '',
              descriptionExtractor: (item) => item['description']?.toString() ?? '',
              onItemTap: (item) => () => _openVideo(item),
            ),
          ),
        ],
      ),
    );
  }
}