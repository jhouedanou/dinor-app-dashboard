<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('comments', function (Blueprint $table) {
            $table->id();
            $table->morphs('commentable'); // Pour recettes, événements, etc.
            $table->string('author_name');
            $table->string('author_email');
            $table->text('content');
            $table->enum('status', ['pending', 'approved', 'rejected'])->default('pending');
            $table->string('user_identifier'); // IP ou device ID
            $table->integer('rating')->nullable(); // Note 1-5 étoiles
            $table->timestamps();
            
            $table->index(['commentable_type', 'commentable_id']);
            $table->index('status');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('comments');
    }
}; 