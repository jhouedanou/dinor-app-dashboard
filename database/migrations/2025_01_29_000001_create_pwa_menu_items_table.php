<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('pwa_menu_items', function (Blueprint $table) {
            $table->id();
            $table->string('label');
            $table->string('icon')->default('heroicon-o-home');
            $table->string('route');
            $table->integer('order')->default(0);
            $table->boolean('is_active')->default(true);
            $table->string('color', 7)->nullable();
            $table->timestamps();

            $table->index(['is_active', 'order']);
        });

        // Insertion des éléments par défaut
        DB::table('pwa_menu_items')->insert([
            [
                'label' => 'Accueil',
                'icon' => 'heroicon-o-home',
                'route' => 'home',
                'order' => 1,
                'is_active' => true,
                'color' => '#E1251B',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'label' => 'Recettes',
                'icon' => 'heroicon-o-cake',
                'route' => 'recipes',
                'order' => 2,
                'is_active' => true,
                'color' => '#9E7C22',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'label' => 'Astuces',
                'icon' => 'heroicon-o-light-bulb',
                'route' => 'tips',
                'order' => 3,
                'is_active' => true,
                'color' => '#E6D9D0',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'label' => 'Dinor TV',
                'icon' => 'heroicon-o-play-circle',
                'route' => 'dinor-tv',
                'order' => 4,
                'is_active' => true,
                'color' => '#690E08',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'label' => 'Événements',
                'icon' => 'heroicon-o-calendar-days',
                'route' => 'events',
                'order' => 5,
                'is_active' => true,
                'color' => '#818080',
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('pwa_menu_items');
    }
}; 