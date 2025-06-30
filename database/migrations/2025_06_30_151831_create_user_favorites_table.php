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
        Schema::create('user_favorites', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->unsignedBigInteger('favoritable_id');
            $table->string('favoritable_type');
            $table->timestamp('favorited_at')->useCurrent();
            $table->timestamps();
            
            // Index pour les relations polymorphiques
            $table->index(['favoritable_id', 'favoritable_type']);
            
            // Index unique pour éviter les doublons
            $table->unique(['user_id', 'favoritable_id', 'favoritable_type'], 'user_favorites_unique');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('user_favorites');
    }
};
