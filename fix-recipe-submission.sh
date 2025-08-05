#!/bin/bash

echo "=== CORRECTION SOUMISSION DE RECETTES ==="

# 1. Vérifier que la migration existe et l'exécuter
echo "1. Vérification et exécution des migrations..."
php artisan migrate --force

# 2. Vérifier la table professional_contents
echo "2. Vérification de la table professional_contents..."
php artisan tinker --execute="
if (Schema::hasTable('professional_contents')) {
    echo 'Table professional_contents existe' . PHP_EOL;
    echo 'Colonnes: ' . implode(', ', Schema::getColumnListing('professional_contents')) . PHP_EOL;
} else {
    echo 'Table professional_contents n\'existe pas!' . PHP_EOL;
}
"

# 3. Créer le dossier de stockage si nécessaire
echo "3. Création des dossiers de stockage..."
mkdir -p storage/app/public/professional-content
chmod -R 775 storage/app/public/

# 4. S'assurer que le lien symbolique existe
echo "4. Création du lien symbolique storage..."
php artisan storage:link

# 5. Vérifier les utilisateurs et leurs rôles
echo "5. Vérification des utilisateurs..."
php artisan tinker --execute="
\$users = App\Models\User::all();
foreach (\$users as \$user) {
    \$role = \$user->role ?? 'user';
    \$isPro = method_exists(\$user, 'isProfessional') ? (\$user->isProfessional() ? 'Oui' : 'Non') : 'Méthode inexistante';
    echo \"User: {\$user->name} - Role: {\$role} - Professional: {\$isPro}\" . PHP_EOL;
}
"

# 6. Tester la création d'un contenu professionnel
echo "6. Test de création de contenu professionnel..."
php artisan tinker --execute="
try {
    \$user = App\Models\User::first();
    if (\$user) {
        // Forcer le rôle à professional pour le test
        \$user->role = 'professional';
        \$user->save();
        
        \$content = App\Models\ProfessionalContent::create([
            'user_id' => \$user->id,
            'content_type' => 'recipe',
            'title' => 'Test Recipe',
            'description' => 'Test description',
            'content' => 'Test content',
            'status' => 'pending',
            'submitted_at' => now(),
        ]);
        
        echo 'Test de création réussi! ID: ' . \$content->id . PHP_EOL;
        \$content->delete();
        echo 'Test nettoyé' . PHP_EOL;
    } else {
        echo 'Aucun utilisateur trouvé' . PHP_EOL;
    }
} catch (Exception \$e) {
    echo 'Erreur: ' . \$e->getMessage() . PHP_EOL;
}
"

# 7. Nettoyer le cache
echo "7. Nettoyage du cache..."
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear

echo "=== CORRECTION TERMINÉE ==="