# Guide de déploiement PWA - Fix de l'erreur index.html

## 🚨 Problème résolu

**Erreur** : `The file "/var/www/html/public/pwa/dist/index.html" does not exist`

**Cause** : Configuration Vite PWA incorrecte qui ne générait pas le fichier `index.html`

**Solution** : ✅ Configuration corrigée dans `vite.pwa.config.js`

## 🔧 Actions prises

### 1. Correction de la configuration Vite PWA
```javascript
// AVANT (incorrect)
rollupOptions: {
  input: {
    main: path.resolve(__dirname, 'src/pwa/index.html')
  }
}

// APRÈS (correct)
rollupOptions: {
  input: path.resolve(__dirname, 'src/pwa/index.html')
}
```

### 2. Scripts de déploiement créés
- `deploy-pwa-fix.sh` - Script de build et déploiement
- `check-pwa-files.sh` - Vérification des fichiers PWA
- `npm run pwa:check` - Commande de vérification
- `npm run pwa:deploy` - Commande de déploiement

## 📋 Déploiement sur serveur

### Option 1 : Déploiement manuel
```bash
# Sur votre machine locale
npm run pwa:build

# Copier les fichiers vers le serveur
scp -r public/pwa/dist/* user@server:/var/www/html/public/pwa/dist/

# Sur le serveur, ajuster les permissions
sudo chown -R www-data:www-data /var/www/html/public/pwa/dist/
sudo chmod -R 755 /var/www/html/public/pwa/dist/
```

### Option 2 : Avec rsync
```bash
# Depuis votre machine locale
rsync -avz --delete public/pwa/dist/ user@server:/var/www/html/public/pwa/dist/
```

### Option 3 : Script automatisé
```bash
# Exécuter le script de déploiement
npm run pwa:deploy
```

## ✅ Vérification post-déploiement

### Sur votre machine locale
```bash
# Vérifier que tous les fichiers sont présents
npm run pwa:check
```

### Sur le serveur
```bash
# Vérifier que les fichiers existent
ls -la /var/www/html/public/pwa/dist/

# Fichiers requis :
# - index.html
# - manifest.webmanifest  
# - sw.js
# - assets/ (répertoire avec JS/CSS)
```

### Test via navigateur
```
https://votre-domaine.com/pwa/
```

## 🔍 Diagnostic des problèmes

### Fichier index.html manquant
```bash
# Relancer le build
npm run pwa:rebuild

# Vérifier la génération
npm run pwa:check
```

### Erreurs de permissions
```bash
# Sur le serveur
sudo chown -R www-data:www-data /var/www/html/public/pwa/
sudo chmod -R 755 /var/www/html/public/pwa/
```

### Problèmes de cache
```bash
# Vider le cache et rebuilder
npm run pwa:clear-cache
npm run pwa:build
```

## 📝 Checklist de déploiement

- [ ] ✅ Build PWA local successful
- [ ] ✅ Fichier `index.html` généré
- [ ] ✅ Tous les assets présents
- [ ] ✅ Fichiers copiés sur le serveur
- [ ] ✅ Permissions serveur correctes
- [ ] ✅ Test navigateur OK

## 🚀 Commandes utiles

```bash
# Développement
npm run pwa:dev          # Serveur de développement

# Build et déploiement
npm run pwa:build        # Build de production
npm run pwa:rebuild      # Nettoyage + build
npm run pwa:check        # Vérification des fichiers
npm run pwa:deploy       # Script de déploiement

# Débogage
npm run pwa:clear-cache  # Nettoyer le cache
```

## 🎯 Prévention

Pour éviter ce problème à l'avenir :

1. **Toujours vérifier** le build avant déploiement avec `npm run pwa:check`
2. **Utiliser les scripts** de déploiement automatisés
3. **Tester** sur un environnement de staging
4. **Surveiller** les logs du serveur web

## 🔗 Ressources

- [Vite PWA Documentation](https://vite-pwa-org.netlify.app/)
- [Configuration Rollup](https://rollupjs.org/guide/en/#configuration-files)
- [Service Worker API](https://developer.mozilla.org/en-US/docs/Web/API/Service_Worker_API) 