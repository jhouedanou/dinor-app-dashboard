import { ref } from 'vue'

export const useSocialShare = () => {
  const isSharing = ref(false)
  const showShareModal = ref(false)

  // URLs de partage pour chaque réseau social
  const shareUrls = {
    facebook: (url, title) => 
      `https://www.facebook.com/sharer/sharer.php?u=${encodeURIComponent(url)}`,
    
    twitter: (url, title, text) => 
      `https://twitter.com/intent/tweet?url=${encodeURIComponent(url)}&text=${encodeURIComponent(text || title)}`,
    
    whatsapp: (url, title, text) => 
      `https://wa.me/?text=${encodeURIComponent((text || title) + ' ' + url)}`,
    
    linkedin: (url, title, text) => 
      `https://www.linkedin.com/sharing/share-offsite/?url=${encodeURIComponent(url)}`,
    
    telegram: (url, title, text) => 
      `https://t.me/share/url?url=${encodeURIComponent(url)}&text=${encodeURIComponent(text || title)}`,
    
    email: (url, title, text) => 
      `mailto:?subject=${encodeURIComponent(title)}&body=${encodeURIComponent((text || title) + '\n\n' + url)}`,
    
    pinterest: (url, title, image) => 
      `https://pinterest.com/pin/create/button/?url=${encodeURIComponent(url)}&description=${encodeURIComponent(title)}${image ? '&media=' + encodeURIComponent(image) : ''}`,
  }

  // Partager via l'API native si disponible
  const shareNative = async (data) => {
    if (navigator.share) {
      try {
        isSharing.value = true
        await navigator.share({
          title: data.title,
          text: data.text || data.title,
          url: data.url || window.location.href
        })
        return true
      } catch (err) {
        if (err.name !== 'AbortError') {
          console.error('Erreur de partage:', err)
        }
        return false
      } finally {
        isSharing.value = false
      }
    }
    return false
  }

  // Partager via un réseau social spécifique
  const shareToSocial = async (platform, data) => {
    console.log('🌐 [useSocialShare] shareToSocial appelé avec:', { platform, data })
    const { url = window.location.href, title = document.title, text, image } = data
    
    if (shareUrls[platform]) {
      const shareUrl = shareUrls[platform](url, title, text, image)
      console.log('🔗 [useSocialShare] URL de partage générée:', shareUrl)
      
      // Ouvrir dans une popup pour desktop, nouvel onglet pour mobile
      if (window.innerWidth > 768 && platform !== 'email') {
        console.log('💻 [useSocialShare] Ouverture en popup (desktop)')
        const width = 600
        const height = 400
        const left = (window.innerWidth - width) / 2
        const top = (window.innerHeight - height) / 2
        
        window.open(
          shareUrl,
          'share-popup',
          `width=${width},height=${height},left=${left},top=${top},toolbar=no,menubar=no`
        )
      } else {
        console.log('📱 [useSocialShare] Ouverture en nouvel onglet (mobile/email)')
        window.open(shareUrl, '_blank')
      }
      
      // Tracker l'événement de partage dans notre API
      if (data.type && data.id) {
        try {
          await fetch('/api/v1/shares/track', {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json'
            },
            body: JSON.stringify({
              type: data.type,
              id: data.id,
              platform: platform
            })
          })
        } catch (error) {
          console.error('Erreur lors du tracking du partage:', error)
        }
      }
      
      // Tracker l'événement de partage si Google Analytics est disponible
      if (typeof gtag !== 'undefined') {
        gtag('event', 'share', {
          method: platform,
          content_type: data.type || 'content',
          item_id: data.id
        })
      }
    } else {
      console.error('❌ [useSocialShare] Plateforme non supportée:', platform)
    }
  }

  // Copier le lien dans le presse-papier
  const copyLink = async (url = window.location.href) => {
    try {
      await navigator.clipboard.writeText(url)
      return true
    } catch (err) {
      // Fallback pour les anciens navigateurs
      const textArea = document.createElement('textarea')
      textArea.value = url
      textArea.style.position = 'fixed'
      textArea.style.left = '-999999px'
      document.body.appendChild(textArea)
      textArea.select()
      
      try {
        document.execCommand('copy')
        document.body.removeChild(textArea)
        return true
      } catch (err) {
        document.body.removeChild(textArea)
        return false
      }
    }
  }

  // Partage principal avec fallback
  const share = async (data) => {
    // Essayer d'abord le partage natif
    const nativeShared = await shareNative(data)
    
    // Si pas de partage natif ou annulé, afficher le modal
    if (!nativeShared) {
      showShareModal.value = true
    }
  }

  // Fermer le modal de partage
  const closeShareModal = () => {
    showShareModal.value = false
  }

  // Mettre à jour les métadonnées Open Graph
  const updateOpenGraphTags = (data) => {
    const { title, description, image, url } = data
    
    // Supprimer les anciens tags Open Graph
    const existingOgTags = document.querySelectorAll('meta[property^="og:"]')
    existingOgTags.forEach(tag => tag.remove())
    
    // Ajouter les nouveaux tags
    const head = document.getElementsByTagName('head')[0]
    
    // Titre
    if (title) {
      const ogTitle = document.createElement('meta')
      ogTitle.setAttribute('property', 'og:title')
      ogTitle.content = title
      head.appendChild(ogTitle)
    }
    
    // Description
    if (description) {
      const ogDescription = document.createElement('meta')
      ogDescription.setAttribute('property', 'og:description')
      ogDescription.content = description
      head.appendChild(ogDescription)
    }
    
    // Image
    if (image) {
      const ogImage = document.createElement('meta')
      ogImage.setAttribute('property', 'og:image')
      ogImage.content = image.startsWith('http') ? image : `${window.location.origin}${image}`
      head.appendChild(ogImage)
    }
    
    // URL
    const ogUrl = document.createElement('meta')
    ogUrl.setAttribute('property', 'og:url')
    ogUrl.content = url || window.location.href
    head.appendChild(ogUrl)
    
    // Type
    const ogType = document.createElement('meta')
    ogType.setAttribute('property', 'og:type')
    ogType.content = 'article'
    head.appendChild(ogType)
    
    // Site name
    const ogSiteName = document.createElement('meta')
    ogSiteName.setAttribute('property', 'og:site_name')
    ogSiteName.content = 'Dinor'
    head.appendChild(ogSiteName)
  }

  return {
    isSharing,
    showShareModal,
    share,
    shareNative,
    shareToSocial,
    copyLink,
    closeShareModal,
    updateOpenGraphTags
  }
} 