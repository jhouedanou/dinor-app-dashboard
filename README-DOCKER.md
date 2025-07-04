# 🐳 Dinor Dashboard - Guide Docker

Ce guide explique comment utiliser Docker pour développer et exécuter l'application Dinor Dashboard.

## 📋 Prérequis

- Docker (version 20.10+)
- Docker Compose (version 1.29+)

## 🚀 Démarrage rapide

### 1. Démarrer l'environnement complet
```bash
./start-docker.sh
```

### 2. Arrêter l'environnement
```bash
./stop-docker.sh
```

## 🌐 URLs d'accès

Une fois démarré, vous pouvez accéder à :

- **Application Laravel** : http://localhost:8000
- **Admin Dashboard** : http://localhost:8000/admin
- **Adminer (Base de données)** : http://localhost:8080
- **PWA Development** : http://localhost:5173

## 🔧 Commandes utiles

### Gestion des conteneurs
```bash
# Démarrer les conteneurs
docker-compose up -d

# Arrêter les conteneurs
docker-compose down

# Voir les logs
docker-compose logs -f

# Reconstruire les images
docker-compose build --no-cache
```

### Accès au conteneur principal
```bash
# Ouvrir un shell dans le conteneur
docker exec -it dinor-app bash

# Exécuter des commandes Artisan
docker exec -it dinor-app php artisan migrate
docker exec -it dinor-app php artisan cache:clear
docker exec -it dinor-app php artisan config:clear

# Installer des dépendances
docker exec -it dinor-app composer install
docker exec -it dinor-app npm install
```

### Base de données
```bash
# Accéder à PostgreSQL
docker exec -it dinor-postgres psql -U postgres -d postgres

# Voir les logs de la base de données
docker logs dinor-postgres
```

## 🏗️ Architecture Docker

L'environnement Docker comprend :

- **dinor-app** : Application Laravel + Nginx + PHP-FPM
- **dinor-postgres** : Base de données PostgreSQL
- **dinor-redis** : Cache Redis
- **dinor-adminer** : Interface web pour gérer PostgreSQL

## 🔍 Dépannage

### Problème de permissions
```bash
# Corriger les permissions des dossiers
sudo chown -R $USER:$USER .
chmod -R 755 storage bootstrap/cache
```

### Problème de dépendances
```bash
# Réinstaller les dépendances
docker exec -it dinor-app composer install --no-cache
docker exec -it dinor-app npm install
```

### Problème de base de données
```bash
# Redémarrer la base de données
docker-compose restart db

# Vérifier la connexion
docker exec -it dinor-app php artisan tinker
```

## 📝 Notes importantes

- Les volumes Docker sont configurés pour persister les données
- Le hot reload est disponible pour le développement PWA
- Les logs sont accessibles via `docker-compose logs -f`
- L'environnement utilise PHP 8.2 avec toutes les extensions nécessaires

## 🆘 Support

En cas de problème :
1. Vérifiez que Docker est démarré
2. Consultez les logs : `docker-compose logs -f`
3. Redémarrez les conteneurs : `docker-compose restart`
4. Reconstruisez si nécessaire : `docker-compose build --no-cache` 