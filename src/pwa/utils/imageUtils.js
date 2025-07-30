/**
 * IMAGE UTILS - Utilitaires pour la gestion des images
 * 
 * FONCTIONNALITÉS :
 * - Correction des URLs d'images pour utiliser /storage/ au lieu de /images/
 * - Gestion des images par défaut par type de contenu
 * - Support des URLs complètes et relatives
 */

const BASE_URL = window.location.origin

// Images par défaut pour chaque type de contenu
const DEFAULT_IMAGES = {
  'recipe': '/images/default-recipe.jpg',
  'tip': '/images/default-content.jpg',
  'tips': '/images/default-content.jpg',
  'event': '/images/default-event.jpg',
  'events': '/images/default-event.jpg',
  'dinor_tv': '/images/default-video.jpg',
  'video': '/images/default-video.jpg',
  'videos': '/images/default-video.jpg',
  'banner': '/images/default-content.jpg',
  'banners': '/images/default-content.jpg',
  'user': '/images/default-content.jpg',
  'users': '/images/default-content.jpg',
  'content': '/images/default-content.jpg'
}

/**
 * Obtenir l'URL d'image avec fallback vers l'image par défaut
 */
export function getImageUrl(imageUrl, contentType = 'content') {
  if (imageUrl && imageUrl.trim() !== '') {
    // Si l'URL est déjà complète, la retourner
    if (imageUrl.startsWith('http')) {
      return imageUrl
    }
    
    // Si c'est un chemin relatif commençant par /, le compléter avec l'URL de base
    if (imageUrl.startsWith('/')) {
      return `${BASE_URL}${imageUrl}`
    }
    
    // Si c'est un chemin storage, utiliser /storage/
    if (imageUrl.startsWith('storage/') || 
        imageUrl.startsWith('tips/') || 
        imageUrl.startsWith('recipes/') || 
        imageUrl.startsWith('events/') ||
        imageUrl.startsWith('banners/')) {
      return `${BASE_URL}/storage/${imageUrl}`
    }
    
    // Sinon, ajouter le chemin vers les images
    return `${BASE_URL}/images/${imageUrl}`
  }
  
  // Retourner l'image par défaut pour le type de contenu
  return DEFAULT_IMAGES[contentType] || DEFAULT_IMAGES['content']
}

/**
 * Obtenir l'URL d'image pour les recettes
 */
export function getRecipeImageUrl(recipe) {
  const imageUrl = recipe?.featured_image_url || 
                  recipe?.image_url || 
                  recipe?.image
  return getImageUrl(imageUrl, 'recipe')
}

/**
 * Obtenir l'URL d'image pour les astuces
 */
export function getTipImageUrl(tip) {
  const imageUrl = tip?.featured_image_url || 
                  tip?.image_url || 
                  tip?.image
  return getImageUrl(imageUrl, 'tip')
}

/**
 * Obtenir l'URL d'image pour les événements
 */
export function getEventImageUrl(event) {
  const imageUrl = event?.featured_image_url || 
                  event?.image_url || 
                  event?.image
  return getImageUrl(imageUrl, 'event')
}

/**
 * Obtenir l'URL d'image pour les vidéos
 */
export function getVideoImageUrl(video) {
  const imageUrl = video?.thumbnail_url || 
                  video?.image_url || 
                  video?.featured_image_url || 
                  video?.image
  return getImageUrl(imageUrl, 'video')
}

/**
 * Obtenir l'URL d'image pour les bannières
 */
export function getBannerImageUrl(banner) {
  const imageUrl = banner?.image_url || 
                  banner?.featured_image_url || 
                  banner?.image
  return getImageUrl(imageUrl, 'banner')
}

/**
 * Traiter un élément pour corriger ses URLs d'images
 */
export function processItemImages(item, contentType) {
  if (!item) return item
  
  const processedItem = { ...item }
  
  // Traiter les différents champs d'image selon le type
  switch (contentType) {
    case 'tip':
    case 'tips':
      if (processedItem.featured_image_url) {
        processedItem.featured_image_url = getTipImageUrl(processedItem)
      }
      if (processedItem.image_url) {
        processedItem.image_url = getTipImageUrl(processedItem)
      }
      break
      
    case 'recipe':
    case 'recipes':
      if (processedItem.featured_image_url) {
        processedItem.featured_image_url = getRecipeImageUrl(processedItem)
      }
      if (processedItem.image_url) {
        processedItem.image_url = getRecipeImageUrl(processedItem)
      }
      break
      
    case 'event':
    case 'events':
      if (processedItem.featured_image_url) {
        processedItem.featured_image_url = getEventImageUrl(processedItem)
      }
      if (processedItem.image_url) {
        processedItem.image_url = getEventImageUrl(processedItem)
      }
      break
      
    case 'video':
    case 'videos':
    case 'dinor_tv':
      if (processedItem.thumbnail_url) {
        processedItem.thumbnail_url = getVideoImageUrl(processedItem)
      }
      if (processedItem.featured_image_url) {
        processedItem.featured_image_url = getVideoImageUrl(processedItem)
      }
      if (processedItem.image_url) {
        processedItem.image_url = getVideoImageUrl(processedItem)
      }
      break
      
    default:
      // Traitement générique
      if (processedItem.featured_image_url) {
        processedItem.featured_image_url = getImageUrl(processedItem.featured_image_url, contentType)
      }
      if (processedItem.image_url) {
        processedItem.image_url = getImageUrl(processedItem.image_url, contentType)
      }
      if (processedItem.image) {
        processedItem.image = getImageUrl(processedItem.image, contentType)
      }
  }
  
  return processedItem
}

/**
 * Traiter une liste d'éléments pour corriger leurs URLs d'images
 */
export function processItemsImages(items, contentType) {
  if (!Array.isArray(items)) return items
  
  return items.map(item => processItemImages(item, contentType))
} 