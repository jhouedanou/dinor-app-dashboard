<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('dinor_tv', function (Blueprint $table) {
            // Supprimer d'abord la contrainte de clé étrangère si elle existe
            if (Schema::hasColumn('dinor_tv', 'category_id')) {
                $table->dropForeign(['category_id']);
            }
            
            // Supprimer les colonnes non utilisées si elles existent
            $columnsToRemove = [
                'thumbnail',
                'duration',
                'category_id',
                'tags',
                'is_live',
                'scheduled_at',
                'like_count',
                'slug'
            ];
            
            foreach ($columnsToRemove as $column) {
                if (Schema::hasColumn('dinor_tv', $column)) {
                    $table->dropColumn($column);
                }
            }
            
            // Modifier la colonne description pour la rendre nullable si elle existe
            if (Schema::hasColumn('dinor_tv', 'description')) {
                $table->text('description')->nullable()->change();
            }
        });
    }

    public function down(): void
    {
        Schema::table('dinor_tv', function (Blueprint $table) {
            // Restaurer les colonnes supprimées
            $table->string('thumbnail')->nullable();
            $table->integer('duration')->nullable();
            $table->foreignId('category_id')->constrained()->onDelete('cascade');
            $table->json('tags')->nullable();
            $table->boolean('is_live')->default(false);
            $table->datetime('scheduled_at')->nullable();
            $table->bigInteger('like_count')->default(0);
            $table->string('slug')->unique();
            
            // Remettre description comme non-nullable
            $table->text('description')->change();
        });
    }
};