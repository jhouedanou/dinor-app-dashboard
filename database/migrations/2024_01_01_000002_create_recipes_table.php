<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('recipes', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->text('description');
            $table->longText('short_description')->nullable();
            $table->json('ingredients');
            $table->json('instructions');
            $table->integer('preparation_time')->default(0); // en minutes
            $table->integer('cooking_time')->default(0); // en minutes
            $table->integer('resting_time')->default(0); // temps de repos en minutes
            $table->integer('servings')->default(1);
            $table->enum('difficulty', ['easy', 'medium', 'hard'])->default('easy');
            $table->enum('meal_type', ['breakfast', 'lunch', 'dinner', 'snack', 'dessert', 'aperitif'])->nullable();
            $table->enum('diet_type', ['none', 'vegetarian', 'vegan', 'gluten_free', 'dairy_free', 'keto', 'paleo'])->default('none');
            $table->foreignId('category_id')->constrained()->onDelete('cascade');
            
            // Images et médias
            $table->string('featured_image')->nullable(); // Image principale
            $table->json('gallery')->nullable(); // Galerie d'images
            $table->string('video_url')->nullable();
            $table->string('video_thumbnail')->nullable();
            
            // Informations nutritionnelles
            $table->integer('calories_per_serving')->nullable();
            $table->decimal('protein_grams', 5, 2)->nullable();
            $table->decimal('carbs_grams', 5, 2)->nullable();
            $table->decimal('fat_grams', 5, 2)->nullable();
            $table->decimal('fiber_grams', 5, 2)->nullable();
            
            // Coût et disponibilité
            $table->enum('cost_level', ['low', 'medium', 'high'])->default('medium');
            $table->enum('season', ['all', 'spring', 'summer', 'autumn', 'winter'])->default('all');
            $table->string('origin_country')->nullable();
            $table->string('region')->nullable();
            
            // Équipements nécessaires
            $table->json('required_equipment')->nullable();
            $table->json('cooking_methods')->nullable(); // four, poêle, mixeur, etc.
            
            // Métadonnées
            $table->json('tags')->nullable();
            $table->boolean('is_featured')->default(false);
            $table->boolean('is_published')->default(false);
            $table->text('meta_description')->nullable();
            $table->string('slug')->unique();
            
            // Chef/Auteur
            $table->string('chef_name')->nullable();
            $table->text('chef_notes')->nullable();
            
            // Statistiques
            $table->bigInteger('views_count')->default(0);
            $table->bigInteger('likes_count')->default(0);
            $table->bigInteger('favorites_count')->default(0);
            $table->decimal('rating_average', 3, 2)->default(0);
            $table->integer('rating_count')->default(0);
            
            $table->timestamps();
            $table->softDeletes();
            
            // Index pour les recherches
            $table->index(['is_published', 'is_featured']);
            $table->index(['difficulty', 'meal_type']);
            $table->index(['category_id', 'is_published']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('recipes');
    }
}; 