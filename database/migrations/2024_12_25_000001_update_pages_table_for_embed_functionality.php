<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('pages', function (Blueprint $table) {
            // Supprimer d'abord la contrainte de clé étrangère si elle existe
            if (Schema::hasColumn('pages', 'parent_id')) {
                $table->dropForeign(['parent_id']);
            }
            
            // Supprimer les colonnes non utilisées si elles existent
            $columnsToRemove = [
                'content',
                'slug', 
                'meta_title',
                'meta_description',
                'meta_keywords',
                'template',
                'is_homepage',
                'parent_id',
                'featured_image'
            ];
            
            foreach ($columnsToRemove as $column) {
                if (Schema::hasColumn('pages', $column)) {
                    $table->dropColumn($column);
                }
            }
        });
        
        // Ajouter les nouvelles colonnes dans une transaction séparée
        Schema::table('pages', function (Blueprint $table) {
            // Ajouter les nouvelles colonnes seulement si elles n'existent pas
            if (!Schema::hasColumn('pages', 'url')) {
                $table->string('url')->after('title');
            }
            if (!Schema::hasColumn('pages', 'description')) {
                $table->text('description')->nullable()->after('url');
            }
        });
    }

    public function down(): void
    {
        Schema::table('pages', function (Blueprint $table) {
            // Supprimer les nouvelles colonnes
            $table->dropColumn(['url', 'description']);
            
            // Restaurer les anciennes colonnes
            $table->longText('content');
            $table->string('slug')->unique();
            $table->string('meta_title')->nullable();
            $table->text('meta_description')->nullable();
            $table->text('meta_keywords')->nullable();
            $table->string('template')->default('default');
            $table->boolean('is_homepage')->default(false);
            $table->foreignId('parent_id')->nullable()->constrained('pages')->onDelete('cascade');
            $table->string('featured_image')->nullable();
        });
    }
};