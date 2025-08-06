<# 🚀 ÉTAPES RAPIDES - GÉNÉRATION iOS DINOR APP

## ⚡ RÉSUMÉ EXPRESS

### 📋 **PRÉREQUIS (Une seule fois)**
1. **macOS** + **Xcode** (Mac App Store)
2. **Apple Developer Account** ($99/an pour App Store)
3. **CocoaPods** : `sudo gem install cocoapods`

### 🔨 **COMMANDES ESSENTIELLES**

#### **🧪 Pour DÉVELOPPEMENT/TEST :**
```bash
# Script automatique (recommandé)
./build-ios.sh debug

# OU manuellement :
flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter build ios --debug
```

#### **📦 Pour APP STORE :**
```bash
# Script automatique (recommandé)  
./build-ios.sh ipa

# OU manuellement :
flutter build ipa --release
```

### 🎯 **CONFIGURATION XCODE (Une seule fois)**
1. Ouvrir : `ios/Runner.xcworkspace` dans Xcode
2. **Signing & Capabilities :**
   - Team : Votre équipe Apple Developer
   - Bundle ID : `com.dinorapp.mobile`
   - Signing : Automatic

### 📱 **INSTALLATION/DISTRIBUTION**

#### **Test sur appareil :**
```bash
# Via Xcode (plus simple)
# Connecter iPhone → Run dans Xcode

# Via Flutter
flutter devices
flutter install --device-id [DEVICE_ID]
```

#### **Distribution App Store :**
1. **App Store Connect :** Créer l'app
2. **Upload IPA :** Via Transporter ou Xcode
3. **Review :** Soumettre à Apple

## ⚠️ **LIMITATIONS IMPORTANTES**

### 🚫 **Linux/Windows**
- **Impossible** de compiler iOS nativement
- **Alternatives :**
  - Codemagic (service cloud)
  - GitHub Actions (runners macOS)
  - Location Mac en cloud

### 💰 **Coûts**
- **Développement/test :** Gratuit (limité 7 jours)
- **App Store :** Apple Developer Program 99€/an

## 🎉 **FICHIERS GÉNÉRÉS**

### **Debug :** `build/ios/iphoneos/Runner.app`
### **Release IPA :** `dinor-app-v1.2.0-ios-YYYYMMDD.ipa`

---

## 📞 **BESOIN D'AIDE ?**

### **Erreurs communes :**
- **"No iOS devices"** → Connecter iPhone + mode développeur
- **"Code signing error"** → Vérifier Apple Developer Account
- **"Pod install failed"** → `cd ios && pod cache clean --all && pod install`

### **Support :**
- Guide complet : `iOS_BUILD_GUIDE.md`
- Script automatisé : `./build-ios.sh`
- Documentation Apple : [developer.apple.com](https://developer.apple.com)

**🚀 Prêt à générer votre app iOS !**