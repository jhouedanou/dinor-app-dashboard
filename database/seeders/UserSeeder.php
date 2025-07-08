<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Utiliser un mot de passe fixe pour les tests en développement
        $testPassword = env('TEST_USER_PASSWORD', 'password123');
        
        $users = [
            [
                'name' => 'Chef Aya Kouamé',
                'email' => 'chef.aya@dinor.app',
                'password' => Hash::make($testPassword),
                'role' => 'moderator',
                'is_active' => true,
                'email_verified_at' => now(),
            ],
            [
                'name' => 'Marie Adjoua',
                'email' => 'marie.adjoua@example.com',
                'password' => Hash::make($testPassword),
                'role' => 'user',
                'is_active' => true,
                'email_verified_at' => now(),
            ],
            [
                'name' => 'Kouadio Jean',
                'email' => 'kouadio.jean@example.com',
                'password' => Hash::make($testPassword),
                'role' => 'user',
                'is_active' => true,
                'email_verified_at' => now(),
            ],
            [
                'name' => 'Fatima Traoré',
                'email' => 'fatima.traore@example.com',
                'password' => Hash::make($testPassword),
                'role' => 'user',
                'is_active' => true,
                'email_verified_at' => now(),
            ],
            [
                'name' => 'Yves Diabaté',
                'email' => 'yves.diabate@example.com',
                'password' => Hash::make($testPassword),
                'role' => 'user',
                'is_active' => true,
                'email_verified_at' => now(),
            ],
            [
                'name' => 'Aminata Coulibaly',
                'email' => 'aminata.coulibaly@example.com',
                'password' => Hash::make($testPassword),
                'role' => 'user',
                'is_active' => true,
                'email_verified_at' => now(),
            ],
            [
                'name' => 'Ibrahim Ouattara',
                'email' => 'ibrahim.ouattara@example.com',
                'password' => Hash::make($testPassword),
                'role' => 'user',
                'is_active' => true,
                'email_verified_at' => now(),
            ],
        ];

        foreach ($users as $userData) {
            User::firstOrCreate(
                ['email' => $userData['email']], 
                $userData
            );
        }

        $this->command->info('Utilisateurs créés avec succès!');
        $this->command->info('Comptes de test disponibles:');
        $this->command->info("- Chef: chef.aya@dinor.app / {$testPassword}");
        $this->command->info("- Fatima: fatima.traore@example.com / {$testPassword}");
        $this->command->info("- Utilisateur test: marie.adjoua@example.com / {$testPassword}");
        $this->command->warn('⚠️ Mot de passe de test fixe - changez-le en production!');
    }
}