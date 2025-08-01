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
            $table->string('content_type')->nullable()->after('url');
            $table->unsignedBigInteger('content_id')->nullable()->after('content_type');
            
            $table->index(['content_type', 'content_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('push_notifications', function (Blueprint $table) {
            $table->dropIndex(['content_type', 'content_id']);
            $table->dropColumn(['content_type', 'content_id']);
        });
    }
};
