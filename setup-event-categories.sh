#!/bin/bash

# Script pour configurer les catégories d'événements
echo "🚀 Configuration des catégories d'événements..."

# Exécuter les migrations
echo "📦 Exécution des migrations..."
php artisan migrate --path=database/migrations/2025_01_01_000000_create_event_categories_table.php
php artisan migrate --path=database/migrations/2025_01_01_000001_add_event_category_id_to_events_table.php

# Exécuter le seeder
echo "🌱 Peuplement des catégories d'événements..."
php artisan db:seed --class=EventCategorySeeder

# Vider le cache
echo "🧹 Nettoyage du cache..."
php artisan cache:clear
php artisan config:clear
php artisan view:clear

# Optionnel : Migration des données existantes
echo "🔄 Voulez-vous migrer les événements existants vers les nouvelles catégories ? (y/n)"
read -r migrate_data

if [ "$migrate_data" = "y" ] || [ "$migrate_data" = "Y" ]; then
    echo "🔄 Migration des données existantes..."
    php artisan tinker --execute="
        \$events = App\Models\Event::whereNotNull('category_id')->get();
        foreach (\$events as \$event) {
            \$categoryName = \$event->category?->name;
            if (\$categoryName) {
                \$eventCategory = App\Models\EventCategory::where('name', 'LIKE', '%' . \$categoryName . '%')->first();
                if (!\$eventCategory) {
                    \$eventCategory = App\Models\EventCategory::where('name', 'Événement général')->first();
                }
                if (\$eventCategory) {
                    \$event->update(['event_category_id' => \$eventCategory->id]);
                    echo \"Événement '{\$event->title}' associé à '{\$eventCategory->name}'\n\";
                }
            }
        }
        echo \"Migration terminée !\n\";
    "
fi

echo "✅ Configuration terminée !"
echo ""
echo "📋 Prochaines étapes :"
echo "1. Accédez à l'admin Filament"
echo "2. Allez dans Configuration > Catégories d'événements"
echo "3. Créez ou modifiez les catégories selon vos besoins"
echo "4. Éditez vos événements pour leur assigner les nouvelles catégories"
echo ""
echo "🔗 API disponible :"
echo "- GET /api/event-categories - Liste des catégories"
echo "- GET /api/events?event_category_id=X - Filtrer par catégorie" 