import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import '../services/navigation_service.dart';
import '../services/cache_service.dart';
import '../services/image_service.dart';
import '../components/common/like_button.dart';
import '../components/common/share_modal.dart';
import '../components/common/auth_modal.dart';
import '../components/common/youtube_video_modal.dart';
import '../components/common/comments_section.dart';
import '../components/common/favorite_button.dart';

class SimpleTipDetailScreen extends ConsumerStatefulWidget {
  final String id;
  
  const SimpleTipDetailScreen({Key? key, required this.id}) : super(key: key);

  @override
  ConsumerState<SimpleTipDetailScreen> createState() => _SimpleTipDetailScreenState();
}

class _SimpleTipDetailScreenState extends ConsumerState<SimpleTipDetailScreen> {
  Map<String, dynamic>? tip;
  bool isLoading = true;
  String? error;
  bool _showAuthModal = false;
  bool _isShareModalVisible = false;
  bool _showVideoModal = false;
  bool isFavorite = false;
  Map<String, dynamic>? _shareData;
  
  final CacheService _cacheService = CacheService();

  @override
  void initState() {
    super.initState();
    _loadTipDetail();
  }

  Future<void> _loadTipDetail() async {
    final tipId = widget.id;
    
    try {
      // Vérifier d'abord le cache
      final cachedTip = await _cacheService.getCachedTipDetail(tipId);
      if (cachedTip != null) {
        setState(() {
          tip = cachedTip;
          isLoading = false;
        });
        print('✅ [SimpleTipDetail] Astuce chargée depuis le cache');
        return;
      }

      // Sinon, charger depuis l'API
      print('🔄 [SimpleTipDetail] Chargement depuis l\'API pour ID: $tipId');
      
      final response = await http.get(
        Uri.parse('https://new.dinorapp.com/api/v1/tips/$tipId'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] && data['data'] != null) {
          setState(() {
            tip = data['data'];
            isLoading = false;
          });
          
          // Mettre en cache
          await _cacheService.cacheTipDetail(tipId, data['data']);
          print('✅ [SimpleTipDetail] Astuce chargée et mise en cache');
        } else {
          setState(() {
            error = data['message'] ?? 'Astuce non trouvée';
            isLoading = false;
          });
        }
      } else if (response.statusCode == 404) {
        setState(() {
          error = 'Astuce non trouvée';
          isLoading = false;
        });
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [SimpleTipDetail] Erreur chargement: $e');
      setState(() {
        error = 'Erreur de chargement';
        isLoading = false;
      });
    }
  }

  void _openVideo(String? videoUrl) {
    if (videoUrl == null || videoUrl.isEmpty) {
      print('❌ [SimpleTipDetail] URL vidéo vide ou nulle');
      return;
    }
    
    print('🎥 [SimpleTipDetail] Ouverture de la vidéo: $videoUrl');
    setState(() {
      _showVideoModal = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (error != null) {
      return Scaffold(
        body: Center(
          child: Text('Erreur: $error'),
        ),
      );
    }

    if (tip == null) {
      return const Scaffold(
        body: Center(
          child: Text('Astuce non trouvée'),
        ),
      );
    }

    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          body: _buildContent(),
        ),
        
        // Modal d'authentification
        if (_showAuthModal) ...[
          Positioned.fill(
            child: Container(
              color: Colors.black54,
              child: GestureDetector(
                onTap: () => setState(() => _showAuthModal = false),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          Positioned.fill(
            child: AuthModal(
              isOpen: _showAuthModal,
              onClose: () => setState(() => _showAuthModal = false),
              onAuthenticated: () => setState(() => _showAuthModal = false),
            ),
          ),
        ],
        
        // Modal de partage
        if (_isShareModalVisible && _shareData != null)
          Positioned.fill(
            child: Container(
              color: Colors.black54,
              child: ShareModal(
                isOpen: _isShareModalVisible,
                shareData: _shareData!,
                onClose: () => setState(() => _isShareModalVisible = false),
              ),
            ),
          ),
        
        // Modal vidéo YouTube
        if (_showVideoModal && tip!['video_url'] != null)
          Positioned.fill(
            child: YouTubeVideoModal(
              isOpen: _showVideoModal,
              videoUrl: tip!['video_url'],
              title: _formatText(tip!['title']) ?? 'Vidéo',
              onClose: () => setState(() => _showVideoModal = false),
            ),
          ),
      ],
    );
  }

  Widget _buildContent() {
    return CustomScrollView(
      slivers: [
        // Hero Image
        SliverToBoxAdapter(
          child: _buildHeroImage(),
        ),

        // Tip Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Statistiques
                _buildTipStats(),
                const SizedBox(height: 24),

                // Contenu
                if (tip!['content'] != null) ...[
                  _buildSection('Contenu', _buildContentWidget()),
                  const SizedBox(height: 24),
                ],

                // Vidéo
                if (tip!['video_url'] != null) ...[
                  _buildSection('Vidéo', _buildVideoContainer()),
                  const SizedBox(height: 24),
                ],

                // Tags
                if (tip!['tags'] != null) ...[
                  _buildSection('Tags', _buildTagsList()),
                  const SizedBox(height: 24),
                ],

                // Actions
                _buildActions(),
                const SizedBox(height: 24),

                // Section des commentaires
                CommentsSection(
                  contentType: 'tip',
                  contentId: widget.id,
                  contentTitle: _formatText(tip!['title']) ?? 'Astuce',
                  onAuthRequired: () => setState(() => _showAuthModal = true),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroImage() {
    return Stack(
      children: [
        SizedBox(
          height: 250,
          width: double.infinity,
          child: ImageService.buildCachedNetworkImage(
            imageUrl: tip!['featured_image_url'] ?? tip!['image_url'] ?? '',
            contentType: 'tip',
            fit: BoxFit.cover,
          ),
        ),
        
        // Overlay avec gradient
        Container(
          height: 250,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
        ),
        
        // Bouton favori en haut à droite
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(24),
            ),
            child: FavoriteButton(
              type: 'tip',
              itemId: tip!['id'].toString(),
              initialFavorited: isFavorite,
              showCount: false,
              size: 24,
              onFavoriteChanged: (isFavorited) {
                setState(() {
                  isFavorite = isFavorited;
                });
              },
              onAuthRequired: () => setState(() => _showAuthModal = true),
            ),
          ),
        ),
        
        // Contenu en overlay
        Positioned(
          bottom: 20,
          left: 16,
          right: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatText(tip!['title']) ?? 'Astuce',
                style: const TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (tip!['summary'] != null) ...[
                const SizedBox(height: 8),
                Text(
                  _formatText(tip!['summary']),
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTipStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStatItem(
            Icons.lightbulb,
            'Catégorie',
            _formatText(tip!['category']) ?? 'Astuce',
            const Color(0xFFF4D03F),
          ),
          const SizedBox(width: 16),
          _buildStatItem(
            Icons.favorite,
            'Likes',
            '${tip!['likes_count'] ?? 0}',
            const Color(0xFFE53E3E),
          ),
          const SizedBox(width: 16),
          _buildStatItem(
            Icons.visibility,
            'Vues',
            '${tip!['views_count'] ?? 0}',
            const Color(0xFF4A5568),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 12,
              color: Color(0xFF718096),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 12),
        content,
      ],
    );
  }

  Widget _buildContentWidget() {
    final content = tip!['content'];
    if (content == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: HtmlWidget(
        _formatTipContent(content),
        textStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 16,
          color: Color(0xFF4A5568),
          height: 1.6,
        ),
      ),
    );
  }

  String _formatTipContent(dynamic content) {
    if (content == null) return '';
    
    // Si c'est déjà une chaîne, la retourner
    if (content is String) return content;
    
    // Si c'est un Map avec une propriété 'text'
    if (content is Map && content['text'] != null) {
      return content['text'];
    }
    
    // Si c'est un Map avec une propriété 'content'
    if (content is Map && content['content'] != null) {
      return content['content'];
    }
    
    // Si c'est un Map avec une propriété 'description'
    if (content is Map && content['description'] != null) {
      return content['description'];
    }
    
    // Si c'est une liste, joindre les éléments
    if (content is List) {
      return content.map((item) => _formatTipContent(item)).join('\n\n');
    }
    
    return content.toString();
  }

  Widget _buildVideoContainer() {
    final videoUrl = tip!['video_url'];
    
    return GestureDetector(
      onTap: () => _openVideo(videoUrl),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: const Color(0xFFF7FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Stack(
          children: [
            // Arrière-plan avec dégradé
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF667EEA).withOpacity(0.8),
                    const Color(0xFF764BA2).withOpacity(0.8),
                  ],
                ),
              ),
            ),
            
            // Contenu centré
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      size: 48,
                      color: Color(0xFFE53E3E),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Regarder la vidéo',
                    style: TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsList() {
    final tags = tip!['tags'];
    if (tags == null) return const SizedBox.shrink();
    
    final tagsList = tags is List ? tags : [tags];
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tagsList.map<Widget>((tag) {
        final tagText = _formatTagText(tag);
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF4D03F).withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFF4D03F),
              width: 1,
            ),
          ),
          child: Text(
            tagText,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2D3748),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _formatTagText(dynamic tag) {
    if (tag == null) return '';
    
    // Si c'est déjà une chaîne, la retourner
    if (tag is String) return tag;
    
    // Si c'est un Map, essayer d'extraire le nom
    if (tag is Map) {
      return tag['name'] ?? tag['text'] ?? tag['title'] ?? tag['label'] ?? tag.toString();
    }
    
    // Si c'est une liste, joindre les éléments
    if (tag is List) {
      return tag.map((item) => _formatTagText(item)).join(', ');
    }
    
    return tag.toString();
  }

  String _formatText(dynamic text) {
    if (text == null) return '';
    
    // Si c'est déjà une chaîne, la retourner
    if (text is String) return text;
    
    // Si c'est un Map, essayer d'extraire le texte
    if (text is Map) {
      return text['text'] ?? text['content'] ?? text['title'] ?? text['name'] ?? text.toString();
    }
    
    // Si c'est une liste, joindre les éléments
    if (text is List) {
      return text.map((item) => _formatText(item)).join(' ');
    }
    
    return text.toString();
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Like Button
          Expanded(
            child: LikeButton(
              type: 'tip',
              itemId: widget.id,
              initialLiked: tip!['user_liked'] ?? false,
              initialCount: tip!['likes_count'] ?? 0,
              showCount: true,
              size: 'medium',
              variant: 'standard',
              onAuthRequired: () => setState(() => _showAuthModal = true),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Share Button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _shareData = {
                    'title': _formatText(tip!['title']) ?? 'Astuce Dinor',
                    'text': 'Découvrez cette astuce sur Dinor',
                    'url': 'https://new.dinor.app/tip/${widget.id}',
                    'type': 'tip',
                    'id': widget.id,
                  };
                  _isShareModalVisible = true;
                });
              },
              icon: const Icon(Icons.share, size: 18),
              label: const Text('Partager'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A5568),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}