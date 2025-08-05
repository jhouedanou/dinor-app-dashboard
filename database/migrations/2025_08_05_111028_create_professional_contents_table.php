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
        Schema::create('professional_contents', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->enum('content_type', ['recipe', 'tip', 'event', 'video']);
            $table->string('title');
            $table->text('description');
            $table->longText('content');
            $table->json('images')->nullable();
            $table->string('video_url')->nullable();
            $table->enum('difficulty', ['beginner', 'easy', 'medium', 'hard', 'expert'])->nullable();
            $table->string('category')->nullable();
            $table->integer('preparation_time')->nullable(); // en minutes
            $table->integer('cooking_time')->nullable(); // en minutes
            $table->integer('servings')->nullable();
            $table->json('ingredients')->nullable();
            $table->json('steps')->nullable();
            $table->json('tags')->nullable();
            $table->enum('status', ['pending', 'approved', 'rejected', 'published'])->default('pending');
            $table->text('admin_notes')->nullable();
            $table->timestamp('submitted_at')->useCurrent();
            $table->timestamp('reviewed_at')->nullable();
            $table->foreignId('reviewed_by')->nullable()->constrained('users')->onDelete('set null');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('professional_contents');
    }
};
