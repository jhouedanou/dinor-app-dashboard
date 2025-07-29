import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../services/navigation_service.dart';
import '../services/cache_service.dart';
import '../services/image_service.dart';
import '../components/common/favorite_button.dart';
import '../components/common/auth_modal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SimpleEventDetailScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> arguments;

  const SimpleEventDetailScreen({Key? key, required this.arguments}) : super(key: key);

  @override
  ConsumerState<SimpleEventDetailScreen> createState() => _SimpleEventDetailScreenState();
}

class _SimpleEventDetailScreenState extends ConsumerState<SimpleEventDetailScreen> {
  Map<String, dynamic>? event;
  bool isLoading = true;
  String? error;
  bool isLiked = false;
  bool isFavorite = false;
  bool _showAuthModal = false;

  final CacheService _cacheService = CacheService();

  @override
  void initState() {
    super.initState();
    _loadEventDetail();
  }

  Future<void> _loadEventDetail() async {
    final eventId = widget.arguments['id'] as String;
    
    try {
      // Vérifier d'abord le cache
      final cachedEvent = await _cacheService.getCachedEventDetail(eventId);
      if (cachedEvent != null) {
        setState(() {
          event = cachedEvent;
          isLoading = false;
        });
        return;
      }

      // Charger depuis l'API
      final response = await http.get(
        Uri.parse('https://new.dinorapp.com/api/v1/events/$eventId'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final eventData = data['data'] ?? data;
        
        // Mettre en cache
        await _cacheService.cacheEventDetail(eventId, eventData);
        
        setState(() {
          event = eventData;
          isLoading = false;
          error = null;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          isLoading = false;
          error = 'Événement non trouvé';
        });
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [EventDetail] Erreur chargement: $e');
      setState(() {
        isLoading = false;
        error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE53E3E)),
              ),
            )
          : error != null
              ? _buildErrorWidget()
              : event != null
                  ? _buildEventDetail()
                  : const Center(child: Text('Événement non trouvé')),
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
              onAuthenticated: () async {
                setState(() => _showAuthModal = false);
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE53E3E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => NavigationService.pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
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
                error == 'Événement non trouvé' ? 'Événement non trouvé' : 'Erreur de chargement',
                style: const TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                error == 'Événement non trouvé' 
                    ? 'Cet événement n\'existe pas ou a été supprimé.'
                    : 'Impossible de charger les détails de l\'événement.',
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 16,
                  color: Color(0xFF718096),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadEventDetail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53E3E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventDetail() {
    return CustomScrollView(
      slivers: [
        // AppBar avec image hero
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          backgroundColor: const Color(0xFFE53E3E),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => NavigationService.pop(),
          ),
          actions: [
            FavoriteButton(
              type: 'event',
              itemId: event!['id'].toString(),
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
            IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              onPressed: _shareEvent,
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              children: [
                // Image de fond
                Positioned.fill(
                  child: ImageService.buildNetworkImage(
                    imageUrl: event!['image_url'] ?? '',
                    contentType: 'event',
                    fit: BoxFit.cover,
                  ),
                ),
                // Gradient overlay
                Positioned.fill(
                  child: Container(
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
                ),
                // Titre et description en bas
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event!['title'] ?? 'Sans titre',
                        style: const TextStyle(
                          fontFamily: 'OpenSans',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (event!['short_description'] != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          event!['short_description'],
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
            ),
          ),
        ),

        // Contenu principal
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Statistiques
                _buildEventStats(),
                const SizedBox(height: 24),

                // Détails de l'événement
                if (event!['description'] != null || event!['start_date'] != null || event!['location'] != null) ...[
                  _buildSection('Détails', _buildEventDetails()),
                  const SizedBox(height: 24),
                ],

                // Vidéo
                if (event!['video_url'] != null) ...[
                  _buildSection('Vidéo', _buildVideoContainer()),
                  const SizedBox(height: 24),
                ],

                // Tags
                if (event!['tags'] != null) ...[
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
    );
  }

  Widget _buildEventStats() {
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
            Icons.calendar_today,
            'Date de début',
            _formatDate(event!['start_date']),
            const Color(0xFFE53E3E),
          ),
          _buildStatItem(
            Icons.location_on,
            'Lieu',
            event!['location'] ?? 'Non spécifié',
            const Color(0xFF38A169),
          ),
          _buildStatItem(
            Icons.info,
            'Statut',
            _getStatusLabel(event!['status']),
            _getStatusColor(event!['status']),
          ),
          _buildStatItem(
            Icons.favorite,
            'Likes',
            '${event!['likes_count'] ?? 0}',
            const Color(0xFFE53E3E),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 10,
              color: Color(0xFF718096),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
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

  Widget _buildEventDetails() {
    return Column(
      children: [
        if (event!['description'] != null) ...[
          _buildDetailItem('Description', event!['description']),
          const SizedBox(height: 16),
        ],
        if (event!['start_date'] != null) ...[
          _buildDetailItem('Date de début', _formatDate(event!['start_date'])),
          const SizedBox(height: 16),
        ],
        if (event!['end_date'] != null) ...[
          _buildDetailItem('Date de fin', _formatDate(event!['end_date'])),
          const SizedBox(height: 16),
        ],
        if (event!['location'] != null) ...[
          _buildDetailItem('Lieu', event!['location']),
          const SizedBox(height: 16),
        ],
        if (event!['status'] != null) ...[
          _buildDetailItem('Statut', _getStatusLabel(event!['status'])),
        ],
      ],
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14,
              color: Color(0xFF4A5568),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoContainer() {
    final videoUrl = event!['video_url'];
    
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

  Widget _buildTagsList() {
    final tags = event!['tags'];
    if (tags == null) return const Text('Aucun tag disponible');

    final tagsList = tags is List ? tags : [tags];
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tagsList.map<Widget>((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF7FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Text(
            tag.toString(),
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

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _toggleLike,
            icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border),
            label: Text(isLiked ? 'Aimé' : 'J\'aime'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isLiked ? const Color(0xFFE53E3E) : Colors.white,
              foregroundColor: isLiked ? Colors.white : const Color(0xFFE53E3E),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: isLiked ? Colors.transparent : const Color(0xFFE53E3E),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _shareEvent,
            icon: const Icon(Icons.share),
            label: const Text('Partager'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFE53E3E),
              side: const BorderSide(color: Color(0xFFE53E3E)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });
    // TODO: Implémenter l'API pour les likes
  }

  void _shareEvent() {
    if (event == null) return;
    
    final title = event!['title'] ?? 'Événement Dinor';
    final description = event!['short_description'] ?? event!['description'] ?? 'Découvrez cet événement sur Dinor';
    final eventId = widget.arguments['id'] as String;
    final url = 'https://new.dinor.app/events/$eventId';
    
    final shareText = '$title\n\n$description\n\nDécouvrez plus d\'événements sur Dinor:\n$url';
    
    Share.share(shareText, subject: title);
    print('📤 [EventDetail] Contenu partagé: $title');
  }

  Future<void> _openVideo(String videoUrl) async {
    try {
      final uri = Uri.parse(videoUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        print('🎥 [EventDetail] Vidéo ouverte: $videoUrl');
      } else {
        _showSnackBar('Impossible d\'ouvrir la vidéo', Colors.red);
      }
    } catch (e) {
      print('❌ [EventDetail] Erreur ouverture vidéo: $e');
      _showSnackBar('Erreur lors de l\'ouverture de la vidéo', Colors.red);
    }
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

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Non spécifiée';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  String _getStatusLabel(String? status) {
    if (status == null) return 'Non spécifié';
    final labels = {
      'active': 'Actif',
      'upcoming': 'À venir',
      'completed': 'Terminé',
      'cancelled': 'Annulé',
    };
    return labels[status] ?? status;
  }

  Color _getStatusColor(String? status) {
    if (status == null) return const Color(0xFF718096);
    final colors = {
      'active': const Color(0xFF38A169),
      'upcoming': const Color(0xFFF4D03F),
      'completed': const Color(0xFFE53E3E),
      'cancelled': const Color(0xFF718096),
    };
    return colors[status] ?? const Color(0xFF718096);
  }
}