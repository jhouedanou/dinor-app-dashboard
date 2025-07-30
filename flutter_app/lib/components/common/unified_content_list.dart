import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../services/navigation_service.dart';
import '../../services/image_service.dart';

class UnifiedContentList extends ConsumerStatefulWidget {
  final String contentType;
  final String apiEndpoint;
  final Widget Function(Map<String, dynamic> item) itemBuilder;
  final String Function(Map<String, dynamic> item) titleExtractor;
  final String Function(Map<String, dynamic> item) imageExtractor;
  final String Function(Map<String, dynamic> item) descriptionExtractor;
  final VoidCallback Function(Map<String, dynamic> item) onItemTap;
  final int itemsPerPage;
  final bool enableSearch;
  final bool enableFilters;

  const UnifiedContentList({
    super.key,
    required this.contentType,
    required this.apiEndpoint,
    required this.itemBuilder,
    required this.titleExtractor,
    required this.imageExtractor,
    required this.descriptionExtractor,
    required this.onItemTap,
    this.itemsPerPage = 2,
    this.enableSearch = true,
    this.enableFilters = true,
  });

  @override
  ConsumerState<UnifiedContentList> createState() => _UnifiedContentListState();
}

class _UnifiedContentListState extends ConsumerState<UnifiedContentList> {
  List<dynamic> _allItems = [];
  List<dynamic> _displayedItems = [];
  List<dynamic> _filteredItems = [];
  List<String> _availableTags = [];
  List<String> _selectedTags = [];
  String _searchQuery = '';
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _showTags = true;
  String? _error;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await http.get(
        Uri.parse(widget.apiEndpoint),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        setState(() {
          if (data['data'] != null) {
            _allItems = data['data'] is List ? data['data'] : [data['data']];
            _filteredItems = List.from(_allItems);
            _displayedItems = _filteredItems.take(widget.itemsPerPage).toList();
            _currentPage = 1;
            _extractTags();
          } else {
            _allItems = [];
            _filteredItems = [];
            _displayedItems = [];
          }
          _isLoading = false;
        });
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  void _extractTags() {
    if (!widget.enableFilters) return;
    
    Set<String> tags = {};
    for (var item in _allItems) {
      if (item['tags'] != null) {
        if (item['tags'] is List) {
          for (var tag in item['tags']) {
            if (tag is String) tags.add(tag);
          }
        } else if (item['tags'] is String) {
          tags.add(item['tags']);
        }
      }
      
      // Extraire aussi la catégorie si disponible
      if (item['category'] != null) {
        String categoryName = item['category'] is String 
            ? item['category'] 
            : item['category']['name'] ?? '';
        if (categoryName.isNotEmpty) tags.add(categoryName);
      }
    }
    _availableTags = tags.toList()..sort();
  }

  void _filterItems() {
    setState(() {
      _filteredItems = _allItems.where((item) {
        // Filtre par recherche
        bool matchesSearch = _searchQuery.isEmpty || 
          widget.titleExtractor(item).toLowerCase().contains(_searchQuery.toLowerCase()) ||
          widget.descriptionExtractor(item).toLowerCase().contains(_searchQuery.toLowerCase());
        
        // Filtre par tags
        bool matchesTags = _selectedTags.isEmpty;
        if (!matchesTags && item['tags'] != null) {
          if (item['tags'] is List) {
            matchesTags = _selectedTags.any((selectedTag) =>
                (item['tags'] as List).any((tag) => tag.toString() == selectedTag));
          } else if (item['tags'] is String) {
            matchesTags = _selectedTags.contains(item['tags']);
          }
        }
        
        // Vérifier aussi la catégorie
        if (!matchesTags && item['category'] != null) {
          String categoryName = item['category'] is String 
              ? item['category'] 
              : item['category']['name'] ?? '';
          matchesTags = _selectedTags.contains(categoryName);
        }
        
        return matchesSearch && matchesTags;
      }).toList();
      
      // Reset pagination
      _currentPage = 1;
      _displayedItems = _filteredItems.take(widget.itemsPerPage).toList();
    });
  }

  void _loadMoreItems() {
    if (_isLoadingMore) return;
    
    final remainingItems = _filteredItems.length - _displayedItems.length;
    if (remainingItems <= 0) return;
    
    setState(() {
      _isLoadingMore = true;
    });
    
    // Simuler un délai de chargement
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          final startIndex = _currentPage * widget.itemsPerPage;
          final endIndex = (startIndex + widget.itemsPerPage).clamp(0, _filteredItems.length);
          final newItems = _filteredItems.sublist(startIndex, endIndex);
          _displayedItems.addAll(newItems);
          _currentPage++;
          _isLoadingMore = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadItems,
      child: CustomScrollView(
        slivers: [
          // Barre de recherche et filtres
          if (widget.enableSearch || widget.enableFilters)
            SliverToBoxAdapter(
              child: _buildSearchAndFilters(),
            ),
          
          // État de chargement
          if (_isLoading)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          
          // État d'erreur
          if (_error != null && !_isLoading)
            SliverToBoxAdapter(
              child: _buildErrorState(),
            ),
          
          // Liste des éléments
          if (!_isLoading && _error == null)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index < _displayedItems.length) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: widget.itemBuilder(_displayedItems[index]),
                    );
                  } else if (index == _displayedItems.length && _hasMoreItems()) {
                    return _buildLoadMoreButton();
                  }
                  return null;
                },
                childCount: _displayedItems.length + (_hasMoreItems() ? 1 : 0),
              ),
            ),
          
          // État vide
          if (!_isLoading && _error == null && _displayedItems.isEmpty)
            SliverToBoxAdapter(
              child: _buildEmptyState(),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barre de recherche
          if (widget.enableSearch) ...[
            TextField(
              decoration: const InputDecoration(
                hintText: 'Rechercher...',
                prefixIcon: Icon(LucideIcons.search),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                _filterItems();
              },
            ),
            const SizedBox(height: 16),
          ],
          
          // Bouton pour afficher/masquer les tags
          if (widget.enableFilters && _availableTags.isNotEmpty) ...[
            Row(
              children: [
                Text(
                  'Filtres (${_selectedTags.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showTags = !_showTags;
                    });
                  },
                  icon: Icon(_showTags ? LucideIcons.chevronUp : LucideIcons.chevronDown),
                ),
              ],
            ),
            
            // Tags
            if (_showTags) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableTags.map((tag) {
                  final isSelected = _selectedTags.contains(tag);
                  return FilterChip(
                    label: Text(tag),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedTags.add(tag);
                        } else {
                          _selectedTags.remove(tag);
                        }
                      });
                      _filterItems();
                    },
                  );
                }).toList(),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (_isLoadingMore)
            const CircularProgressIndicator()
          else ...[
            ElevatedButton.icon(
              onPressed: _loadMoreItems,
              icon: const Icon(LucideIcons.plus),
              label: Text('Charger ${_getRemainingItemsCount()} éléments suivants'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF4D03F),
                foregroundColor: const Color(0xFF2D3748),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Affichage de ${_displayedItems.length} sur ${_filteredItems.length} éléments',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF718096),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
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
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF718096),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadItems,
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            _getEmptyStateIcon(),
            size: 64,
            color: const Color(0xFF718096),
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty || _selectedTags.isNotEmpty
                ? 'Aucun résultat trouvé'
                : 'Aucun contenu disponible',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty || _selectedTags.isNotEmpty
                ? 'Essayez de modifier vos critères de recherche'
                : 'Le contenu sera bientôt disponible',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF718096),
            ),
            textAlign: TextAlign.center,
          ),
          if (_searchQuery.isNotEmpty || _selectedTags.isNotEmpty) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _selectedTags.clear();
                });
                _filterItems();
              },
              child: const Text('Effacer les filtres'),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getEmptyStateIcon() {
    switch (widget.contentType) {
      case 'recipe':
        return LucideIcons.chefHat;
      case 'tip':
        return LucideIcons.lightbulb;
      case 'event':
        return LucideIcons.calendar;
      default:
        return LucideIcons.fileX;
    }
  }

  bool _hasMoreItems() {
    return _displayedItems.length < _filteredItems.length;
  }

  int _getRemainingItemsCount() {
    final remaining = _filteredItems.length - _displayedItems.length;
    return remaining.clamp(0, widget.itemsPerPage);
  }
}