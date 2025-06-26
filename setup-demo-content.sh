#!/bin/bash

echo "🚀 Configuration de l'environnement de démonstration..."

# Créer une sauvegarde de l'env actuel
cp .env .env.backup

# Configurer SQLite temporairement
echo "🔧 Configuration de SQLite..."
sed -i 's/DB_CONNECTION=.*/DB_CONNECTION=sqlite/' .env
sed -i 's/DB_DATABASE=.*/DB_DATABASE=database\/database.sqlite/' .env

# Créer le fichier de base de données SQLite
echo "📝 Création de la base de données SQLite..."
touch database/database.sqlite

# Exécuter les migrations
echo "🗄️ Exécution des migrations..."
php artisan migrate --force

# Exécuter les seeders
echo "🌱 Chargement des données de démonstration..."
php artisan db:seed --class=DemoContentSeeder --force

echo "✅ Configuration terminée avec succès !"
echo ""
echo "📋 Résumé :"
echo "- Base de données SQLite créée"
echo "- Migrations exécutées"  
echo "- Contenu de démonstration ajouté :"
echo "  - 4 recettes traditionnelles ivoiriennes"
echo "  - 4 astuces culinaires"
echo "  - 4 événements gastronomiques"
echo "  - Bannières pour la page d'accueil"
echo ""
echo "🔄 Pour revenir à la configuration PostgreSQL :"
echo "   mv .env.backup .env"
echo ""
echo "🌐 Vous pouvez maintenant tester l'application avec :"
echo "   npm run dev"
echo "   php artisan serve" 