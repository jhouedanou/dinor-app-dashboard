<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('likes', function (Blueprint $table) {
            $table->id();
            $table->morphs('likeable'); // Pour pouvoir liker recettes, événements, etc.
            $table->string('user_identifier'); // IP, device ID, user ID, etc.
            $table->string('user_type')->default('anonymous'); // anonymous, registered
            $table->timestamp('created_at');
            
            $table->unique(['likeable_type', 'likeable_id', 'user_identifier'], 'unique_like');
            $table->index(['likeable_type', 'likeable_id']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('likes');
    }
}; 