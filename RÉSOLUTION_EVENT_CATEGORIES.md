# Résolution du problème "event_categories does not exist"

## 🚨 Problème
Erreur HTTP 500 : 
```
SQLSTATE[42P01]: Undefined table: 7 ERROR: relation "event_categories" does not exist
```

## 💡 Cause
La table `event_categories` n'existe pas dans la base de données, bien que les migrations soient présentes.

## 🔧 Solutions

### Solution 1 : Utiliser le script Docker automatisé (RECOMMANDÉ)

1. **Démarrer Docker Desktop** 
   - Ouvrir Docker Desktop depuis le bureau
   - Attendre que l'icône Docker soit verte/stable

2. **Exécuter le script de migration**
   ```bash
   ./docker-migrate-event-categories.sh
   ```

3. **Vérifier avec le diagnostic**
   ```bash
   ./docker-diagnostic-db.sh
   ```

### Solution 2 : Commandes manuelles Docker

Si les scripts ne fonctionnent pas :

```bash
# 1. Démarrer les conteneurs
docker compose up -d

# 2. Attendre 10 secondes pour la DB
sleep 10

# 3. Exécuter les migrations
docker exec -it dinor-app php artisan migrate --force

# 4. Migration spécifique event_categories
docker exec -it dinor-app php artisan migrate --path=database/migrations/2025_01_01_000000_create_event_categories_table.php --force

# 5. Migration event_category_id dans events
docker exec -it dinor-app php artisan migrate --path=database/migrations/2025_01_01_000001_add_event_category_id_to_events_table.php --force

# 6. Seeder des catégories
docker exec -it dinor-app php artisan db:seed --class=EventCategorySeeder --force

# 7. Nettoyer les caches
docker exec -it dinor-app php artisan cache:clear
docker exec -it dinor-app php artisan config:clear
```

### Solution 3 : Déploiement Forge

Le fichier `deploy-forge-final.sh` a été mis à jour pour inclure automatiquement les migrations event_categories.

## 📝 Fichiers modifiés

1. **`deploy-forge-final.sh`** - Ajout de la section migration event_categories
2. **`docker-migrate-event-categories.sh`** - Script automatisé pour Docker
3. **`docker-diagnostic-db.sh`** - Script de diagnostic de la DB

## ✅ Vérification

Après la migration, vous devriez voir :

```bash
# Vérifier les tables
docker exec -it dinor-postgres psql -U postgres -d postgres -c "\dt event_categories"

# Vérifier le contenu
docker exec -it dinor-postgres psql -U postgres -d postgres -c "SELECT * FROM event_categories;"

# Tester l'API
curl http://localhost:8000/api/event-categories
```

## 🌐 Accès après résolution

1. **Dashboard Filament** : http://localhost:8000/admin
   - Email : `admin@dinor.app`
   - Mot de passe : `Dinor2024!Admin`

2. **API Event Categories** : http://localhost:8000/api/event-categories

3. **API Events filtrés** : http://localhost:8000/api/events?event_category_id=1

## 🛠️ Dépannage

### Docker ne démarre pas
```bash
# Vérifier Docker
docker --version
docker info

# Redémarrer Docker Desktop
docker desktop restart
```

### Conteneurs ne démarrent pas
```bash
# Supprimer et recréer
docker compose down
docker compose up -d --build
```

### Permissions PostgreSQL
```bash
# Réinitialiser la base de données
docker compose down
docker volume rm dinor-app-dashboard_postgres_data
docker compose up -d
```

## 📞 Support

Si le problème persiste :
1. Exécuter `./docker-diagnostic-db.sh`
2. Copier la sortie complète
3. Vérifier les logs : `docker logs dinor-app`

## 🔄 Prochaines étapes

Une fois résolu :
1. Créer des catégories d'événements dans l'admin
2. Associer les événements existants aux nouvelles catégories
3. Tester les filtres dans l'API et la PWA 