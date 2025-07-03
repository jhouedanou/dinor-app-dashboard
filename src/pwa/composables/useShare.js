import { ref } from 'vue'

export function useShare() {
  const isSharing = ref(false)
  const shareError = ref(null)

  // Partage via l'API Web Share native si disponible
  const canShare = () => {
    return 'share' in navigator
  }

  // Partage simple via l'API native
  const share = async (data) => {
    if (!canShare()) {
      shareError.value = 'Le partage n\'est pas supporté sur cet appareil'
      return false
    }

    try {
      isSharing.value = true
      shareError.value = null

      await navigator.share({
        title: data.title || document.title,
        text: data.text || data.description || '',
        url: data.url || window.location.href
      })

      return true
    } catch (error) {
      if (error.name !== 'AbortError') {
        console.error('Erreur lors du partage:', error)
        shareError.value = 'Erreur lors du partage'
      }
      return false
    } finally {
      isSharing.value = false
    }
  }

  // Copier l'URL dans le presse-papier
  const copyToClipboard = async (text) => {
    try {
      await navigator.clipboard.writeText(text)
      return true
    } catch (error) {
      console.error('Erreur lors de la copie:', error)
      shareError.value = 'Impossible de copier le lien'
      return false
    }
  }

  // Partage via URL (fallback)
  const shareViaUrl = (platform, data) => {
    const { url = window.location.href, title = document.title, text = '' } = data
    let shareUrl = ''

    switch (platform) {
      case 'facebook':
        shareUrl = `https://www.facebook.com/sharer/sharer.php?u=${encodeURIComponent(url)}`
        break
      case 'twitter':
        shareUrl = `https://twitter.com/intent/tweet?url=${encodeURIComponent(url)}&text=${encodeURIComponent(text || title)}`
        break
      case 'whatsapp':
        shareUrl = `https://wa.me/?text=${encodeURIComponent((text || title) + ' ' + url)}`
        break
      case 'telegram':
        shareUrl = `https://t.me/share/url?url=${encodeURIComponent(url)}&text=${encodeURIComponent(text || title)}`
        break
      default:
        shareError.value = 'Plateforme non supportée'
        return false
    }

    if (shareUrl) {
      window.open(shareUrl, '_blank', 'width=600,height=400')
      return true
    }

    return false
  }

  return {
    isSharing,
    shareError,
    canShare,
    share,
    copyToClipboard,
    shareViaUrl
  }
}