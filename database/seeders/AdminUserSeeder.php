<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\AdminUser;
use Illuminate\Support\Facades\Hash;

class AdminUserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Récupérer les informations depuis les variables d'environnement
        $adminEmail = env('ADMIN_DEFAULT_EMAIL', 'admin@dinor.app');
        $adminPassword = env('ADMIN_DEFAULT_PASSWORD', 'Dinor2024!Admin');
        $adminName = env('ADMIN_DEFAULT_NAME', 'Administrateur Dinor');

        // Vérifier si l'admin existe déjà
        $existingAdmin = AdminUser::where('email', $adminEmail)->first();

        if ($existingAdmin) {
            // Mettre à jour le mot de passe si nécessaire
            if (!Hash::check($adminPassword, $existingAdmin->password)) {
                $existingAdmin->update([
                    'password' => Hash::make($adminPassword),
                    'name' => $adminName,
                    'is_active' => true,
                ]);
                $this->command->info("✅ Utilisateur admin mis à jour: {$adminEmail}");
            } else {
                $this->command->info("ℹ️ Utilisateur admin existe déjà et est à jour: {$adminEmail}");
            }
        } else {
            // Créer un nouvel administrateur
            AdminUser::create([
                'name' => $adminName,
                'email' => $adminEmail,
                'password' => Hash::make($adminPassword),
                'email_verified_at' => now(),
                'is_active' => true,
            ]);
            
            $this->command->info("✅ Nouvel utilisateur admin créé: {$adminEmail}");
        }

        // Afficher les informations de connexion
        $this->command->info("📧 Email: {$adminEmail}");
        $this->command->info("🌐 URL: " . config('app.url') . "/admin/login");
    }
} 