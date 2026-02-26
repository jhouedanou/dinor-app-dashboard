/// NBA_RECOMMENDATIONS_CAROUSEL.DART - CARROUSEL DE RECOMMANDATIONS NBA
/// 
/// FONCTIONNALITÉS :
/// - Affichage horizontal avec 3-4 suggestions visibles
/// - Métadonnées : titre, type, équipe, durée
/// - Tracking des interactions pour améliorer l'algorithme
/// - Animation fluide et design moderne
/// - Support de tous les types de contenu NBA
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../models/nba_content.dart';
import '../../services/nba_recommendation_service.dart';
import '../../services/navigation_service.dart';

class NBARecommendationsCarousel extends ConsumerStatefulWidget {
  final NBAContent currentContent;
  final Function(NBAContent)? onContentTap;
  final bool showTitle;
  final EdgeInsets? padding;

  const NBARecommendationsCarousel({
    super.key,
    required this.currentContent,
    this.onContentTap,
    this.showTitle = true,
    this.padding,
  });

  @override
  ConsumerState<NBARecommendationsCarousel> createState() => _NBARecommendationsCarouselState();
}

class _NBARecommendationsCarouselState extends ConsumerState<NBARecommendationsCarousel> {
  @override
  void initState() {
    super.initState();
    
    // Générer les recommandations au chargement
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(nbaRecommendationServiceProvider.notifier)
          .generateRecommendations(widget.currentContent);
    });
  }

  @override
  Widget build(BuildContext context) {
    final recommendationState = ref.watch(nbaRecommendationServiceProvider);
    
    if (recommendationState.isLoading) {
      return _buildLoadingState();
    }
    
    if (recommendationState.error != null) {
      return _buildErrorState(recommendationState.error!);
    }
    
    if (recommendationState.recommendations.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return _buildRecommendationsSection(recommendationState.recommendations);
  }

  Widget _buildRecommendationsSection(List<NBARecommendation> recommendations) {
    return Container(
      padding: widget.padding ?? const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showTitle) _buildSectionHeader(),
          const SizedBox(height: 16),
          _buildCarousel(recommendations),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE53E3E).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              LucideIcons.sparkles,
              color: Color(0xFFE53E3E),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Contenu similaire',
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
                Text(
                  'Basé sur vos centres d\'intérêt',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 12,
                    color: Color(0xFF4A5568),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarousel(List<NBARecommendation> recommendations) {
    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: recommendations.length,
        itemBuilder: (context, index) {
          final recommendation = recommendations[index];
          return _buildRecommendationCard(recommendation);
        },
      ),
    );
  }

  Widget _buildRecommendationCard(NBARecommendation recommendation) {
    final content = recommendation.content;
    
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () => _handleContentTap(content),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCardImage(content),
              _buildCardContent(content, recommendation),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardImage(NBAContent content) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: content.imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: content.imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => _buildImagePlaceholder(),
                    errorWidget: (context, url, error) => _buildImagePlaceholder(),
                  )
                : _buildImagePlaceholder(),
          ),
        ),
        
        // Type badge
        Positioned(
          top: 8,
          left: 8,
          child: _buildTypeBadge(content.type),
        ),
        
        // Duration badge (pour les vidéos)
        if (content.duration != null)
          Positioned(
            bottom: 8,
            right: 8,
            child: _buildDurationBadge(content.formattedDuration),
          ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: const Color(0xFFF7FAFC),
      child: const Center(
        child: Icon(
          LucideIcons.image,
          size: 32,
          color: Color(0xFFCBD5E0),
        ),
      ),
    );
  }

  Widget _buildTypeBadge(NBAContentType type) {
    IconData icon;
    String label;
    Color color;

    switch (type) {
      case NBAContentType.video:
        icon = LucideIcons.play;
        label = 'Vidéo';
        color = const Color(0xFFE53E3E);
        break;
      case NBAContentType.highlight:
        icon = LucideIcons.zap;
        label = 'Highlight';
        color = const Color(0xFFF6AD55);
        break;
      case NBAContentType.article:
        icon = LucideIcons.fileText;
        label = 'Article';
        color = const Color(0xFF4299E1);
        break;
      case NBAContentType.analysis:
        icon = LucideIcons.trendingUp;
        label = 'Analyse';
        color = const Color(0xFF38B2AC);
        break;
      case NBAContentType.news:
        icon = LucideIcons.newspaper;
        label = 'News';
        color = const Color(0xFF805AD5);
        break;
      case NBAContentType.interview:
        icon = LucideIcons.mic;
        label = 'Interview';
        color = const Color(0xFFED8936);
        break;
      case NBAContentType.recap:
        icon = LucideIcons.clock;
        label = 'Récap';
        color = const Color(0xFF48BB78);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: Colors.white),
          const SizedBox(width: 3),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationBadge(String duration) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        duration,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildCardContent(NBAContent content, NBARecommendation recommendation) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre
            Text(
              content.title,
              style: const TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 6),
            
            // Équipe/Joueur principal
            if (content.primaryTeam != null || content.primaryPlayer != null)
              _buildPrimaryInfo(content),
            
            const Spacer(),
            
            // Raison de la recommandation
            _buildRecommendationReason(recommendation),
            
            const SizedBox(height: 6),
            
            // Stats
            _buildCardStats(content),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryInfo(NBAContent content) {
    String info = '';
    IconData icon = LucideIcons.info;
    
    if (content.primaryTeam != null) {
      info = content.primaryTeam!;
      icon = LucideIcons.shield;
    } else if (content.primaryPlayer != null) {
      info = content.primaryPlayer!;
      icon = LucideIcons.user;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 12, color: const Color(0xFF4A5568)),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              info,
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 11,
                color: Color(0xFF4A5568),
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationReason(NBARecommendation recommendation) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFE53E3E).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        recommendation.reason,
        style: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 9,
          color: Color(0xFFE53E3E),
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildCardStats(NBAContent content) {
    return Row(
      children: [
        // Vues
        _buildStatItem(LucideIcons.eye, _formatNumber(content.views)),
        const SizedBox(width: 8),
        // Likes
        _buildStatItem(LucideIcons.heart, _formatNumber(content.likes)),
        
        const Spacer(),
        
        // Date
        Text(
          _formatDate(content.publishedAt),
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 9,
            color: Color(0xFF718096),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 10, color: const Color(0xFF718096)),
        const SizedBox(width: 2),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 9,
            color: Color(0xFF718096),
          ),
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}j';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inMinutes}m';
    }
  }

  void _handleContentTap(NBAContent content) {
    // Tracking de l'interaction
    ref.read(nbaRecommendationServiceProvider.notifier)
        .trackInteraction(content.id, 'click');
    
    // Callback personnalisé ou navigation par défaut
    if (widget.onContentTap != null) {
      widget.onContentTap!(content);
    } else {
      _navigateToContent(content);
    }
  }

  void _navigateToContent(NBAContent content) {
    // Navigation selon le type de contenu
    switch (content.type) {
      case NBAContentType.video:
      case NBAContentType.highlight:
        // Naviguer vers lecteur vidéo
        NavigationService.pushNamed('/video/${content.id}');
        break;
      case NBAContentType.article:
      case NBAContentType.analysis:
      case NBAContentType.news:
        // Naviguer vers article
        NavigationService.pushNamed('/article/${content.id}');
        break;
      default:
        // Navigation générique
        NavigationService.pushNamed('/content/${content.id}');
    }
  }

  Widget _buildLoadingState() {
    return Container(
      padding: widget.padding ?? const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showTitle) _buildSectionHeader(),
          const SizedBox(height: 16),
          SizedBox(
            height: 240,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 4,
              itemBuilder: (context, index) => _buildLoadingCard(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder avec shimmer
          Container(
            height: 100,
            decoration: const BoxDecoration(
              color: Color(0xFFF7FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE53E3E)),
                strokeWidth: 2,
              ),
            ),
          ),
          
          // Content placeholder
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 12,
                    width: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    height: 8,
                    width: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(
            LucideIcons.alertCircle,
            color: Color(0xFFE53E3E),
            size: 20,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Erreur lors du chargement des recommandations',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 12,
                color: Color(0xFF4A5568),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(nbaRecommendationServiceProvider.notifier)
                  .generateRecommendations(widget.currentContent);
            },
            child: const Text(
              'Réessayer',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 12,
                color: Color(0xFFE53E3E),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 