/// YOUTUBE_VIDEO_PLAYER.DART - LECTEUR VIDÉO YOUTUBE NATIF
/// 
/// FONCTIONNALITÉS :
/// - Lecture YouTube native avec youtube_player_flutter
/// - Contrôles intégrés et optimisés
/// - Support des URLs YouTube variées
/// - Performance et stabilité améliorées
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

  @override
  State<YouTubeVideoPlayer> createState() => YouTubeVideoPlayerState();
}

class YouTubeVideoPlayerState extends State<YouTubeVideoPlayer> {
  late YoutubePlayerController _controller;
  bool _isPlayerReady = false;
  String? _error;

  // Méthode pour pauser la vidéo depuis l'extérieur
  void pause() {
    if (_isPlayerReady) {
      _controller.pause();
      widget.onPause?.call();
    }
  }

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    try {
      print('📺 [YouTubePlayer] Initialisation pour: ${widget.title}');
      print('📺 [YouTubePlayer] URL: ${widget.videoUrl}');
      
      // Extraire l'ID de la vidéo YouTube
      final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
      
      if (videoId == null) {
        setState(() {
          _error = 'URL YouTube invalide';
        });
        return;
      }

      print('📺 [YouTubePlayer] Video ID: $videoId');

      _controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: YoutubePlayerFlags(
          autoPlay: widget.autoPlay,
          mute: widget.mute,
          enableCaption: true,
          isLive: false,
          forceHD: false,
          hideControls: !widget.showControls,
          controlsVisibleAtStart: widget.showControls,
          // startAt: 0, // Paramètre supprimé car obsolète
        ),
      );

      _controller.addListener(() {
        if (_controller.value.isReady && !_isPlayerReady) {
          setState(() {
            _isPlayerReady = true;
          });
          widget.onReady?.call();
          print('✅ [YouTubePlayer] Player ready');
        }
        
        if (_controller.value.hasError) {
          setState(() {
            _error = 'Erreur de lecture vidéo';
          });
          print('❌ [YouTubePlayer] Player error: ${_controller.value.errorCode}');
        }
      });
      
    } catch (e) {
      print('❌ [YouTubePlayer] Erreur initialisation: $e');
      setState(() {
        _error = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return _buildErrorWidget();
    }

    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
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
        return Column(
          children: [
            // Player principal
            player,
            
            // Info de la vidéo (optionnel)
            if (widget.title.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Roboto',
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        );
      },
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
                });
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