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
        $driver = Schema::getConnection()->getDriverName();
        
        if ($driver === 'pgsql') {
            DB::statement("ALTER TABLE categories DROP CONSTRAINT IF EXISTS categories_type_check");
            DB::statement("ALTER TABLE categories ADD CONSTRAINT categories_type_check CHECK (type IN ('general', 'recipe', 'event', 'tip'))");
        } else {
            DB::statement("ALTER TABLE `categories` MODIFY `type` ENUM('general', 'recipe', 'event', 'tip') NOT NULL DEFAULT 'general'");
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        $driver = Schema::getConnection()->getDriverName();
        
        if ($driver === 'pgsql') {
            DB::statement("ALTER TABLE categories DROP CONSTRAINT IF EXISTS categories_type_check");
            DB::statement("ALTER TABLE categories ADD CONSTRAINT categories_type_check CHECK (type IN ('general', 'recipe', 'event'))");
        } else {
            DB::statement("ALTER TABLE `categories` MODIFY `type` ENUM('general', 'recipe', 'event') NOT NULL DEFAULT 'general'");
        }
    }
};
