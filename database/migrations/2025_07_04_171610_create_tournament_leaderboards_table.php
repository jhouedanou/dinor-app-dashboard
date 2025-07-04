<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('tournament_leaderboards', function (Blueprint $table) {
            $table->id();
            $table->foreignId('tournament_id')->constrained()->onDelete('cascade');
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->integer('rank')->default(0);
            $table->integer('total_points')->default(0);
            $table->integer('total_predictions')->default(0);
            $table->integer('correct_predictions')->default(0);
            $table->decimal('accuracy', 5, 1)->default(0);
            $table->datetime('last_updated');
            $table->timestamps();

            $table->unique(['tournament_id', 'user_id']);
            $table->index(['tournament_id', 'rank']);
            $table->index(['tournament_id', 'total_points']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('tournament_leaderboards');
    }
};