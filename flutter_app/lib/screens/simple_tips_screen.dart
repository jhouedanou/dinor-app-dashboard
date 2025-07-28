import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/navigation_service.dart';

class SimpleTipsScreen extends StatefulWidget {
  const SimpleTipsScreen({Key? key}) : super(key: key);

  @override
  State<SimpleTipsScreen> createState() => _SimpleTipsScreenState();
}

class _SimpleTipsScreenState extends State<SimpleTipsScreen> {
  List<dynamic> tips = [];
  List<dynamic> allTips = [];
  List<String> availableTags = [];
  List<String> selectedTags = [];
  String searchQuery = '';
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadTips();
  }

  Future<void> _loadTips() async {
    try {
      print('🔄 [SimpleTips] Chargement des astuces...');
      
      final response = await http.get(
        Uri.parse('https://new.dinorapp.com/api/v1/tips'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print('📡 [SimpleTips] Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ [SimpleTips] Data reçue: ${data.toString().substring(0, 100)}...');
        
        setState(() {
          if (data['data'] != null) {
            allTips = data['data'] is List ? data['data'] : [data['data']];
            tips = List.from(allTips);
            _extractTags();
          } else {
            allTips = [];
            tips = [];
          }
          isLoading = false;
          error = null;
        });
        
        print('💡 [SimpleTips] ${tips.length} astuces chargées');
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [SimpleTips] Erreur: $e');
      setState(() {
        isLoading = false;
        error = e.toString();
      });
    }
  }

  void _extractTags() {
    Set<String> tags = {};
    for (var tip in allTips) {
      if (tip['tags'] != null) {
        if (tip['tags'] is List) {
          for (var tag in tip['tags']) {
            if (tag is String) tags.add(tag);
          }
        } else if (tip['tags'] is String) {
          tags.add(tip['tags']);
        }
      }
    }
    availableTags = tags.toList()..sort();
  }

  void _filterTips() {
    setState(() {
      tips = allTips.where((tip) {
        // Filtre par recherche
        bool matchesSearch = searchQuery.isEmpty || 
          tip['title']?.toString().toLowerCase().contains(searchQuery.toLowerCase()) == true ||
          tip['description']?.toString().toLowerCase().contains(searchQuery.toLowerCase()) == true ||
          tip['content']?.toString().toLowerCase().contains(searchQuery.toLowerCase()) == true;
        
        // Filtre par tags
        bool matchesTags = selectedTags.isEmpty;
        if (!matchesTags && tip['tags'] != null) {
          List<String> tipTags = [];
          if (tip['tags'] is List) {
            tipTags = tip['tags'].whereType<String>().toList();
          } else if (tip['tags'] is String) {
            tipTags = [tip['tags']];
          }
          matchesTags = selectedTags.every((tag) => tipTags.contains(tag));
        }
        
        return matchesSearch && matchesTags;
      }).toList();
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      searchQuery = query;
    });
    _filterTips();
  }

  void _onTagSelected(String tag) {
    setState(() {
      if (selectedTags.contains(tag)) {
        selectedTags.remove(tag);
      } else {
        selectedTags.add(tag);
      }
    });
    _filterTips();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Astuces',
          style: TextStyle(
            fontFamily: 'OpenSans',
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3748)),
          onPressed: () => NavigationService.pop(),
        ),
      ),
      body: Column(
        children: [
          // Barre de recherche
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Rechercher une astuce...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF718096)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE53E3E)),
                ),
                filled: true,
                fillColor: const Color(0xFFF7FAFC),
              ),
            ),
          ),

          // Filtres par tags
          if (availableTags.isNotEmpty)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filtrer par tags:',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF4A5568),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: availableTags.map<Widget>((tag) {
                      bool isSelected = selectedTags.contains(tag);
                      return FilterChip(
                        label: Text(tag),
                        selected: isSelected,
                        onSelected: (_) => _onTagSelected(tag),
                        backgroundColor: const Color(0xFFF7FAFC),
                        selectedColor: const Color(0xFFE53E3E),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF4A5568),
                          fontSize: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

          // Liste des astuces
          Expanded(
            child: _buildTipsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsList() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE53E3E)),
            ),
            SizedBox(height: 16),
            Text(
              'Chargement des astuces...',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 16,
                color: Color(0xFF4A5568),
              ),
            ),
          ],
        ),
      );
    }

    if (error != null) {
      return Center(
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
              onPressed: _loadTips,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53E3E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (tips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lightbulb_outline,
              size: 64,
              color: Color(0xFFCBD5E0),
            ),
            const SizedBox(height: 16),
            Text(
              searchQuery.isNotEmpty || selectedTags.isNotEmpty
                ? 'Aucune astuce trouvée'
                : 'Aucune astuce disponible',
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 18,
                color: Color(0xFF4A5568),
              ),
            ),
            if (searchQuery.isNotEmpty || selectedTags.isNotEmpty) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  setState(() {
                    searchQuery = '';
                    selectedTags.clear();
                  });
                  _filterTips();
                },
                child: const Text(
                  'Effacer les filtres',
                  style: TextStyle(color: Color(0xFFE53E3E)),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTips,
      color: const Color(0xFFE53E3E),
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: tips.length,
        itemBuilder: (context, index) {
          final tip = tips[index];
          return _buildTipCard(tip);
        },
      ),
    );
  }

  Widget _buildTipCard(Map<String, dynamic> tip) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      child: InkWell(
        onTap: () {
          NavigationService.pushNamed('/tip-detail', arguments: {'id': tip['id'].toString()});
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image de l'astuce
            if (tip['image_url'] != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    tip['image_url'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFFF7FAFC),
                        child: const Icon(
                          Icons.lightbulb,
                          size: 48,
                          color: Color(0xFFCBD5E0),
                        ),
                      );
                    },
                  ),
                ),
              ),

            // Contenu de la carte
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre
                  Text(
                    tip['title'] ?? 'Sans titre',
                    style: const TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3748),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Description
                  if (tip['description'] != null) ...[
                    Text(
                      tip['description'],
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14,
                        color: Color(0xFF718096),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Tags
                  if (tip['tags'] != null && tip['tags'].isNotEmpty) ...[
                                         Wrap(
                       spacing: 4,
                       runSpacing: 4,
                       children: (tip['tags'] is List 
                         ? tip['tags'] 
                         : [tip['tags']]).map<Widget>((tag) {
                         return Container(
                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                           decoration: BoxDecoration(
                             color: const Color(0xFFF7FAFC),
                             borderRadius: BorderRadius.circular(12),
                           ),
                           child: Text(
                             tag.toString(),
                             style: const TextStyle(
                               fontSize: 10,
                               color: Color(0xFF718096),
                             ),
                           ),
                         );
                       }).toList(),
                     ),
                    const SizedBox(height: 8),
                  ],

                  // Stats
                  Row(
                    children: [
                      if (tip['difficulty_level'] != null) ...[
                        Icon(
                          Icons.star,
                          size: 16,
                          color: _getDifficultyColor(tip['difficulty_level']),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getDifficultyLabel(tip['difficulty_level']),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF718096),
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      if (tip['estimated_time'] != null) ...[
                        const Icon(
                          Icons.schedule,
                          size: 16,
                          color: Color(0xFF718096),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${tip['estimated_time']} min',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF718096),
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      if (tip['likes_count'] != null) ...[
                        const Icon(
                          Icons.favorite,
                          size: 16,
                          color: Color(0xFFE53E3E),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${tip['likes_count']}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF718096),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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