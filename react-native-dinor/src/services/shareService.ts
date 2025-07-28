import { Share, Platform } from 'react-native';
import { Linking } from 'react-native';

interface ShareData {
  title: string;
  text?: string;
  url?: string;
  type?: 'recipe' | 'tip' | 'event' | 'video';
  id?: string;
}

class ShareService {
  /**
   * Partage natif via l'API système
   */
  static async shareContent(data: ShareData): Promise<boolean> {
    try {
      console.log('📤 [ShareService] Partage natif:', data.title);
      
      let shareText = data.title;
      if (data.text) {
        shareText += '\n\n' + data.text;
      }
      if (data.url) {
        shareText += '\n\n' + data.url;
      }
      
      const result = await Share.share({
        title: data.title,
        message: shareText,
        url: data.url,
      });
      
      if (result.action === Share.sharedAction) {
        console.log('✅ [ShareService] Partage réussi');
        return true;
      } else {
        console.log('❌ [ShareService] Partage annulé');
        return false;
      }
    } catch (error) {
      console.error('❌ [ShareService] Erreur partage:', error);
      return false;
    }
  }

  /**
   * Partage via WhatsApp
   */
  static async shareToWhatsApp(data: ShareData): Promise<boolean> {
    try {
      console.log('📱 [ShareService] Partage WhatsApp:', data.title);
      
      let shareText = data.title;
      if (data.text) {
        shareText += '\n\n' + data.text;
      }
      if (data.url) {
        shareText += '\n\n' + data.url;
      }
      
      const whatsappUrl = `whatsapp://send?text=${encodeURIComponent(shareText)}`;
      
      const canOpen = await Linking.canOpenURL(whatsappUrl);
      if (canOpen) {
        await Linking.openURL(whatsappUrl);
        console.log('✅ [ShareService] Partage WhatsApp lancé');
        return true;
      } else {
        // Fallback au partage natif
        return await this.shareContent(data);
      }
    } catch (error) {
      console.error('❌ [ShareService] Erreur partage WhatsApp:', error);
      // Fallback au partage natif
      return await this.shareContent(data);
    }
  }

  /**
   * Partage via Facebook
   */
  static async shareToFacebook(data: ShareData): Promise<boolean> {
    try {
      console.log('📘 [ShareService] Partage Facebook:', data.title);
      
      if (!data.url) {
        console.error('❌ [ShareService] URL requise pour Facebook');
        return false;
      }
      
      const facebookUrl = `https://www.facebook.com/sharer/sharer.php?u=${encodeURIComponent(data.url)}`;
      
      const canOpen = await Linking.canOpenURL(facebookUrl);
      if (canOpen) {
        await Linking.openURL(facebookUrl);
        console.log('✅ [ShareService] Partage Facebook lancé');
        return true;
      } else {
        // Fallback au partage natif
        return await this.shareContent(data);
      }
    } catch (error) {
      console.error('❌ [ShareService] Erreur partage Facebook:', error);
      // Fallback au partage natif
      return await this.shareContent(data);
    }
  }

  /**
   * Partage via Twitter/X
   */
  static async shareToTwitter(data: ShareData): Promise<boolean> {
    try {
      console.log('🐦 [ShareService] Partage Twitter:', data.title);
      
      let shareText = data.title;
      if (data.url) {
        shareText += ' ' + data.url;
      }
      
      const twitterUrl = `https://twitter.com/intent/tweet?text=${encodeURIComponent(shareText)}`;
      
      const canOpen = await Linking.canOpenURL(twitterUrl);
      if (canOpen) {
        await Linking.openURL(twitterUrl);
        console.log('✅ [ShareService] Partage Twitter lancé');
        return true;
      } else {
        // Fallback au partage natif
        return await this.shareContent(data);
      }
    } catch (error) {
      console.error('❌ [ShareService] Erreur partage Twitter:', error);
      // Fallback au partage natif
      return await this.shareContent(data);
    }
  }

  /**
   * Partage via Email
   */
  static async shareViaEmail(data: ShareData): Promise<boolean> {
    try {
      console.log('📧 [ShareService] Partage Email:', data.title);
      
      const subject = data.title;
      let body = data.text || 'Découvrez ceci sur Dinor';
      if (data.url) {
        body += '\n\n' + data.url;
      }
      
      const mailtoUrl = `mailto:?subject=${encodeURIComponent(subject)}&body=${encodeURIComponent(body)}`;
      
      const canOpen = await Linking.canOpenURL(mailtoUrl);
      if (canOpen) {
        await Linking.openURL(mailtoUrl);
        console.log('✅ [ShareService] Partage Email lancé');
        return true;
      } else {
        // Fallback au partage natif
        return await this.shareContent(data);
      }
    } catch (error) {
      console.error('❌ [ShareService] Erreur partage Email:', error);
      // Fallback au partage natif
      return await this.shareContent(data);
    }
  }

  /**
   * Partage via SMS
   */
  static async shareViaSMS(data: ShareData): Promise<boolean> {
    try {
      console.log('💬 [ShareService] Partage SMS:', data.title);
      
      let smsText = data.title;
      if (data.text) {
        smsText += '\n\n' + data.text;
      }
      if (data.url) {
        smsText += '\n\n' + data.url;
      }
      
      const smsUrl = `sms:?body=${encodeURIComponent(smsText)}`;
      
      const canOpen = await Linking.canOpenURL(smsUrl);
      if (canOpen) {
        await Linking.openURL(smsUrl);
        console.log('✅ [ShareService] Partage SMS lancé');
        return true;
      } else {
        // Fallback au partage natif
        return await this.shareContent(data);
      }
    } catch (error) {
      console.error('❌ [ShareService] Erreur partage SMS:', error);
      // Fallback au partage natif
      return await this.shareContent(data);
    }
  }

  /**
   * Partage de recette avec formatage spécial
   */
  static async shareRecipe(data: {
    title: string;
    description: string;
    url: string;
    cookingTime?: string;
    servings?: string;
  }): Promise<boolean> {
    try {
      console.log('🍳 [ShareService] Partage recette:', data.title);
      
      let shareText = data.title + '\n\n';
      
      if (data.description) {
        shareText += data.description + '\n\n';
      }
      
      if (data.cookingTime) {
        shareText += '⏱️ Temps de cuisson: ' + data.cookingTime + '\n';
      }
      
      if (data.servings) {
        shareText += '👥 Pour ' + data.servings + ' personnes\n\n';
      }
      
      shareText += 'Découvrez cette recette sur Dinor:\n' + data.url;
      
      return await this.shareContent({
        title: data.title,
        text: shareText,
        url: data.url,
        type: 'recipe',
      });
    } catch (error) {
      console.error('❌ [ShareService] Erreur partage recette:', error);
      return false;
    }
  }

  /**
   * Partage d'astuce avec formatage spécial
   */
  static async shareTip(data: {
    title: string;
    content: string;
    url: string;
  }): Promise<boolean> {
    try {
      console.log('💡 [ShareService] Partage astuce:', data.title);
      
      const shareText = data.title + '\n\n' + data.content + '\n\nDécouvrez cette astuce sur Dinor:\n' + data.url;
      
      return await this.shareContent({
        title: data.title,
        text: shareText,
        url: data.url,
        type: 'tip',
      });
    } catch (error) {
      console.error('❌ [ShareService] Erreur partage astuce:', error);
      return false;
    }
  }

  /**
   * Partage d'événement avec formatage spécial
   */
  static async shareEvent(data: {
    title: string;
    description: string;
    url: string;
    date?: string;
    location?: string;
  }): Promise<boolean> {
    try {
      console.log('📅 [ShareService] Partage événement:', data.title);
      
      let shareText = data.title + '\n\n';
      
      if (data.description) {
        shareText += data.description + '\n\n';
      }
      
      if (data.date) {
        shareText += '📅 Date: ' + data.date + '\n';
      }
      
      if (data.location) {
        shareText += '📍 Lieu: ' + data.location + '\n\n';
      }
      
      shareText += 'Découvrez cet événement sur Dinor:\n' + data.url;
      
      return await this.shareContent({
        title: data.title,
        text: shareText,
        url: data.url,
        type: 'event',
      });
    } catch (error) {
      console.error('❌ [ShareService] Erreur partage événement:', error);
      return false;
    }
  }

  /**
   * Partage de vidéo avec formatage spécial
   */
  static async shareVideo(data: {
    title: string;
    description: string;
    url: string;
    duration?: string;
  }): Promise<boolean> {
    try {
      console.log('🎥 [ShareService] Partage vidéo:', data.title);
      
      let shareText = data.title + '\n\n';
      
      if (data.description) {
        shareText += data.description + '\n\n';
      }
      
      if (data.duration) {
        shareText += '⏱️ Durée: ' + data.duration + '\n\n';
      }
      
      shareText += 'Regardez cette vidéo sur Dinor:\n' + data.url;
      
      return await this.shareContent({
        title: data.title,
        text: shareText,
        url: data.url,
        type: 'video',
      });
    } catch (error) {
      console.error('❌ [ShareService] Erreur partage vidéo:', error);
      return false;
    }
  }
}

export default ShareService; 