# 🔒 Configuration de Sécurité - Dinor App

## ⚠️ CLÉS D'API RETIRÉES

Pour des raisons de sécurité, les clés d'API sensibles ont été retirées du code source.

## 📁 Fichiers de Configuration Requis

### 🔥 Firebase
Les fichiers suivants ont été renommés et doivent être restaurés avec vos vraies configurations :

```
android/app/google-services.json.example        → google-services.json
android/app/google-services-backup.json.example → (backup)
ios/Runner/GoogleService-Info.plist.example     → GoogleService-Info.plist  
macos/Runner/GoogleService-Info.plist.example   → GoogleService-Info.plist
```

### 📝 Variables d'Environnement
Créez un fichier `.env` basé sur `.env.example` :

```bash
cp .env.example .env
```

### 🛠️ Fichiers Modifiés

#### `lib/firebase_options.dart`
```dart
apiKey: 'YOUR_FIREBASE_API_KEY_HERE'  // ← À remplacer
```

#### `android/app/src/main/res/values/firebase_values.xml`  
```xml
<string name="google_api_key" translatable="false">YOUR_FIREBASE_API_KEY_HERE</string>
```

## 🚀 Instructions de Configuration

### 1. **Restaurer les Configurations Firebase**
```bash
# Renommez les fichiers exemple
mv android/app/google-services.json.example android/app/google-services.json
mv ios/Runner/GoogleService-Info.plist.example ios/Runner/GoogleService-Info.plist
mv macos/Runner/GoogleService-Info.plist.example macos/Runner/GoogleService-Info.plist
```

### 2. **Configurer les Clés d'API**
- Remplacez `YOUR_FIREBASE_API_KEY_HERE` dans `firebase_options.dart`
- Remplacez `YOUR_FIREBASE_API_KEY_HERE` dans `firebase_values.xml`
- Ajoutez vos vraies configurations Firebase dans les fichiers JSON/plist

### 3. **Vérifier le .gitignore**
Assurez-vous que ces fichiers sont dans `.gitignore` :
```
# Firebase
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
macos/Runner/GoogleService-Info.plist

# Environnement
.env
.env.local
```

## ⚡ Après Configuration

Une fois configuré, reconstruisez l'app :
```bash
flutter clean
flutter pub get
flutter build apk --release
```

## 🔐 Bonnes Pratiques

1. **Jamais de clés dans le code source**
2. **Utilisez des variables d'environnement**
3. **Différentes clés pour dev/prod**
4. **Rotation régulière des clés**
5. **Monitoring des accès API**

---

⚠️ **Ne commitez JAMAIS les vraies clés d'API dans Git !** ⚠️