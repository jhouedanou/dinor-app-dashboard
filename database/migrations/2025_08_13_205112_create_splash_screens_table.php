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
        Schema::create('splash_screens', function (Blueprint $table) {
            $table->id();
            
            // Status et activation
            $table->boolean('is_active')->default(false);
            
            // Contenu textuel
            $table->string('title')->default('Dinor se prépare...');
            $table->string('subtitle')->default('Chargement de l\'application');
            
            // Timing
            $table->integer('duration')->default(2500); // millisecondes
            
            // Background
            $table->enum('background_type', ['gradient', 'solid', 'image'])->default('gradient');
            $table->string('background_color_start')->default('#E53E3E');
            $table->string('background_color_end')->default('#C53030');
            $table->enum('background_gradient_direction', ['top_left', 'top_right', 'bottom_left', 'bottom_right', 'vertical', 'horizontal'])->default('top_left');
            
            // Logo
            $table->enum('logo_type', ['default', 'custom', 'none'])->default('default');
            $table->integer('logo_size')->default(80); // pixels
            
            // Couleurs du texte et éléments
            $table->string('text_color')->default('#FFFFFF');
            $table->string('progress_bar_color')->default('#F4D03F');
            
            // Animation
            $table->enum('animation_type', ['default', 'minimal', 'none'])->default('default');
            
            // Metadata pour extensions futures
            $table->json('meta_data')->nullable();
            
            // Programmation optionnelle
            $table->datetime('schedule_start')->nullable();
            $table->datetime('schedule_end')->nullable();
            
            $table->timestamps();
            
            // Index pour performance
            $table->index(['is_active', 'schedule_start', 'schedule_end']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('splash_screens');
    }
};
