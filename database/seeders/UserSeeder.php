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
        $users = [
            [
                'name' => 'Admin Dinor',
                'email' => 'admin@dinor.app',
                'password' => Hash::make('admin123'),
                'role' => 'admin',
                'is_active' => true,
                'email_verified_at' => now(),
            ],
            [
                'name' => 'Chef Aya Kouamé',
                'email' => 'chef.aya@dinor.app',
                'password' => Hash::make('password'),
                'role' => 'moderator',
                'is_active' => true,
                'email_verified_at' => now(),
            ],
            [
                'name' => 'Marie Adjoua',
                'email' => 'marie.adjoua@example.com',
                'password' => Hash::make('password'),
                'role' => 'user',
                'is_active' => true,
                'email_verified_at' => now(),
            ],
            [
                'name' => 'Kouadio Jean',
                'email' => 'kouadio.jean@example.com',
                'password' => Hash::make('password'),
                'role' => 'user',
                'is_active' => true,
                'email_verified_at' => now(),
            ],
            [
                'name' => 'Fatima Traoré',
                'email' => 'fatima.traore@example.com',
                'password' => Hash::make('password'),
                'role' => 'user',
                'is_active' => true,
                'email_verified_at' => now(),
            ],
            [
                'name' => 'Yves Diabaté',
                'email' => 'yves.diabate@example.com',
                'password' => Hash::make('password'),
                'role' => 'user',
                'is_active' => true,
                'email_verified_at' => now(),
            ],
            [
                'name' => 'Aminata Coulibaly',
                'email' => 'aminata.coulibaly@example.com',
                'password' => Hash::make('password'),
                'role' => 'user',
                'is_active' => true,
                'email_verified_at' => now(),
            ],
            [
                'name' => 'Ibrahim Ouattara',
                'email' => 'ibrahim.ouattara@example.com',
                'password' => Hash::make('password'),
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
        $this->command->info('- Admin: admin@dinor.app / admin123');
        $this->command->info('- Chef: chef.aya@dinor.app / password');
        $this->command->info('- Utilisateurs: marie.adjoua@example.com / password (et autres)');
    }
}