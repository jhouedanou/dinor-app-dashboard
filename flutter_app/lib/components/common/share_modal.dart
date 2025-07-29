/**
 * SHARE_MODAL.DART - CONVERSION FIDÈLE DE ShareModal.vue
 * 
 * FIDÉLITÉ FONCTIONNELLE :
 * - Modal de partage identique
 * - Options de partage identiques
 * - Share API native ou fallback
 */

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class ShareModal extends StatelessWidget {
  final bool isOpen;
  final Map<String, dynamic> shareData;
  final VoidCallback? onClose;

  const ShareModal({
    Key? key,
    required this.isOpen,
    required this.shareData,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isOpen) return const SizedBox.shrink();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Partager',
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Content Preview
            if (shareData['title'] != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    if (shareData['image'] != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          shareData['image'],
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF4D03F),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                LucideIcons.image,
                                color: Color(0xFF2D3748),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            shareData['title'] ?? '',
                            style: const TextStyle(
                              fontFamily: 'OpenSans',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D3748),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (shareData['text'] != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              shareData['text'],
                              style: const TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 14,
                                color: Color(0xFF4A5568),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Share Options
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareOption(
                  icon: LucideIcons.share2,
                  label: 'Partager',
                  onTap: () => _shareContent(),
                ),
                _buildShareOption(
                  icon: LucideIcons.copy,
                  label: 'Copier le lien',
                  onTap: () => _copyLink(context),
                ),
                _buildShareOption(
                  icon: LucideIcons.messageCircle,
                  label: 'SMS',
                  onTap: () => _shareViaSMS(),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Social Media Options
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareOption(
                  icon: LucideIcons.facebook,
                  label: 'Facebook',
                  onTap: () => _shareToFacebook(context),
                ),
                _buildShareOption(
                  icon: LucideIcons.twitter,
                  label: 'Twitter',
                  onTap: () => _shareToTwitter(context),
                ),
                _buildShareOption(
                  icon: LucideIcons.mail,
                  label: 'Email',
                  onTap: () => _shareViaEmail(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF4D03F),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF2D3748),
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 12,
                color: Color(0xFF4A5568),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareContent() {
    final title = shareData['title'] ?? 'Contenu Dinor';
    final description = shareData['text'] ?? shareData['description'] ?? '';
    final url = shareData['url'] ?? '';
    
    final text = '$title\n\n$description\n\nDécouvrez plus sur Dinor:\n$url';
    Share.share(text, subject: title);
    print('📤 [ShareModal] Partage natif: $title');
  }

  void _copyLink(BuildContext context) async {
    try {
      final url = shareData['url'] ?? '';
      await Clipboard.setData(ClipboardData(text: url));
      
      // Afficher un feedback visuel
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lien copié dans le presse-papier'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      
      print('📋 [ShareModal] Lien copié: $url');
    } catch (e) {
      print('❌ [ShareModal] Erreur copie: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la copie'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _shareViaSMS() {
    final text = '${shareData['title']}\n\n${shareData['text'] ?? ''}\n\n${shareData['url'] ?? ''}';
    Share.share(text, subject: shareData['title']);
  }

  void _shareToFacebook(BuildContext context) async {
    final shareUrl = shareData['url'] ?? 'https://new.dinor.app';
    final url = 'https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(shareUrl)}';
    await _launchUrl(context, url);
    print('📘 [ShareModal] Partager sur Facebook: $shareUrl');
  }

  void _shareToTwitter(BuildContext context) async {
    final title = shareData['title'] ?? 'Contenu Dinor';
    final shareUrl = shareData['url'] ?? 'https://new.dinor.app';
    final text = '$title $shareUrl';
    final url = 'https://twitter.com/intent/tweet?text=${Uri.encodeComponent(text)}';
    await _launchUrl(context, url);
    print('🐦 [ShareModal] Partager sur Twitter: $shareUrl');
  }

  void _shareViaEmail(BuildContext context) async {
    final subject = shareData['title'] ?? 'Partage Dinor';
    final description = shareData['text'] ?? shareData['description'] ?? 'Découvrez ce contenu sur Dinor';
    final shareUrl = shareData['url'] ?? 'https://new.dinor.app';
    final body = '$description\n\n$shareUrl';
    final url = 'mailto:?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}';
    await _launchUrl(context, url);
    print('📧 [ShareModal] Partager par email: $shareUrl');
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        print('❌ [ShareModal] Impossible d\'ouvrir l\'URL: $url');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible d\'ouvrir l\'application'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      print('❌ [ShareModal] Erreur ouverture URL: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de l\'ouverture'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}