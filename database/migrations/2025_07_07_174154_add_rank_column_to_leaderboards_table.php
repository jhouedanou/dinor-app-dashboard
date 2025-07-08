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
        Schema::table('leaderboards', function (Blueprint $table) {
            // Vérifier si la colonne 'rank' n'existe pas déjà
            if (!Schema::hasColumn('leaderboards', 'rank')) {
                $table->integer('rank')->nullable()->after('accuracy_percentage');
            }
            
            // Vérifier si la colonne 'correct_predictions' n'existe pas déjà
            if (!Schema::hasColumn('leaderboards', 'correct_predictions')) {
                $table->integer('correct_predictions')->default(0)->after('correct_winners');
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('leaderboards', function (Blueprint $table) {
            // Seulement supprimer les colonnes si elles existent
            if (Schema::hasColumn('leaderboards', 'rank')) {
                $table->dropColumn('rank');
            }
            if (Schema::hasColumn('leaderboards', 'correct_predictions')) {
                $table->dropColumn('correct_predictions');
            }
        });
    }
};
