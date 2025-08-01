#!/bin/bash

# Script d'urgence pour corriger les colonnes manquantes push_notifications
# À copier et exécuter directement sur le serveur Forge

echo "🚨 === CORRECTION D'URGENCE NOTIFICATIONS PUSH ==="
echo ""

# Vérifier qu'on est bien sur le serveur
if [ ! -f "artisan" ]; then
    echo "❌ Erreur: fichier artisan non trouvé. Êtes-vous dans le bon répertoire ?"
    echo "Utilisation: cd /home/forge/new.dinorapp.com && ./fix-push-notifications-urgent.sh"
    exit 1
fi

echo "1. 🔍 Diagnostic initial..."
php artisan tinker --execute="
try {
    if (Schema::hasTable('push_notifications')) {
        \$columns = Schema::getColumnListing('push_notifications');
        echo 'Table push_notifications existe' . PHP_EOL;
        echo 'Colonnes actuelles: ' . implode(', ', \$columns) . PHP_EOL;
        
        \$hasContentType = in_array('content_type', \$columns);
        \$hasContentId = in_array('content_id', \$columns);
        
        echo 'content_type: ' . (\$hasContentType ? '✅ PRÉSENTE' : '❌ MANQUANTE') . PHP_EOL;
        echo 'content_id: ' . (\$hasContentId ? '✅ PRÉSENTE' : '❌ MANQUANTE') . PHP_EOL;
        
        if (\$hasContentType && \$hasContentId) {
            echo 'STATUS:OK' . PHP_EOL;
        } else {
            echo 'STATUS:NEEDS_FIX' . PHP_EOL;
        }
    } else {
        echo '❌ Table push_notifications n\\'existe pas !' . PHP_EOL;
        echo 'STATUS:NO_TABLE' . PHP_EOL;
    }
} catch (Exception \$e) {
    echo '❌ Erreur: ' . \$e->getMessage() . PHP_EOL;
    echo 'STATUS:ERROR' . PHP_EOL;
}
"

echo ""
echo "2. 🔧 Application de la migration spécifique..."

# Exécuter la migration spécifique pour ajouter les colonnes
if php artisan migrate --path=database/migrations/2025_08_01_190812_add_content_fields_to_push_notifications_table.php --force; then
    echo "✅ Migration appliquée avec succès"
else
    echo "❌ Erreur lors de l'application de la migration"
    echo "Vérification si les colonnes existent déjà..."
fi

echo ""
echo "3. 🧪 Vérification post-migration..."
php artisan tinker --execute="
try {
    \$columns = Schema::getColumnListing('push_notifications');
    \$hasContentType = in_array('content_type', \$columns);
    \$hasContentId = in_array('content_id', \$columns);
    
    echo 'Colonnes après migration:' . PHP_EOL;
    echo 'content_type: ' . (\$hasContentType ? '✅ PRÉSENTE' : '❌ ENCORE MANQUANTE') . PHP_EOL;
    echo 'content_id: ' . (\$hasContentId ? '✅ PRÉSENTE' : '❌ ENCORE MANQUANTE') . PHP_EOL;
    
    if (\$hasContentType && \$hasContentId) {
        echo 'STATUS:FIXED' . PHP_EOL;
    } else {
        echo 'STATUS:STILL_BROKEN' . PHP_EOL;
    }
} catch (Exception \$e) {
    echo '❌ Erreur lors de la vérification: ' . \$e->getMessage() . PHP_EOL;
}
"

echo ""
echo "4. 🧪 Test de création d'une notification..."
php artisan tinker --execute="
try {
    \$notification = new App\\Models\\PushNotification();
    \$notification->title = 'Test Urgence - ' . date('H:i:s');
    \$notification->message = 'Test des colonnes content_type et content_id';
    \$notification->content_type = 'recipe';
    \$notification->content_id = 1;
    \$notification->target_audience = 'all';
    \$notification->status = 'draft';
    \$notification->created_by = 1;
    
    \$notification->save();
    echo '✅ SUCCESS: Notification créée avec succès (ID: ' . \$notification->id . ')' . PHP_EOL;
    
    // Supprimer le test
    \$notification->delete();
    echo '✅ Test nettoyé' . PHP_EOL;
    
} catch (Exception \$e) {
    echo '❌ ERREUR lors du test: ' . \$e->getMessage() . PHP_EOL;
    echo 'Les colonnes sont peut-être encore manquantes.' . PHP_EOL;
}
"

echo ""
echo "5. 📋 Résumé final..."
php artisan tinker --execute="
try {
    \$columns = Schema::getColumnListing('push_notifications');
    \$hasContentType = in_array('content_type', \$columns);
    \$hasContentId = in_array('content_id', \$columns);
    
    if (\$hasContentType && \$hasContentId) {
        echo '🎉 SUCCÈS: Les notifications push sont maintenant opérationnelles !' . PHP_EOL;
        echo '✅ Vous pouvez créer des notifications avec types de contenu' . PHP_EOL;
        echo '🌐 Interface admin: https://new.dinorapp.com/admin/push-notifications/create' . PHP_EOL;
    } else {
        echo '❌ PROBLÈME PERSISTANT: Les colonnes sont encore manquantes' . PHP_EOL;
        echo 'Contactez le support technique pour assistance' . PHP_EOL;
    }
} catch (Exception \$e) {
    echo '❌ Erreur finale: ' . \$e->getMessage() . PHP_EOL;
}
"

echo ""
echo "=== CORRECTION D'URGENCE TERMINÉE ===" 