<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\AdminUser;
use Illuminate\Support\Facades\Hash;

class ProductionAdminSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $email = env('ADMIN_DEFAULT_EMAIL', 'admin@dinor.app');
        $name = env('ADMIN_DEFAULT_NAME', 'AdministrateurDinor');
        $password = env('ADMIN_DEFAULT_PASSWORD');

        if (!$password) {
            $this->command?->error('ADMIN_DEFAULT_PASSWORD non défini dans .env — admin non créé.');
            return;
        }

        AdminUser::updateOrCreate(
            ['email' => $email],
            [
                'name' => $name,
                'password' => Hash::make($password),
                'email_verified_at' => now(),
                'is_active' => true
            ]
        );
    }
}