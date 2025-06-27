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
            $table->string('type_contenu')->after('title')->nullable();
            $table->string('titre')->after('type_contenu')->nullable();
            $table->string('sous_titre')->after('titre')->nullable();
            $table->string('section')->after('sous_titre')->nullable();
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
