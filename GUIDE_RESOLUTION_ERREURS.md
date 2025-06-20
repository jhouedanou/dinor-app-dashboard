# Guide de Résolution des Erreurs de Déploiement

## Erreur CollisionServiceProvider

### Symptôme
```
Class "NunoMaduro\Collision\Adapters\Laravel\CollisionServiceProvider" not found
```

### Solution
Cette erreur se produit quand les dépendances Composer ne sont pas correctement installées avec la bonne version de PHP.

**Étapes de résolution :**

1. **Nettoyage des dépendances**
```bash
rm -rf vendor/
rm -f composer.lock
```

2. **Installation avec Docker (recommandé)**
```bash
docker run --rm -v $(pwd):/app -w /app composer:latest composer install --no-dev --optimize-autoloader
```

3. **Ou avec Composer local si PHP 8.2+ est disponible**
```bash
composer install --no-dev --optimize-autoloader
```

## Erreur de Conflits Git

### Symptôme
```
error: Your local changes to the following files would be overwritten by merge:
	storage/logs/laravel.log
Please commit your changes or stash them before you merge.
```

### Solution Automatique
Utilisez le script de nettoyage :
```bash
./fix-git-conflicts.sh
```

### Solution Manuelle
```bash
# Supprimer les logs problématiques
rm -rf storage/logs/*.log

# Nettoyer le cache Git
git rm --cached storage/logs/*.log 2>/dev/null || true

# Stash les changements
git stash push -m "Backup avant déploiement"

# Mettre à jour
git fetch origin main
git reset --hard origin/main
```

## Déploiement avec Docker

Le script de déploiement a été modifié pour utiliser Docker automatiquement. Il utilise :
- **PHP 8.2** via Docker
- **Composer** via Docker
- Résolution automatique des conflits Git

### Commandes de déploiement
```bash
# 1. Nettoyer les conflits (optionnel)
./fix-git-conflicts.sh

# 2. Déployer
./deploy-production.sh
```

## Vérification Post-Déploiement

### Vérifier l'installation
```bash
# Vérifier PHP
docker run --rm -v $(pwd):/app -w /app php:8.2-cli php --version

# Vérifier les dépendances
ls -la vendor/nunomaduro/collision/

# Vérifier Laravel
docker run --rm -v $(pwd):/app -w /app php:8.2-cli php artisan --version
```

### Tester l'API
```bash
curl -X GET https://new.dinorapp.com/api/test/database-check
```

## Problèmes Courants

### 1. Docker non disponible
Si Docker n'est pas disponible, assurez-vous que :
- Docker est installé
- Le service Docker est démarré
- L'utilisateur a les permissions Docker

### 2. Permissions insuffisantes
```bash
sudo chown -R $USER:$USER storage/
sudo chmod -R 775 storage/
sudo chmod -R 775 bootstrap/cache/
```

### 3. Base de données non accessible
Vérifiez les variables d'environnement dans `.env` :
```
DB_CONNECTION=pgsql
DB_HOST=localhost
DB_PORT=5432
DB_DATABASE=dinor_db
DB_USERNAME=postgres
DB_PASSWORD=votre_mot_de_passe
```

## Commandes d'Urgence

### Arrêter la maintenance
```bash
docker run --rm -v $(pwd):/app -w /app php:8.2-cli php artisan up
```

### Nettoyer le cache
```bash
docker run --rm -v $(pwd):/app -w /app php:8.2-cli php artisan cache:clear
docker run --rm -v $(pwd):/app -w /app php:8.2-cli php artisan config:clear
```

### Régénérer la clé d'application
```bash
docker run --rm -v $(pwd):/app -w /app php:8.2-cli php artisan key:generate --force
```

## Contact Support

Si le problème persiste :
1. Vérifiez les logs : `storage/logs/laravel.log`
2. Contactez l'équipe technique avec le message d'erreur complet
3. Incluez la version PHP et la configuration système 