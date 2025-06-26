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
        Schema::create('banners', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->text('description')->nullable();
            $table->string('image_url')->nullable();
            $table->string('background_color')->default('#E1251B');
            $table->string('text_color')->default('#FFFFFF');
            $table->string('button_text')->nullable();
            $table->string('button_url')->nullable();
            $table->string('button_color')->default('#FFFFFF');
            $table->boolean('is_active')->default(true);
            $table->integer('order')->default(0);
            $table->string('position')->default('home'); // home, all_pages, specific
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('banners');
    }
};
