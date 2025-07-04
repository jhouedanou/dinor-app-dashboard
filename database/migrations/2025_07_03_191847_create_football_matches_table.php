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
        Schema::create('football_matches', function (Blueprint $table) {
            $table->id();
            $table->foreignId('home_team_id')->constrained('teams')->onDelete('cascade');
            $table->foreignId('away_team_id')->constrained('teams')->onDelete('cascade');
            $table->datetime('match_date');
            $table->datetime('predictions_close_at')->nullable(); // Heure limite pour parier
            $table->string('status')->default('scheduled'); // scheduled, live, finished, cancelled
            $table->integer('home_score')->nullable();
            $table->integer('away_score')->nullable();
            $table->string('competition')->nullable(); // Nom de la compétition
            $table->string('round')->nullable(); // Phase/tour de la compétition
            $table->string('venue')->nullable(); // Lieu du match
            $table->text('notes')->nullable();
            $table->boolean('is_active')->default(true);
            $table->boolean('predictions_enabled')->default(true);
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('football_matches');
    }
};
