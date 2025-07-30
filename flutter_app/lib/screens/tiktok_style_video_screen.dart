/**
 * TIKTOK_STYLE_VIDEO_SCREEN.DART - INTERFACE VIDÉO PLEIN ÉCRAN TYPE TIKTOK
 * 
 * FONCTIONNALITÉS :
 * - Lecteur vidéo en mode portrait plein écran
 * - Défilement vertical PageView pour navigation entre vidéos
 * - Lecture automatique de la vidéo visible
 * - Pause automatique des vidéos hors écran
 * - Contrôles superposés : play/pause, progression, interactions
 * - Informations du contenu en bas à gauche
 * - Gestes : tap pour pause/lecture, swipe vertical
 * - Optimisation performances avec préchargement
 * - Support formats vidéo courants (MP4, MOV, etc.)
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:async';

import '../services/navigation_service.dart';
import '../components/common/unified_like_button.dart';
import '../composables/use_auth_handler.dart';
import '../components/common/auth_modal.dart';

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
      thumbnailUrl: json['thumbnail'] ?? json['image'],
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
    Key? key,
    required this.videos,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  ConsumerState<TikTokStyleVideoScreen> createState() => _TikTokStyleVideoScreenState();
}

class _TikTokStyleVideoScreenState extends ConsumerState<TikTokStyleVideoScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentIndex = 0;
  bool _showAuthModal = false;
  
  // Gestion des contrôleurs vidéo
  final Map<int, VideoPlayerController> _controllers = {};
  final Map<int, bool> _initialized = {};
  
  // Animation des contrôles
  late AnimationController _controlsAnimationController;
  late Animation<double> _controlsAnimation;
  bool _showControls = false;
  Timer? _hideControlsTimer;

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

    // Charger les vidéos dans le provider
    ref.read(videoPlayerProvider.notifier).loadVideos(widget.videos);
    ref.read(videoPlayerProvider.notifier).setCurrentIndex(_currentIndex);

    // Initialiser la première vidéo et précharger les suivantes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeVideo(_currentIndex);
      _preloadAdjacentVideos(_currentIndex);
    });

    // Mettre en plein écran
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    // Nettoyer tous les contrôleurs
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    
    _pageController.dispose();
    _controlsAnimationController.dispose();
    _hideControlsTimer?.cancel();
    
    // Restaurer l'interface système
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    
    super.dispose();
  }

  // Initialiser une vidéo
  Future<void> _initializeVideo(int index) async {
    if (index < 0 || index >= widget.videos.length) return;
    if (_controllers.containsKey(index)) return;

    final video = widget.videos[index];
    if (video.videoUrl.isEmpty) return;

    try {
      print('🎥 [TikTokVideo] Initialisation vidéo $index: ${video.title}');
      
      VideoPlayerController controller;
      
      // Supporter différents types d'URL
      if (video.videoUrl.startsWith('http')) {
        controller = VideoPlayerController.networkUrl(Uri.parse(video.videoUrl));
      } else {
        controller = VideoPlayerController.asset(video.videoUrl);
      }

      _controllers[index] = controller;
      
      await controller.initialize();
      
      setState(() {
        _initialized[index] = true;
      });

      // Auto-play si c'est la vidéo courante
      if (index == _currentIndex) {
        controller.play();
        controller.setLooping(true);
      }

      print('✅ [TikTokVideo] Vidéo $index initialisée');
    } catch (e) {
      print('❌ [TikTokVideo] Erreur initialisation vidéo $index: $e');
      setState(() {
        _initialized[index] = false;
      });
    }
  }

  // Précharger les vidéos adjacentes
  void _preloadAdjacentVideos(int currentIndex) {
    // Précharger la vidéo précédente
    if (currentIndex > 0) {
      _initializeVideo(currentIndex - 1);
    }
    
    // Précharger la vidéo suivante
    if (currentIndex < widget.videos.length - 1) {
      _initializeVideo(currentIndex + 1);
    }
  }

  // Changer de vidéo
  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    ref.read(videoPlayerProvider.notifier).setCurrentIndex(index);

    // Pause toutes les autres vidéos
    for (int i = 0; i < _controllers.length; i++) {
      if (i != index && _controllers[i] != null) {
        _controllers[i]!.pause();
      }
    }

    // Play la vidéo courante
    if (_controllers[index] != null && _initialized[index] == true) {
      _controllers[index]!.play();
    } else {
      _initializeVideo(index);
    }

    // Précharger les adjacentes
    _preloadAdjacentVideos(index);
    
    // Nettoyer les vidéos trop éloignées pour économiser la mémoire
    _cleanupDistantVideos(index);
  }

  // Nettoyer les vidéos éloignées
  void _cleanupDistantVideos(int currentIndex) {
    final toRemove = <int>[];
    
    for (final index in _controllers.keys) {
      if ((index - currentIndex).abs() > 2) {
        toRemove.add(index);
      }
    }
    
    for (final index in toRemove) {
      _controllers[index]?.dispose();
      _controllers.remove(index);
      _initialized.remove(index);
    }
  }

  // Toggle play/pause
  void _togglePlayPause() {
    final controller = _controllers[_currentIndex];
    if (controller != null && _initialized[_currentIndex] == true) {
      if (controller.value.isPlaying) {
        controller.pause();
      } else {
        controller.play();
      }
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

          // Modal d'authentification
          if (_showAuthModal)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: AuthModal(
                  isOpen: _showAuthModal,
                  onClose: () => setState(() => _showAuthModal = false),
                  onAuthenticated: () => setState(() => _showAuthModal = false),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Page vidéo individuelle
  Widget _buildVideoPage(int index) {
    final video = widget.videos[index];
    final controller = _controllers[index];
    final isInitialized = _initialized[index] ?? false;

    return GestureDetector(
      onTap: _togglePlayPause,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Vidéo ou placeholder
            if (controller != null && isInitialized)
              Center(
                child: AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: VideoPlayer(controller),
                ),
              )
            else if (video.thumbnailUrl != null)
              // Thumbnail en attendant la vidéo
              Image.network(
                video.thumbnailUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildVideoPlaceholder(),
              )
            else
              _buildVideoPlaceholder(),

            // Indicateur de chargement
            if (!isInitialized)
              const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),

            // Bouton play/pause central (quand contrôles visibles)
            if (_showControls)
              FadeTransition(
                opacity: _controlsAnimation,
                child: Center(
                  child: _buildPlayPauseButton(),
                ),
              ),
          ],
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

  // Bouton play/pause central
  Widget _buildPlayPauseButton() {
    final controller = _controllers[_currentIndex];
    final isPlaying = controller?.value.isPlaying ?? false;

    return GestureDetector(
      onTap: _togglePlayPause,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black54,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isPlaying ? LucideIcons.pause : LucideIcons.play,
          size: 48,
          color: Colors.white,
        ),
      ),
    );
  }

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
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.arrowLeft,
                  color: Colors.white,
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

          // Barre de progression en bas
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildProgressBar(),
          ),
        ],
      ),
    );
  }

  // Boutons d'action à droite
  Widget _buildActionButtons(VideoData video) {
    return Column(
      children: [
        // Like
        _buildActionButton(
          child: UnifiedLikeButton(
            type: 'video',
            itemId: video.id,
            initialLiked: video.isLiked,
            initialCount: video.likesCount,
            showCount: true,
            size: 'large',
            variant: 'minimal',
            onAuthRequired: () => setState(() => _showAuthModal = true),
          ),
        ),
        
        const SizedBox(height: 24),

        // Commentaires
        _buildActionButton(
          onTap: _openComments,
          child: Column(
            children: [
              const Icon(
                LucideIcons.messageCircle,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(height: 4),
              Text(
                '${video.commentsCount}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Partage
        _buildActionButton(
          onTap: _shareVideo,
          child: Column(
            children: [
              const Icon(
                LucideIcons.share,
                color: Colors.white,
                size: 32,
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

        const SizedBox(height: 8),

        // Stats
        Row(
          children: [
            const Icon(LucideIcons.eye, size: 16, color: Colors.white70),
            const SizedBox(width: 4),
            Text(
              '${video.views} vues',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Barre de progression
  Widget _buildProgressBar() {
    final controller = _controllers[_currentIndex];
    
    if (controller == null || !(_initialized[_currentIndex] ?? false)) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<Duration>(
      stream: Stream.periodic(const Duration(milliseconds: 100), (_) => controller.value.position),
      builder: (context, snapshot) {
        final position = snapshot.data ?? Duration.zero;
        final duration = controller.value.duration;
        
        if (duration == Duration.zero) return const SizedBox.shrink();
        
        final progress = position.inMilliseconds / duration.inMilliseconds;
        
        return Container(
          height: 3,
          width: double.infinity,
          color: Colors.white24,
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  // Sheet des commentaires
  Widget _buildCommentsSheet(VideoData video) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.9,
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
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Text(
                      'Commentaires',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${video.commentsCount}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              
              const Divider(),
              
              // Placeholder pour les commentaires
              Expanded(
                child: Center(
                  child: Text(
                    'Section commentaires à implémenter',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
} 