/// YOUTUBE_VIDEO_PLAYER.DART - LECTEUR VIDÉO YOUTUBE NATIF
/// 
/// FONCTIONNALITÉS :
/// - Chargement ultra-rapide avec thumbnail YouTube (CDN Google)
/// - Initialisation lazy du player : chargé uniquement au tap
/// - Lecture YouTube native avec youtube_player_flutter
/// - Contrôles intégrés et optimisés
/// - Support des URLs YouTube variées
/// - Mode plein écran et mini-player
library;

import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YouTubeVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String title;
  final bool autoPlay;
  final bool mute;
  final bool showControls;
  final VoidCallback? onReady;
  final VoidCallback? onPause;

  const YouTubeVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.title,
    this.autoPlay = false,
    this.mute = false,
    this.showControls = true,
    this.onReady,
    this.onPause,
  });

  /// Extrait l'ID YouTube depuis n'importe quel format d'URL
  static String? extractVideoId(String url) {
    return YoutubePlayer.convertUrlToId(url);
  }

  /// Génère l'URL du thumbnail YouTube haute qualité
  static String? getThumbnailUrl(String videoUrl, {String quality = 'hqdefault'}) {
    final videoId = extractVideoId(videoUrl);
    if (videoId == null) return null;
    return 'https://img.youtube.com/vi/$videoId/$quality.jpg';
  }

  @override
  State<YouTubeVideoPlayer> createState() => YouTubeVideoPlayerState();
}

class YouTubeVideoPlayerState extends State<YouTubeVideoPlayer> {
  YoutubePlayerController? _controller;
  bool _isPlayerReady = false;
  bool _isPlayerInitialized = false;
  String? _error;
  String? _videoId;
  String? _thumbnailUrl;

  // Méthode pour pauser la vidéo depuis l'extérieur
  void pause() {
    if (_isPlayerReady && _controller != null) {
      _controller!.pause();
      widget.onPause?.call();
    }
  }

  // Méthode pour lancer la lecture depuis l'extérieur
  void play() {
    if (!_isPlayerInitialized) {
      _initializePlayer();
    } else if (_isPlayerReady && _controller != null) {
      _controller!.play();
    }
  }

  @override
  void initState() {
    super.initState();
    
    // Extraire l'ID vidéo et préparer le thumbnail (instantané, pas de WebView)
    _videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
    if (_videoId != null) {
      _thumbnailUrl = 'https://img.youtube.com/vi/$_videoId/hqdefault.jpg';
    } else {
      _error = 'URL YouTube invalide';
    }

    // Si autoPlay est activé, lancer le player immédiatement
    if (widget.autoPlay && _videoId != null) {
      _initializePlayer();
    }
  }

  void _initializePlayer() {
    if (_isPlayerInitialized || _videoId == null) return;
    
    try {
      print('📺 [YouTubePlayer] Initialisation du player pour: ${widget.title}');

      _controller = YoutubePlayerController(
        initialVideoId: _videoId!,
        flags: YoutubePlayerFlags(
          autoPlay: true, // Toujours autoPlay quand on init (l'user a cliqué)
          mute: widget.mute,
          enableCaption: true,
          isLive: false,
          forceHD: false,
          hideControls: !widget.showControls,
          controlsVisibleAtStart: widget.showControls,
        ),
      );

      _controller!.addListener(() {
        if (_controller!.value.isReady && !_isPlayerReady) {
          if (mounted) {
            setState(() {
              _isPlayerReady = true;
            });
          }
          widget.onReady?.call();
          print('✅ [YouTubePlayer] Player ready');
        }
        
        if (_controller!.value.hasError) {
          if (mounted) {
            setState(() {
              _error = 'Erreur de lecture vidéo';
            });
          }
          print('❌ [YouTubePlayer] Player error: ${_controller!.value.errorCode}');
        }
      });

      if (mounted) {
        setState(() {
          _isPlayerInitialized = true;
        });
      }
      
    } catch (e) {
      print('❌ [YouTubePlayer] Erreur initialisation: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return _buildErrorWidget();
    }

    // Si le player est initialisé, afficher le player YouTube
    if (_isPlayerInitialized && _controller != null) {
      return _buildPlayer();
    }

    // Sinon, afficher le thumbnail avec bouton play (chargement instantané)
    return _buildThumbnailPreview();
  }

  /// Thumbnail YouTube avec bouton play — affichage instantané
  Widget _buildThumbnailPreview() {
    return GestureDetector(
      onTap: _initializePlayer,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Thumbnail depuis le CDN YouTube (très rapide)
          if (_thumbnailUrl != null)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                _thumbnailUrl!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.black,
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE53E3E)),
                        strokeWidth: 2,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[900],
                    child: const Center(
                      child: Icon(Icons.video_library, color: Colors.white54, size: 48),
                    ),
                  );
                },
              ),
            ),

          // Bouton play par-dessus le thumbnail
          Container(
            width: 68,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFE53E3E).withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.play_arrow,
              color: Colors.white,
              size: 36,
            ),
          ),

          // Titre en bas
          if (widget.title.isNotEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Roboto',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Player YouTube actif (chargé après le tap)
  Widget _buildPlayer() {
    return Stack(
      children: [
        YoutubePlayerBuilder(
          player: YoutubePlayer(
            controller: _controller!,
            showVideoProgressIndicator: true,
            progressIndicatorColor: const Color(0xFFE53E3E),
            progressColors: const ProgressBarColors(
              playedColor: Color(0xFFE53E3E),
              handleColor: Color(0xFFE53E3E),
            ),
            onReady: () {
              print('✅ [YouTubePlayer] Player onReady callback');
            },
            onEnded: (metaData) {
              print('🏁 [YouTubePlayer] Video ended');
            },
          ),
          builder: (context, player) {
            return player;
          },
        ),
        // Spinner de chargement pendant l'init du player
        if (!_isPlayerReady)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.6),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE53E3E)),
                  strokeWidth: 3,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.white54,
            ),
            const SizedBox(height: 12),
            Text(
              _error ?? 'Erreur de lecture',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontFamily: 'Roboto',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _error = null;
                  _isPlayerInitialized = false;
                  _isPlayerReady = false;
                });
                _controller?.dispose();
                _controller = null;
                _initializePlayer();
              },
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
}