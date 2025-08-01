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
        Schema::table('push_notifications', function (Blueprint $table) {
            if (!Schema::hasColumn('push_notifications', 'content_type')) {
                $table->string('content_type')->nullable()->after('url');
            }
            if (!Schema::hasColumn('push_notifications', 'content_id')) {
                $table->unsignedBigInteger('content_id')->nullable()->after('content_type');
            }
            
            // Vérifier si l'index existe déjà avant de le créer
            $indexName = 'push_notifications_content_type_content_id_index';
            $indexes = Schema::getConnection()->getDoctrineSchemaManager()
                ->listTableIndexes('push_notifications');
            
            if (!isset($indexes[$indexName])) {
                $table->index(['content_type', 'content_id']);
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('push_notifications', function (Blueprint $table) {
            // Supprimer l'index s'il existe
            $indexes = Schema::getConnection()->getDoctrineSchemaManager()
                ->listTableIndexes('push_notifications');
            $indexName = 'push_notifications_content_type_content_id_index';
            
            if (isset($indexes[$indexName])) {
                $table->dropIndex(['content_type', 'content_id']);
            }
            
            // Supprimer les colonnes si elles existent
            if (Schema::hasColumn('push_notifications', 'content_id')) {
                $table->dropColumn('content_id');
            }
            if (Schema::hasColumn('push_notifications', 'content_type')) {
                $table->dropColumn('content_type');
            }
        });
    }
};
