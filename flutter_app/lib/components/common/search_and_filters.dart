import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SearchAndFilters extends StatefulWidget {
  final String searchQuery;
  final Function(String) onSearchQueryChanged;
  final String? selectedCategory;
  final Function(String?) onSelectedCategoryChanged;
  final List<dynamic> categories;
  final List<Map<String, dynamic>> additionalFilters;
  final Map<String, dynamic> selectedFilters;
  final Function(String, dynamic) onAdditionalFilterChanged;
  final int resultsCount;
  final String itemType;
  final String searchPlaceholder;

  const SearchAndFilters({
    Key? key,
    required this.searchQuery,
    required this.onSearchQueryChanged,
    required this.selectedCategory,
    required this.onSelectedCategoryChanged,
    required this.categories,
    required this.additionalFilters,
    required this.selectedFilters,
    required this.onAdditionalFilterChanged,
    required this.resultsCount,
    required this.itemType,
    required this.searchPlaceholder,
  }) : super(key: key);

  @override
  State<SearchAndFilters> createState() => _SearchAndFiltersState();
}

class _SearchAndFiltersState extends State<SearchAndFilters> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.searchQuery;
  }

  @override
  void didUpdateWidget(SearchAndFilters oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      _searchController.text = widget.searchQuery;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          _buildSearchBar(),
          const SizedBox(height: 16),

          // Categories
          if (widget.categories.isNotEmpty) ...[
            _buildCategories(),
            const SizedBox(height: 16),
          ],

          // Additional Filters
          if (widget.additionalFilters.isNotEmpty) ...[
            _buildAdditionalFilters(),
            const SizedBox(height: 16),
          ],

          // Results Count
          _buildResultsCount(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: widget.onSearchQueryChanged,
        decoration: InputDecoration(
          hintText: widget.searchPlaceholder,
          prefixIcon: const Icon(
            LucideIcons.search,
            color: Color(0xFF49454F),
          ),
          suffixIcon: widget.searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    widget.onSearchQueryChanged('');
                  },
                  icon: const Icon(
                    LucideIcons.x,
                    color: Color(0xFF49454F),
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Catégories',
          style: const TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // Tous les catégories
              _buildCategoryChip(
                'Toutes',
                null,
                widget.selectedCategory == null,
              ),
              const SizedBox(width: 8),
              // Catégories spécifiques
              ...widget.categories.map((category) {
                final isSelected = widget.selectedCategory == category['id'].toString();
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildCategoryChip(
                    category['name'],
                    category['id'].toString(),
                    isSelected,
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String label, String? value, bool isSelected) {
    return GestureDetector(
      onTap: () => widget.onSelectedCategoryChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF4D03F) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFFFF6B35) : const Color(0xFFE2E8F0),
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? const Color(0xFF2D3748) : const Color(0xFF4A5568),
          ),
        ),
      ),
    );
  }

  Widget _buildAdditionalFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filtres additionnels',
          style: const TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 8),
        ...widget.additionalFilters.map((filter) => _buildFilterSection(filter)),
      ],
    );
  }

  Widget _buildFilterSection(Map<String, dynamic> filter) {
    final key = filter['key'] as String;
    final label = filter['label'] as String;
    final icon = filter['icon'] as String;
    final allLabel = filter['allLabel'] as String;
    final options = filter['options'] as List<Map<String, dynamic>>;
    final selectedValue = widget.selectedFilters[key];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF4A5568),
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Tous les options
                _buildFilterChip(
                  allLabel,
                  null,
                  selectedValue == null,
                  () => widget.onAdditionalFilterChanged(key, null),
                ),
                const SizedBox(width: 8),
                // Options spécifiques
                ...options.map((option) {
                  final value = option['value'] as String;
                  final optionLabel = option['label'] as String;
                  final isSelected = selectedValue == value;
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildFilterChip(
                      optionLabel,
                      value,
                      isSelected,
                      () => widget.onAdditionalFilterChanged(key, value),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? value, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF4D03F) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFFFF6B35) : const Color(0xFFE2E8F0),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? const Color(0xFF2D3748) : const Color(0xFF4A5568),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsCount() {
    return Text(
      '${widget.resultsCount} ${widget.itemType}${widget.resultsCount > 1 ? 's' : ''} trouvé${widget.resultsCount > 1 ? 's' : ''}',
      style: const TextStyle(
        fontFamily: 'Roboto',
        fontSize: 14,
        color: Color(0xFF49454F),
      ),
    );
  }
} 