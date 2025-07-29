/**
 * VIDEO_MODAL.DART - MODAL DE LECTURE VIDÉO YOUTUBE INTÉGRÉE
 * 
 * FONCTIONNALITÉS :
 * - Lecture YouTube intégrée avec WebView
 * - Modal plein écran avec fermeture
 * - Support des URLs embed et normales
 * - Pas besoin de l'app YouTube externe
 */

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class VideoModal extends StatefulWidget {
  final bool isOpen;
  final String videoUrl;
  final String title;
  final VoidCallback? onClose;

  const VideoModal({
    Key? key,
    required this.isOpen,
    required this.videoUrl,
    required this.title,
    this.onClose,
  }) : super(key: key);

  @override
  State<VideoModal> createState() => _VideoModalState();
}

class _VideoModalState extends State<VideoModal> {
  late WebViewController _controller;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.isOpen) {
      _initializeWebView();
    }
  }

  @override
  void didUpdateWidget(VideoModal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOpen && !oldWidget.isOpen) {
      _initializeWebView();
    }
  }

  void _initializeWebView() {
    print('📺 [VideoModal] Initialisation WebView pour: ${widget.title}');
    print('📺 [VideoModal] URL: ${widget.videoUrl}');
    
    // Convertir en URL embed si nécessaire
    final embedUrl = _convertToEmbedUrl(widget.videoUrl);
    print('📺 [VideoModal] URL embed: $embedUrl');
    
    try {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              print('📺 [VideoModal] Page en cours de chargement: $url');
              if (mounted) {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
              }
            },
            onPageFinished: (String url) {
              print('✅ [VideoModal] Page chargée: $url');
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
              }
            },
            onWebResourceError: (WebResourceError error) {
              print('❌ [VideoModal] Erreur WebView: ${error.description}');
              if (mounted) {
                setState(() {
                  _isLoading = false;
                  _error = error.description;
                });
              }
            },
          ),
        )
        ..loadRequest(Uri.parse(embedUrl));
      
      print('✅ [VideoModal] WebViewController initialisé');
    } catch (e) {
      print('❌ [VideoModal] Erreur initialisation WebView: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  String _convertToEmbedUrl(String url) {
    print('🔄 [VideoModal] Conversion vers URL embed: $url');
    
    // Si c'est déjà une URL embed, l'utiliser telle quelle
    if (url.contains('/embed/')) {
      print('✅ [VideoModal] URL embed conservée: $url');
      return url;
    }
    
    // Si c'est une URL watch normale, la convertir en embed
    if (url.contains('watch?v=')) {
      final regex = RegExp(r'[?&]v=([a-zA-Z0-9_-]+)');
      final match = regex.firstMatch(url);
      if (match != null) {
        final videoId = match.group(1);
        final embedUrl = 'https://www.youtube.com/embed/$videoId?autoplay=1&rel=0&modestbranding=1';
        print('✅ [VideoModal] URL convertie en embed: $embedUrl');
        return embedUrl;
      }
    }
    
    // Si c'est une URL youtu.be, la convertir en embed
    if (url.contains('youtu.be/')) {
      final regex = RegExp(r'youtu\.be/([a-zA-Z0-9_-]+)');
      final match = regex.firstMatch(url);
      if (match != null) {
        final videoId = match.group(1);
        final embedUrl = 'https://www.youtube.com/embed/$videoId?autoplay=1&rel=0&modestbranding=1';
        print('✅ [VideoModal] URL youtu.be convertie: $embedUrl');
        return embedUrl;
      }
    }
    
    // Si aucun format reconnu, essayer de l'utiliser tel quel
    print('⚠️ [VideoModal] Format URL non reconnu, utilisation directe: $url');
    return url;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isOpen) return const SizedBox.shrink();

    return Material(
      color: Colors.transparent,
      child: Container(
        color: Colors.black87,
        child: SafeArea(
          child: Column(
            children: [
              // Header avec titre et bouton fermer
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: Colors.black,
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
                    IconButton(
                      onPressed: () {
                        print('📺 [VideoModal] Fermeture demandée');
                        widget.onClose?.call();
                      },
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Contenu vidéo
              Expanded(
                child: _buildVideoContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoContent() {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.white54,
              ),
              const SizedBox(height: 16),
              const Text(
                'Impossible de charger la vidéo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'OpenSans',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                  fontFamily: 'Roboto',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  print('📺 [VideoModal] Tentative de rechargement');
                  _initializeWebView();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53E3E),
                ),
                child: const Text(
                  'Réessayer',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        // WebView
        WebViewWidget(controller: _controller),
        
        // Indicateur de chargement
        if (_isLoading)
          Container(
            color: Colors.black,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE53E3E)),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Chargement de la vidéo...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
} 