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
        Schema::table('predictions', function (Blueprint $table) {
            $table->integer('bet_amount')->nullable()->after('predicted_winner')->comment('Montant du pari en points');
            $table->index(['user_id', 'bet_amount']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('predictions', function (Blueprint $table) {
            $table->dropIndex(['user_id', 'bet_amount']);
            $table->dropColumn('bet_amount');
        });
    }
};
