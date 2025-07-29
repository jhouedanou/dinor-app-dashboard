import { Platform } from 'react-native';

interface ShareData {
  title: string;
  text?: string;
  url?: string;
  type?: 'recipe' | 'tip' | 'event' | 'video';
  id?: string;
}

interface ApiResponse {
  success: boolean;
  data?: any;
  message?: string;
}

class ApiService {
  private static baseUrl = 'https://new.dinor.app/api/v1';

  private static getDefaultHeaders(): Record<string, string> {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  /**
   * Récupérer l'URL de partage depuis l'API
   */
  static async getShareUrl({
    type,
    id,
    platform,
  }: {
    type: string;
    id: string;
    platform?: string;
  }): Promise<string | null> {
    try {
      console.log('📡 [ApiService] Récupération URL de partage:', type, id);
      
      const params = new URLSearchParams({
        type,
        id,
        ...(platform && { platform }),
      });

      const response = await fetch(`${this.baseUrl}/shares/url?${params}`, {
        method: 'GET',
        headers: this.getDefaultHeaders(),
      });

      if (response.ok) {
        const data: ApiResponse = await response.json();
        if (data.success && data.data?.url) {
          const shareUrl = data.data.url;
          console.log('✅ [ApiService] URL de partage récupérée:', shareUrl);
          return shareUrl;
        }
      }
      
      console.log('❌ [ApiService] Échec récupération URL de partage:', response.status);
      return null;
    } catch (error) {
      console.error('💥 [ApiService] Erreur récupération URL de partage:', error);
      return null;
    }
  }

  /**
   * Récupérer les métadonnées de partage depuis l'API
   */
  static async getShareMetadata({
    type,
    id,
  }: {
    type: string;
    id: string;
  }): Promise<Record<string, any> | null> {
    try {
      console.log('📡 [ApiService] Récupération métadonnées:', type, id);
      
      const params = new URLSearchParams({ type, id });
      const response = await fetch(`${this.baseUrl}/shares/metadata?${params}`, {
        method: 'GET',
        headers: this.getDefaultHeaders(),
      });

      if (response.ok) {
        const data: ApiResponse = await response.json();
        if (data.success && data.data) {
          console.log('✅ [ApiService] Métadonnées récupérées');
          return data.data;
        }
      }
      
      console.log('❌ [ApiService] Échec récupération métadonnées:', response.status);
      return null;
    } catch (error) {
      console.error('💥 [ApiService] Erreur récupération métadonnées:', error);
      return null;
    }
  }

  /**
   * Tracker un partage dans l'API
   */
  static async trackShare({
    type,
    id,
    platform,
  }: {
    type: string;
    id: string;
    platform: string;
  }): Promise<boolean> {
    try {
      console.log('📡 [ApiService] Tracking partage:', type, id, platform);
      
      const response = await fetch(`${this.baseUrl}/shares/track`, {
        method: 'POST',
        headers: this.getDefaultHeaders(),
        body: JSON.stringify({
          type,
          id,
          platform,
        }),
      });

      if (response.ok) {
        const data: ApiResponse = await response.json();
        if (data.success) {
          console.log('✅ [ApiService] Partage tracké avec succès');
          return true;
        }
      }
      
      console.log('❌ [ApiService] Échec tracking partage:', response.status);
      return false;
    } catch (error) {
      console.error('💥 [ApiService] Erreur tracking partage:', error);
      return false;
    }
  }

  /**
   * Récupérer les données complètes de partage (URL + métadonnées)
   */
  static async getCompleteShareData({
    type,
    id,
    platform,
  }: {
    type: string;
    id: string;
    platform?: string;
  }): Promise<Record<string, any> | null> {
    try {
      console.log('📡 [ApiService] Récupération données complètes:', type, id);
      
      // Récupérer l'URL de partage
      const shareUrl = await this.getShareUrl({ type, id, platform });
      if (!shareUrl) {
        console.log('❌ [ApiService] Impossible de récupérer l\'URL de partage');
        return null;
      }
      
      // Récupérer les métadonnées
      const metadata = await this.getShareMetadata({ type, id });
      
      // Combiner les données
      const completeData = {
        url: shareUrl,
        title: metadata?.title ?? 'Dinor',
        description: metadata?.description ?? 'Découvrez ceci sur Dinor',
        image: metadata?.image,
        type,
        id,
      };
      
      console.log('✅ [ApiService] Données complètes récupérées');
      return completeData;
    } catch (error) {
      console.error('💥 [ApiService] Erreur récupération données complètes:', error);
      return null;
    }
  }
}

export default ApiService; 