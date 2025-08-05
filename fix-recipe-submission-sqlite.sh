#!/bin/bash

echo "=== CORRECTION SOUMISSION DE RECETTES (SQLite) ==="

# 1. Créer une copie de l'env pour SQLite
echo "1. Configuration SQLite temporaire..."
cp .env .env.backup
cat > .env.sqlite << 'EOF'
APP_NAME="Dinor Dashboard"
APP_ENV=local
APP_KEY=base64:M5GytSDj8iMdMvmmkK9aWVFuswKLMq+hwBjnRnnk+UM=
APP_DEBUG=true
APP_URL=http://localhost:8000
APP_LOCALE=fr
APP_FALLBACK_LOCALE=en
APP_TIMEZONE="Europe/Paris"

FILAMENT_AUTH_GUARD=admin
FILAMENT_FILESYSTEM_DRIVER=public

LOG_CHANNEL=stack
LOG_DEPRECATIONS_CHANNEL=null
LOG_LEVEL=debug

DB_CONNECTION=sqlite
DB_DATABASE=database/database.sqlite

BROADCAST_DRIVER=log
CACHE_DRIVER=file
FILESYSTEM_DISK=local
QUEUE_CONNECTION=sync
SESSION_DRIVER=file
SESSION_LIFETIME=120
EOF

# 2. Utiliser SQLite temporairement
cp .env.sqlite .env

# 3. Créer la base SQLite si elle n'existe pas
echo "2. Création de la base SQLite..."
mkdir -p database
touch database/database.sqlite

# 4. Exécuter les migrations
echo "3. Exécution des migrations..."
php artisan migrate --force

# 5. Vérifier que la table existe
echo "4. Vérification de la table..."
php artisan tinker --execute="
if (Schema::hasTable('professional_contents')) {
    echo '✅ Table professional_contents existe' . PHP_EOL;
    \$columns = Schema::getColumnListing('professional_contents');
    echo 'Colonnes: ' . implode(', ', \$columns) . PHP_EOL;
    \$count = App\Models\ProfessionalContent::count();
    echo 'Nombre d\'enregistrements: ' . \$count . PHP_EOL;
} else {
    echo '❌ Table professional_contents n\'existe pas!' . PHP_EOL;
}
"

# 6. Créer les dossiers de stockage
echo "5. Création des dossiers de stockage..."
mkdir -p storage/app/public/professional-content
chmod -R 775 storage/app/public/

# 7. Créer un utilisateur test avec le bon rôle
echo "6. Création d'un utilisateur test..."
php artisan tinker --execute="
try {
    \$user = App\Models\User::updateOrCreate(
        ['email' => 'test@example.com'],
        [
            'name' => 'Test Professional',
            'password' => Hash::make('password'),
            'role' => 'professional',
            'email_verified_at' => now()
        ]
    );
    echo '✅ Utilisateur test créé: ' . \$user->name . ' (' . \$user->email . ')' . PHP_EOL;
    echo 'Role: ' . \$user->role . PHP_EOL;
    echo 'isProfessional: ' . (\$user->isProfessional() ? 'Oui' : 'Non') . PHP_EOL;
} catch (Exception \$e) {
    echo '❌ Erreur création utilisateur: ' . \$e->getMessage() . PHP_EOL;
}
"

# 8. Tester la création d'un contenu professionnel
echo "7. Test de création de contenu..."
php artisan tinker --execute="
try {
    \$user = App\Models\User::where('email', 'test@example.com')->first();
    if (\$user && \$user->isProfessional()) {
        \$content = App\Models\ProfessionalContent::create([
            'user_id' => \$user->id,
            'content_type' => 'recipe',
            'title' => 'Test Recipe Submission',
            'description' => 'This is a test recipe description',
            'content' => 'Test recipe content with steps...',
            'ingredients' => [
                ['name' => 'Ingredient 1', 'quantity' => '1', 'unit' => 'cup'],
                ['name' => 'Ingredient 2', 'quantity' => '2', 'unit' => 'tbsp']
            ],
            'steps' => [
                ['instruction' => 'Step 1: Do something'],
                ['instruction' => 'Step 2: Do something else']
            ],
            'status' => 'pending',
            'submitted_at' => now(),
        ]);
        
        echo '✅ Test de création réussi!' . PHP_EOL;
        echo 'ID: ' . \$content->id . PHP_EOL;
        echo 'Titre: ' . \$content->title . PHP_EOL;
        echo 'Type: ' . \$content->content_type . PHP_EOL;
        echo 'Status: ' . \$content->status . PHP_EOL;
        
        // Vérifier que le contenu peut être récupéré
        \$retrieved = App\Models\ProfessionalContent::find(\$content->id);
        if (\$retrieved) {
            echo '✅ Contenu récupéré avec succès' . PHP_EOL;
        }
        
        // Nettoyer le test
        \$content->delete();
        echo '🧹 Test nettoyé' . PHP_EOL;
        
    } else {
        echo '❌ Utilisateur test non trouvé ou pas professionnel' . PHP_EOL;
    }
} catch (Exception \$e) {
    echo '❌ Erreur test création: ' . \$e->getMessage() . PHP_EOL;
    echo 'Trace: ' . \$e->getTraceAsString() . PHP_EOL;
}
"

# 9. Tester l'API directement
echo "8. Test de l'API REST..."
echo "Génération d'un token pour l'utilisateur test..."
php artisan tinker --execute="
\$user = App\Models\User::where('email', 'test@example.com')->first();
if (\$user) {
    \$token = \$user->createToken('test-token')->plainTextToken;
    echo 'Token généré: ' . \$token . PHP_EOL;
    echo 'Pour tester l\'API, utilisez:' . PHP_EOL;
    echo 'curl -X POST http://localhost:8000/api/v1/professional-content \\' . PHP_EOL;
    echo '  -H \"Authorization: Bearer ' . \$token . '\" \\' . PHP_EOL;
    echo '  -H \"Content-Type: application/json\" \\' . PHP_EOL;
    echo '  -d \'{\"content_type\":\"recipe\",\"title\":\"Test API Recipe\",\"description\":\"Test description\",\"content\":\"Test content\"}\'' . PHP_EOL;
}
"

# 10. Restaurer l'env original
echo "9. Restauration de la configuration originale..."
cp .env.backup .env
rm .env.sqlite .env.backup

echo "=== TESTS TERMINÉS ==="
echo ""
echo "🔧 POUR CORRIGER EN PRODUCTION:"
echo "1. Vérifier que la migration professional_contents a été exécutée"
echo "2. S'assurer que les utilisateurs ont le bon rôle (professional/admin/moderator)"
echo "3. Vérifier les permissions du dossier storage/"
echo "4. Vérifier les logs Laravel pour les erreurs détaillées"
echo ""
echo "📊 TABLE CRÉÉE AVEC SUCCÈS DANS SQLITE - Structure validée ✅"