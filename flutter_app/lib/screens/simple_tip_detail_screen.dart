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
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF4D03F)),
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
          title: const Text('Erreur'),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3748)),
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
                  color: Color(0xFFF4D03F),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Astuce introuvable',
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error ?? 'Cette astuce n\'existe pas ou plus.',
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 14,
                    color: Color(0xFF4A5568),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => NavigationService.pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF4D03F),
                    foregroundColor: const Color(0xFF2D3748),
                  ),
                  child: const Text('Retour'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final title = tip!['title'] ?? tip!['name'] ?? 'Astuce';
    final content = tip!['content'] ?? tip!['description'] ?? tip!['excerpt'] ?? '';
    final category = tip!['category'] ?? tip!['type'] ?? 'Astuce';
    final imageUrl = tip!['image'] ?? tip!['featured_image'] ?? tip!['thumbnail'];

    return CustomScrollView(
      slivers: [
        // App Bar
        SliverAppBar(
          expandedHeight: 120,
          pinned: true,
          backgroundColor: const Color(0xFFF4D03F),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3748)),
            onPressed: () => NavigationService.pop(),
          ),
          actions: [
            IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? const Color(0xFFE53E3E) : const Color(0xFF2D3748),
              ),
              onPressed: () {
                setState(() {
                  isFavorite = !isFavorite;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.share, color: Color(0xFF2D3748)),
              onPressed: () {
                // TODO: Implémenter le partage
              },
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF4D03F), Color(0xFFECC94B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.lightbulb,
                  size: 48,
                  color: Color(0xFF2D3748),
                ),
              ),
            ),
          ),
        ),
        
        // Contenu
        SliverToBoxAdapter(
          child: Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête avec catégorie
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge catégorie
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4D03F).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.lightbulb,
                              size: 16,
                              color: Color(0xFFF4D03F),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              category,
                              style: const TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFF4D03F),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Titre
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'OpenSans',
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2D3748),
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Image si disponible
                if (imageUrl != null) ...[
                  Container(
                    height: 200,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFFF7FAFC),
                            child: const Center(
                              child: Icon(
                                Icons.image,
                                size: 48,
                                color: Color(0xFF718096),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Contenu de l'astuce
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF4D03F).withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4D03F).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.tips_and_updates,
                              size: 20,
                              color: Color(0xFFF4D03F),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Conseil pratique',
                            style: TextStyle(
                              fontFamily: 'OpenSans',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Text(
                        _cleanHtmlContent(content),
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 16,
                          color: Color(0xFF2D3748),
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Section d'action
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF4D03F), Color(0xFFECC94B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 24,
                        color: Color(0xFF2D3748),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Cette astuce vous a-t-elle été utile ?',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: Implémenter le système de notation
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.9),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Oui !',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _cleanHtmlContent(String content) {
    return content
        .replaceAll(RegExp(r'<[^>]*>'), '') // Supprimer les balises HTML
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .trim();
  }
}