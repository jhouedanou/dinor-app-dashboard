# Documentation PWA - Intégration Embed/Iframe

## Structure des données simplifiée

### API Pages (/admin/pages)
Les pages sont maintenant simplifiées pour une utilisation optimale en PWA avec des embeds/iframes :

**Structure JSON retournée par l'API :**
```json
{
  "id": 1,
  "title": "Ma Page Web",
  "url": "https://example.com/ma-page",
  "description": "Description optionnelle",
  "is_published": true,
  "order": 0,
  "created_at": "2024-12-25T10:00:00.000000Z",
  "updated_at": "2024-12-25T10:00:00.000000Z"
}
```

### API Dinor TV (/admin/dinortv)
Les contenus Dinor TV sont aussi simplifiés :

**Structure JSON retournée par l'API :**
```json
{
  "id": 1,
  "title": "Ma Vidéo YouTube",
  "video_url": "https://www.youtube.com/embed/dQw4w9WgXcQ",
  "description": "Description optionnelle",
  "is_featured": false,
  "is_published": true,
  "view_count": 0,
  "created_at": "2024-12-25T10:00:00.000000Z",
  "updated_at": "2024-12-25T10:00:00.000000Z"
}
```

## Intégration dans la PWA

### Exemple d'affichage avec iframe
```javascript
// Composant React/Vue pour afficher une page
function EmbedPage({ page }) {
  return (
    <div className="embed-container">
      <h2>{page.title}</h2>
      {page.description && <p>{page.description}</p>}
      <iframe
        src={page.url}
        width="100%"
        height="600px"
        frameBorder="0"
        allowFullScreen
        title={page.title}
      />
    </div>
  );
}

// Composant pour Dinor TV
function VideoPlayer({ video }) {
  return (
    <div className="video-container">
      <h2>{video.title}</h2>
      {video.description && <p>{video.description}</p>}
      <iframe
        src={video.video_url}
        width="100%"
        height="400px"
        frameBorder="0"
        allowFullScreen
        title={video.title}
      />
      <p>Vues: {video.view_count}</p>
    </div>
  );
}
```

### CSS pour un affichage responsive
```css
.embed-container, .video-container {
  position: relative;
  width: 100%;
  margin-bottom: 20px;
}

.embed-container iframe, .video-container iframe {
  width: 100%;
  height: auto;
  min-height: 400px;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}

/* Responsive design */
@media (max-width: 768px) {
  .embed-container iframe, .video-container iframe {
    height: 250px;
  }
}
```

## URLs recommandées

### Pour YouTube
- **Normale** : `https://www.youtube.com/watch?v=VIDEO_ID`
- **Embed** : `https://www.youtube.com/embed/VIDEO_ID` (recommandé pour iframe)
- **Avec paramètres** : `https://www.youtube.com/embed/VIDEO_ID?autoplay=1&mute=1`

### Pour d'autres services
- **Vimeo** : `https://player.vimeo.com/video/VIDEO_ID`
- **Twitch** : `https://player.twitch.tv/?video=VIDEO_ID&parent=DOMAIN`
- **Google Maps** : `https://maps.google.com/maps?q=LOCATION&output=embed`

## Endpoints API disponibles

### Pages
- `GET /api/v1/pages` - Liste toutes les pages publiées
- `GET /api/v1/pages/{id}` - Détails d'une page
- `GET /api/v1/pages/homepage` - Première page par ordre
- `GET /api/v1/pages/menu` - Liste pour navigation

### Dinor TV
- `GET /api/v1/dinor-tv` - Liste tous les contenus publiés
- `GET /api/v1/dinor-tv/{id}` - Détails d'un contenu
- `GET /api/v1/dinor-tv/featured/list` - Contenus mis en avant
- `POST /api/v1/dinor-tv/{id}/view` - Incrémenter les vues