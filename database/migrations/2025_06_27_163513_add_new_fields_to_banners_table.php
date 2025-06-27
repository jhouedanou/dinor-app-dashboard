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
        Schema::table('banners', function (Blueprint $table) {
            $table->string('type_contenu')->nullable()->after('id'); // recipes, tips, events, dinor_tv, pages, home
            $table->string('titre')->nullable()->after('type_contenu'); // Nouveau titre
            $table->string('sous_titre')->nullable()->after('titre'); // Nouveau sous-titre
            $table->string('section')->default('hero')->after('sous_titre'); // header, hero, featured, footer
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('banners', function (Blueprint $table) {
            $table->dropColumn(['type_contenu', 'titre', 'sous_titre', 'section']);
        });
    }
};
