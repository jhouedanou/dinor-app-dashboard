<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('ingredients', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('category');
            $table->string('subcategory')->nullable();
            $table->enum('unit', ['kg', 'g', 'mg', 'l', 'ml', 'cl', 'dl', 'pièce', 'cuillère à soupe', 'cuillère à café', 'tasse', 'verre', 'pincée', 'botte', 'sachet', 'boîte', 'tranche', 'gousse', 'brin', 'feuille']);
            $table->string('recommended_brand')->nullable();
            $table->decimal('average_price', 8, 2)->nullable();
            $table->text('description')->nullable();
            $table->string('image')->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamps();
            
            // Index pour les recherches
            $table->index(['category', 'subcategory']);
            $table->index(['name', 'is_active']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('ingredients');
    }
}; 