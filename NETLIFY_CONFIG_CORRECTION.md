# 🔧 Correction Configuration Netlify

## ❌ Problèmes dans votre configuration actuelle

### Configuration incorrecte :
```
Runtime: Not set
Base directory: /flutter_app
Package directory: Not set
Build command: ./build-web.sh
Publish directory: /flutter_app/flutter_app/build/web
Functions directory: /flutter_app/netlify/functions
```

### Problèmes identifiés :
1. **Base directory** : `/flutter_app` est incorrect
2. **Publish directory** : `/flutter_app/flutter_app/build/web` est dupliqué
3. **Build command** : Ne spécifie pas le chemin correct

## ✅ Configuration correcte

### Option 1: Configuration manuelle dans Netlify

```
Runtime: Not set (ou Node.js 18)
Base directory: (laisser vide)
Package directory: (laisser vide)
Build command: cd flutter_app && ./build-web.sh
Publish directory: flutter_app/build/web
Functions directory: (laisser vide)
```

### Option 2: Utiliser le fichier netlify.toml (Recommandé)

Le fichier `netlify.toml` a été créé à la racine du projet. Il configure automatiquement :

```toml
[build]
  command = "cd flutter_app && ./build-web.sh"
  publish = "flutter_app/build/web"
```

## 🚀 Étapes de correction

### Étape 1: Mettre à jour la configuration Netlify

1. **Allez dans les paramètres de votre site Netlify**
2. **Section "Build & deploy"**
3. **Modifiez les paramètres :**

```
Build command: cd flutter_app && ./build-web.sh
Publish directory: flutter_app/build/web
Base directory: (laisser vide)
```

### Étape 2: Redéployer

1. **Allez dans l'onglet "Deploys"**
2. **Cliquez sur "Trigger deploy" → "Deploy site"**
3. **Attendez que le build se termine**

## 🔍 Vérification

### Vérifiez que le build fonctionne :

1. **Logs de build** : Pas d'erreurs
2. **Fichiers générés** : Le dossier `flutter_app/build/web/` existe
3. **Site en ligne** : L'application se charge correctement

### Structure attendue après build :

```
flutter_app/build/web/
├── index.html
├── main.dart.js
├── flutter.js
├── manifest.json
├── _redirects
├── _headers
└── assets/
```

## 🐛 Dépannage

### Erreur: "Build command not found"
**Solution :** Vérifiez que le script `build-web.sh` existe dans `flutter_app/`

### Erreur: "Publish directory not found"
**Solution :** Vérifiez que le chemin `flutter_app/build/web` existe après le build

### Erreur: "Flutter not found"
**Solution :** Netlify utilise Node.js par défaut. Flutter doit être installé via le script.

## 📋 Configuration finale recommandée

```
Runtime: Not set
Base directory: (vide)
Build command: cd flutter_app && ./build-web.sh
Publish directory: flutter_app/build/web
Functions directory: (vide)
```

## ✅ Vérification finale

Après correction, votre configuration devrait ressembler à :

```
✅ Build command: cd flutter_app && ./build-web.sh
✅ Publish directory: flutter_app/build/web
✅ Base directory: (vide)
✅ Runtime: Not set
```

---

**🎉 Une fois ces corrections appliquées, votre déploiement devrait fonctionner !** 