<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    private function getDriver(): string
    {
        try {
            return Schema::getConnection()->getDriverName();
        } catch (\Exception $e) {
            return config('database.default', 'pgsql');
        }
    }

    public function up(): void
    {
        $driver = $this->getDriver();
        
        if ($driver === 'mysql' || $driver === 'mariadb') {
            DB::statement("ALTER TABLE `recipes` MODIFY `difficulty` ENUM('beginner','easy','medium','hard','expert') NOT NULL DEFAULT 'beginner'");
        } else {
            // PostgreSQL (et autres) : contrainte CHECK
            DB::statement("ALTER TABLE recipes DROP CONSTRAINT IF EXISTS recipes_difficulty_check");
            DB::statement("ALTER TABLE recipes ADD CONSTRAINT recipes_difficulty_check CHECK (difficulty IN ('beginner','easy','medium','hard','expert'))");
            DB::statement("ALTER TABLE recipes ALTER COLUMN difficulty SET DEFAULT 'beginner'");
        }
    }

    public function down(): void
    {
        $driver = $this->getDriver();
        
        if ($driver === 'mysql' || $driver === 'mariadb') {
            DB::statement("ALTER TABLE `recipes` MODIFY `difficulty` ENUM('easy','medium','hard') NOT NULL DEFAULT 'easy'");
        } else {
            DB::statement("ALTER TABLE recipes DROP CONSTRAINT IF EXISTS recipes_difficulty_check");
            DB::statement("ALTER TABLE recipes ADD CONSTRAINT recipes_difficulty_check CHECK (difficulty IN ('easy','medium','hard'))");
            DB::statement("ALTER TABLE recipes ALTER COLUMN difficulty SET DEFAULT 'easy'");
        }
    }
};


