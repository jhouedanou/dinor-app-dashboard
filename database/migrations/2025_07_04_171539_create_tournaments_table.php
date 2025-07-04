<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('tournaments', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('slug')->unique();
            $table->text('description')->nullable();
            $table->datetime('start_date');
            $table->datetime('end_date');
            $table->datetime('registration_start')->nullable();
            $table->datetime('registration_end')->nullable();
            $table->datetime('prediction_deadline')->nullable();
            $table->integer('max_participants')->nullable();
            $table->decimal('entry_fee', 10, 2)->default(0);
            $table->string('currency', 3)->default('XOF');
            $table->decimal('prize_pool', 10, 2)->default(0);
            $table->enum('status', [
                'upcoming', 
                'registration_open', 
                'registration_closed', 
                'active', 
                'finished', 
                'cancelled'
            ])->default('upcoming');
            $table->json('rules')->nullable();
            $table->string('image')->nullable();
            $table->boolean('is_featured')->default(false);
            $table->boolean('is_public')->default(true);
            $table->foreignId('created_by')->constrained('users');
            $table->timestamps();

            $table->index(['status', 'is_public']);
            $table->index(['start_date', 'end_date']);
            $table->index('is_featured');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('tournaments');
    }
};