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
        Schema::create('pwa_menu_items', function (Blueprint $table) {
            $table->id();
            $table->string('name')->unique(); // Nom technique unique
            $table->string('label'); // Libellé affiché à l'utilisateur
            $table->string('icon'); // Icône Material Design
            $table->string('path')->nullable(); // Chemin de navigation interne
            $table->enum('action_type', ['route', 'web_embed', 'external_link'])->default('route');
            $table->text('web_url')->nullable(); // URL pour action web_embed ou external_link
            $table->boolean('is_active')->default(true);
            $table->integer('order')->default(0); // Ordre d'affichage
            $table->text('description')->nullable(); // Description pour l'admin
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('pwa_menu_items');
    }
};
