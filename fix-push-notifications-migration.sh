#!/bin/bash

# Script pour corriger les colonnes manquantes dans push_notifications
# À exécuter sur le serveur Forge si le problème persiste

echo "=== DIAGNOSTIC ET CORRECTION PUSH NOTIFICATIONS ==="

# Définir l'environnement PHP
FORGE_PHP="/usr/bin/php8.2"

echo "1. Vérification de la structure actuelle de la table..."
$FORGE_PHP artisan tinker --execute="
try {
    \$columns = Schema::getColumnListing('push_notifications');
    echo 'Colonnes actuelles : ' . implode(', ', \$columns) . PHP_EOL;
    
    \$hasContentType = in_array('content_type', \$columns);
    \$hasContentId = in_array('content_id', \$columns);
    
    echo 'content_type existe : ' . (\$hasContentType ? 'OUI' : 'NON') . PHP_EOL;
    echo 'content_id existe : ' . (\$hasContentId ? 'OUI' : 'NON') . PHP_EOL;
} catch (Exception \$e) {
    echo 'Erreur : ' . \$e->getMessage() . PHP_EOL;
}
"

echo ""
echo "2. Vérification du statut des migrations..."
$FORGE_PHP artisan migrate:status | grep -E "(push_notifications|2025_08_01)"

echo ""
echo "3. Exécution forcée de la migration spécifique..."
$FORGE_PHP artisan migrate --path=database/migrations/2025_08_01_190812_add_content_fields_to_push_notifications_table.php --force

echo ""
echo "4. Vérification finale..."
$FORGE_PHP artisan tinker --execute="
try {
    \$columns = Schema::getColumnListing('push_notifications');
    \$hasContentType = in_array('content_type', \$columns);
    \$hasContentId = in_array('content_id', \$columns);
    
    if (\$hasContentType && \$hasContentId) {
        echo '✅ SUCCESS: Les colonnes content_type et content_id existent maintenant !' . PHP_EOL;
    } else {
        echo '❌ ERREUR: Les colonnes sont toujours manquantes.' . PHP_EOL;
        echo 'Colonnes disponibles : ' . implode(', ', \$columns) . PHP_EOL;
    }
} catch (Exception \$e) {
    echo '❌ ERREUR : ' . \$e->getMessage() . PHP_EOL;
}
"

echo ""
echo "5. Test de création d'une notification..."
$FORGE_PHP artisan tinker --execute="
try {
    \$notification = new App\Models\PushNotification();
    \$notification->title = 'Test Migration';
    \$notification->message = 'Test des nouvelles colonnes';
    \$notification->content_type = 'recipe';
    \$notification->content_id = 1;
    \$notification->target_audience = 'all';
    \$notification->status = 'draft';
    \$notification->created_by = 1;
    
    \$notification->save();
    echo '✅ SUCCESS: Notification créée avec succès (ID: ' . \$notification->id . ')' . PHP_EOL;
    
    // Supprimer le test
    \$notification->delete();
    echo '✅ Test nettoyé.' . PHP_EOL;
    
} catch (Exception \$e) {
    echo '❌ ERREUR lors du test : ' . \$e->getMessage() . PHP_EOL;
}
"

echo ""
echo "=== DIAGNOSTIC TERMINÉ ===" 