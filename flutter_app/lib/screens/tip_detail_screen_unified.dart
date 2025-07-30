import '../services/navigation_service.dart';
/**
 * TIP_DETAIL_SCREEN_UNIFIED.DART - VERSION UNIFIÉE DU DÉTAIL ASTUCE
 * - Utilise les nouveaux composants unifiés
 * - Interface cohérente avec les autres types de contenu
 * - Pagination des commentaires intégrée
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

// Components unifiés
import '../components/common/accordion.dart';
import '../components/common/unified_content_header.dart';
import '../components/common/unified_video_player.dart';
import '../components/common/unified_comments_section.dart';
import '../components/common/unified_content_actions.dart';

// Services
import '../services/api_service.dart';

class TipDetailScreenUnified extends ConsumerStatefulWidget {
  final String id;
  
  const TipDetailScreenUnified({super.key, required this.id});

  @override
  ConsumerState<TipDetailScreenUnified> createState() => _TipDetailScreenUnifiedState();
}

class _TipDetailScreenUnifiedState extends ConsumerState<TipDetailScreenUnified> with AutomaticKeepAliveClientMixin {
  Map<String, dynamic>? _tip;
  bool _loading = true;
  bool _userLiked = false;
  String? _error;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadTip();
  }

  Future<void> _loadTip({bool forceRefresh = false}) async {
    try {
      setState(() => _loading = true);
      
      final apiService = ApiService();
      final data = forceRefresh 
        ? await apiService.request('/tips/${widget.id}', forceRefresh: true)
        : await apiService.get('/tips/${widget.id}');
        
      if (data['success']) {
        setState(() {
          _tip = data['data'];
          _loading = false;
        });
        
        await _checkUserLike();
      } else {
        setState(() {
          _error = data['message'] ?? 'Erreur lors du chargement';
          _loading = false;
        });
      }
    } catch (error) {
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  Future<void> _checkUserLike() async {
    // TODO: Implémenter la vérification du like utilisateur
    setState(() => _userLiked = false);
  }

  String _getDifficultyLabel(String difficulty) {
    const labels = {
      'beginner': 'Débutant',
      'easy': 'Facile',
      'medium': 'Intermédiaire',
      'hard': 'Difficile',
      'expert': 'Expert'
    };
    return labels[difficulty] ?? difficulty;
  }

  String _getTypeLabel(String type) {
    const labels = {
      'cooking': 'Cuisine',
      'preparation': 'Préparation',
      'storage': 'Conservation',
      'technique': 'Technique',
      'equipment': 'Équipement'
    };
    return labels[type] ?? type;
  }

  String _formatTipContent(dynamic content) {
    if (content == null) return '';
    
    if (content is String) return content;
    
    if (content is Map && content['text'] != null) {
      return content['text'];
    }
    
    if (content is Map && content['content'] != null) {
      return content['content'];
    }
    
    if (content is Map && content['description'] != null) {
      return content['description'];
    }
    
    if (content is List) {
      return content.map((item) => _formatTipContent(item)).join('\n\n');
    }
    
    return content.toString();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: _loading
        ? _buildLoadingState()
        : _error != null
          ? _buildErrorState()
          : _tip == null
            ? _buildNotFoundState()
            : _buildTipContent(),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Chargement de l\'astuce...',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.alertCircle,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Erreur lors du chargement',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Une erreur est survenue',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _loadTip(),
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotFoundState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.alertCircle,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Astuce introuvable',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            'L\'astuce demandée n\'existe pas ou a été supprimée.',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => NavigationService.pop(),
            child: const Text('Retour'),
          ),
        ],
      ),
    );
  }

  Widget _buildTipContent() {
    return CustomScrollView(
      slivers: [
        // Hero Image avec composant unifié
        SliverToBoxAdapter(
          child: UnifiedContentHeader(
            imageUrl: _tip!['featured_image_url'] ?? '',
            contentType: 'tip',
            customOverlay: Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  if (_tip!['difficulty'] != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4D03F).withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getDifficultyLabel(_tip!['difficulty']),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (_tip!['type'] != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getTypeLabel(_tip!['type']),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),

        // Tip Info
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tip Stats avec composant unifié
                UnifiedContentStats(
                  stats: [
                    {
                      'icon': LucideIcons.star,
                      'text': _getDifficultyLabel(_tip!['difficulty'] ?? 'N/A'),
                    },
                    {
                      'icon': LucideIcons.tag,
                      'text': _getTypeLabel(_tip!['type'] ?? 'N/A'),
                    },
                    {
                      'icon': LucideIcons.heart,
                      'text': '${_tip!['likes_count'] ?? 0}',
                    },
                    {
                      'icon': LucideIcons.messageCircle,
                      'text': '${_tip!['comments_count'] ?? 0}',
                    },
                  ],
                ),
                const SizedBox(height: 24),

                // Titre de l'astuce
                Text(
                  _tip!['title'] ?? 'Sans titre',
                  style: const TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 16),

                // Description courte
                if (_tip!['short_description'] != null) ...[
                  _buildSection(
                    'Description',
                    Text(
                      _tip!['short_description'],
                      style: const TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 16,
                        color: Color(0xFF4A5568),
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Vidéo explicative avec composant unifié
                if (_tip!['video_url'] != null) ...[
                  _buildSection(
                    'Vidéo explicative',
                    UnifiedVideoPlayer(
                      videoUrl: _tip!['video_url'],
                      title: 'Voir la vidéo explicative',
                      subtitle: 'Appuyez pour ouvrir',
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Tip Sections
                _buildTipSections(),

                // Tip Actions avec composant unifié
                const SizedBox(height: 24),
                UnifiedContentActions(
                  contentType: 'tip',
                  contentId: widget.id,
                  title: _tip!['title'] ?? 'Astuce',
                  description: _tip!['short_description'] ?? 'Découvrez cette astuce : ${_tip!['title']}',
                  shareUrl: 'https://new.dinorapp.com/tips/${widget.id}',
                  imageUrl: _tip!['featured_image_url'],
                  initialLiked: _userLiked,
                  initialLikeCount: _tip!['likes_count'] ?? 0,
                  onRefresh: () => _loadTip(forceRefresh: true),
                  isLoading: _loading,
                ),

                // Comments avec composant unifié
                const SizedBox(height: 24),
                UnifiedCommentsSection(
                  contentType: 'tip',
                  contentId: widget.id,
                  contentTitle: _tip!['title'] ?? 'Astuce',
                ),
              ],
            ),
          ),
        ),
      ],
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
        const SizedBox(height: 16),
        content,
      ],
    );
  }

  Widget _buildTipSections() {
    return Column(
      children: [
        // Content Accordion
        if (_tip!['content'] != null)
          Accordion(
            title: 'Contenu',
            initiallyOpen: true,
            child: HtmlWidget(
              _formatTipContent(_tip!['content']),
              textStyle: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 16,
                color: Color(0xFF4A5568),
                height: 1.6,
              ),
            ),
          ),
      ],
    );
  }
}