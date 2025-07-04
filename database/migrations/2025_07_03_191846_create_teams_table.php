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
        Schema::create('teams', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('short_name', 10)->nullable();
            $table->string('country', 3)->nullable(); // Code pays ISO 3
            $table->string('logo')->nullable();
            $table->string('color_primary', 7)->nullable(); // Couleur hexadécimale
            $table->string('color_secondary', 7)->nullable();
            $table->boolean('is_active')->default(true);
            $table->integer('founded_year')->nullable();
            $table->text('description')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('teams');
    }
};
