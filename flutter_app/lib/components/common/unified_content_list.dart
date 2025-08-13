import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';



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
  final bool useGridView;

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
    this.useGridView = false,
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
  bool _showTags = false;
  bool _showDateFilters = false;
  String? _error;
  int _currentPage = 0;
  DateTime? _startDate;
  DateTime? _endDate;

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
        
        // Filtre par dates (pour les événements)
        bool matchesDate = true;
        if (widget.contentType == 'event' && (_startDate != null || _endDate != null)) {
          DateTime? itemDate = _extractDateFromItem(item);
          if (itemDate != null) {
            if (_startDate != null && itemDate.isBefore(_startDate!)) {
              matchesDate = false;
            }
            if (_endDate != null && itemDate.isAfter(_endDate!.add(const Duration(days: 1)))) {
              matchesDate = false;
            }
          }
        }
        
        return matchesSearch && matchesTags && matchesDate;
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
            if (widget.useGridView)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index < _displayedItems.length) {
                        return widget.itemBuilder(_displayedItems[index]);
                      }
                      return null;
                    },
                    childCount: _displayedItems.length,
                  ),
                ),
              )
            else
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
          
          // Bouton "Charger plus" pour la GridView
          if (widget.useGridView && !_isLoading && _error == null && _hasMoreItems())
            SliverToBoxAdapter(
              child: _buildLoadMoreButton(),
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
                        print('Selected tags: $_selectedTags'); // Log pour le débogage
                      });
                      _filterItems();
                    },
                  );
                }).toList(),
              ),
            ],
          ],
          
          // Filtre par dates (pour les événements)
          if (widget.contentType == 'event') ...[
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  'Filtrer par dates',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showDateFilters = !_showDateFilters;
                    });
                  },
                  icon: Icon(_showDateFilters ? LucideIcons.chevronUp : LucideIcons.chevronDown),
                ),
              ],
            ),
            
            if (_showDateFilters) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  // Date de début
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectStartDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date de début',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(LucideIcons.calendar),
                        ),
                        child: Text(
                          _startDate != null
                              ? '${_startDate!.day.toString().padLeft(2, '0')}/${_startDate!.month.toString().padLeft(2, '0')}/${_startDate!.year}'
                              : 'Sélectionner',
                          style: TextStyle(
                            color: _startDate != null ? Colors.black : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Date de fin
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectEndDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date de fin',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(LucideIcons.calendar),
                        ),
                        child: Text(
                          _endDate != null
                              ? '${_endDate!.day.toString().padLeft(2, '0')}/${_endDate!.month.toString().padLeft(2, '0')}/${_endDate!.year}'
                              : 'Sélectionner',
                          style: TextStyle(
                            color: _endDate != null ? Colors.black : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              if (_startDate != null || _endDate != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _startDate = null;
                          _endDate = null;
                        });
                        _filterItems();
                      },
                      icon: const Icon(LucideIcons.x, size: 16),
                      label: const Text('Effacer les dates'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                        foregroundColor: Colors.grey[600],
                        elevation: 0,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${_filteredItems.length} événement${_filteredItems.length > 1 ? 's' : ''} trouvé${_filteredItems.length > 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF718096),
                      ),
                    ),
                  ],
                ),
              ],
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

  // Extraire la date d'un élément pour le filtrage
  DateTime? _extractDateFromItem(Map<String, dynamic> item) {
    final possibleDateFields = [
      'date', 'event_date', 'start_date', 'scheduled_date', 
      'datetime', 'event_datetime', 'start_datetime', 'begins_at',
      'created_at', 'published_at'
    ];
    
    for (final field in possibleDateFields) {
      final value = item[field];
      if (value != null && value.toString().isNotEmpty) {
        try {
          return DateTime.parse(value.toString());
        } catch (e) {
          // Essayer d'autres formats
          try {
            final parts = value.toString().split('/');
            if (parts.length == 3) {
              return DateTime(
                int.parse(parts[2]), // année
                int.parse(parts[1]), // mois  
                int.parse(parts[0]), // jour
              );
            }
          } catch (e) {
            continue;
          }
        }
      }
    }
    return null;
  }

  // Sélectionner la date de début
  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('fr', 'FR'),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        // Si la date de fin est antérieure à la date de début, la réinitialiser
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = null;
        }
      });
      _filterItems();
    }
  }

  // Sélectionner la date de fin
  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('fr', 'FR'),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
      _filterItems();
    }
  }
}