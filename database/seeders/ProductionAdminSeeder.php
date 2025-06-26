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
        AdminUser::updateOrCreate(
            ['email' => 'admin@dinor.app'],
            [
                'name' => 'AdministrateurDinor',
                'password' => Hash::make('Dinor2024!Admin'),
                'email_verified_at' => now(),
                'is_active' => true
            ]
        );
    }
}