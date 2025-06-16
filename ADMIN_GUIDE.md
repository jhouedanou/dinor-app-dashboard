# Guide d'Administration - Dinor Dashboard

## 🎨 Thème et Interface

### Mode Light par Défaut
Le dashboard Filament est maintenant configuré pour utiliser le mode light par défaut avec un thème personnalisé Dinor.

**Caractéristiques du thème :**
- Couleurs primaires en tons ambrés (#f59e0b)
- Interface claire et moderne
- Amélioration de la lisibilité
- Mise en forme optimisée pour les formulaires et tableaux

### Personnalisation
Le fichier de thème se trouve dans : `resources/css/filament/admin/theme.css`

## 🔐 Gestion des Mots de Passe

### Nouvelle Commande : `admin:reset-password`

Cette commande permet de réinitialiser ou créer des comptes administrateurs facilement.

#### Utilisation

```bash
# Réinitialiser avec un mot de passe spécifique
docker exec -it dinor-app php artisan admin:reset-password admin@dinor.app --password="MonNouveauMotDePasse"

# Réinitialiser avec génération automatique
docker exec -it dinor-app php artisan admin:reset-password admin@dinor.app

# Mode interactif (demande email et mot de passe)
docker exec -it dinor-app php artisan admin:reset-password

# Créer un nouvel administrateur
docker exec -it dinor-app php artisan admin:reset-password nouvel.admin@dinor.app
```

#### Fonctionnalités
- ✅ Réinitialisation de mots de passe existants
- ✅ Création de nouveaux administrateurs
- ✅ Génération automatique de mots de passe sécurisés
- ✅ Mode interactif pour saisie sécurisée
- ✅ Validation des emails et mots de passe

#### Exemples d'utilisation

**Réinitialiser l'admin par défaut :**
```bash
docker exec -it dinor-app php artisan admin:reset-password admin@dinor.app
```

**Créer un nouvel admin :**
```bash
docker exec -it dinor-app php artisan admin:reset-password john.doe@dinor.app
```

## 🚀 Configuration Automatisée

Le script `manual-setup.sh` a été mis à jour pour inclure :

1. **Création de la table notifications** - Pour les notifications Filament
2. **Assets Filament** - Génération des CSS et JS
3. **Thème personnalisé** - Application du thème Dinor
4. **Nettoyage des caches** - Optimisation des performances

## 📋 Identifiants par Défaut

**Email :** admin@dinor.app  
**Mot de passe :** Dinor2024!Admin

> ⚠️ **Important :** Il est recommandé de changer ce mot de passe après la première connexion.

## 🔧 Maintenance

### Commandes Utiles

```bash
# Réinitialiser tous les caches
docker exec -it dinor-app php artisan optimize:clear

# Régénérer les assets Filament
docker exec -it dinor-app php artisan filament:assets

# Vérifier le statut des migrations
docker exec -it dinor-app php artisan migrate:status

# Afficher l'aide de la commande admin
docker exec -it dinor-app php artisan admin:reset-password --help
```

### Dépannage

**Problème : CSS mal appliqué**
```bash
# Recréer les assets
docker exec -it dinor-app mkdir -p public/build/assets
docker exec -it dinor-app cp resources/css/filament/admin/theme.css public/build/assets/theme.css
docker exec -it dinor-app php artisan optimize:clear
```

**Problème : Erreur de base de données**
```bash
# Vérifier et exécuter les migrations
docker exec -it dinor-app php artisan migrate:status
docker exec -it dinor-app php artisan migrate
```

## 📚 Ressources

- **Dashboard Admin :** http://localhost:8000/admin
- **API :** http://localhost:8000/api/v1/
- **PhpMyAdmin :** http://localhost:8080

Pour toute question technique, consultez la documentation Laravel Filament : https://filamentphp.com/docs 