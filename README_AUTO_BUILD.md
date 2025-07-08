# Automatisation du Build et du Vidage du Cache

Ce système automatise le build et le vidage du cache lors des modifications de fichiers dans votre projet Dinor Dashboard.

## 🚀 Installation Rapide

### 1. Configuration initiale

```bash
# Configuration complète automatique
./start-auto-build.sh setup

# Ou manuellement
./scripts/setup-auto-build.sh --all
```

### 2. Test du système

```bash
# Tester que tout fonctionne
./start-auto-build.sh test

# Ou manuellement
./scripts/test-auto-build.sh --all
```

### 3. Démarrage

```bash
# Surveillance automatique avec build
./start-auto-build.sh watch

# Environnement de développement complet
./start-auto-build.sh dev

# Build immédiat
./start-auto-build.sh build

# Vider le cache
./start-auto-build.sh clear
```

## 📋 Utilisation

### Commandes principales

#### Surveillance automatique
```bash
# Surveillance complète avec build automatique
./scripts/auto-build-watch.sh

# Surveillance seulement (sans build)
./scripts/auto-build-watch.sh --watch-only

# Build immédiat sans surveillance
./scripts/auto-build-watch.sh --build-only

# Vider le cache avant de commencer
./scripts/auto-build-watch.sh --clear-cache
```

#### Environnement de développement
```bash
# Environnement complet (Laravel + PWA + BrowserSync + surveillance)
./scripts/dev-watch.sh

# Serveur Laravel seulement
./scripts/dev-watch.sh --laravel-only

# Serveur PWA seulement
./scripts/dev-watch.sh --pwa-only

# Surveillance seulement
./scripts/dev-watch.sh --watch-only

# Vider le cache avant de commencer
./scripts/dev-watch.sh --clear-cache
```

### Commandes npm (après configuration)

```bash
npm run auto:watch      # Surveillance automatique
npm run auto:dev        # Environnement de développement
npm run auto:build      # Build immédiat
npm run auto:clear      # Vider le cache
npm run dev:full        # Développement complet
npm run dev:laravel     # Serveur Laravel seulement
npm run dev:pwa         # Serveur PWA seulement
```

### Commandes composer (après configuration)

```bash
composer auto:watch     # Surveillance automatique
composer auto:build     # Build immédiat
composer auto:clear     # Vider le cache
composer dev:full       # Développement complet
composer dev:laravel    # Serveur Laravel seulement
```

### Alias (après configuration)

```bash
dinor-watch            # Surveillance automatique
dinor-dev              # Environnement de développement
dinor-build            # Build immédiat
dinor-clear            # Vider le cache
dinor-dev-full         # Développement complet
dinor-dev-laravel      # Serveur Laravel seulement
dinor-dev-pwa          # Serveur PWA seulement
```

## ⚙️ Configuration

### Fichier de configuration

Le fichier `.auto-build-config` contient la configuration du système d'automatisation.

#### Options principales

```bash
# Répertoires surveillés
WATCH_DIRS=("app" "resources" "config" "routes" "database" "src")

# Patterns à exclure
EXCLUDE_PATTERNS=("*.log" "*.tmp" "*.cache" "node_modules/*" "vendor/*" ".git/*")

# Délai entre les builds (en secondes)
BUILD_DELAY=2

# Mode par défaut (dev/prod)
DEFAULT_MODE="dev"

# Configuration des ports
LARAVEL_PORT=8000
PWA_PORT=5173
BROWSERSYNC_PORT=3001
```

### Personnalisation

Vous pouvez modifier le fichier `.auto-build-config` pour adapter le comportement :

```bash
# Changer le délai entre les builds
BUILD_DELAY=5

# Ajouter des répertoires à surveiller
WATCH_DIRS=("app" "resources" "config" "routes" "database" "src" "custom")

# Exclure des patterns supplémentaires
EXCLUDE_PATTERNS=("*.log" "*.tmp" "*.cache" "node_modules/*" "vendor/*" ".git/*" "*.swp")
```

## 🔧 Fonctionnalités

### Surveillance automatique
- **Détection en temps réel** : Utilise `inotify-tools` pour détecter les modifications
- **Exclusion intelligente** : Ignore les fichiers temporaires et de cache
- **Déclenchement automatique** : Lance le build et le vidage du cache automatiquement
- **Protection contre les builds multiples** : Évite les builds trop fréquents

### Build automatique
- **Vidage du cache Laravel** :
  - Cache général (`cache:clear`)
  - Cache de configuration (`config:clear`)
  - Cache des vues (`view:clear`)
  - Cache des routes (`route:clear`)
- **Vidage du cache PWA** : Nettoie les caches de build PWA
- **Redécouverte des composants** : Redécouvre les composants Livewire
- **Optimisation de l'autoloader** : Optimise l'autoloader Composer
- **Reconstruction des caches** : Reconstruit les caches optimisés
- **Build PWA en arrière-plan** : Build PWA non-bloquant

### Environnement de développement
- **Serveur Laravel automatique** : Port 8000
- **Serveur PWA automatique** : Port 5173
- **BrowserSync optionnel** : Port 3001 (synchronisation navigateurs)
- **Nettoyage automatique** : Arrête tous les processus à la sortie
- **Gestion des erreurs** : Gestion gracieuse des erreurs

## 🛠️ Dépannage

### Problèmes courants

#### 1. inotify-tools non installé
```bash
# Ubuntu/Debian
sudo apt-get install inotify-tools

# CentOS/RHEL/Fedora
sudo yum install inotify-tools

# Arch Linux
sudo pacman -S inotify-tools

# macOS
brew install inotify-tools
```

#### 2. Permissions insuffisantes
```bash
# Rendre les scripts exécutables
chmod +x scripts/*.sh
chmod +x start-auto-build.sh
```

#### 3. Ports déjà utilisés
```bash
# Vérifier les processus sur les ports
lsof -i :8000  # Laravel
lsof -i :5173  # PWA
lsof -i :3001  # BrowserSync

# Arrêter les processus conflictuels
kill -9 <PID>
```

#### 4. Cache corrompu
```bash
# Vider manuellement le cache
./start-auto-build.sh clear

# Ou plus spécifiquement
php artisan cache:clear
php artisan config:clear
php artisan view:clear
php artisan route:clear
npm run pwa:clear-cache
```

#### 5. Dépendances manquantes
```bash
# Vérifier les dépendances
./scripts/test-auto-build.sh --deps

# Installer les dépendances manquantes
./scripts/setup-auto-build.sh --install-deps
```

### Logs et débogage

#### Logs en temps réel
```bash
# Logs Laravel
tail -f storage/logs/laravel.log

# Logs PWA
npm run pwa:dev  # Dans un autre terminal

# Logs d'automatisation
tail -f storage/logs/auto-build.log
```

#### Mode debug
```bash
# Activer les logs détaillés
export AUTO_BUILD_DEBUG=true
./scripts/auto-build-watch.sh
```

## 📊 Monitoring

### Métriques disponibles
- **Temps de build** : Durée des opérations de build
- **Taille du cache** : Utilisation de l'espace cache
- **Nombre de fichiers** : Fichiers surveillés
- **Taux d'erreur** : Fréquence des erreurs

### Alertes
- **Échec de build** : Notification en cas d'échec
- **Erreur de cache** : Problèmes de vidage de cache
- **Espace disque** : Utilisation élevée du disque
- **Utilisation mémoire** : Consommation mémoire élevée

## 🔒 Sécurité

### Fichiers sensibles
Le système exclut automatiquement les fichiers sensibles :
- `.env` et `.env.*`
- Fichiers de clés (`*.key`, `*.pem`, `*.crt`, `*.p12`)

### Permissions
- Vérification des permissions de fichiers
- Validation des chemins d'accès
- Exclusion des répertoires sensibles

## 🚀 Optimisations

### Mode performance
```bash
# Activer le mode performance dans .auto-build-config
PERFORMANCE_MODE=true
PERFORMANCE_PARALLEL_BUILDS=4
```

### Cache warming
```bash
# Précharger les caches
PERFORMANCE_CACHE_WARMUP=true
```

### Builds parallèles
```bash
# Exécuter plusieurs builds en parallèle
PERFORMANCE_PARALLEL_BUILDS=2
```

## 📝 Exemples d'utilisation

### Développement quotidien
```bash
# 1. Démarrer l'environnement de développement
./start-auto-build.sh dev

# 2. Modifier des fichiers (build automatique)
# 3. Tester les changements
# 4. Arrêter avec Ctrl+C
```

### Production
```bash
# 1. Build optimisé pour la production
./scripts/auto-build-watch.sh --prod

# 2. Vérifier le build
./scripts/test-auto-build.sh --build

# 3. Déployer
```

### Debug
```bash
# 1. Vider le cache
./start-auto-build.sh clear

# 2. Tester le système
./start-auto-build.sh test

# 3. Surveillance en mode debug
AUTO_BUILD_DEBUG=true ./start-auto-build.sh watch
```

## 🤝 Contribution

### Ajouter de nouvelles fonctionnalités
1. Modifiez les scripts dans `scripts/`
2. Mettez à jour la configuration dans `.auto-build-config`
3. Ajoutez des tests dans `scripts/test-auto-build.sh`
4. Mettez à jour cette documentation

### Structure des scripts
```
scripts/
├── auto-build-watch.sh      # Surveillance et build automatique
├── dev-watch.sh             # Environnement de développement
├── setup-auto-build.sh      # Configuration initiale
└── test-auto-build.sh       # Tests du système
```

### Bonnes pratiques
- Toujours tester avant de déployer
- Utiliser les logs pour le débogage
- Configurer les exclusions appropriées
- Surveiller les performances

## 📞 Support

### Commandes d'aide
```bash
# Aide générale
./start-auto-build.sh help

# Aide spécifique
./scripts/auto-build-watch.sh --help
./scripts/dev-watch.sh --help
./scripts/setup-auto-build.sh --help
./scripts/test-auto-build.sh --help
```

### Ressources
- [Documentation Laravel](https://laravel.com/docs)
- [Documentation Vite](https://vitejs.dev/guide/)
- [Documentation inotify-tools](https://github.com/inotify-tools/inotify-tools)

---

**Note** : Ce système est conçu pour améliorer votre productivité de développement. Il automatise les tâches répétitives et vous permet de vous concentrer sur le code plutôt que sur la configuration. 