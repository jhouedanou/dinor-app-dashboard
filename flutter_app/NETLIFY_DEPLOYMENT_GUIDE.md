# 🚀 Guide de Déploiement Netlify - Dinor App Flutter

## 📋 Vue d'ensemble

Ce guide vous explique comment déployer votre application Flutter web sur Netlify en quelques étapes simples.

## ✅ Prérequis

- ✅ Version web Flutter construite (`build/web/` complet)
- ✅ Compte Netlify (gratuit)
- ✅ Navigateur web moderne

## 🎯 Méthodes de déploiement

### Méthode 1: Glisser-déposer (Recommandée pour débutants)

#### Étape 1: Préparer les fichiers
```bash
# Assurez-vous que le build est à jour
./build-web.sh

# Vérifiez que le dossier build/web existe
ls -la build/web/
```

#### Étape 2: Déployer sur Netlify

1. **Allez sur Netlify** : [netlify.com](https://netlify.com)
2. **Créez un compte** ou connectez-vous
3. **Glissez-déposez** le dossier `build/web/` dans la zone de déploiement
4. **Attendez** que le déploiement se termine (30-60 secondes)
5. **Votre site est en ligne !** 🎉

### Méthode 2: Déploiement via Git (Recommandée pour les développeurs)

#### Étape 1: Préparer le repository

```bash
# Créez un fichier netlify.toml à la racine du projet
cat > netlify.toml << 'EOF'
[build]
  publish = "build/web"
  command = "./build-web.sh"

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
EOF
```

#### Étape 2: Pousser vers GitHub

```bash
# Ajoutez le fichier netlify.toml
git add netlify.toml
git commit -m "Ajout configuration Netlify"
git push origin main
```

#### Étape 3: Connecter Netlify à GitHub

1. Allez sur [netlify.com](https://netlify.com)
2. Cliquez sur "New site from Git"
3. Choisissez GitHub
4. Sélectionnez votre repository
5. Configurez :
   - **Build command** : `./build-web.sh`
   - **Publish directory** : `build/web`
6. Cliquez sur "Deploy site"

## 🔧 Configuration avancée

### Configuration des redirections

Créez un fichier `_redirects` dans `build/web/` :

```
/*    /index.html   200
```

### Configuration des headers

Créez un fichier `_headers` dans `build/web/` :

```
/*
  X-Frame-Options: DENY
  X-XSS-Protection: 1; mode=block
  X-Content-Type-Options: nosniff
  Referrer-Policy: strict-origin-when-cross-origin

/*.js
  Cache-Control: public, max-age=31536000, immutable

/*.css
  Cache-Control: public, max-age=31536000, immutable

/*.png
  Cache-Control: public, max-age=31536000, immutable

/*.jpg
  Cache-Control: public, max-age=31536000, immutable
```

### Configuration du domaine personnalisé

1. Dans Netlify, allez dans "Site settings"
2. Cliquez sur "Domain management"
3. Ajoutez votre domaine personnalisé
4. Suivez les instructions pour configurer les DNS

## 📱 Optimisations PWA

### Vérifier le manifeste PWA

Le fichier `build/web/manifest.json` doit contenir :

```json
{
  "name": "Dinor App",
  "short_name": "Dinor",
  "description": "Votre chef de poche",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#ffffff",
  "theme_color": "#000000",
  "icons": [
    {
      "src": "icons/Icon-192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "icons/Icon-512.png",
      "sizes": "512x512",
      "type": "image/png"
    }
  ]
}
```

## 🚀 Script de déploiement automatisé

Créez un script pour automatiser le déploiement :

```bash
#!/bin/bash
# deploy-netlify.sh

echo "🚀 Déploiement Netlify - Dinor App"

# Construire l'application
echo "🔨 Construction de l'application..."
./build-web.sh

# Vérifier que le build est réussi
if [ ! -d "build/web" ]; then
    echo "❌ Erreur: Le dossier build/web n'existe pas"
    exit 1
fi

echo "✅ Build réussi !"
echo "📁 Fichiers prêts pour le déploiement:"
ls -la build/web/

echo ""
echo "🌐 Pour déployer sur Netlify:"
echo "1. Allez sur https://netlify.com"
echo "2. Glissez-déposez le dossier build/web/"
echo "3. Attendez le déploiement"
echo ""
echo "🔗 Ou utilisez la CLI Netlify:"
echo "npm install -g netlify-cli"
echo "netlify deploy --dir=build/web --prod"
```

## 🔍 Vérification du déploiement

### Tests à effectuer après déploiement

1. **Chargement de la page** : L'application se charge-t-elle ?
2. **Navigation** : Les liens fonctionnent-ils ?
3. **PWA** : L'installation fonctionne-t-elle ?
4. **Responsive** : L'application s'adapte-t-elle aux mobiles ?
5. **Performance** : Utilisez Lighthouse pour tester

### Outils de test

```bash
# Test local avant déploiement
./serve-web.sh

# Test avec Lighthouse (si installé)
lighthouse https://votre-site.netlify.app
```

## 🐛 Dépannage

### Problème: L'application ne se charge pas

**Solutions :**
1. Vérifiez que tous les fichiers sont dans `build/web/`
2. Vérifiez les erreurs dans la console du navigateur
3. Assurez-vous que le fichier `index.html` est à la racine

### Problème: Erreurs 404 sur les routes

**Solution :** Ajoutez un fichier `_redirects` dans `build/web/` :
```
/*    /index.html   200
```

### Problème: Assets non trouvés

**Solutions :**
1. Vérifiez que le dossier `assets/` est copié
2. Vérifiez les chemins dans `pubspec.yaml`
3. Reconstruisez l'application : `./build-web.sh`

### Problème: Performance lente

**Solutions :**
1. Activez la compression gzip sur Netlify
2. Optimisez les images
3. Utilisez le CDN Netlify

## 📊 Monitoring et Analytics

### Netlify Analytics

1. Activez Netlify Analytics dans les paramètres du site
2. Surveillez les performances
3. Analysez le trafic

### Google Analytics

Ajoutez le code Google Analytics dans `web/index.html` :

```html
<!-- Google Analytics -->
<script async src="https://www.googletagmanager.com/gtag/js?id=GA_MEASUREMENT_ID"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'GA_MEASUREMENT_ID');
</script>
```

## 🔄 Mise à jour

Pour mettre à jour votre application :

1. **Modifiez le code Flutter**
2. **Reconstruisez** : `./build-web.sh`
3. **Redéployez** en glissant-déposant le nouveau `build/web/`

## 📞 Support

- **Documentation Netlify** : [docs.netlify.com](https://docs.netlify.com)
- **Support Flutter Web** : [flutter.dev/web](https://flutter.dev/web)
- **Community** : [community.netlify.com](https://community.netlify.com)

---

**🎉 Félicitations !** Votre application Flutter est maintenant en ligne sur Netlify ! 