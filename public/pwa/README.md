# PWA Dinor - Application Culinaire

## 🚀 Fonctionnalités

- **Progressive Web App** complète avec installation native
- **Vue.js 3** avec Composition API pour des performances optimales
- **Service Worker** pour le mode hors-ligne
- **Cache stratégique** : API + Assets statiques
- **Lazy loading** des composants et images
- **Responsive design** optimisé mobile-first
- **Authentification** intégrée avec les APIs existantes

## 📱 Installation PWA

1. Accédez à `/pwa/` dans votre navigateur
2. Cliquez sur le bouton "Installer l'app" (apparaît après 3 secondes)
3. Ou utilisez le menu navigateur : "Ajouter à l'écran d'accueil"

## 🏗️ Architecture

```
public/pwa/
├── index.html          # Point d'entrée
├── app.js             # Application Vue principale
├── style.css          # Styles optimisés PWA
├── components/        # Composants Vue
│   ├── Recipe.js      # Page recette
│   ├── Tip.js         # Page astuce
│   └── Event.js       # Page événement
└── icons/             # Icônes PWA (à générer)
```

## ⚡ Optimisations de performance

### Chargement
- **Vue.js production** (minifié)
- **CSS critique** inline dans le HTML
- **Preload** des ressources importantes
- **Lazy loading** des images avec `loading="lazy"`

### Caching
- **Service Worker** avec stratégies adaptées :
  - Cache First : Assets statiques
  - Network First : APIs avec fallback cache
- **Mise en cache automatique** des pages visitées

### Code Splitting
- **Composants lazy** avec `import()`
- **Debouncing** de la recherche
- **Optimisations Vue** (Composition API)

## 🔧 Configuration

### APIs requises
- `/api/v1/recipes` - Liste et détails des recettes
- `/api/v1/tips` - Liste et détails des astuces  
- `/api/v1/events` - Liste et détails des événements
- `/api/v1/comments` - Gestion des commentaires
- `/api/v1/likes` - Gestion des likes

### Auth Managers
Réutilise les gestionnaires existants :
- `authManager` - Authentification
- `likesManager` - Gestion des likes
- `commentsManager` - Gestion des commentaires

## 📊 Métriques de performance

### Objectifs ciblés
- **First Contentful Paint** < 1.5s
- **Largest Contentful Paint** < 2.5s
- **Time to Interactive** < 3.5s
- **Cumulative Layout Shift** < 0.1

### Techniques utilisées
- Critical CSS inline
- Resource hints (preload)
- Image optimization
- Service Worker caching
- Vue 3 optimizations

## 🔧 Maintenance

### Mise à jour du cache
Le Service Worker se met à jour automatiquement. Pour forcer :
```javascript
// Dans la console navigateur
navigator.serviceWorker.getRegistrations()
  .then(regs => regs.forEach(reg => reg.unregister()));
```

### Debugging
- Chrome DevTools > Application > Service Workers
- Network tab pour vérifier le cache
- Lighthouse pour les performances PWA

## 📱 Compatibilité

- **Chrome/Edge** 88+ (support complet)
- **Firefox** 85+ (support partiel)
- **Safari** 14+ (iOS 14.3+)
- **Samsung Internet** 13+

## 🚀 Déploiement

1. Générer les icônes PWA (voir section suivante)
2. Configurer HTTPS (requis pour PWA)
3. Vérifier les URLs d'API
4. Tester avec Lighthouse

## 🎨 Génération des icônes

Les icônes doivent être générées dans `/pwa/icons/` :
- 72x72, 96x96, 128x128, 144x144, 152x152
- 192x192, 384x384, 512x512 (formats maskable)

Utilisez un outil comme [PWA Asset Generator](https://github.com/onderceylan/pwa-asset-generator) ou créez-les manuellement.

## 🐛 Dépannage

### PWA ne s'installe pas
- Vérifiez HTTPS
- Vérifiez le manifest.json
- Service Worker doit être enregistré
- Icons 192x192 et 512x512 requis

### Performance lente
- Vérifiez le cache Service Worker
- Optimisez les images
- Utilisez le mode production Vue

### Erreurs API
- Vérifiez les CORS
- Authentification requise pour certaines APIs
- Fallback cache en mode offline