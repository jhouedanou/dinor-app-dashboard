<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('predictions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->foreignId('football_match_id')->constrained()->onDelete('cascade');
            $table->integer('predicted_home_score');
            $table->integer('predicted_away_score');
            $table->string('predicted_winner'); // 'home', 'away', 'draw'
            $table->integer('points_earned')->default(0);
            $table->boolean('is_calculated')->default(false);
            $table->string('ip_address')->nullable();
            $table->string('user_agent')->nullable();
            $table->timestamps();
            
            // Une prédiction unique par utilisateur et par match
            $table->unique(['user_id', 'football_match_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('predictions');
    }
};
