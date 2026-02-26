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
        // Compatible PostgreSQL et MySQL
        $driver = Schema::getConnection()->getDriverName();
        
        if ($driver === 'pgsql') {
            DB::statement("ALTER TABLE users DROP CONSTRAINT IF EXISTS users_role_check");
        } else {
            try {
                DB::statement("ALTER TABLE users DROP CHECK users_role_check");
            } catch (\Exception $e) {
                // La contrainte n'existe pas, on continue
            }
        }
        
        DB::statement("ALTER TABLE users ADD CONSTRAINT users_role_check CHECK (role IN ('user', 'admin', 'moderator', 'professional'))");
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        $driver = Schema::getConnection()->getDriverName();
        
        if ($driver === 'pgsql') {
            DB::statement("ALTER TABLE users DROP CONSTRAINT IF EXISTS users_role_check");
        } else {
            try {
                DB::statement("ALTER TABLE users DROP CHECK users_role_check");
            } catch (\Exception $e) {
                // La contrainte n'existe pas, on continue
            }
        }
        
        DB::statement("ALTER TABLE users ADD CONSTRAINT users_role_check CHECK (role IN ('user', 'admin', 'moderator'))");
    }
};