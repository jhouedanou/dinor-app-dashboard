<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        DB::statement("ALTER TABLE `recipes` MODIFY `difficulty` ENUM('beginner','easy','medium','hard','expert') NOT NULL DEFAULT 'beginner'");
    }

    public function down(): void
    {
        DB::statement("ALTER TABLE `recipes` MODIFY `difficulty` ENUM('easy','medium','hard') NOT NULL DEFAULT 'easy'");
    }
};


