import '../services/navigation_service.dart';
/**
 * DINOR_TV_SCREEN.DART - ÉCRAN DINOR TV
 * 
 * FIDÉLITÉ VISUELLE :
 * - Design moderne avec cards vidéo
 * - Pull-to-refresh pour rafraîchir
 * - Loading states et error handling
 * - Navigation vers détail vidéo
 * 
 * FIDÉLITÉ FONCTIONNELLE :
 * - Chargement des vidéos via API
 * - Gestion d'état avec Riverpod
 * - Like/Favorite functionality
 * - Pagination si nécessaire
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';


import '../services/image_service.dart';

// Composables
import '../composables/use_dinor_tv.dart';
import '../composables/use_auth_handler.dart';

// Components
import '../components/common/banner_section.dart';
import '../components/common/auth_modal.dart';
import '../components/common/content_gallery_grid.dart';



class DinorTVScreen extends ConsumerStatefulWidget {
  const DinorTVScreen({super.key});

  @override
  ConsumerState<DinorTVScreen> createState() => _DinorTVScreenState();
}

class _DinorTVScreenState extends ConsumerState<DinorTVScreen> with AutomaticKeepAliveClientMixin {
  bool _showAuthModal = false;
  String _authModalMessage = '';
  List<dynamic> _banners = [];


  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    print('📺 [DinorTVScreen] Écran DinorTV initialisé');
    _loadVideos();
    _loadBanners();
  }



  Future<void> _loadVideos() async {
    await ref.read(dinorTVProvider.notifier).loadVideos(
      params: {
        'limit': '20',
        'sort_by': 'created_at',
        'sort_order': 'desc',
      },
    );
  }

  Future<void> _loadBanners() async {
    try {
      print('🎨 [DinorTVScreen] Chargement bannières pour type: dinor-tv');
      // TODO: Implémenter le chargement des bannières spécifiques à Dinor TV
      setState(() {
        _banners = []; // TODO: Charger les vraies bannières
      });
    } catch (error) {
      print('❌ [DinorTVScreen] Erreur chargement bannières: $error');
    }
  }

  Future<void> _handleRefresh() async {
    print('🔄 [DinorTVScreen] Rafraîchissement des vidéos...');
    await ref.read(dinorTVProvider.notifier).refresh();
  }



  void _handleVideoClick(Map<String, dynamic> video) {
    final videoUrl = video['video_url'] as String?;
    final title = video['title'] as String? ?? 'Vidéo Dinor TV';
    final description = video['description'] as String?;

    if (videoUrl != null && videoUrl.isNotEmpty) {
      print('🎬 [DinorTV] Ouverture vidéo: $title');
      print('🎬 [DinorTV] URL: $videoUrl');

      // TODO: Implémenter la modal vidéo pour Dinor TV
      // Pour l'instant, juste des logs pour debug
    } else {
      print('⚠️ [DinorTV] URL vidéo manquante pour: $title');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('URL de vidéo non disponible'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleLikeTap(dynamic video) async {
    final authHandler = ref.read(useAuthHandlerProvider.notifier);
    
    if (!authHandler.isAuthenticated) {
      setState(() {
        _showAuthModal = true;
        _authModalMessage = 'Connectez-vous pour liker cette vidéo';
      });
      return;
    }

    try {
      // TODO: Implémenter toggle like
      print('👍 [DinorTVScreen] Like vidéo: ${video['id']}');
    } catch (error) {
      print('❌ [DinorTVScreen] Erreur like: $error');
    }
  }

  void _handleFavoriteTap(dynamic video) async {
    final authHandler = ref.read(useAuthHandlerProvider.notifier);
    
    if (!authHandler.isAuthenticated) {
      setState(() {
        _showAuthModal = true;
        _authModalMessage = 'Connectez-vous pour ajouter aux favoris';
      });
      return;
    }

    try {
      // TODO: Implémenter toggle favorite
      print('⭐ [DinorTVScreen] Favorite vidéo: ${video['id']}');
    } catch (error) {
      print('❌ [DinorTVScreen] Erreur favorite: $error');
    }
  }

  void _closeAuthModal() {
    setState(() {
      _showAuthModal = false;
      _authModalMessage = '';
    });
  }

  void _displayAuthModal() {
    // Vérifier que le contexte est prêt avant d'afficher la modale
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _showAuthModal) {
        showDialog(
          context: context,
          barrierDismissible: true,
          useRootNavigator: true,
          builder: (BuildContext context) {
            return AuthModal(
              isOpen: true,
              onClose: () {
                Navigator.of(context, rootNavigator: true).pop();
                setState(() => _showAuthModal = false);
              },
              onAuthenticated: () {
                Navigator.of(context, rootNavigator: true).pop();
                setState(() => _showAuthModal = false);
              },
            );
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    

    
    final dinorTVState = ref.watch(dinorTVProvider);
    final videos = dinorTVState.videos;
    final loading = dinorTVState.loading;
    final error = dinorTVState.error;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: CustomScrollView(
          slivers: [
            // Header compact avec logo
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 16,
                  right: 16,
                  bottom: 12,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3748)),
                      onPressed: () => NavigationService.pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                    Expanded(
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/images/LOGO_DINOR_monochrome.svg',
                          width: 28,
                          height: 28,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFF2D3748),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 32), // Pour équilibrer le bouton retour
                  ],
                ),
              ),
            ),
            // Bannières Dinor TV
            if (_banners.isNotEmpty)
              SliverToBoxAdapter(
                child: BannerSection(
                  type: 'dinor-tv',
                  section: 'hero',
                  banners: _banners,
                  height: 150, // Hauteur réduite pour Dinor TV
                ),
              ),
            // Contenu principal - Filtrer les vidéos vides et enlever les marges
            SliverToBoxAdapter(
              child: ContentGalleryGrid(
                title: 'Dinor TV',
                items: videos.where((video) => 
                  video != null && 
                  video['video_url'] != null && 
                  video['video_url'].toString().isNotEmpty &&
                  video['title'] != null &&
                  video['title'].toString().isNotEmpty
                ).toList(),
                loading: loading,
                error: error,
                contentType: 'videos',
                viewAllLink: '/dinor-tv', 
                onItemClick: _handleVideoClick,
                darkTheme: true,
              ),
            ),
          ],
        ),
      ),
    );
  }


}