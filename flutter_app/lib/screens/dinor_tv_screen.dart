import '../services/navigation_service.dart';
/**
 * DINOR_TV_SCREEN.DART - ÉCRAN DINOR TV
 * 
 * FIDÉLITÉ VISUELLE :
 * - Design moderne avec cards vidéo
 * - Pull-to-refresh pour rafraîchir
 * - Loading states et error handling
 * - Navigation vers détail vidéo
 * 
 * FIDÉLITÉ FONCTIONNELLE :
 * - Chargement des vidéos via API
 * - Gestion d'état avec Riverpod
 * - Like/Favorite functionality
 * - Pagination si nécessaire
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Composables
import '../composables/use_dinor_tv.dart';
import '../composables/use_auth_handler.dart';

// Components
import '../components/common/like_button.dart';
import '../components/common/auth_modal.dart';

// TikTok Mode
import '../screens/tiktok_style_video_screen.dart';

class DinorTVScreen extends ConsumerStatefulWidget {
  const DinorTVScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DinorTVScreen> createState() => _DinorTVScreenState();
}

class _DinorTVScreenState extends ConsumerState<DinorTVScreen> with AutomaticKeepAliveClientMixin {
  bool _showAuthModal = false;
  String _authModalMessage = '';
  bool _hasLaunchedTikTok = false; // Pour éviter les lancements multiples

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    print('📺 [DinorTVScreen] Écran DinorTV initialisé');
    _loadVideos();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Écouter les changements d'état du provider DinorTV
    ref.listen(dinorTVProvider, (previous, next) {
      // Lancer automatiquement le mode TikTok quand les vidéos sont chargées
      if (!_hasLaunchedTikTok && 
          !next.loading && 
          next.videos.isNotEmpty && 
          next.error == null) {
        
        _hasLaunchedTikTok = true;
        print('🚀 [DinorTVScreen] Lancement automatique du mode TikTok avec ${next.videos.length} vidéos');
        
        // Lancer le mode TikTok après un petit délai pour éviter les conflits
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _openTikTokPlayer();
          }
        });
      }
    });
  }

  Future<void> _loadVideos() async {
    await ref.read(dinorTVProvider.notifier).loadVideos(
      params: {
        'limit': '20',
        'sort_by': 'created_at',
        'sort_order': 'desc',
      },
    );
  }

  Future<void> _handleRefresh() async {
    print('🔄 [DinorTVScreen] Rafraîchissement des vidéos...');
    await ref.read(dinorTVProvider.notifier).refresh();
  }

  void _openTikTokPlayer({int startIndex = 0}) {
    final dinorTVState = ref.read(dinorTVProvider);
    
    if (dinorTVState.videos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucune vidéo disponible'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Convertir les vidéos DinorTV en VideoData pour TikTok
    final tiktokVideos = dinorTVState.videos.map((video) {
      return VideoData(
        id: video['id']?.toString() ?? '',
        title: video['title'] ?? '',
        description: video['description'] ?? '',
        author: video['author'] ?? video['user_name'] ?? 'Dinor',
        authorAvatar: video['author_avatar'] ?? video['user_avatar'],
        videoUrl: video['video_url'] ?? video['url'] ?? '',
        thumbnailUrl: video['thumbnail'] ?? video['image'],
        likesCount: video['likes_count'] ?? 0,
        commentsCount: video['comments_count'] ?? 0,
        sharesCount: video['shares_count'] ?? 0,
        views: video['views'] ?? 0,
        isLiked: video['is_liked'] ?? false,
      );
    }).toList();

    // Naviguer vers le lecteur TikTok
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TikTokStyleVideoScreen(
          videos: tiktokVideos,
          initialIndex: startIndex,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  void _handleVideoTap(dynamic video) {
    print('🎬 [DinorTVScreen] Clic sur vidéo: ${video['id']}');
    // TODO: Navigation vers détail vidéo
    // NavigationService.pushNamed('/dinor-tv/${video['id']}');
  }

  void _handleLikeTap(dynamic video) async {
    final authHandler = ref.read(useAuthHandlerProvider.notifier);
    
    if (!authHandler.isAuthenticated) {
      setState(() {
        _showAuthModal = true;
        _authModalMessage = 'Connectez-vous pour liker cette vidéo';
      });
      return;
    }

    try {
      // TODO: Implémenter toggle like
      print('👍 [DinorTVScreen] Like vidéo: ${video['id']}');
    } catch (error) {
      print('❌ [DinorTVScreen] Erreur like: $error');
    }
  }

  void _handleFavoriteTap(dynamic video) async {
    final authHandler = ref.read(useAuthHandlerProvider.notifier);
    
    if (!authHandler.isAuthenticated) {
      setState(() {
        _showAuthModal = true;
        _authModalMessage = 'Connectez-vous pour ajouter aux favoris';
      });
      return;
    }

    try {
      // TODO: Implémenter toggle favorite
      print('⭐ [DinorTVScreen] Favorite vidéo: ${video['id']}');
    } catch (error) {
      print('❌ [DinorTVScreen] Erreur favorite: $error');
    }
  }

  void _closeAuthModal() {
    setState(() {
      _showAuthModal = false;
      _authModalMessage = '';
    });
  }

  void _displayAuthModal() {
    // Vérifier que le contexte est prêt avant d'afficher la modale
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _showAuthModal) {
        showDialog(
          context: context,
          barrierDismissible: true,
          useRootNavigator: true,
          builder: (BuildContext context) {
            return AuthModal(
              isOpen: true,
              onClose: () {
                Navigator.of(context, rootNavigator: true).pop();
                setState(() => _showAuthModal = false);
              },
              onAuthenticated: () {
                Navigator.of(context, rootNavigator: true).pop();
                setState(() => _showAuthModal = false);
              },
            );
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    final dinorTVState = ref.watch(dinorTVProvider);
    final videos = dinorTVState.videos;
    final loading = dinorTVState.loading;
    final error = dinorTVState.error;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: SvgPicture.asset(
          'assets/images/LOGO_DINOR_monochrome.svg',
          width: 32,
          height: 32,
          colorFilter: const ColorFilter.mode(
            Color(0xFF2D3748),
            BlendMode.srcIn,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3748)),
          onPressed: () => NavigationService.pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: _buildBody(videos, loading, error),
      ),
    );
  }

  Widget _buildBody(List<dynamic> videos, bool loading, String? error) {
    if (loading && videos.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF4D03F)),
            ),
            SizedBox(height: 16),
            Text(
              'Chargement des vidéos...',
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 16,
                color: Color(0xFF718096),
              ),
            ),
          ],
        ),
      );
    }

    if (error != null && videos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Color(0xFFE53E3E),
            ),
            const SizedBox(height: 16),
            Text(
              'Erreur de chargement',
              style: const TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 14,
                color: Color(0xFF718096),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadVideos,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF4D03F),
                foregroundColor: const Color(0xFF2D3748),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (videos.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library_outlined,
              size: 64,
              color: Color(0xFFCBD5E0),
            ),
            SizedBox(height: 16),
            Text(
              'Aucune vidéo disponible',
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Les nouvelles vidéos apparaîtront ici',
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 14,
                color: Color(0xFF718096),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final video = videos[index];
        return _buildVideoCard(video);
      },
    );
  }

  Widget _buildVideoCard(dynamic video) {
    final thumbnail = video['thumbnail'] ?? video['image'] ?? '';
    final title = video['title'] ?? 'Sans titre';
    final description = video['description'] ?? '';
    final duration = video['duration'] ?? '';
    final views = video['views'] ?? 0;
    final likes = video['likes_count'] ?? 0;
    final isLiked = video['is_liked'] ?? false;
    final isFavorited = video['is_favorited'] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail avec play button
          GestureDetector(
            onTap: () => _handleVideoTap(video),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: thumbnail.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: thumbnail,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: const Color(0xFFE2E8F0),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF4D03F)),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: const Color(0xFFE2E8F0),
                              child: const Icon(
                                Icons.video_library_outlined,
                                size: 48,
                                color: Color(0xFFCBD5E0),
                              ),
                            ),
                          )
                        : Container(
                            color: const Color(0xFFE2E8F0),
                            child: const Icon(
                              Icons.video_library_outlined,
                              size: 48,
                              color: Color(0xFFCBD5E0),
                            ),
                          ),
                  ),
                ),
                // Play button overlay
                Positioned.fill(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ),
                // Duration badge
                if (duration.isNotEmpty)
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
                        duration,
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
                // Title
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
                // Description
                if (description.isNotEmpty) ...[
                  Text(
                    description,
                    style: const TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 14,
                      color: Color(0xFF718096),
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                ],
                // Stats and actions
                Row(
                  children: [
                    // Views
                    Icon(
                      Icons.visibility_outlined,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$views vues',
                      style: TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Likes
                    Icon(
                      Icons.thumb_up_outlined,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$likes',
                      style: TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                    // Action buttons
                    IconButton(
                      onPressed: () => _handleLikeTap(video),
                      icon: Icon(
                        isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                        color: isLiked ? const Color(0xFFE53E3E) : Colors.grey[600],
                        size: 20,
                      ),
                    ),
                    IconButton(
                      onPressed: () => _handleFavoriteTap(video),
                      icon: Icon(
                        isFavorited ? Icons.favorite : Icons.favorite_border,
                        color: isFavorited ? const Color(0xFFE53E3E) : Colors.grey[600],
                        size: 20,
                      ),
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
}