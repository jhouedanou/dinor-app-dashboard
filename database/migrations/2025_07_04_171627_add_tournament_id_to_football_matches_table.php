<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('football_matches', function (Blueprint $table) {
            $table->foreignId('tournament_id')->nullable()->constrained()->onDelete('set null');
            $table->index('tournament_id');
        });
    }

    public function down(): void
    {
        Schema::table('football_matches', function (Blueprint $table) {
            $table->dropForeign(['tournament_id']);
            $table->dropIndex(['tournament_id']);
            $table->dropColumn('tournament_id');
        });
    }
};