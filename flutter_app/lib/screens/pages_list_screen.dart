import '../services/navigation_service.dart';
/**
 * PAGES_LIST_SCREEN.DART - ÉCRAN LISTE DES PAGES
 * 
 * FIDÉLITÉ VISUELLE :
 * - Design moderne avec cards page
 * - Pull-to-refresh pour rafraîchir
 * - Loading states et error handling
 * - Navigation vers détail page
 * 
 * FIDÉLITÉ FONCTIONNELLE :
 * - Chargement des pages via API
 * - Gestion d'état avec Riverpod
 * - Recherche et filtrage
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Services
import '../services/api_service.dart';

class PagesListScreen extends ConsumerStatefulWidget {
  const PagesListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PagesListScreen> createState() => _PagesListScreenState();
}

class _PagesListScreenState extends ConsumerState<PagesListScreen> with AutomaticKeepAliveClientMixin {
  List<dynamic> _pages = [];
  bool _loading = true;
  String? _error;
  String _searchQuery = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    print('📄 [PagesListScreen] Écran pages initialisé');
    _loadPages();
  }

  Future<void> _loadPages() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      print('📄 [PagesListScreen] Chargement des pages');
      // TODO: Implémenter l'API pour les pages
      // final data = await ApiService.instance.getPages();
      
      // Données de test pour l'instant
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _pages = [
          {
            'id': '1',
            'title': 'À propos de Dinor',
            'description': 'Découvrez notre histoire et notre mission',
            'image': '',
            'slug': 'about',
          },
          {
            'id': '2',
            'title': 'Comment ça marche',
            'description': 'Guide d\'utilisation de l\'application',
            'image': '',
            'slug': 'how-it-works',
          },
          {
            'id': '3',
            'title': 'FAQ',
            'description': 'Questions fréquemment posées',
            'image': '',
            'slug': 'faq',
          },
        ];
        _loading = false;
      });
      print('✅ [PagesListScreen] ${_pages.length} pages chargées');
    } catch (error) {
      print('❌ [PagesListScreen] Erreur: $error');
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  Future<void> _handleRefresh() async {
    print('🔄 [PagesListScreen] Rafraîchissement des pages...');
    await _loadPages();
  }

  void _handlePageTap(dynamic page) {
    print('📄 [PagesListScreen] Clic sur page: ${page['slug']}');
    NavigationService.pushNamed('/pages/${page['slug']}');
  }

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  List<dynamic> get _filteredPages {
    if (_searchQuery.isEmpty) return _pages;
    return _pages.where((page) {
      final title = page['title']?.toString().toLowerCase() ?? '';
      final description = page['description']?.toString().toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();
      return title.contains(query) || description.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // Header secondaire collé sans espace
          Container(
            width: double.infinity,
            height: 56,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3748)),
                  onPressed: () => NavigationService.pop(),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Pages',
                      style: TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 48), // Pour équilibrer le bouton retour
              ],
            ),
          ),
          // Barre de recherche
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              onChanged: _handleSearch,
              decoration: InputDecoration(
                hintText: 'Rechercher une page...',
                hintStyle: const TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 14,
                  color: Color(0xFF718096),
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xFF718096),
                ),
                filled: true,
                fillColor: const Color(0xFFF7FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          // Liste des pages
          Expanded(
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
              child: _buildBody(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF4D03F)),
            ),
            SizedBox(height: 16),
            Text(
              'Chargement des pages...',
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 16,
                color: Color(0xFF718096),
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
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
            const Text(
              'Erreur de chargement',
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 14,
                color: Color(0xFF718096),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPages,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF4D03F),
                foregroundColor: const Color(0xFF2D3748),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_filteredPages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.article_outlined,
              size: 64,
              color: Color(0xFFCBD5E0),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty ? 'Aucune page disponible' : 'Aucun résultat trouvé',
              style: const TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isEmpty 
                  ? 'Les pages apparaîtront ici'
                  : 'Essayez avec d\'autres mots-clés',
              style: const TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 14,
                color: Color(0xFF718096),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredPages.length,
      itemBuilder: (context, index) {
        final page = _filteredPages[index];
        return _buildPageCard(page);
      },
    );
  }

  Widget _buildPageCard(dynamic page) {
    final title = page['title'] ?? 'Sans titre';
    final description = page['description'] ?? '';
    final image = page['image'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handlePageTap(page),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Image ou icône
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4D03F).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: image.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: image,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Icon(
                              Icons.article_outlined,
                              color: Color(0xFFF4D03F),
                              size: 24,
                            ),
                            errorWidget: (context, url, error) => const Icon(
                              Icons.article_outlined,
                              color: Color(0xFFF4D03F),
                              size: 24,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.article_outlined,
                          color: Color(0xFFF4D03F),
                          size: 24,
                        ),
                ),
                const SizedBox(width: 16),
                // Contenu
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'OpenSans',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3748),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: const TextStyle(
                            fontFamily: 'OpenSans',
                            fontSize: 14,
                            color: Color(0xFF718096),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Flèche
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFFCBD5E0),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}