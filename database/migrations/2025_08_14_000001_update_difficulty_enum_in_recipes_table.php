<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        $driver = Schema::getConnection()->getDriverName();
        
        if ($driver === 'pgsql') {
            // PostgreSQL : le type est varchar, on ajoute une contrainte CHECK
            DB::statement("ALTER TABLE recipes DROP CONSTRAINT IF EXISTS recipes_difficulty_check");
            DB::statement("ALTER TABLE recipes ADD CONSTRAINT recipes_difficulty_check CHECK (difficulty IN ('beginner','easy','medium','hard','expert'))");
            DB::statement("ALTER TABLE recipes ALTER COLUMN difficulty SET DEFAULT 'beginner'");
        } else {
            DB::statement("ALTER TABLE `recipes` MODIFY `difficulty` ENUM('beginner','easy','medium','hard','expert') NOT NULL DEFAULT 'beginner'");
        }
    }

    public function down(): void
    {
        $driver = Schema::getConnection()->getDriverName();
        
        if ($driver === 'pgsql') {
            DB::statement("ALTER TABLE recipes DROP CONSTRAINT IF EXISTS recipes_difficulty_check");
            DB::statement("ALTER TABLE recipes ADD CONSTRAINT recipes_difficulty_check CHECK (difficulty IN ('easy','medium','hard'))");
            DB::statement("ALTER TABLE recipes ALTER COLUMN difficulty SET DEFAULT 'easy'");
        } else {
            DB::statement("ALTER TABLE `recipes` MODIFY `difficulty` ENUM('easy','medium','hard') NOT NULL DEFAULT 'easy'");
        }
    }
};


