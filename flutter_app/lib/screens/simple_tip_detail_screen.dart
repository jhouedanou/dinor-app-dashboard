import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/navigation_service.dart';

class SimpleTipDetailScreen extends StatefulWidget {
  final String id;
  
  const SimpleTipDetailScreen({Key? key, required this.id}) : super(key: key);

  @override
  State<SimpleTipDetailScreen> createState() => _SimpleTipDetailScreenState();
}

class _SimpleTipDetailScreenState extends State<SimpleTipDetailScreen> {
  Map<String, dynamic>? tip;
  bool isLoading = true;
  String? error;
  bool isFavorite = false;
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    _loadTip();
  }

  Future<void> _loadTip() async {
    try {
      print('🔄 [TipDetail] Chargement de l\'astuce ${widget.id}...');
      
      final response = await http.get(
        Uri.parse('https://new.dinorapp.com/api/v1/tips/${widget.id}'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print('📡 [TipDetail] Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ [TipDetail] Data reçue: ${data.toString().substring(0, 100)}...');
        
        setState(() {
          tip = data['data'];
          isLoading = false;
          error = null;
        });
        
        print('💡 [TipDetail] Astuce chargée: ${tip?['title']}');
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [TipDetail] Erreur: $e');
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
                'Chargement de l\'astuce...',
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

    if (error != null || tip == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: const Text('Astuce'),
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
                onPressed: _loadTip,
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
              onPressed: _shareTip,
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                // Image de fond
                if (tip!['image_url'] != null)
                  Image.network(
                    tip!['image_url'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFFE53E3E),
                        child: const Icon(
                          Icons.lightbulb,
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
                        tip!['title'] ?? 'Sans titre',
                        style: const TextStyle(
                          fontFamily: 'OpenSans',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (tip!['short_description'] != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          tip!['short_description'],
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
                // Stats de l'astuce
                _buildTipStats(),
                const SizedBox(height: 24),

                // Description
                if (tip!['description'] != null) ...[
                  _buildSection(
                    'Description',
                    Text(
                      tip!['description'],
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

                // Contenu détaillé
                if (tip!['content'] != null) ...[
                  _buildSection(
                    'Astuce',
                    _buildContent(),
                  ),
                  const SizedBox(height: 24),
                ],

                // Vidéo
                if (tip!['video_url'] != null) ...[
                  _buildSection(
                    'Vidéo explicative',
                    _buildVideoContainer(),
                  ),
                  const SizedBox(height: 24),
                ],

                // Tags
                if (tip!['tags'] != null && tip!['tags'].isNotEmpty) ...[
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

  Widget _buildTipStats() {
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
          if (tip!['difficulty_level'] != null) ...[
            Expanded(
              child: _buildStatItem(
                Icons.star,
                _getDifficultyLabel(tip!['difficulty_level']),
                _getDifficultyColor(tip!['difficulty_level']),
              ),
            ),
          ],
          if (tip!['estimated_time'] != null) ...[
            Expanded(
              child: _buildStatItem(
                Icons.schedule,
                '${tip!['estimated_time']} min',
                const Color(0xFF718096),
              ),
            ),
          ],
          if (tip!['likes_count'] != null) ...[
            Expanded(
              child: _buildStatItem(
                Icons.favorite,
                '${tip!['likes_count']}',
                const Color(0xFFE53E3E),
              ),
            ),
          ],
          if (tip!['comments_count'] != null) ...[
            Expanded(
              child: _buildStatItem(
                Icons.comment,
                '${tip!['comments_count']}',
                const Color(0xFF718096),
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

  Widget _buildContent() {
    String content = '';
    if (tip!['content'] is String) {
      content = tip!['content'];
    } else if (tip!['content'] is List) {
      content = tip!['content'].map((item) {
        if (item is Map && item['step'] != null) {
          return item['step'];
        }
        return item.toString();
      }).join('\n\n');
    }

    return Text(
      content,
      style: const TextStyle(
        fontFamily: 'Roboto',
        fontSize: 16,
        color: Color(0xFF4A5568),
        height: 1.6,
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
              'Vidéo explicative disponible',
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
    if (tip!['tags'] is List) {
      tags = tip!['tags'].whereType<String>().toList();
    } else if (tip!['tags'] is String) {
      tags = [tip!['tags']];
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
            onPressed: _shareTip,
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

  void _shareTip() {
    // TODO: Implémenter le partage
    print('Partager l\'astuce: ${tip?['title']}');
  }

  Color _getDifficultyColor(String? difficulty) {
    switch (difficulty?.toLowerCase()) {
      case 'easy':
      case 'beginner':
        return Colors.green;
      case 'medium':
      case 'intermediate':
        return Colors.orange;
      case 'hard':
      case 'advanced':
        return Colors.red;
      default:
        return const Color(0xFF718096);
    }
  }

  String _getDifficultyLabel(String? difficulty) {
    switch (difficulty?.toLowerCase()) {
      case 'easy':
      case 'beginner':
        return 'Facile';
      case 'medium':
      case 'intermediate':
        return 'Moyen';
      case 'hard':
      case 'advanced':
        return 'Difficile';
      default:
        return difficulty ?? 'Facile';
    }
  }
}