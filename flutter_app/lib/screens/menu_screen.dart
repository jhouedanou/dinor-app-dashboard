import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7), // Fond gris clair comme l'image
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Menu',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto',
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(0),
        children: [
          // Section Organisation
          _buildSectionHeader('Organisation'),
          _buildMenuTile(
            icon: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B35), // Orange Dinor
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'B',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            title: 'Big Five Abidjan',
            onTap: () {
              // Navigation vers organisation
            },
          ),
          
          const SizedBox(height: 8),
          
          _buildMenuTile(
            icon: const Icon(
              LucideIcons.briefcase,
              size: 24,
              color: Colors.black87,
            ),
            title: 'Congés',
            onTap: () {
              // Navigation vers congés
            },
          ),

          // Section Compte
          _buildSectionHeader('Compte'),
          _buildMenuTile(
            icon: const Icon(
              LucideIcons.userCog,
              size: 24,
              color: Colors.black87,
            ),
            title: 'Paramètres personnels',
            onTap: () {
              // Navigation vers paramètres
            },
          ),

          // Section Aide
          _buildSectionHeader('Aide'),
          _buildMenuTile(
            icon: const Icon(
              LucideIcons.helpCircle,
              size: 24,
              color: Colors.black87,
            ),
            title: 'Assistance',
            onTap: () {
              // Navigation vers assistance
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
          fontFamily: 'Roboto',
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required Widget icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: SizedBox(
          width: 50,
          height: 50,
          child: Center(child: icon),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
            fontFamily: 'Roboto',
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Colors.grey,
          size: 20,
        ),
        onTap: onTap,
      ),
    );
  }
}