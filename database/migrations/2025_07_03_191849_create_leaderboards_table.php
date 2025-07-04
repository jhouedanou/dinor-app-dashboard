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
        Schema::create('leaderboards', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->integer('total_points')->default(0);
            $table->integer('total_predictions')->default(0);
            $table->integer('correct_scores')->default(0); // Prédictions avec score exact
            $table->integer('correct_winners')->default(0); // Prédictions avec bon gagnant seulement
            $table->integer('perfect_predictions')->default(0); // Score exact + gagnant
            $table->decimal('accuracy_percentage', 5, 2)->default(0.00);
            $table->integer('current_rank')->nullable();
            $table->integer('previous_rank')->nullable();
            $table->date('last_updated')->nullable();
            $table->timestamps();
            
            // Un seul enregistrement par utilisateur
            $table->unique('user_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('leaderboards');
    }
};
