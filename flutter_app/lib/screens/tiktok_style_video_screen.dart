/// TIKTOK_STYLE_VIDEO_SCREEN.DART - INTERFACE VIDÉO PLEIN ÉCRAN TYPE TIKTOK
/// 
/// FONCTIONNALITÉS :
/// - Lecteur vidéo en mode portrait plein écran
/// - Défilement vertical PageView pour navigation entre vidéos
/// - Lecture automatique de la vidéo visible
/// - Pause automatique des vidéos hors écran
/// - Contrôles superposés : play/pause, progression, interactions
/// - Informations du contenu en bas à gauche
/// - Gestes : tap pour pause/lecture, swipe vertical
/// - Optimisation performances avec préchargement
/// - Support formats vidéo courants (MP4, MOV, etc.)
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:async';
import 'dart:ui';

import '../services/navigation_service.dart';
import '../components/common/youtube_video_player.dart';
import '../components/common/unified_comments_section.dart';
import '../services/comments_service.dart';

// Modèle pour les données vidéo
class VideoData {
  final String id;
  final String title;
  final String description;
  final String author;
  final String? authorAvatar;
  final String videoUrl;
  final String? thumbnailUrl;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final int views;
  final bool isLiked;
  final Duration? duration;

  VideoData({
    required this.id,
    required this.title,
    required this.description,
    required this.author,
    this.authorAvatar,
    required this.videoUrl,
    this.thumbnailUrl,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
    this.views = 0,
    this.isLiked = false,
    this.duration,
  });

  factory VideoData.fromJson(Map<String, dynamic> json) {
    return VideoData(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      author: json['author'] ?? json['user_name'] ?? 'Dinor',
      authorAvatar: json['author_avatar'] ?? json['user_avatar'],
      videoUrl: json['video_url'] ?? json['url'] ?? '',
      thumbnailUrl: json['thumbnail_url'] ?? json['thumbnail'] ?? json['image'],
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      sharesCount: json['shares_count'] ?? 0,
      views: json['views'] ?? 0,
      isLiked: json['is_liked'] ?? false,
      duration: json['duration'] != null ? 
        Duration(seconds: int.tryParse(json['duration'].toString()) ?? 0) : null,
    );
  }
}

// État global pour la gestion des vidéos
class VideoPlayerState {
  final List<VideoData> videos;
  final int currentIndex;
  final bool isLoading;
  final String? error;

  const VideoPlayerState({
    this.videos = const [],
    this.currentIndex = 0,
    this.isLoading = false,
    this.error,
  });

  VideoPlayerState copyWith({
    List<VideoData>? videos,
    int? currentIndex,
    bool? isLoading,
    String? error,
  }) {
    return VideoPlayerState(
      videos: videos ?? this.videos,
      currentIndex: currentIndex ?? this.currentIndex,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Service de gestion des vidéos
class VideoPlayerService extends StateNotifier<VideoPlayerState> {
  VideoPlayerService() : super(const VideoPlayerState());

  void loadVideos(List<VideoData> videos) {
    state = state.copyWith(videos: videos, isLoading: false);
  }

  void setCurrentIndex(int index) {
    state = state.copyWith(currentIndex: index);
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(String? error) {
    state = state.copyWith(error: error);
  }
}

final videoPlayerProvider = StateNotifierProvider<VideoPlayerService, VideoPlayerState>((ref) {
  return VideoPlayerService();
});

// Écran principal TikTok
class TikTokStyleVideoScreen extends ConsumerStatefulWidget {
  final List<VideoData> videos;
  final int initialIndex;

  const TikTokStyleVideoScreen({
    super.key,
    required this.videos,
    this.initialIndex = 0,
  });

  @override
  ConsumerState<TikTokStyleVideoScreen> createState() => _TikTokStyleVideoScreenState();
}

class _TikTokStyleVideoScreenState extends ConsumerState<TikTokStyleVideoScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentIndex = 0;
  
  // Animation des contrôles
  late AnimationController _controlsAnimationController;
  late Animation<double> _controlsAnimation;
  bool _showControls = false;
  Timer? _hideControlsTimer;
  
  // Gestion des lecteurs YouTube
  final Map<int, GlobalKey<YouTubeVideoPlayerState>> _playerKeys = {};
  
  // Cache des couleurs extraites par vidéo
  final Map<String, List<Color>> _extractedColors = {};

  @override
  void initState() {
    super.initState();
    
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    
    _controlsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _controlsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controlsAnimationController,
      curve: Curves.easeInOut,
    ));

    // Charger les vidéos dans le provider après la construction
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(videoPlayerProvider.notifier).loadVideos(widget.videos);
      ref.read(videoPlayerProvider.notifier).setCurrentIndex(_currentIndex);
    });

    // Mettre en plein écran
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    // Nettoyer les références aux lecteurs
    _playerKeys.clear();
    
    _pageController.dispose();
    _controlsAnimationController.dispose();
    _hideControlsTimer?.cancel();
    
    // Restaurer l'interface système
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    
    super.dispose();
  }

  // Pauser tous les autres lecteurs sauf le courant
  void _pauseOtherPlayers(int currentIndex) {
    for (final entry in _playerKeys.entries) {
      if (entry.key != currentIndex) {
        entry.value.currentState?.pause();
      }
    }
  }

  // Changer de vidéo
  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    // Modifier le provider de manière sécurisée
    Future(() {
      ref.read(videoPlayerProvider.notifier).setCurrentIndex(index);
    });

    // Pauser tous les autres lecteurs
    _pauseOtherPlayers(index);
    
    print('🎬 [TikTokVideo] Changement vers vidéo $index: ${widget.videos[index].title}');
  }

  // Toggle play/pause pour le lecteur YouTube courant
  void _togglePlayPause() {
    final playerKey = _playerKeys[_currentIndex];
    if (playerKey?.currentState != null) {
      // Note: YouTubeVideoPlayer gère son propre toggle via les contrôles intégrés
      print('🎵 [TikTokVideo] Toggle play/pause via contrôles YouTube');
    }
    
    _showControlsTemporarily();
  }

  // Afficher les contrôles temporairement
  void _showControlsTemporarily() {
    setState(() {
      _showControls = true;
    });
    
    _controlsAnimationController.forward();
    
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
        _controlsAnimationController.reverse();
      }
    });
  }

  // Partager la vidéo
  void _shareVideo() {
    final video = widget.videos[_currentIndex];
    Share.share(
      'Regardez cette vidéo sur Dinor : ${video.title}\n\nhttps://new.dinorapp.com/video/${video.id}',
      subject: video.title,
    );
  }


  // Naviguer vers les commentaires
  void _openComments() {
    final video = widget.videos[_currentIndex];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildCommentsSheet(video),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // PageView principal avec vidéos
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            onPageChanged: _onPageChanged,
            itemCount: widget.videos.length,
            itemBuilder: (context, index) {
              return _buildVideoPage(index);
            },
          ),

          // Interface superposée
          _buildOverlayInterface(),
        ],
      ),
    );
  }

  // Page vidéo NOUVELLE avec design révolutionnaire
  Widget _buildVideoPage(int index) {
    final video = widget.videos[index];
    
    // Créer une clé unique pour ce lecteur
    if (!_playerKeys.containsKey(index)) {
      _playerKeys[index] = GlobalKey<YouTubeVideoPlayerState>();
    }

    return GestureDetector(
      onTap: _togglePlayPause,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          // Gradient de fond très visible
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1a1a2e),  // Bleu foncé
              Color(0xFF16213e),  // Bleu marine
              Color(0xFF0f3460),  // Bleu profond
              Colors.black,
            ],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image de fond avec effet dramatique
            _buildDramaticBackground(video),
            
            // Effet de particules animé (simulation)
            _buildAnimatedOverlay(),
            
            // Lecteur vidéo au centre avec effet WOW
            _buildCenteredVideoPlayer(video, index),
          ],
        ),
      ),
    );
  }

  // Image de fond avec effet dramatique
  Widget _buildDramaticBackground(VideoData video) {
    if (video.thumbnailUrl == null || video.thumbnailUrl!.isEmpty) {
      return Container();
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Image de fond
        Image.network(
          video.thumbnailUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(),
        ),
        
        // Triple effet blur très visible
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
          child: Container(
            color: Colors.black.withValues(alpha: 0.6),
          ),
        ),
        
        // Gradient overlay dramatique
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.2,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.3),
                Colors.black.withValues(alpha: 0.7),
                Colors.black.withValues(alpha: 0.9),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Effet d'overlay animé
  Widget _buildAnimatedOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF4facfe).withValues(alpha: 0.1),
            Colors.transparent,
            const Color(0xFFe100ff).withValues(alpha: 0.1),
          ],
        ),
      ),
    );
  }

  // Extracteur de couleurs simple basé sur l'URL de l'image
  List<Color> _getColorsFromImage(VideoData video) {
    final videoId = video.id;
    
    // Si on a déjà extrait les couleurs pour cette vidéo
    if (_extractedColors.containsKey(videoId)) {
      return _extractedColors[videoId]!;
    }
    
    // Couleurs par défaut basées sur l'ID de la vidéo pour la cohérence
    final hash = videoId.hashCode;
    final colors = [
      // Première couleur : teintes chaudes/froides basées sur le hash
      Color.fromARGB(
        153, // Alpha fixe (0.6)
        100 + (hash % 156), // Rouge variable
        150 + ((hash >> 8) % 106), // Vert variable  
        200 + ((hash >> 16) % 56), // Bleu variable
      ),
      // Deuxième couleur : complémentaire
      Color.fromARGB(
        153, // Alpha fixe (0.6)
        200 + ((hash >> 4) % 56), // Rouge variable
        100 + ((hash >> 12) % 156), // Vert variable
        150 + ((hash >> 20) % 106), // Bleu variable
      ),
    ];
    
    // Cache pour éviter de recalculer
    _extractedColors[videoId] = colors;
    return colors;
  }

  // Détecter le ratio optimal pour la vidéo
  double _getOptimalAspectRatio(VideoData video) {
    // Pour les vidéos YouTube, le ratio standard est 16:9
    // Pour les vidéos courtes/TikTok, on garde 9:16
    // On peut détecter via l'URL ou utiliser des heuristiques
    
    if (video.videoUrl.contains('youtube.com') || video.videoUrl.contains('youtu.be')) {
      // Vidéos YouTube classiques = 16:9 (paysage)
      return 16 / 9;
    }
    
    // Si la durée est courte (< 60s), probablement du contenu vertical
    if (video.duration != null && video.duration!.inSeconds < 60) {
      return 9 / 16; // Portrait pour contenus courts
    }
    
    // Par défaut, utiliser le ratio YouTube standard
    return 16 / 9;
  }

  // Lecteur vidéo centré avec ratio adaptatif
  Widget _buildCenteredVideoPlayer(VideoData video, int index) {
    final colors = _getColorsFromImage(video);
    final aspectRatio = _getOptimalAspectRatio(video);
    final isPortrait = aspectRatio < 1;
    
    // Ajuster les marges selon l'orientation
    final margin = isPortrait 
        ? const EdgeInsets.symmetric(horizontal: 30, vertical: 40)  // Plus d'espace vertical pour portrait
        : const EdgeInsets.symmetric(horizontal: 20, vertical: 60); // Plus d'espace horizontal pour paysage
    
    return Center(
      child: Container(
        margin: margin,
        constraints: BoxConstraints(
          // Limiter les dimensions pour éviter que la vidéo soit trop grande
          maxWidth: MediaQuery.of(context).size.width - 40,
          maxHeight: MediaQuery.of(context).size.height * (isPortrait ? 0.8 : 0.6),
        ),
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: Stack(
            children: [
              // Container pour les shadows uniquement
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(isPortrait ? 30 : 20),
                    // SHADOWS avec couleurs extraites de l'image
                    boxShadow: [
                      // Shadow principale avec première couleur extraite
                      BoxShadow(
                        color: colors[0],
                        blurRadius: isPortrait ? 50 : 40,
                        offset: Offset(isPortrait ? -15 : -10, isPortrait ? -15 : -10),
                        spreadRadius: isPortrait ? 10 : 8,
                      ),
                      // Shadow secondaire avec deuxième couleur extraite
                      BoxShadow(
                        color: colors[1],
                        blurRadius: isPortrait ? 50 : 40,
                        offset: Offset(isPortrait ? 15 : 10, isPortrait ? 15 : 10),
                        spreadRadius: isPortrait ? 10 : 8,
                      ),
                      // Shadow noire pour la profondeur
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.8),
                        blurRadius: isPortrait ? 40 : 30,
                        offset: Offset(0, isPortrait ? 20 : 15),
                        spreadRadius: isPortrait ? 8 : 6,
                      ),
                    ],
                  ),
                ),
              ),
              // Container de la vidéo SANS shadows (bordure limitée aux dimensions de la vidéo)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(isPortrait ? 30 : 20),
                  // Border limitée aux dimensions exactes de la vidéo
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4),
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(isPortrait ? 28 : 18),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.grey[900]!,
                          Colors.black,
                        ],
                      ),
                    ),
                    child: video.videoUrl.isNotEmpty
                        ? YouTubeVideoPlayer(
                            key: _playerKeys[index],
                            videoUrl: video.videoUrl,
                            title: '',
                            autoPlay: index == _currentIndex,
                            showControls: true,
                            onReady: () {
                              print('✅ [TikTokVideo] Player $index ready: ${video.title}');
                            },
                            onPause: () {
                              print('⏸️ [TikTokVideo] Player $index paused');
                            },
                          )
                        : _buildVideoPlaceholder(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  // Placeholder pour vidéo
  Widget _buildVideoPlaceholder() {
    return Container(
      color: Colors.grey[900],
      child: const Center(
        child: Icon(
          LucideIcons.play,
          size: 64,
          color: Colors.white54,
        ),
      ),
    );
  }

  // Note: Le bouton play/pause central n'est plus nécessaire 
  // car YouTubeVideoPlayer a ses propres contrôles intégrés

  // Interface superposée
  Widget _buildOverlayInterface() {
    final video = widget.videos[_currentIndex];

    return Positioned.fill(
      child: Stack(
        children: [
          // Bouton retour en haut à gauche
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: GestureDetector(
              onTap: () => NavigationService.pop(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  LucideIcons.arrowLeft,
                  color: Color(0xFF2D3748),
                  size: 24,
                ),
              ),
            ),
          ),

          // Boutons d'interaction à droite
          Positioned(
            right: 16,
            bottom: 100,
            child: _buildActionButtons(video),
          ),

          // Informations du contenu en bas à gauche
          Positioned(
            left: 16,
            right: 80,
            bottom: 100,
            child: _buildVideoInfo(video),
          ),

          // Note: Barre de progression gérée par YouTubeVideoPlayer
        ],
      ),
    );
  }

  // Boutons d'action à droite
  Widget _buildActionButtons(VideoData video) {
    return Consumer(
      builder: (context, ref, _) {
        return Column(
          children: [
            // Commentaires avec nombre dynamique
            _buildActionButton(
              onTap: _openComments,
              child: Consumer(
                builder: (context, ref, _) {
                  final commentsState = ref.watch(commentsProvider('dinor_tv_${video.id}'));
                  final actualCount = commentsState.comments.isNotEmpty 
                      ? commentsState.comments.length 
                      : video.commentsCount;
                  
                  return Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          LucideIcons.messageCircle,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$actualCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Partage
            _buildActionButton(
              onTap: _shareVideo,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.share,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${video.sharesCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // Bouton d'action générique
  Widget _buildActionButton({
    VoidCallback? onTap,
    required Widget child,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: child,
      ),
    );
  }

  // Informations de la vidéo
  Widget _buildVideoInfo(VideoData video) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Auteur
        Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white24,
              backgroundImage: video.authorAvatar != null 
                ? NetworkImage(video.authorAvatar!)
                : null,
              child: video.authorAvatar == null
                ? const Icon(LucideIcons.user, size: 18, color: Colors.white)
                : null,
            ),
            const SizedBox(width: 8),
            Text(
              '@${video.author}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),

        // Titre
        Text(
          video.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 4),

        // Description
        if (video.description.isNotEmpty)
          Text(
            video.description,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),

      ],
    );
  }

  // Note: Barre de progression maintenant gérée par YouTubeVideoPlayer

  // Sheet des commentaires avec composant unifié
  Widget _buildCommentsSheet(VideoData video) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header avec bouton fermer
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Text(
                      'Commentaires',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const Spacer(),
                    Consumer(
                      builder: (context, ref, _) {
                        final commentsState = ref.watch(commentsProvider('dinor_tv_${video.id}'));
                        final actualCount = commentsState.comments.isNotEmpty 
                            ? commentsState.comments.length 
                            : video.commentsCount;
                            
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4D03F),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$actualCount',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.close,
                        color: Color(0xFF718096),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              
              const Divider(height: 1),
              
              // Section commentaires unifiée
              Expanded(
                child: UnifiedCommentsSection(
                  contentType: 'dinor_tv',
                  contentId: video.id,
                  contentTitle: video.title,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
} 