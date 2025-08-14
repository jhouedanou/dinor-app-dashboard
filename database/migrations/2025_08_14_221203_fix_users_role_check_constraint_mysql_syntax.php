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
        // Corriger la contrainte role pour MySQL - supprimer l'ancienne avec la syntaxe PostgreSQL
        try {
            // Essayer de supprimer la contrainte avec la syntaxe MySQL correcte
            DB::statement("ALTER TABLE users DROP CHECK users_role_check");
        } catch (\Exception $e) {
            // La contrainte n'existe peut-être pas ou a un nom différent, on continue
        }
        
        // Ajouter la nouvelle contrainte avec la syntaxe MySQL
        try {
            DB::statement("ALTER TABLE users ADD CONSTRAINT users_role_check CHECK (role IN ('user', 'admin', 'moderator', 'professional'))");
        } catch (\Exception $e) {
            // Si elle existe déjà, c'est ok
        }
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
        
        // Remettre l'ancienne contrainte sans 'professional'
        try {
            DB::statement("ALTER TABLE users ADD CONSTRAINT users_role_check CHECK (role IN ('user', 'admin', 'moderator'))");
        } catch (\Exception $e) {
            // Si elle existe déjà, c'est ok
        }
    }
};
