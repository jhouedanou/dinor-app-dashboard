/**
 * YOUTUBE_VIDEO_MODAL.DART - MODAL VIDÉO YOUTUBE OPTIMISÉE
 * 
 * FONCTIONNALITÉS :
 * - Modal plein écran avec lecteur YouTube natif
 * - Contrôles de lecture optimisés
 * - Support des gestes pour fermer
 * - Performance améliorée vs WebView
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'youtube_video_player.dart';

class YouTubeVideoModal extends StatefulWidget {
  final bool isOpen;
  final String videoUrl;
  final String title;
  final VoidCallback? onClose;

  const YouTubeVideoModal({
    Key? key,
    required this.isOpen,
    required this.videoUrl,
    required this.title,
    this.onClose,
  }) : super(key: key);

  @override
  State<YouTubeVideoModal> createState() => _YouTubeVideoModalState();
}

class _YouTubeVideoModalState extends State<YouTubeVideoModal>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  final GlobalKey<YouTubeVideoPlayerState> _playerKey = GlobalKey<YouTubeVideoPlayerState>();

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    if (widget.isOpen) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(YouTubeVideoModal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOpen && !oldWidget.isOpen) {
      _animationController.forward();
    } else if (!widget.isOpen && oldWidget.isOpen) {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleClose() {
    print('📺 [YouTubeVideoModal] Fermeture demandée');
    
    // Arrêter la vidéo avant de fermer
    try {
      final playerState = _playerKey.currentState;
      if (playerState != null) {
        playerState.pause();
        print('⏸️ [YouTubeVideoModal] Vidéo mise en pause');
      }
    } catch (e) {
      print('⚠️ [YouTubeVideoModal] Erreur lors de la pause: $e');
    }
    
    widget.onClose?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isOpen) return const SizedBox.shrink();

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (didPop) _handleClose();
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Material(
            color: Colors.transparent,
            child: Container(
              color: Colors.black.withOpacity(0.95 * _opacityAnimation.value),
              child: SafeArea(
                child: GestureDetector(
                  onTap: _handleClose,
                  child: Container(
                    color: Colors.transparent,
                    child: Center(
                      child: GestureDetector(
                        onTap: () {}, // Empêche la fermeture quand on tape sur le player
                        child: Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Container(
                            margin: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Header avec titre et bouton fermer
                                _buildHeader(),
                                
                                // Player vidéo
                                _buildVideoPlayer(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        border: Border(
          bottom: BorderSide(color: Colors.white24, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'OpenSans',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              onPressed: _handleClose,
              icon: const Icon(
                Icons.close,
                color: Colors.white,
                size: 20,
              ),
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(
                minWidth: 36,
                minHeight: 36,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width - 40,
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        child: YouTubeVideoPlayer(
          key: _playerKey,
          videoUrl: widget.videoUrl,
          title: '', // Pas besoin du titre ici, il est dans le header
          autoPlay: true,
          showControls: true,
          onReady: () {
            print('✅ [YouTubeVideoModal] Player ready dans la modal');
          },
          onPause: () {
            print('⏸️ [YouTubeVideoModal] Vidéo mise en pause par le player');
          },
        ),
      ),
    );
  }
}