/**
 * NBA_CONTENT_DETAIL_SCREEN.DART - ÉCRAN DE DÉTAIL AVEC RECOMMANDATIONS
 * 
 * EXEMPLE D'INTÉGRATION :
 * - Affichage du contenu principal
 * - Section "Contenu similaire" en bas
 * - Tracking automatique des interactions
 * - Navigation fluide vers d'autres contenus
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/nba_content.dart';
import '../components/common/nba_recommendations_carousel.dart';
import '../components/common/unified_like_button.dart';
import '../components/common/unified_video_player.dart';
import '../services/nba_recommendation_service.dart';
import '../services/navigation_service.dart';
import '../composables/use_auth_handler.dart';
import '../components/common/auth_modal.dart';
import '../services/likes_service.dart';
import '../services/share_service.dart';

class NBAContentDetailScreen extends ConsumerStatefulWidget {
  final String contentId;
  final NBAContent? content; // Peut être passé directement

  const NBAContentDetailScreen({
    Key? key,
    required this.contentId,
    this.content,
  }) : super(key: key);

  @override
  ConsumerState<NBAContentDetailScreen> createState() => _NBAContentDetailScreenState();
}

class _NBAContentDetailScreenState extends ConsumerState<NBAContentDetailScreen> {
  NBAContent? _content;
  bool _isLoading = true;
  String? _error;
  bool _showAuthModal = false;
  bool _userLiked = false;

  @override
  void initState() {
    super.initState();
    
    if (widget.content != null) {
      _content = widget.content;
      _isLoading = false;
      _trackContentView();
    } else {
      _loadContent();
    }
  }

  Future<void> _loadContent() async {
    // Simulation de chargement de contenu
    // Dans un vrai cas, cela viendrait d'une API
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Simuler un délai de réseau
      await Future.delayed(const Duration(seconds: 1));
      
      // Créer un contenu NBA d'exemple
      _content = _createSampleContent();
      
      setState(() {
        _isLoading = false;
      });
      
      _trackContentView();
      
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  NBAContent _createSampleContent() {
    // Exemple de contenu NBA avec tags
    return NBAContent(
      id: widget.contentId,
      title: 'LeBron James dépasse Kareem Abdul-Jabbar : Un moment historique',
      description: 'Le roi LeBron James entre dans l\'histoire en devenant le meilleur marqueur de tous les temps en NBA, dépassant le record légendaire de Kareem Abdul-Jabbar avec 38 388 points.',
      type: NBAContentType.highlight,
      imageUrl: 'https://picsum.photos/800/450?random=1',
      videoUrl: 'https://www.youtube.com/watch?v=example',
      tags: [
        const NBATag(
          id: 'lebron_james',
          name: 'LeBron James',
          category: 'player',
          priority: TagPriority.primary,
        ),
        const NBATag(
          id: 'lakers',
          name: 'Los Angeles Lakers',
          category: 'team',
          priority: TagPriority.primary,
        ),
        const NBATag(
          id: 'scoring_record',
          name: 'Record de points',
          category: 'stat',
          priority: TagPriority.secondary,
        ),
        const NBATag(
          id: '2024_season',
          name: 'Saison 2023-2024',
          category: 'season',
          priority: TagPriority.tertiary,
        ),
      ],
      publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
      views: 1250000,
      likes: 45000,
      comments: 3200,
      shares: 8500,
      duration: const Duration(minutes: 3, seconds: 45),
      author: 'NBA Official',
      popularityScore: 95.0,
    );
  }

  void _trackContentView() {
    if (_content != null) {
      ref.read(nbaRecommendationServiceProvider.notifier)
          .trackInteraction(_content!.id, 'view');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading ? _buildLoadingState() :
             _error != null ? _buildErrorState() :
             _buildContentDetail(),
      floatingActionButton: _buildFloatingActionButtons(),
    );
  }

  Widget _buildFloatingActionButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          onPressed: () => NavigationService.pop(),
          heroTag: 'back_fab',
          backgroundColor: Colors.white,
          child: const Icon(LucideIcons.arrowLeft, color: Color(0xFF2D3748)),
        ),
        const SizedBox(height: 16),
        // Bouton Like flottant
        FloatingActionButton(
          onPressed: () => _handleLikeAction(),
          heroTag: 'like_fab',
          backgroundColor: _userLiked ? const Color(0xFFE53E3E) : Colors.white,
          child: Icon(
            _userLiked ? LucideIcons.heart : LucideIcons.heart,
            color: _userLiked ? Colors.white : const Color(0xFFE53E3E),
          ),
        ),
        const SizedBox(height: 16),
        FloatingActionButton(
          onPressed: () => _handleShareAction(),
          heroTag: 'share_fab',
          backgroundColor: const Color(0xFFE53E3E),
          child: const Icon(LucideIcons.share2, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildContentDetail() {
    if (_content == null) return const SizedBox.shrink();

    return CustomScrollView(
      slivers: [
        _buildAppBar(),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMainContent(),
              _buildContentInfo(),
              _buildActions(),
              _buildTags(),
              const SizedBox(height: 32),
              _buildRecommendationsSection(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
        onPressed: () => NavigationService.pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Image de fond
            _content!.imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: _content!.imageUrl!,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => _buildImagePlaceholder(),
                  )
                : _buildImagePlaceholder(),
            
            // Gradient overlay
            Container(
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
            
            // Badge type et durée
            Positioned(
              top: 60,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildTypeBadge(),
                  if (_content!.duration != null) ...[
                    const SizedBox(height: 8),
                    _buildDurationBadge(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: const Color(0xFFF7FAFC),
      child: const Center(
        child: Icon(
          LucideIcons.image,
          size: 64,
          color: Color(0xFFCBD5E0),
        ),
      ),
    );
  }

  Widget _buildTypeBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE53E3E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.zap, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            'Highlight',
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _content!.formattedDuration,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre
          Text(
            _content!.title,
            style: const TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D3748),
              height: 1.3,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Métadonnées
          Row(
            children: [
              const Icon(LucideIcons.user, size: 16, color: Color(0xFF4A5568)),
              const SizedBox(width: 6),
              Text(
                _content!.author ?? 'NBA',
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  color: Color(0xFF4A5568),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 16),
              const Icon(LucideIcons.clock, size: 16, color: Color(0xFF4A5568)),
              const SizedBox(width: 6),
              Text(
                _formatTimeAgo(_content!.publishedAt),
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  color: Color(0xFF4A5568),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContentInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vidéo (si présente)
          if (_content!.videoUrl != null) ...[
            UnifiedVideoPlayer(
              videoUrl: _content!.videoUrl!,
              title: 'Voir la vidéo',
              subtitle: _content!.title,
            ),
            const SizedBox(height: 16),
          ],
          
          // Description
          Text(
            _content!.description,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 16,
              color: Color(0xFF4A5568),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Like
          Expanded(
            child: UnifiedLikeButton(
              type: 'nba_content',
              itemId: _content!.id,
              initialLiked: _content!.isLiked,
              initialCount: _content!.likes,
              showCount: true,
              size: 'medium',
              onAuthRequired: () => setState(() => _showAuthModal = true),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Partage
          IconButton(
            onPressed: _shareContent,
            icon: const Icon(LucideIcons.share),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFF7FAFC),
              padding: const EdgeInsets.all(12),
            ),
          ),
          
          // Commentaires
          IconButton(
            onPressed: _showComments,
            icon: const Icon(LucideIcons.messageCircle),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFF7FAFC),
              padding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTags() {
    if (_content!.tags.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tags',
            style: TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _content!.tags.map((tag) => _buildTagChip(tag)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTagChip(NBATag tag) {
    Color color;
    IconData icon;
    
    switch (tag.category) {
      case 'team':
        color = const Color(0xFFE53E3E);
        icon = LucideIcons.shield;
        break;
      case 'player':
        color = const Color(0xFF3182CE);
        icon = LucideIcons.user;
        break;
      case 'stat':
        color = const Color(0xFF38A169);
        icon = LucideIcons.trendingUp;
        break;
      case 'season':
        color = const Color(0xFF805AD5);
        icon = LucideIcons.calendar;
        break;
      default:
        color = const Color(0xFF718096);
        icon = LucideIcons.tag;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            tag.name,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection() {
    return NBARecommendationsCarousel(
      currentContent: _content!,
      onContentTap: (content) {
        // Navigation vers le nouveau contenu
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => NBAContentDetailScreen(
              contentId: content.id,
              content: content,
            ),
          ),
        );
      },
    );
  }

  void _shareContent() {
    ref.read(nbaRecommendationServiceProvider.notifier)
        .trackInteraction(_content!.id, 'share');
    
    // Implémentation du partage
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Contenu partagé !'),
        backgroundColor: Color(0xFF38A169),
      ),
    );
  }

  void _showComments() {
    ref.read(nbaRecommendationServiceProvider.notifier)
        .trackInteraction(_content!.id, 'comment_view');
    
    // Ouvrir la section commentaires
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildCommentsSheet(),
    );
  }

  Widget _buildCommentsSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
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
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
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
                      '${_content!.comments}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              const Expanded(
                child: Center(
                  child: Text(
                    'Section commentaires à implémenter',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return 'il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else {
      return 'il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    }
  }

  Widget _buildLoadingState() {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE53E3E)),
            ),
            SizedBox(height: 16),
            Text(
              'Chargement du contenu...',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 16,
                color: Color(0xFF4A5568),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                LucideIcons.alertCircle,
                size: 64,
                color: Color(0xFFE53E3E),
              ),
              const SizedBox(height: 16),
              const Text(
                'Erreur de chargement',
                style: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  color: Color(0xFF4A5568),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadContent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53E3E),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLikeAction() async {
    final authState = ref.read(useAuthHandlerProvider);
    
    if (!authState.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connectez-vous pour liker ce contenu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final success = await ref.read(likesProvider.notifier).toggleLike('nba_content', widget.contentId);
      
      if (success) {
        setState(() => _userLiked = !_userLiked);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_userLiked ? '❤️ Contenu ajouté aux favoris' : '💔 Contenu retiré des favoris'),
            backgroundColor: const Color(0xFFE53E3E),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleShareAction() {
    if (_content != null) {
      ref.read(shareServiceProvider).shareContent(
        type: 'nba_content',
        id: widget.contentId,
        title: _content!.title,
        description: _content!.description ?? 'Découvrez ce contenu NBA',
        shareUrl: 'https://new.dinorapp.com/nba/${widget.contentId}',
        imageUrl: _content!.imageUrl,
      );
    }
  }
} 