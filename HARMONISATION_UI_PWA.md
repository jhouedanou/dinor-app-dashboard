# Harmonisation UI PWA - Material Design 3 + Carousels Vidéo

## Objectif
Unifier l'interface utilisateur de la PWA Dinor avec Material Design 3 et ajouter des carousels vidéo interactifs sur les pages individuelles.

## ✅ Pages individuelles modernisées

### 🎯 **Tip.js** - Refonte complète Material Design 3
```javascript
// Structure harmonisée avec Recipe.js
- Hero Image Card avec overlay gradient Dinor
- Stats Section avec icônes Material
- Sections organisées avec titres iconographiés  
- Lecteur vidéo principal avec poster/overlay
- Carousel d'astuces vidéo similaires
- Tags en chips Material Design
- Commentaires Material Design
```

### 📅 **Event.js** - Améliorations et carousel
```javascript
// Structure cohérente avec Recipe.js
- Hero Image Card avec badge de statut
- Stats Section adaptée aux événements
- Détails organisés en grille
- Section organisateur
- Participation avec stats visuelles
- Lecteur vidéo principal
- Carousel d'événements vidéo
- Inscription centralisée
```

## 🎬 Système de carousels vidéo

### Fonctionnalités
```javascript
// Navigation fluide
- Boutons chevron avec états disabled
- Scroll horizontal smooth
- Détection automatique des limites
- Responsive design

// Lecteur vidéo principal
- Poster avec overlay play
- Bouton play Material avec animation
- Iframe YouTube autoplay
- Toggle activation/désactivation

// Items carousel
- Miniatures avec play overlay
- Informations contextuelles
- Navigation vers pages individuelles
- Effet hover avec élévation
```

### CSS Carousel
```css
.video-carousel
├── .carousel-container
│   ├── .carousel-nav (left/right)
│   ├── .carousel-track (scroll horizontal)
│   └── .carousel-item
│       ├── .video-thumbnail
│       │   ├── .thumbnail-image
│       │   └── .play-overlay
│       └── .video-details
│           ├── .video-title
│           └── .video-meta
```

## 📱 Interface unifiée

### Structure standard des pages individuelles
```javascript
// Template commun
<div class="recipe-page [type]-page">
  <nav class="md3-top-app-bar">
    // Navigation avec breadcrumb et partage
  </nav>
  <main class="md3-main-content">
    // Hero Card avec image/overlay/badges
    // Stats Section avec métadonnées
    // Contenu principal organisé en sections
    // Lecteur vidéo principal (si vidéo)
    // Carousel vidéos similaires (si disponibles)
    // Commentaires Material Design
  </main>
</div>
```

### Sections harmonisées
```javascript
// Hero Image Card
- .recipe-hero avec .recipe-hero-image
- .hero-overlay avec gradient Dinor
- .hero-content avec titre/sous-titre/badges

// Stats Section  
- .recipe-stats avec grille adaptive
- .stat-item avec icône/valeur/label
- Bouton like intégré

// Content Sections
- .content-section avec .section-title iconographié
- Contenu organisé et stylé MD3
```

## 🎨 Styles CSS ajoutés

### Carousel vidéo
```css
// Navigation
.carousel-nav - Boutons circulaires MD3
.carousel-track - Scroll horizontal sans scrollbar
.carousel-item - Cards avec hover effects

// Lecteur principal
.video-player-container - Aspect ratio 16:9
.video-poster - Poster avec overlay interactif
.play-button-overlay - Animation au hover
.play-button - Bouton circulaire avec scale

// Responsive
- Mobile: items 200px
- Tablet: items 250px  
- Desktop: items 300px
```

### Événements spécifiques
```css
// Détails améliorés
.event-details-grid - Grille adaptive
.event-detail-item - Items avec icônes et labels
.detail-content - Structure label/value

// Organisateur
.organizer-card - Card dédiée avec contacts
.contact-item - Items avec icônes Material

// Participation
.participation-card - Stats visuelles
.participation-numbers - Grille 3 colonnes
.participation-stat - Nombre + label
.progress-bar - Barre de progression animée
```

### Astuces spécifiques
```css
// Tags
.tags-container - Flex wrap avec gap
.tag-chip - Chips Material avec #

// Contenu riche
.tip-content - Typography améliorée
- Titres hiérarchisés
- Listes avec marges
- Blockquotes stylées
- Code syntax highlight
```

## 🚀 Fonctionnalités techniques

### APIs étendues
```javascript
// Tips
loadRelatedVideos() - Charge astuces avec vidéos
playRelatedVideo() - Navigation vers astuce

// Events  
loadRelatedVideos() - Charge événements avec vidéos
playRelatedVideo() - Navigation vers événement

// Commun
getEmbedUrl() - Convertit URL YouTube en embed
getVideoThumbnail() - Génère thumbnail YouTube
scrollCarousel() - Navigation carousel
updateCarouselButtons() - États des boutons
toggleVideoPlayer() - Active/désactive lecteur
```

### État du carousel
```javascript
// Refs Vue 3
carouselTrack - Référence DOM du track
canScrollLeft/Right - États des boutons navigation
videoPlayerActive - État du lecteur principal
relatedVideos - Array des vidéos similaires

// Logique de scroll
- Scroll par blocs de 320px
- Détection automatique des limites
- Smooth scrolling avec setTimeout
- Event listeners sur scroll
```

## 📱 Responsive Design

### Breakpoints
```css
// Desktop (1024px+)
carousel-item: 300px
grid: 4 colonnes stats
navigation: 48px buttons

// Tablet (768px-1023px)  
carousel-item: 250px
grid: 3 colonnes stats
participation: 3 colonnes

// Mobile (480px-767px)
carousel-item: 200px  
grid: 2 colonnes stats
participation: 1 colonne

// Small Mobile (<480px)
carousel-nav: 40px
play-button: 60px
padding: réduit
```

## 🎯 Résultats obtenus

### ✅ Pages Tips harmonisées
- Design cohérent avec Recipe.js
- Carousel d'astuces vidéo fonctionnel
- Tags Material Design
- Lecteur vidéo intégré
- Navigation fluide

### ✅ Pages Events améliorées  
- Sections réorganisées et clarifiées
- Stats de participation visuelles
- Carousel d'événements vidéo
- Détails organisés en grille
- Inscription mise en valeur

### ✅ Système carousel universel
- Navigation intuitive avec chevrons
- Responsive sur tous écrans
- Performance optimisée
- Intégration YouTube native
- Design Material cohérent

### ✅ UX/UI unifiée
- Structure de page standardisée
- Iconographie Material Icons
- Typography et espacement MD3
- Interactions fluides et modernes
- Accessibilité améliorée

## 🔄 Navigation améliorée

### Breadcrumbs
```
Dinor / Astuce → tip-page
Dinor / Événement → event-page  
Dinor / Recette → recipe-page
```

### Actions contextuelles
```javascript
// Header actions
- Retour avec arrow_back
- Partage natif si disponible
- Boutons Material avec états

// Contenu interactif
- Like/Unlike avec animation
- Commentaires avec formulaire MD3
- Carousels avec navigation tactile
- Lecteurs vidéo responsifs
```

La PWA Dinor dispose maintenant d'une interface cohérente et moderne sur toutes les pages individuelles, avec des carousels vidéo qui enrichissent l'expérience utilisateur tout en respectant les principes Material Design 3. 