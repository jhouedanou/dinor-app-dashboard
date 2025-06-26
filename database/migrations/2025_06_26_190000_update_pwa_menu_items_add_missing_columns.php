<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('pwa_menu_items', function (Blueprint $table) {
            // Ajouter les colonnes manquantes si elles n'existent pas
            if (!Schema::hasColumn('pwa_menu_items', 'route')) {
                $table->string('route')->default('')->after('icon');
            }
            if (!Schema::hasColumn('pwa_menu_items', 'name')) {
                $table->string('name')->nullable()->after('id');
            }
            if (!Schema::hasColumn('pwa_menu_items', 'path')) {
                $table->string('path')->nullable()->after('route');
            }
            if (!Schema::hasColumn('pwa_menu_items', 'action_type')) {
                $table->enum('action_type', ['route', 'web_embed', 'external_link'])
                      ->default('route')->after('path');
            }
            if (!Schema::hasColumn('pwa_menu_items', 'web_url')) {
                $table->text('web_url')->nullable()->after('action_type');
            }
            if (!Schema::hasColumn('pwa_menu_items', 'description')) {
                $table->text('description')->nullable()->after('color');
            }
        });

        // Remplir la colonne 'name' avec des valeurs basées sur 'route'
        \Illuminate\Support\Facades\DB::table('pwa_menu_items')->update([
            'name' => \Illuminate\Support\Facades\DB::raw("LOWER(REPLACE(route, '-', '_'))")
        ]);

        // Remplir la colonne 'path' avec des valeurs basées sur 'route'
        \Illuminate\Support\Facades\DB::statement("
            UPDATE pwa_menu_items 
            SET path = CASE 
                WHEN route = 'home' THEN '/'
                WHEN route = 'recipes' THEN '/recipes'
                WHEN route = 'tips' THEN '/tips'
                WHEN route = 'dinor-tv' THEN '/dinor-tv'
                WHEN route = 'events' THEN '/events'
                ELSE CONCAT('/', route)
            END
        ");
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('pwa_menu_items', function (Blueprint $table) {
            $table->dropColumn(['route', 'name', 'path', 'action_type', 'web_url', 'description']);
        });
    }
}; 