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
        Schema::create('likes', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('user_id')->nullable();
            $table->morphs('likeable'); // likeable_id, likeable_type
            $table->string('ip_address', 45)->nullable();
            $table->text('user_agent')->nullable();
            $table->timestamps();

            // Indexes
            $table->index(['likeable_id', 'likeable_type']);
            $table->index(['user_id', 'likeable_id', 'likeable_type']);
            $table->index(['ip_address', 'likeable_id', 'likeable_type']);
            
            // Ensure unique likes per user/IP per content
            $table->unique(['user_id', 'likeable_id', 'likeable_type'], 'unique_user_like');
            $table->unique(['ip_address', 'likeable_id', 'likeable_type'], 'unique_ip_like');

            // Foreign key
            $table->foreign('user_id')
                  ->references('id')
                  ->on('users')
                  ->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('likes');
    }
}; 