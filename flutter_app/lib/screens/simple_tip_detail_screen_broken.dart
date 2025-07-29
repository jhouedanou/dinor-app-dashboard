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
import '../components/common/like_button.dart';
import '../components/common/share_modal.dart';
import '../components/common/auth_modal.dart';
import '../components/common/youtube_video_modal.dart';

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
        return;
      }

      // Charger depuis l'API
      final response = await http.get(
        Uri.parse('https://new.dinorapp.com/api/v1/tips/$tipId'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final tipData = data['data'] ?? data;
        
        // Mettre en cache
        await _cacheService.cacheTipDetail(tipId, tipData);
        
        setState(() {
          tip = tipData;
          isLoading = false;
          error = null;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          isLoading = false;
          error = 'Astuce non trouvée';
        });
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [TipDetail] Erreur chargement: $e');
      setState(() {
        isLoading = false;
        error = e.toString();
      });
    }
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
        appBar: AppBar(
          title: const Text('Erreur'),
          backgroundColor: const Color(0xFFE53E3E),
          foregroundColor: Colors.white,
        ),
        body: Center(
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
                'Erreur: $error',
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 16,
                  color: Color(0xFF4A5568),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadTipDetail,
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

    if (tip == null) {
      return const Scaffold(
        body: Center(
          child: Text('Astuce non trouvée'),
        ),
      );
    }

  void _openVideo(String? videoUrl) {
    if (videoUrl == null || videoUrl.isEmpty) {
      print('❌ [TipDetail] URL vidéo vide ou nulle');
      return;
    }
    
    print('🎥 [TipDetail] Ouverture de la vidéo: $videoUrl');
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

    print('🏗️ [TipDetail] build appelé - _showAuthModal: $_showAuthModal, _isShareModalVisible: $_isShareModalVisible, _showVideoModal: $_showVideoModal');
    
    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          body: CustomScrollView(
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
                        _buildSection('Contenu', _buildContent()),
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Modals avec arrière-plan semi-transparent
        if (_isShareModalVisible && _shareData != null)
          Positioned.fill(
            child: Container(
              color: Colors.black54,
              child: ShareModal(
                isOpen: _isShareModalVisible,
                shareData: _shareData!,
                onClose: () {
                  print('📤 [TipDetail] ShareModal onClose appelé');
                  setState(() => _isShareModalVisible = false);
                },
              ),
            ),
          ),
          
        if (_showAuthModal) ...[
          Positioned.fill(
            child: Container(
              color: Colors.black54,
              child: GestureDetector(
                onTap: () {
                  print('🔐 [TipDetail] Clic sur l\'arrière-plan, fermeture AuthModal');
                  setState(() => _showAuthModal = false);
                },
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          Positioned.fill(
            child: AuthModal(
              isOpen: _showAuthModal,
              onClose: () {
                print('🔐 [TipDetail] AuthModal onClose appelé');
                setState(() => _showAuthModal = false);
              },
              onAuthenticated: () {
                print('🔐 [TipDetail] AuthModal onAuthenticated appelé');
                setState(() => _showAuthModal = false);
              },
            ),
          ),
        ],
        
        // Modal vidéo YouTube
        if (_showVideoModal && tip!['video_url'] != null)
          Positioned.fill(
            child: YouTubeVideoModal(
              isOpen: _showVideoModal,
              videoUrl: tip!['video_url'],
              title: _formatText(tip!['title']) ?? 'Vidéo',
              onClose: () {
                print('🎥 [TipDetail] Fermeture de la modal vidéo');
                setState(() => _showVideoModal = false);
              },
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
          child: CachedNetworkImage(
            imageUrl: tip!['featured_image_url'] ?? tip!['image_url'] ?? '/images/default-tip.jpg',
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: const Color(0xFFF7FAFC),
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              color: const Color(0xFFF7FAFC),
              child: const Icon(Icons.lightbulb, size: 64, color: Color(0xFFCBD5E0)),
            ),
          ),
        ),
        // Overlay gradient
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.6),
                ],
              ),
            ),
          ),
        ),
        // Title overlay
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Text(
                            _formatText(tip!['title']) ?? 'Astuce sans titre',
            style: const TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            Icons.trending_up,
            'Difficulté',
            _getDifficultyLabel(tip!['difficulty_level']),
            _getDifficultyColor(tip!['difficulty_level']),
          ),
          _buildStatItem(
            Icons.schedule,
            'Temps estimé',
            '${tip!['estimated_time'] ?? 0} min',
            const Color(0xFFE53E3E),
          ),
          _buildStatItem(
            Icons.favorite,
            'Likes',
            '${tip!['likes_count'] ?? 0}',
            const Color(0xFFE53E3E),
          ),
          _buildStatItem(
            Icons.comment,
            'Commentaires',
            '${tip!['comments_count'] ?? 0}',
            const Color(0xFF38A169),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
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
    );
  }

  Widget _buildSection(String title, Widget content) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }

  Widget _buildContent() {
    final content = tip!['content'];
    if (content == null) return const Text('Aucun contenu disponible');
    
    return HtmlWidget(
      _formatContent(content),
      textStyle: const TextStyle(
        fontFamily: 'Roboto',
        fontSize: 16,
        color: Color(0xFF4A5568),
        height: 1.6,
      ),
    );
  }

  String _formatContent(dynamic content) {
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
      return content.map((item) => _formatContent(item)).join('\n\n');
    }
    
    return content.toString();
  }

  Widget _buildVideoContainer() {
    final videoUrl = tip!['video_url'];
    print('🎥 [TipDetail] _buildVideoContainer appelé avec videoUrl: $videoUrl');
    
    return GestureDetector(
      onTap: () {
        print('🎥 [TipDetail] GestureDetector onTap appelé');
        _openVideo(videoUrl);
      },
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
                    const Color(0xFF1A202C).withOpacity(0.8),
                    const Color(0xFF2D3748).withOpacity(0.6),
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
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Regarder la vidéo',
                    style: TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Appuyez pour ouvrir',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 12,
                      color: Colors.white70,
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

  void _openVideo(String videoUrl) async {
    print('🎥 [TipDetail] _openVideo appelé avec URL: $videoUrl');
    
    if (videoUrl.isEmpty) {
      print('❌ [TipDetail] URL vidéo vide');
      _showSnackBar('URL de la vidéo non disponible', Colors.red);
      return;
    }
    
    // Convertir URL embed en URL normale pour YouTube externe
    final normalUrl = _convertEmbedToNormalUrl(videoUrl);
    print('🔄 [TipDetail] URL convertie: $normalUrl');
    
    try {
      final uri = Uri.parse(normalUrl);
      if (await canLaunchUrl(uri)) {
        print('📺 [TipDetail] Ouverture avec YouTube externe...');
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        print('✅ [TipDetail] Vidéo ouverte avec succès');
      } else {
        print('❌ [TipDetail] Impossible d\'ouvrir l\'URL');
        _showSnackBar('Impossible d\'ouvrir la vidéo', Colors.red);
      }
    } catch (e) {
      print('❌ [TipDetail] Erreur lors de l\'ouverture: $e');
      _showSnackBar('Erreur lors de l\'ouverture de la vidéo', Colors.red);
    }
  }
  
  String _convertEmbedToNormalUrl(String url) {
    // Si c'est une URL embed, la convertir en URL normale
    if (url.contains('/embed/')) {
      final regex = RegExp(r'/embed/([a-zA-Z0-9_-]+)');
      final match = regex.firstMatch(url);
      if (match != null) {
        final videoId = match.group(1);
        return 'https://www.youtube.com/watch?v=$videoId';
      }
    }
    
    // Si c'est déjà une URL normale, la retourner telle quelle
    return url;
  }

  void _shareContent() {
    if (tip == null) return;
    
    final title = _formatText(tip!['title']) ?? 'Astuce Dinor';
          final description = _formatText(tip!['short_description']) ?? _formatText(tip!['description']) ?? 'Découvrez cette astuce sur Dinor';
    final url = 'https://new.dinorapp.com/tips/${widget.id}';
    
    final shareText = '$title\n\n$description\n\nDécouvrez plus d\'astuces sur Dinor:\n$url';
    
    Share.share(shareText, subject: title);
    print('📤 [TipDetail] Contenu partagé: $title');
  }

  void _showShareModalTest() {
    if (tip == null) return;
    
    setState(() {
      _shareData = {
        'title': _formatText(tip!['title']) ?? 'Astuce Dinor',
        'text': _formatText(tip!['short_description']) ?? _formatText(tip!['description']) ?? 'Découvrez cette astuce sur Dinor',
        'description': _formatText(tip!['short_description']) ?? _formatText(tip!['description']) ?? 'Découvrez cette astuce sur Dinor',
        'url': 'https://new.dinorapp.com/tips/${widget.id}',
      };
      _isShareModalVisible = true;
    });
    print('📤 [TipDetail] Modal de partage ouverte');
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildTagsList() {
    final tags = tip!['tags'];
    if (tags == null) return const Text('Aucun tag disponible');

    final tagsList = tags is List ? tags : [tags];
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tagsList.map<Widget>((tag) {
        final tagText = _formatTagText(tag);
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF7FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Text(
            tagText,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 12,
              color: Color(0xFF4A5568),
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
    return Row(
      children: [
        // Like Button
        Expanded(
          child: LikeButton(
            type: 'tip',
            itemId: widget.id,
            initialLiked: false,
            initialCount: tip!['likes_count'] ?? 0,
            showCount: true,
            size: 'medium',
            onAuthRequired: () {
              print('🔐 [TipDetail] onAuthRequired appelé, ouverture de l\'AuthModal');
              setState(() => _showAuthModal = true);
            },
          ),
        ),
        const SizedBox(width: 12),

        // Share Button - Appui court = partage direct, appui long = modal
        IconButton(
          onPressed: _shareContent,
          onLongPress: _showShareModalTest,
          icon: const Icon(
            Icons.share,
            size: 24,
            color: Color(0xFF49454F),
          ),
          tooltip: 'Partager cette astuce (appui long pour plus d\'options)',
        ),
      ],
    );
  }

  void _showShareModal() {
    setState(() {
      _shareData = {
        'title': _formatText(tip!['title']),
        'text': _formatText(tip!['short_description']) ?? 'Découvrez cette astuce : ${_formatText(tip!['title'])}',
        'url': 'https://new.dinorapp.com/tips/${widget.id}',
        'image': tip!['featured_image_url'] ?? tip!['image_url'],
      };
      _isShareModalVisible = true;
    });
  }

  String _getDifficultyLabel(String? difficulty) {
    const labels = {
      'beginner': 'Débutant',
      'easy': 'Facile',
      'medium': 'Intermédiaire',
      'hard': 'Difficile',
      'expert': 'Expert'
    };
    return labels[difficulty] ?? difficulty ?? 'N/A';
  }

  Color _getDifficultyColor(String? difficulty) {
    const colors = {
      'beginner': Color(0xFF38A169),
      'easy': Color(0xFF48BB78),
      'medium': Color(0xFFF4D03F),
      'hard': Color(0xFFE67E22),
      'expert': Color(0xFFE53E3E)
    };
    return colors[difficulty] ?? const Color(0xFF718096);
  }
}