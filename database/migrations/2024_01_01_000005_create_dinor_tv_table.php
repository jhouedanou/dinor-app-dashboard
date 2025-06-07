<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('dinor_tv', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->text('description');
            $table->string('video_url');
            $table->string('thumbnail')->nullable();
            $table->integer('duration')->nullable(); // en secondes
            $table->foreignId('category_id')->constrained()->onDelete('cascade');
            $table->json('tags')->nullable();
            $table->boolean('is_featured')->default(false);
            $table->boolean('is_published')->default(false);
            $table->boolean('is_live')->default(false);
            $table->datetime('scheduled_at')->nullable();
            $table->bigInteger('view_count')->default(0);
            $table->bigInteger('like_count')->default(0);
            $table->string('slug')->unique();
            $table->timestamps();
            $table->softDeletes();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('dinor_tv');
    }
}; 