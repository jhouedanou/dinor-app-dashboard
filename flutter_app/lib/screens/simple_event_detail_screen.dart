import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/navigation_service.dart';

class SimpleEventDetailScreen extends StatefulWidget {
  final String id;
  
  const SimpleEventDetailScreen({Key? key, required this.id}) : super(key: key);

  @override
  State<SimpleEventDetailScreen> createState() => _SimpleEventDetailScreenState();
}

class _SimpleEventDetailScreenState extends State<SimpleEventDetailScreen> {
  Map<String, dynamic>? event;
  bool isLoading = true;
  String? error;
  bool isFavorite = false;
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    _loadEvent();
  }

  Future<void> _loadEvent() async {
    try {
      print('🔄 [EventDetail] Chargement de l\'événement ${widget.id}...');
      
      final response = await http.get(
        Uri.parse('https://new.dinorapp.com/api/v1/events/${widget.id}'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print('📡 [EventDetail] Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ [EventDetail] Data reçue: ${data.toString().substring(0, 100)}...');
        
        setState(() {
          event = data['data'];
          isLoading = false;
          error = null;
        });
        
        print('📅 [EventDetail] Événement chargé: ${event?['title']}');
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [EventDetail] Erreur: $e');
      setState(() {
        isLoading = false;
        error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F5F5),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE53E3E)),
              ),
              SizedBox(height: 16),
              Text(
                'Chargement de l\'événement...',
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

    if (error != null || event == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: const Text('Événement'),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => NavigationService.pop(),
          ),
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
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadEvent,
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

    return CustomScrollView(
      slivers: [
        // AppBar avec image de fond
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          backgroundColor: const Color(0xFFE53E3E),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => NavigationService.pop(),
          ),
          actions: [
            IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: Colors.white,
              ),
              onPressed: _toggleFavorite,
            ),
            IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              onPressed: _shareEvent,
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                // Image de fond
                if (event!['image_url'] != null)
                  Image.network(
                    event!['image_url'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFFE53E3E),
                        child: const Icon(
                          Icons.event,
                          size: 64,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                // Overlay gradient
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
                // Titre en bas
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
                // Stats de l'événement
                _buildEventStats(),
                const SizedBox(height: 24),

                // Description
                if (event!['description'] != null) ...[
                  _buildSection(
                    'Description',
                    Text(
                      event!['description'],
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16,
                        color: Color(0xFF4A5568),
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Détails de l'événement
                if (event!['details'] != null) ...[
                  _buildSection(
                    'Détails',
                    _buildEventDetails(),
                  ),
                  const SizedBox(height: 24),
                ],

                // Vidéo
                if (event!['video_url'] != null) ...[
                  _buildSection(
                    'Vidéo de présentation',
                    _buildVideoContainer(),
                  ),
                  const SizedBox(height: 24),
                ],

                // Tags
                if (event!['tags'] != null && event!['tags'].isNotEmpty) ...[
                  _buildSection(
                    'Tags',
                    _buildTagsList(),
                  ),
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
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (event!['start_date'] != null) ...[
            Expanded(
              child: _buildStatItem(
                Icons.calendar_today,
                _formatDate(event!['start_date']),
                const Color(0xFFE53E3E),
              ),
            ),
          ],
          if (event!['location'] != null) ...[
            Expanded(
              child: _buildStatItem(
                Icons.location_on,
                event!['location'],
                const Color(0xFF718096),
              ),
            ),
          ],
          if (event!['status'] != null) ...[
            Expanded(
              child: _buildStatItem(
                Icons.info,
                _getStatusLabel(event!['status']),
                _getStatusColor(event!['status']),
              ),
            ),
          ],
          if (event!['likes_count'] != null) ...[
            Expanded(
              child: _buildStatItem(
                Icons.favorite,
                '${event!['likes_count']}',
                const Color(0xFFE53E3E),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 12,
            color: Color(0xFF4A5568),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
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
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  Widget _buildEventDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (event!['start_date'] != null) ...[
          _buildDetailItem('Date de début', _formatDate(event!['start_date'])),
        ],
        if (event!['end_date'] != null) ...[
          _buildDetailItem('Date de fin', _formatDate(event!['end_date'])),
        ],
        if (event!['location'] != null) ...[
          _buildDetailItem('Lieu', event!['location']),
        ],
        if (event!['organizer'] != null) ...[
          _buildDetailItem('Organisateur', event!['organizer']),
        ],
        if (event!['category'] != null) ...[
          _buildDetailItem('Catégorie', event!['category']['name'] ?? event!['category']),
        ],
      ],
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF4A5568),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 14,
                color: Color(0xFF2D3748),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoContainer() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFC),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.play_circle_outline,
              size: 48,
              color: Color(0xFFE53E3E),
            ),
            const SizedBox(height: 8),
            Text(
              'Vidéo de présentation disponible',
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 14,
                color: Color(0xFF718096),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsList() {
    List<String> tags = [];
    if (event!['tags'] is List) {
      tags = event!['tags'].whereType<String>().toList();
    } else if (event!['tags'] is String) {
      tags = [event!['tags']];
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFE53E3E).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFE53E3E).withOpacity(0.3),
            ),
          ),
          child: Text(
            tag,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 12,
              color: Color(0xFFE53E3E),
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        // Like button
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _toggleLike,
            icon: Icon(
              isLiked ? Icons.favorite : Icons.favorite_border,
              color: isLiked ? Colors.white : const Color(0xFFE53E3E),
            ),
            label: Text(
              isLiked ? 'Aimé' : 'J\'aime',
              style: TextStyle(
                color: isLiked ? Colors.white : const Color(0xFFE53E3E),
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isLiked ? const Color(0xFFE53E3E) : Colors.white,
              side: BorderSide(
                color: const Color(0xFFE53E3E),
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Share button
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _shareEvent,
            icon: const Icon(Icons.share, color: Colors.white),
            label: const Text(
              'Partager',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53E3E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
    });
    // TODO: Implémenter l'API pour les favoris
  }

  void _toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });
    // TODO: Implémenter l'API pour les likes
  }

  void _shareEvent() {
    // TODO: Implémenter le partage
    print('Partager l\'événement: ${event?['title']}');
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  String _getStatusLabel(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return 'Actif';
      case 'upcoming':
        return 'À venir';
      case 'completed':
        return 'Terminé';
      case 'cancelled':
        return 'Annulé';
      default:
        return status ?? 'Actif';
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'upcoming':
        return Colors.blue;
      case 'completed':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      default:
        return const Color(0xFF718096);
    }
  }
}