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
        // Supprimer l'ancienne contrainte
        DB::statement('ALTER TABLE categories DROP CONSTRAINT IF EXISTS categories_type_check');
        
        // Ajouter la nouvelle contrainte avec le type 'tip'
        DB::statement("ALTER TABLE categories ADD CONSTRAINT categories_type_check CHECK (type IN ('general', 'recipe', 'event', 'tip'))");
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Rétablir l'ancienne contrainte sans 'tip'
        DB::statement('ALTER TABLE categories DROP CONSTRAINT IF EXISTS categories_type_check');
        DB::statement("ALTER TABLE categories ADD CONSTRAINT categories_type_check CHECK (type IN ('general', 'recipe', 'event'))");
    }
};
