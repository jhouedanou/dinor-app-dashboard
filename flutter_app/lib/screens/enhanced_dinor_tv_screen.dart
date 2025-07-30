/**
 * ENHANCED_DINOR_TV_SCREEN.DART - ÉCRAN DINOR TV
 * 
 * FONCTIONNALITÉS :
 * - Liste des vidéos avec aperçu
 * - Intégration avec le VideoService
 * - Cache et performance optimisés
 * - Navigation fluide
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../services/navigation_service.dart';
import '../services/video_service.dart';

import '../components/common/unified_like_button.dart';
import '../composables/use_auth_handler.dart';
import '../components/common/auth_modal.dart';

class EnhancedDinorTVScreen extends ConsumerStatefulWidget {
  const EnhancedDinorTVScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<EnhancedDinorTVScreen> createState() => _EnhancedDinorTVScreenState();
}

class _EnhancedDinorTVScreenState extends ConsumerState<EnhancedDinorTVScreen>
with AutomaticKeepAliveClientMixin {
  bool _showAuthModal = false;


  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    
    // Charger les vidéos au démarrage de manière sûre
    Future.delayed(Duration.zero, () {
      if (mounted) {
        ref.read(videoServiceProvider.notifier).loadVideos();
      }
    });
  }



  Future<void> _handleRefresh() async {
    await ref.read(videoServiceProvider.notifier).loadVideos(forceRefresh: true);
  }



  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    final videoState = ref.watch(videoServiceProvider);
    final videos = videoState.videos;
    final isLoading = videoState.isLoading;
    final error = videoState.error;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Row(
          children: [
            SvgPicture.asset(
              'assets/images/LOGO_DINOR_monochrome.svg',
              width: 28,
              height: 28,
              colorFilter: const ColorFilter.mode(
                Color(0xFF2D3748),
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Dinor TV',
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3748)),
          onPressed: () => NavigationService.pop(),
        ),
        actions: [

          IconButton(
            onPressed: _handleRefresh,
            icon: const Icon(LucideIcons.refreshCw, color: Color(0xFF2D3748)),
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: _buildBody(videos, isLoading, error),
      ),
      

    );
  }

  Widget _buildBody(List<VideoData> videos, bool isLoading, String? error) {
    if (isLoading && videos.isEmpty) {
      return _buildLoadingState();
    }

    if (error != null && videos.isEmpty) {
      return _buildErrorState(error);
    }

    if (videos.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header avec stats
          _buildHeader(videos),
          
          const SizedBox(height: 24),



          // Liste des vidéos
          const Text(
            'Toutes les vidéos',
            style: TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
          
          const SizedBox(height: 16),
          
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: videos.length,
            itemBuilder: (context, index) {
              return _buildVideoCard(videos[index], index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(List<VideoData> videos) {
    final totalViews = videos.fold<int>(0, (sum, video) => sum + video.views);
    final totalLikes = videos.fold<int>(0, (sum, video) => sum + video.likesCount);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE53E3E),
            Color(0xFFD53F8C),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE53E3E).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Dinor TV',
            style: TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Découvrez nos vidéos culinaires',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('${videos.length}', 'Vidéos', LucideIcons.video),
              _buildStatItem('$totalViews', 'Vues', LucideIcons.eye),
              _buildStatItem('$totalLikes', 'Likes', LucideIcons.heart),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  

  Widget _buildVideoCard(VideoData video, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail avec bouton play
          GestureDetector(
            onTap: () {
              // Lecture de la vidéo en mode normal
              print('Lecture de la vidéo: ${video.title}');
            },
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: video.thumbnailUrl != null
                        ? CachedNetworkImage(
                            imageUrl: video.thumbnailUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => _buildThumbnailPlaceholder(),
                            errorWidget: (context, url, error) => _buildThumbnailPlaceholder(),
                          )
                        : _buildThumbnailPlaceholder(),
                  ),
                ),
                
                // Overlay play button
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: const Center(
                      child: Icon(
                        LucideIcons.play,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  ),
                ),

                // Duration badge
                if (video.duration != null)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _formatDuration(video.duration!),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and author
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: const Color(0xFFE2E8F0),
                      backgroundImage: video.authorAvatar != null 
                        ? NetworkImage(video.authorAvatar!)
                        : null,
                      child: video.authorAvatar == null
                        ? const Icon(LucideIcons.user, size: 16, color: Color(0xFF4A5568))
                        : null,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            video.title,
                            style: const TextStyle(
                              fontFamily: 'OpenSans',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D3748),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            video.author,
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 12,
                              color: Color(0xFF4A5568),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Description
                if (video.description.isNotEmpty) ...[
                  Text(
                    video.description,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 14,
                      color: Color(0xFF4A5568),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                ],

                // Stats and actions
                Row(
                  children: [
                    // Views
                    _buildStatChip(LucideIcons.eye, '${video.views}'),
                    const SizedBox(width: 12),
                    
                    // Comments
                    _buildStatChip(LucideIcons.messageCircle, '${video.commentsCount}'),
                    
                    const Spacer(),
                    
                    // Like button
                    UnifiedLikeButton(
                      type: 'video',
                      itemId: video.id,
                      initialLiked: video.isLiked,
                      initialCount: video.likesCount,
                      showCount: true,
                      size: 'small',
                      variant: 'minimal',
                      onAuthRequired: () => setState(() => _showAuthModal = true),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF4A5568)),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 12,
            color: Color(0xFF4A5568),
          ),
        ),
      ],
    );
  }

  Widget _buildThumbnailPlaceholder() {
    return Container(
      color: const Color(0xFFF7FAFC),
      child: const Center(
        child: Icon(
          LucideIcons.video,
          size: 48,
          color: Color(0xFFCBD5E0),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE53E3E)),
          ),
          SizedBox(height: 16),
          Text(
            'Chargement des vidéos...',
            style: TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 16,
              color: Color(0xFF4A5568),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              LucideIcons.alertCircle,
              size: 64,
              color: Color(0xFFE53E3E),
            ),
            const SizedBox(height: 16),
            const Text(
              'Erreur de chargement',
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 14,
                color: Color(0xFF4A5568),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _handleRefresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53E3E),
                foregroundColor: Colors.white,
              ),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.video,
              size: 64,
              color: Color(0xFFCBD5E0),
            ),
            SizedBox(height: 16),
            Text(
              'Aucune vidéo disponible',
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Les nouvelles vidéos apparaîtront ici dès qu\'elles seront disponibles.',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 14,
                color: Color(0xFF4A5568),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
} 