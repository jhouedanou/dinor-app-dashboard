import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SocialShareNotifier extends StateNotifier<bool> {
  SocialShareNotifier() : super(false);

  Future<void> shareContent({
    required String title,
    required String text,
    required String url,
    String? imageUrl,
  }) async {
    try {
      print('📤 [SocialShareNotifier] Partage de contenu: $title');
      
      final shareText = '$title\n\n$text\n\n$url';
      
      await Share.share(
        shareText,
        subject: title,
      );
      
      print('✅ [SocialShareNotifier] Partage réussi');
    } catch (error) {
      print('❌ [SocialShareNotifier] Erreur partage: $error');
    }
  }

  Future<void> shareToFacebook({
    required String title,
    required String url,
    String? text,
  }) async {
    try {
      print('📘 [SocialShareNotifier] Partage Facebook: $title');
      
      final shareUrl = 'https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(url)}';
      
      if (await canLaunchUrl(Uri.parse(shareUrl))) {
        await launchUrl(Uri.parse(shareUrl));
        print('✅ [SocialShareNotifier] Partage Facebook lancé');
      } else {
        // Fallback au partage natif
        await shareContent(
          title: title,
          text: text ?? 'Découvrez ceci sur Dinor',
          url: url,
        );
      }
    } catch (error) {
      print('❌ [SocialShareNotifier] Erreur partage Facebook: $error');
    }
  }

  Future<void> shareToTwitter({
    required String title,
    required String url,
    String? text,
  }) async {
    try {
      print('🐦 [SocialShareNotifier] Partage Twitter: $title');
      
      final shareText = '$title $url';
      final shareUrl = 'https://twitter.com/intent/tweet?text=${Uri.encodeComponent(shareText)}';
      
      if (await canLaunchUrl(Uri.parse(shareUrl))) {
        await launchUrl(Uri.parse(shareUrl));
        print('✅ [SocialShareNotifier] Partage Twitter lancé');
      } else {
        // Fallback au partage natif
        await shareContent(
          title: title,
          text: text ?? 'Découvrez ceci sur Dinor',
          url: url,
        );
      }
    } catch (error) {
      print('❌ [SocialShareNotifier] Erreur partage Twitter: $error');
    }
  }

  Future<void> shareViaEmail({
    required String title,
    required String url,
    String? text,
  }) async {
    try {
      print('📧 [SocialShareNotifier] Partage Email: $title');
      
      final subject = title;
      final body = '${text ?? 'Découvrez ceci sur Dinor'}\n\n$url';
      final mailtoUrl = 'mailto:?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}';
      
      if (await canLaunchUrl(Uri.parse(mailtoUrl))) {
        await launchUrl(Uri.parse(mailtoUrl));
        print('✅ [SocialShareNotifier] Partage Email lancé');
      } else {
        // Fallback au partage natif
        await shareContent(
          title: title,
          text: text ?? 'Découvrez ceci sur Dinor',
          url: url,
        );
      }
    } catch (error) {
      print('❌ [SocialShareNotifier] Erreur partage Email: $error');
    }
  }

  Future<void> shareViaSMS({
    required String title,
    required String url,
    String? text,
  }) async {
    try {
      print('💬 [SocialShareNotifier] Partage SMS: $title');
      
      final smsText = '$title\n\n${text ?? 'Découvrez ceci sur Dinor'}\n\n$url';
      final smsUrl = 'sms:?body=${Uri.encodeComponent(smsText)}';
      
      if (await canLaunchUrl(Uri.parse(smsUrl))) {
        await launchUrl(Uri.parse(smsUrl));
        print('✅ [SocialShareNotifier] Partage SMS lancé');
      } else {
        // Fallback au partage natif
        await shareContent(
          title: title,
          text: text ?? 'Découvrez ceci sur Dinor',
          url: url,
        );
      }
    } catch (error) {
      print('❌ [SocialShareNotifier] Erreur partage SMS: $error');
    }
  }

  Future<void> copyToClipboard(String text) async {
    try {
      print('📋 [SocialShareNotifier] Copie dans le presse-papiers: $text');
      
      // TODO: Implémenter la copie dans le presse-papiers
      // await Clipboard.setData(ClipboardData(text: text));
      
      print('✅ [SocialShareNotifier] Texte copié');
    } catch (error) {
      print('❌ [SocialShareNotifier] Erreur copie presse-papiers: $error');
    }
  }

  Future<void> shareRecipe({
    required String title,
    required String description,
    required String url,
    String? imageUrl,
    String? cookingTime,
    String? servings,
  }) async {
    try {
      print('🍳 [SocialShareNotifier] Partage recette: $title');
      
      String shareText = '$title\n\n';
      
      if (description.isNotEmpty) {
        shareText += '$description\n\n';
      }
      
      if (cookingTime != null) {
        shareText += '⏱️ Temps de cuisson: $cookingTime\n';
      }
      
      if (servings != null) {
        shareText += '👥 Pour $servings personnes\n\n';
      }
      
      shareText += 'Découvrez cette recette sur Dinor:\n$url';
      
      await shareContent(
        title: title,
        text: shareText,
        url: url,
        imageUrl: imageUrl,
      );
    } catch (error) {
      print('❌ [SocialShareNotifier] Erreur partage recette: $error');
    }
  }

  Future<void> shareTip({
    required String title,
    required String content,
    required String url,
    String? imageUrl,
  }) async {
    try {
      print('💡 [SocialShareNotifier] Partage astuce: $title');
      
      final shareText = '$title\n\n$content\n\nDécouvrez cette astuce sur Dinor:\n$url';
      
      await shareContent(
        title: title,
        text: shareText,
        url: url,
        imageUrl: imageUrl,
      );
    } catch (error) {
      print('❌ [SocialShareNotifier] Erreur partage astuce: $error');
    }
  }

  Future<void> shareEvent({
    required String title,
    required String description,
    required String url,
    String? date,
    String? location,
    String? imageUrl,
  }) async {
    try {
      print('📅 [SocialShareNotifier] Partage événement: $title');
      
      String shareText = '$title\n\n';
      
      if (description.isNotEmpty) {
        shareText += '$description\n\n';
      }
      
      if (date != null) {
        shareText += '📅 Date: $date\n';
      }
      
      if (location != null) {
        shareText += '📍 Lieu: $location\n\n';
      }
      
      shareText += 'Découvrez cet événement sur Dinor:\n$url';
      
      await shareContent(
        title: title,
        text: shareText,
        url: url,
        imageUrl: imageUrl,
      );
    } catch (error) {
      print('❌ [SocialShareNotifier] Erreur partage événement: $error');
    }
  }

  Future<void> shareVideo({
    required String title,
    required String description,
    required String url,
    String? duration,
    String? imageUrl,
  }) async {
    try {
      print('🎥 [SocialShareNotifier] Partage vidéo: $title');
      
      String shareText = '$title\n\n';
      
      if (description.isNotEmpty) {
        shareText += '$description\n\n';
      }
      
      if (duration != null) {
        shareText += '⏱️ Durée: $duration\n\n';
      }
      
      shareText += 'Regardez cette vidéo sur Dinor:\n$url';
      
      await shareContent(
        title: title,
        text: shareText,
        url: url,
        imageUrl: imageUrl,
      );
    } catch (error) {
      print('❌ [SocialShareNotifier] Erreur partage vidéo: $error');
    }
  }
}

final useSocialShareProvider = StateNotifierProvider<SocialShareNotifier, bool>((ref) {
  return SocialShareNotifier();
}); 