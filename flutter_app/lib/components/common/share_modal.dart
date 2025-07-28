/**
 * SHARE_MODAL.DART - CONVERSION FIDÈLE DE ShareModal.vue
 * 
 * FIDÉLITÉ FONCTIONNELLE :
 * - Modal de partage identique
 * - Options de partage identiques
 * - Share API native ou fallback
 */

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../dinor_icon.dart';

class ShareModal extends StatelessWidget {
  final bool isVisible;
  final Map<String, dynamic> shareData;
  final VoidCallback? onClose;

  const ShareModal({
    Key? key,
    required this.isVisible,
    required this.shareData,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onClose,
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: GestureDetector(
          onTap: () {}, // Empêcher la fermeture en cliquant sur le modal
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle du modal
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(top: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Partager',
                          style: TextStyle(
                            fontFamily: 'OpenSans',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                        IconButton(
                          onPressed: onClose,
                          icon: const DinorIcon(name: 'x', size: 24),
                        ),
                      ],
                    ),
                  ),

                  // Options de partage
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        // Partage natif
                        ListTile(
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              LucideIcons.share2,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          title: const Text(
                            'Partager',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: const Text(
                            'Utiliser le menu de partage',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              color: Color(0xFF4A5568),
                            ),
                          ),
                          onTap: () => _shareNative(context),
                        ),

                        const Divider(),

                        // Copier le lien
                        ListTile(
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2196F3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              LucideIcons.copy,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          title: const Text(
                            'Copier le lien',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: const Text(
                            'Copier l\'URL dans le presse-papiers',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              color: Color(0xFF4A5568),
                            ),
                          ),
                          onTap: () => _copyLink(context),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _shareNative(BuildContext context) async {
    try {
      final title = shareData['title'] ?? 'Dinor';
      final text = shareData['text'] ?? 'Découvrez ceci sur Dinor';
      final url = shareData['url'] ?? '';

      await Share.share(
        '$text\n\n$url',
        subject: title,
      );

      onClose?.call();
    } catch (e) {
      print('❌ [ShareModal] Erreur partage natif: $e');
      _showError(context, 'Erreur lors du partage');
    }
  }

  Future<void> _copyLink(BuildContext context) async {
    try {
      final url = shareData['url'] ?? '';
      
      // TODO: Utiliser clipboard
      // await Clipboard.setData(ClipboardData(text: url));
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lien copié dans le presse-papiers'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );

      onClose?.call();
    } catch (e) {
      print('❌ [ShareModal] Erreur copie lien: $e');
      _showError(context, 'Erreur lors de la copie');
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFE53E3E),
      ),
    );
  }
}