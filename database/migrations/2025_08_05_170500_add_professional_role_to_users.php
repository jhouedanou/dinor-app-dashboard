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
        // Ajouter le rôle 'professional' à la contrainte existante
        try {
            DB::statement("ALTER TABLE users DROP CHECK users_role_check");
        } catch (\Exception $e) {
            // La contrainte n'existe pas, on continue
        }
        
        // MySQL syntax for ENUM-like check constraint
        DB::statement("ALTER TABLE users ADD CONSTRAINT users_role_check CHECK (role IN ('user', 'admin', 'moderator', 'professional'))");
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Retirer le rôle 'professional' de la contrainte
        try {
            DB::statement("ALTER TABLE users DROP CHECK users_role_check");
        } catch (\Exception $e) {
            // La contrainte n'existe pas, on continue
        }
        
        // MySQL syntax for ENUM-like check constraint
        DB::statement("ALTER TABLE users ADD CONSTRAINT users_role_check CHECK (role IN ('user', 'admin', 'moderator'))");
    }
};