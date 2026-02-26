<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class ProductionSetupSeeder extends Seeder
{
    /**
     * Run the database seeds for production setup.
     */
    public function run(): void
    {
        // Vérifier que les tables existent et les créer si nécessaire
        $this->ensureTablesExist();
        
        // Exécuter les seeders dans l'ordre
        $this->call([
            AdminUserSeeder::class,
            UserSeeder::class,
            CategorySeeder::class,
            ProductionDataSeeder::class,
        ]);

        $this->command->info('Setup de production terminé avec succès!');
        $this->command->info('');
        $this->command->info('=== COMPTES CRÉÉS ===');
        $this->command->info('Admin: admin@dinor.app / [mot de passe configuré dans .env]');
        $this->command->info('Utilisateurs: mots de passe générés aléatoirement');
        $this->command->info('');
        $this->command->info('=== DONNÉES CRÉÉES ===');
        $this->command->info('- ' . \App\Models\Category::count() . ' catégories');
        $this->command->info('- ' . \App\Models\Recipe::count() . ' recettes');
        $this->command->info('- ' . \App\Models\Tip::count() . ' astuces');
        $this->command->info('- ' . \App\Models\Event::count() . ' événements');
        $this->command->info('- ' . \App\Models\Page::count() . ' pages');
        $this->command->info('- ' . \App\Models\DinorTv::count() . ' vidéos');
        $this->command->info('- ' . \App\Models\User::count() . ' utilisateurs');
        $this->command->info('- ' . \App\Models\Like::count() . ' likes');
        $this->command->info('- ' . \App\Models\Comment::count() . ' commentaires');
    }

    private function ensureTablesExist()
    {
        $tables = [
            'users',
            'categories', 
            'recipes',
            'tips',
            'events',
            'pages',
            'dinor_tv',
            'likes',
            'comments',
            'media_files'
        ];

        foreach ($tables as $table) {
            if (!Schema::hasTable($table)) {
                $this->command->error("Table '$table' n'existe pas. Veuillez exécuter les migrations d'abord:");
                $this->command->error("php artisan migrate");
                return false;
            }
        }

        return true;
    }
}