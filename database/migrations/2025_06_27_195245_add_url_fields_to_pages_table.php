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
        Schema::table('pages', function (Blueprint $table) {
            // Vérifier si les colonnes n'existent pas déjà avant de les ajouter
            if (!Schema::hasColumn('pages', 'url')) {
                $table->string('url')->nullable();
            }
            if (!Schema::hasColumn('pages', 'embed_url')) {
                $table->string('embed_url')->nullable();
            }
            if (!Schema::hasColumn('pages', 'is_external')) {
                $table->boolean('is_external')->default(false);
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('pages', function (Blueprint $table) {
            // Supprimer seulement les colonnes qui existent
            $columnsToDrop = [];
            if (Schema::hasColumn('pages', 'url')) {
                $columnsToDrop[] = 'url';
            }
            if (Schema::hasColumn('pages', 'embed_url')) {
                $columnsToDrop[] = 'embed_url';
            }
            if (Schema::hasColumn('pages', 'is_external')) {
                $columnsToDrop[] = 'is_external';
            }
            
            if (!empty($columnsToDrop)) {
                $table->dropColumn($columnsToDrop);
            }
        });
    }
};
