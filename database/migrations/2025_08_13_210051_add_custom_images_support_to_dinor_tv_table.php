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
        Schema::table('dinor_tv', function (Blueprint $table) {
            // Champs pour images customisées
            $table->string('featured_image')->nullable()->after('thumbnail');
            $table->json('gallery')->nullable()->after('featured_image');
            $table->string('poster_image')->nullable()->after('gallery');
            $table->string('banner_image')->nullable()->after('poster_image');
            
            // Métadonnées pour les images
            $table->json('image_metadata')->nullable()->after('banner_image');
            
            // Short description pour l'affichage dans les listes
            $table->string('short_description', 500)->nullable()->after('description');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('dinor_tv', function (Blueprint $table) {
            $table->dropColumn([
                'featured_image',
                'gallery', 
                'poster_image',
                'banner_image',
                'image_metadata',
                'short_description'
            ]);
        });
    }
};
