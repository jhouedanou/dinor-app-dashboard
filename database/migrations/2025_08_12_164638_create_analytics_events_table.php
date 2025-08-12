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
        Schema::create('analytics_events', function (Blueprint $table) {
            $table->id();
            $table->string('event_type', 100)->index();
            $table->json('event_data')->nullable();
            $table->string('session_id')->index();
            $table->string('user_id')->nullable()->index();
            $table->string('page_path', 500)->nullable()->index();
            $table->text('user_agent')->nullable();
            $table->string('ip_address', 45)->nullable();
            $table->json('device_info')->nullable();
            $table->timestamp('timestamp')->index();
            $table->timestamps();
            
            // Index composé pour les requêtes fréquentes
            $table->index(['event_type', 'timestamp']);
            $table->index(['session_id', 'timestamp']);
            $table->index(['user_id', 'timestamp']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('analytics_events');
    }
};
