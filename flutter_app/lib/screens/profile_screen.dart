/**
 * PROFILE_SCREEN.DART - ÉCRAN PROFIL UTILISATEUR
 * 
 * FIDÉLITÉ VISUELLE :
 * - Design moderne avec avatar utilisateur
 * - Informations du profil
 * - Section paramètres
 * - Section favoris et historique
 * 
 * FIDÉLITÉ FONCTIONNELLE :
 * - Gestion du profil utilisateur
 * - Authentification et déconnexion
 * - Paramètres de l'application
 * - Navigation vers les favoris
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Composables
import '../composables/use_auth_handler.dart';

// Services
import '../services/api_service.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> with AutomaticKeepAliveClientMixin {
  Map<String, dynamic>? _user;
  bool _loading = true;
  String? _error;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    print('👤 [ProfileScreen] Écran profil initialisé');
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      print('👤 [ProfileScreen] Chargement profil utilisateur');
      final data = await ApiService.instance.getCurrentUser();

      if (data['success'] == true) {
        setState(() {
          _user = data['data'];
          _loading = false;
        });
        print('✅ [ProfileScreen] Profil utilisateur chargé');
      } else {
        throw Exception(data['message'] ?? 'Erreur lors du chargement du profil');
      }
    } catch (error) {
      print('❌ [ProfileScreen] Erreur: $error');
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    try {
      print('🚪 [ProfileScreen] Déconnexion...');
      await ApiService.instance.logout();
      
      final authHandler = ref.read(authHandlerProvider.notifier);
      await authHandler.logout();
      
      if (mounted) {
        context.go('/login');
      }
    } catch (error) {
      print('❌ [ProfileScreen] Erreur déconnexion: $error');
    }
  }

  void _handleEditProfile() {
    // TODO: Navigation vers écran d'édition du profil
    print('✏️ [ProfileScreen] Édition du profil');
  }

  void _handleFavorites() {
    // TODO: Navigation vers les favoris
    print('⭐ [ProfileScreen] Navigation vers favoris');
  }

  void _handleHistory() {
    // TODO: Navigation vers l'historique
    print('📚 [ProfileScreen] Navigation vers historique');
  }

  void _handleSettings() {
    // TODO: Navigation vers les paramètres
    print('⚙️ [ProfileScreen] Navigation vers paramètres');
  }

  void _handleAbout() {
    // TODO: Navigation vers à propos
    print('ℹ️ [ProfileScreen] Navigation vers à propos');
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    final authHandler = ref.watch(authHandlerProvider);
    
    if (!authHandler.isAuthenticated) {
      return _buildNotAuthenticated();
    }

    if (_loading) {
      return _buildLoading();
    }

    if (_error != null) {
      return _buildError();
    }

    return _buildProfile();
  }

  Widget _buildNotAuthenticated() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Profil',
          style: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3748)),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.person_outline,
              size: 64,
              color: Color(0xFFCBD5E0),
            ),
            const SizedBox(height: 16),
            const Text(
              'Connectez-vous pour voir votre profil',
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Accédez à vos favoris et paramètres',
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 14,
                color: Color(0xFF718096),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.push('/login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF4D03F),
                foregroundColor: const Color(0xFF2D3748),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Se connecter',
                style: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF4D03F)),
            ),
            SizedBox(height: 16),
            Text(
              'Chargement du profil...',
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 16,
                color: Color(0xFF718096),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Erreur'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3748)),
          onPressed: () => context.pop(),
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
              onPressed: _loadUserProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF4D03F),
                foregroundColor: const Color(0xFF2D3748),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfile() {
    final name = _user?['name'] ?? 'Utilisateur';
    final email = _user?['email'] ?? '';
    final avatar = _user?['avatar'] ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Profil',
          style: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3748)),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF2D3748)),
            onPressed: _handleEditProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Section profil utilisateur
            _buildUserSection(name, email, avatar),
            const SizedBox(height: 24),
            // Section actions
            _buildActionsSection(),
            const SizedBox(height: 24),
            // Section paramètres
            _buildSettingsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserSection(String name, String email, String avatar) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          CircleAvatar(
            radius: 50,
            backgroundColor: const Color(0xFFE2E8F0),
            backgroundImage: avatar.isNotEmpty ? CachedNetworkImageProvider(avatar) : null,
            child: avatar.isEmpty
                ? const Icon(
                    Icons.person,
                    size: 50,
                    color: Color(0xFFCBD5E0),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          // Nom
          Text(
            name,
            style: const TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 4),
          // Email
          Text(
            email,
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

  Widget _buildActionsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildActionTile(
            icon: Icons.favorite_outline,
            title: 'Mes favoris',
            subtitle: 'Recettes, astuces et événements',
            onTap: _handleFavorites,
          ),
          _buildDivider(),
          _buildActionTile(
            icon: Icons.history,
            title: 'Historique',
            subtitle: 'Vos dernières activités',
            onTap: _handleHistory,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildActionTile(
            icon: Icons.settings_outlined,
            title: 'Paramètres',
            subtitle: 'Préférences de l\'application',
            onTap: _handleSettings,
          ),
          _buildDivider(),
          _buildActionTile(
            icon: Icons.info_outline,
            title: 'À propos',
            subtitle: 'Informations sur l\'application',
            onTap: _handleAbout,
          ),
          _buildDivider(),
          _buildActionTile(
            icon: Icons.logout,
            title: 'Se déconnecter',
            subtitle: 'Fermer votre session',
            onTap: _handleLogout,
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? const Color(0xFFE53E3E) : const Color(0xFFF4D03F),
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'OpenSans',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isDestructive ? const Color(0xFFE53E3E) : const Color(0xFF2D3748),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontFamily: 'OpenSans',
          fontSize: 14,
          color: Color(0xFF718096),
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Color(0xFFCBD5E0),
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      color: Color(0xFFE2E8F0),
      indent: 56,
    );
  }
}