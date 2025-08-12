<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasColumn('recipes', 'dinor_ingredients')) {
            Schema::table('recipes', function (Blueprint $table) {
                $table->json('dinor_ingredients')->nullable()->after('ingredients');
            });
        }
    }

    public function down(): void
    {
        if (Schema::hasColumn('recipes', 'dinor_ingredients')) {
            Schema::table('recipes', function (Blueprint $table) {
                $table->dropColumn('dinor_ingredients');
            });
        }
    }
};


