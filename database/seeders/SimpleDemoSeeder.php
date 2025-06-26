<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class SimpleDemoSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Ce seeder sera utilisé via l'interface Filament
        // Les données sont créées directement dans l'admin
        $this->command->info('✅ Seeder simplifié exécuté - utilisez l\'interface Filament pour créer le contenu');
    }
}
