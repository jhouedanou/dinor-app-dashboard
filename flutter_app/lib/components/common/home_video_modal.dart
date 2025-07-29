/**
 * HOME_VIDEO_MODAL.DART - MODAL VIDÉO POUR LA PAGE D'ACCUEIL
 * 
 * FONCTIONNALITÉS :
 * - Modal optimisé pour les vidéos Dinor TV de la page d'accueil
 * - Interface simplifiée et élégante
 * - Fermeture automatique de la vidéo
 * - Design cohérent avec l'application
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'youtube_video_player.dart';

class HomeVideoModal extends StatefulWidget {
  final bool isOpen;
  final String videoUrl;
  final String title;
  final String? description;
  final VoidCallback? onClose;

  const HomeVideoModal({
    Key? key,
    required this.isOpen,
    required this.videoUrl,
    required this.title,
    this.description,
    this.onClose,
  }) : super(key: key);

  @override
  State<HomeVideoModal> createState() => _HomeVideoModalState();
}

class _HomeVideoModalState extends State<HomeVideoModal>
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
  void didUpdateWidget(HomeVideoModal oldWidget) {
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
    print('📺 [HomeVideoModal] Fermeture demandée');
    
    // Arrêter la vidéo avant de fermer
    try {
      final playerState = _playerKey.currentState;
      if (playerState != null) {
        playerState.pause();
        print('⏸️ [HomeVideoModal] Vidéo mise en pause');
      }
    } catch (e) {
      print('⚠️ [HomeVideoModal] Erreur lors de la pause: $e');
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
                        onTap: () {}, // Empêche la fermeture quand on tape sur le contenu
                        child: Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Container(
                            margin: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(16),
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
                                
                                // Description (optionnelle)
                                if (widget.description != null && widget.description!.isNotEmpty)
                                  _buildDescription(),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        border: Border(
          bottom: BorderSide(color: Colors.white24, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dinor TV',
                  style: const TextStyle(
                    color: Color(0xFFE53E3E),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'OpenSans',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'OpenSans',
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
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
                minWidth: 40,
                minHeight: 40,
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
        maxWidth: MediaQuery.of(context).size.width - 32,
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
        child: YouTubeVideoPlayer(
          key: _playerKey,
          videoUrl: widget.videoUrl,
          title: '', // Pas besoin du titre ici, il est dans le header
          autoPlay: true,
          showControls: true,
          onReady: () {
            print('✅ [HomeVideoModal] Player ready');
          },
          onPause: () {
            print('⏸️ [HomeVideoModal] Vidéo mise en pause par le player');
          },
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: 'OpenSans',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.description!,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'Roboto',
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
} 