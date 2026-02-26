<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

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

    /**
     * Run the migrations.
     */
    public function up(): void
    {
        $driver = $this->getDriver();
        
        if ($driver === 'mysql' || $driver === 'mariadb') {
            DB::statement("ALTER TABLE `categories` MODIFY `type` ENUM('general', 'recipe', 'event', 'tip') NOT NULL DEFAULT 'general'");
        } else {
            // PostgreSQL (et autres) : contrainte CHECK
            DB::statement("ALTER TABLE categories DROP CONSTRAINT IF EXISTS categories_type_check");
            DB::statement("ALTER TABLE categories ADD CONSTRAINT categories_type_check CHECK (type IN ('general', 'recipe', 'event', 'tip'))");
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        $driver = $this->getDriver();
        
        if ($driver === 'mysql' || $driver === 'mariadb') {
            DB::statement("ALTER TABLE `categories` MODIFY `type` ENUM('general', 'recipe', 'event') NOT NULL DEFAULT 'general'");
        } else {
            DB::statement("ALTER TABLE categories DROP CONSTRAINT IF EXISTS categories_type_check");
            DB::statement("ALTER TABLE categories ADD CONSTRAINT categories_type_check CHECK (type IN ('general', 'recipe', 'event'))");
        }
    }
};
