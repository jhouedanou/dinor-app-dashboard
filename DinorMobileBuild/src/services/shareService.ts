import { Share, Platform } from 'react-native';
import { Linking } from 'react-native';
import ApiService from './apiService';

interface ShareData {
  title: string;
  text?: string;
  url?: string;
  type?: 'recipe' | 'tip' | 'event' | 'video';
  id?: string;
}

class ShareService {
  /**
   * Récupérer les données de partage depuis l'API
   */
  private static async getShareData({
    type,
    id,
    platform,
  }: {
    type: string;
    id: string;
    platform?: string;
  }): Promise<Record<string, any> | null> {
    try {
      console.log('📡 [ShareService] Récupération données de partage:', type, id);
      
      const shareData = await ApiService.getCompleteShareData({
        type,
        id,
        platform,
      });
      
      if (shareData) {
        console.log('✅ [ShareService] Données de partage récupérées:', shareData.url);
        return shareData;
      } else {
        console.log('❌ [ShareService] Impossible de récupérer les données de partage');
        return null;
      }
    } catch (error) {
      console.error('💥 [ShareService] Erreur récupération données de partage:', error);
      return null;
    }
  }

  /**
   * Tracker le partage dans l'API
   */
  private static async trackShare({
    type,
    id,
    platform,
  }: {
    type: string;
    id: string;
    platform: string;
  }): Promise<void> {
    try {
      await ApiService.trackShare({
        type,
        id,
        platform,
      });
      console.log('✅ [ShareService] Partage tracké:', type, id, platform);
    } catch (error) {
      console.error('❌ [ShareService] Erreur tracking partage:', error);
    }
  }

  /**
   * Partage natif via l'API système avec URL depuis l'API
   */
  static async shareContent(data: ShareData): Promise<boolean> {
    try {
      console.log('📤 [ShareService] Partage natif:', data.title);
      
      let shareText = data.title;
      let shareUrl = data.url;
      let shareTitle = data.title;
      let shareDescription = data.text;
      
      // Si on a un type et un ID, récupérer l'URL depuis l'API
      if (data.type && data.id) {
        const shareData = await this.getShareData({
          type: data.type,
          id: data.id,
          platform: 'native',
        });
        if (shareData) {
          shareUrl = shareData.url;
          shareTitle = shareData.title ?? data.title;
          shareDescription = shareData.description ?? data.text;
        }
      }
      
      if (shareDescription) {
        shareText += '\n\n' + shareDescription;
      }
      if (shareUrl) {
        shareText += '\n\n' + shareUrl;
      }
      
      const result = await Share.share({
        title: shareTitle,
        message: shareText,
        url: shareUrl,
      });
      
      if (result.action === Share.sharedAction) {
        console.log('✅ [ShareService] Partage réussi');
        
        // Tracker le partage si on a les informations
        if (data.type && data.id) {
          await this.trackShare({
            type: data.type,
            id: data.id,
            platform: 'native',
          });
        }
        
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
   * Partage via WhatsApp avec URL depuis l'API
   */
  static async shareToWhatsApp(data: ShareData): Promise<boolean> {
    try {
      console.log('📱 [ShareService] Partage WhatsApp:', data.title);
      
      let shareText = data.title;
      let shareUrl = data.url;
      let shareTitle = data.title;
      let shareDescription = data.text;
      
      // Si on a un type et un ID, récupérer l'URL depuis l'API
      if (data.type && data.id) {
        const shareData = await this.getShareData({
          type: data.type,
          id: data.id,
          platform: 'whatsapp',
        });
        if (shareData) {
          shareUrl = shareData.url;
          shareTitle = shareData.title ?? data.title;
          shareDescription = shareData.description ?? data.text;
        }
      }
      
      if (shareDescription) {
        shareText += '\n\n' + shareDescription;
      }
      if (shareUrl) {
        shareText += '\n\n' + shareUrl;
      }
      
      const whatsappUrl = `whatsapp://send?text=${encodeURIComponent(shareText)}`;
      
      const canOpen = await Linking.canOpenURL(whatsappUrl);
      if (canOpen) {
        await Linking.openURL(whatsappUrl);
        console.log('✅ [ShareService] Partage WhatsApp lancé');
        
        // Tracker le partage
        if (data.type && data.id) {
          await this.trackShare({
            type: data.type,
            id: data.id,
            platform: 'whatsapp',
          });
        }
        
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
   * Partage via Facebook avec URL depuis l'API
   */
  static async shareToFacebook(data: ShareData): Promise<boolean> {
    try {
      console.log('📘 [ShareService] Partage Facebook:', data.title);
      
      let shareUrl = data.url;
      let shareTitle = data.title;
      let shareDescription = data.text;
      
      // Si on a un type et un ID, récupérer l'URL depuis l'API
      if (data.type && data.id) {
        const shareData = await this.getShareData({
          type: data.type,
          id: data.id,
          platform: 'facebook',
        });
        if (shareData) {
          shareUrl = shareData.url;
          shareTitle = shareData.title ?? data.title;
          shareDescription = shareData.description ?? data.text;
        }
      }
      
      if (!shareUrl) {
        console.error('❌ [ShareService] URL requise pour Facebook');
        return false;
      }
      
      const facebookUrl = `https://www.facebook.com/sharer/sharer.php?u=${encodeURIComponent(shareUrl)}`;
      
      const canOpen = await Linking.canOpenURL(facebookUrl);
      if (canOpen) {
        await Linking.openURL(facebookUrl);
        console.log('✅ [ShareService] Partage Facebook lancé');
        
        // Tracker le partage
        if (data.type && data.id) {
          await this.trackShare({
            type: data.type,
            id: data.id,
            platform: 'facebook',
          });
        }
        
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
   * Partage via Twitter/X avec URL depuis l'API
   */
  static async shareToTwitter(data: ShareData): Promise<boolean> {
    try {
      console.log('🐦 [ShareService] Partage Twitter:', data.title);
      
      let shareText = data.title;
      let shareUrl = data.url;
      let shareTitle = data.title;
      let shareDescription = data.text;
      
      // Si on a un type et un ID, récupérer l'URL depuis l'API
      if (data.type && data.id) {
        const shareData = await this.getShareData({
          type: data.type,
          id: data.id,
          platform: 'twitter',
        });
        if (shareData) {
          shareUrl = shareData.url;
          shareTitle = shareData.title ?? data.title;
          shareDescription = shareData.description ?? data.text;
        }
      }
      
      if (shareUrl) {
        shareText += ' ' + shareUrl;
      }
      
      const twitterUrl = `https://twitter.com/intent/tweet?text=${encodeURIComponent(shareText)}`;
      
      const canOpen = await Linking.canOpenURL(twitterUrl);
      if (canOpen) {
        await Linking.openURL(twitterUrl);
        console.log('✅ [ShareService] Partage Twitter lancé');
        
        // Tracker le partage
        if (data.type && data.id) {
          await this.trackShare({
            type: data.type,
            id: data.id,
            platform: 'twitter',
          });
        }
        
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
   * Partage via Email avec URL depuis l'API
   */
  static async shareViaEmail(data: ShareData): Promise<boolean> {
    try {
      console.log('📧 [ShareService] Partage Email:', data.title);
      
      let shareUrl = data.url;
      let shareTitle = data.title;
      let shareDescription = data.text;
      
      // Si on a un type et un ID, récupérer l'URL depuis l'API
      if (data.type && data.id) {
        const shareData = await this.getShareData({
          type: data.type,
          id: data.id,
          platform: 'email',
        });
        if (shareData) {
          shareUrl = shareData.url;
          shareTitle = shareData.title ?? data.title;
          shareDescription = shareData.description ?? data.text;
        }
      }
      
      const subject = shareTitle;
      let body = shareDescription || 'Découvrez ceci sur Dinor';
      if (shareUrl) {
        body += '\n\n' + shareUrl;
      }
      
      const mailtoUrl = `mailto:?subject=${encodeURIComponent(subject)}&body=${encodeURIComponent(body)}`;
      
      const canOpen = await Linking.canOpenURL(mailtoUrl);
      if (canOpen) {
        await Linking.openURL(mailtoUrl);
        console.log('✅ [ShareService] Partage Email lancé');
        
        // Tracker le partage
        if (data.type && data.id) {
          await this.trackShare({
            type: data.type,
            id: data.id,
            platform: 'email',
          });
        }
        
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
   * Partage via SMS avec URL depuis l'API
   */
  static async shareViaSMS(data: ShareData): Promise<boolean> {
    try {
      console.log('💬 [ShareService] Partage SMS:', data.title);
      
      let shareText = data.title;
      let shareUrl = data.url;
      let shareTitle = data.title;
      let shareDescription = data.text;
      
      // Si on a un type et un ID, récupérer l'URL depuis l'API
      if (data.type && data.id) {
        const shareData = await this.getShareData({
          type: data.type,
          id: data.id,
          platform: 'sms',
        });
        if (shareData) {
          shareUrl = shareData.url;
          shareTitle = shareData.title ?? data.title;
          shareDescription = shareData.description ?? data.text;
        }
      }
      
      if (shareDescription) {
        shareText += '\n\n' + shareDescription;
      }
      if (shareUrl) {
        shareText += '\n\n' + shareUrl;
      }
      
      const smsUrl = `sms:?body=${encodeURIComponent(shareText)}`;
      
      const canOpen = await Linking.canOpenURL(smsUrl);
      if (canOpen) {
        await Linking.openURL(smsUrl);
        console.log('✅ [ShareService] Partage SMS lancé');
        
        // Tracker le partage
        if (data.type && data.id) {
          await this.trackShare({
            type: data.type,
            id: data.id,
            platform: 'sms',
          });
        }
        
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
   * Partage de recette avec formatage spécial et URL depuis l'API
   */
  static async shareRecipe(data: {
    title: string;
    description: string;
    url: string;
    cookingTime?: string;
    servings?: string;
    type?: string;
    id?: string;
  }): Promise<boolean> {
    try {
      console.log('🍳 [ShareService] Partage recette:', data.title);
      
      let shareText = data.title + '\n\n';
      let shareUrl = data.url;
      let shareTitle = data.title;
      let shareDescription = data.description;
      
      // Si on a un ID, récupérer l'URL depuis l'API
      if (data.id) {
        const shareData = await this.getShareData({
          type: data.type || 'recipe',
          id: data.id,
        });
        if (shareData) {
          shareUrl = shareData.url;
          shareTitle = shareData.title ?? data.title;
          shareDescription = shareData.description ?? data.description;
        }
      }
      
      if (shareDescription) {
        shareText += shareDescription + '\n\n';
      }
      
      if (data.cookingTime) {
        shareText += '⏱️ Temps de cuisson: ' + data.cookingTime + '\n';
      }
      
      if (data.servings) {
        shareText += '👥 Pour ' + data.servings + ' personnes\n\n';
      }
      
      shareText += 'Découvrez cette recette sur Dinor:\n' + shareUrl;
      
      return await this.shareContent({
        title: shareTitle,
        text: shareText,
        url: shareUrl,
        type: data.type || 'recipe',
        id: data.id,
      });
    } catch (error) {
      console.error('❌ [ShareService] Erreur partage recette:', error);
      return false;
    }
  }

  /**
   * Partage d'astuce avec formatage spécial et URL depuis l'API
   */
  static async shareTip(data: {
    title: string;
    content: string;
    url: string;
    type?: string;
    id?: string;
  }): Promise<boolean> {
    try {
      console.log('💡 [ShareService] Partage astuce:', data.title);
      
      let shareText = data.title + '\n\n';
      let shareUrl = data.url;
      let shareTitle = data.title;
      let shareContent = data.content;
      
      // Si on a un ID, récupérer l'URL depuis l'API
      if (data.id) {
        const shareData = await this.getShareData({
          type: data.type || 'tip',
          id: data.id,
        });
        if (shareData) {
          shareUrl = shareData.url;
          shareTitle = shareData.title ?? data.title;
          shareContent = shareData.description ?? data.content;
        }
      }
      
      shareText += shareContent + '\n\nDécouvrez cette astuce sur Dinor:\n' + shareUrl;
      
      return await this.shareContent({
        title: shareTitle,
        text: shareText,
        url: shareUrl,
        type: data.type || 'tip',
        id: data.id,
      });
    } catch (error) {
      console.error('❌ [ShareService] Erreur partage astuce:', error);
      return false;
    }
  }

  /**
   * Partage d'événement avec formatage spécial et URL depuis l'API
   */
  static async shareEvent(data: {
    title: string;
    description: string;
    url: string;
    date?: string;
    location?: string;
    type?: string;
    id?: string;
  }): Promise<boolean> {
    try {
      console.log('📅 [ShareService] Partage événement:', data.title);
      
      let shareText = data.title + '\n\n';
      let shareUrl = data.url;
      let shareTitle = data.title;
      let shareDescription = data.description;
      
      // Si on a un ID, récupérer l'URL depuis l'API
      if (data.id) {
        const shareData = await this.getShareData({
          type: data.type || 'event',
          id: data.id,
        });
        if (shareData) {
          shareUrl = shareData.url;
          shareTitle = shareData.title ?? data.title;
          shareDescription = shareData.description ?? data.description;
        }
      }
      
      if (shareDescription) {
        shareText += shareDescription + '\n\n';
      }
      
      if (data.date) {
        shareText += '📅 Date: ' + data.date + '\n';
      }
      
      if (data.location) {
        shareText += '📍 Lieu: ' + data.location + '\n\n';
      }
      
      shareText += 'Découvrez cet événement sur Dinor:\n' + shareUrl;
      
      return await this.shareContent({
        title: shareTitle,
        text: shareText,
        url: shareUrl,
        type: data.type || 'event',
        id: data.id,
      });
    } catch (error) {
      console.error('❌ [ShareService] Erreur partage événement:', error);
      return false;
    }
  }

  /**
   * Partage de vidéo avec formatage spécial et URL depuis l'API
   */
  static async shareVideo(data: {
    title: string;
    description: string;
    url: string;
    duration?: string;
    type?: string;
    id?: string;
  }): Promise<boolean> {
    try {
      console.log('🎥 [ShareService] Partage vidéo:', data.title);
      
      let shareText = data.title + '\n\n';
      let shareUrl = data.url;
      let shareTitle = data.title;
      let shareDescription = data.description;
      
      // Si on a un ID, récupérer l'URL depuis l'API
      if (data.id) {
        const shareData = await this.getShareData({
          type: data.type || 'video',
          id: data.id,
        });
        if (shareData) {
          shareUrl = shareData.url;
          shareTitle = shareData.title ?? data.title;
          shareDescription = shareData.description ?? data.description;
        }
      }
      
      if (shareDescription) {
        shareText += shareDescription + '\n\n';
      }
      
      if (data.duration) {
        shareText += '⏱️ Durée: ' + data.duration + '\n\n';
      }
      
      shareText += 'Regardez cette vidéo sur Dinor:\n' + shareUrl;
      
      return await this.shareContent({
        title: shareTitle,
        text: shareText,
        url: shareUrl,
        type: data.type || 'video',
        id: data.id,
      });
    } catch (error) {
      console.error('❌ [ShareService] Erreur partage vidéo:', error);
      return false;
    }
  }
}

export default ShareService; 