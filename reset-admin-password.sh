#!/bin/bash

echo "🔄 Réinitialisation du mot de passe admin..."

docker-compose exec app php artisan tinker --execute="
\$admin = App\\Models\\AdminUser::where('email', 'admin@dinor.app')->first();
if (\$admin) {
    \$admin->password = bcrypt('Dinor2024!Admin');
    \$admin->is_active = true;
    \$admin->save();
    echo 'Mot de passe réinitialisé avec succès!';
    echo 'Email: admin@dinor.app';
    echo 'Mot de passe: Dinor2024!Admin';
} else {
    echo 'Utilisateur admin introuvable. Création...';
    \$admin = App\\Models\\AdminUser::create([
        'name' => 'AdministrateurDinor',
        'email' => 'admin@dinor.app',
        'password' => bcrypt('Dinor2024!Admin'),
        'email_verified_at' => now(),
        'is_active' => true
    ]);
    echo 'Admin créé avec succès!';
}
"

echo "✅ Terminé ! Tu peux maintenant te connecter sur http://localhost:8000/admin" 