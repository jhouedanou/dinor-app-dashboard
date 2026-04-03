<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Ajouter les champs pour les réponses admin aux commentaires.
     * Permet à l'admin de répondre directement depuis le dashboard Filament.
     */
    public function up(): void
    {
        Schema::table('comments', function (Blueprint $table) {
            $table->text('admin_reply')->nullable()->after('content');
            $table->unsignedBigInteger('admin_reply_by')->nullable()->after('admin_reply');
            $table->timestamp('admin_replied_at')->nullable()->after('admin_reply_by');

            $table->foreign('admin_reply_by')
                  ->references('id')
                  ->on('users')
                  ->onDelete('set null');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('comments', function (Blueprint $table) {
            $table->dropForeign(['admin_reply_by']);
            $table->dropColumn(['admin_reply', 'admin_reply_by', 'admin_replied_at']);
        });
    }
};
