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
        // Migration pour reproduire la structure complète de la base de données locale
        
        // Table users (si elle n'existe pas déjà)
        if (!Schema::hasTable('users')) {
            Schema::create('users', function (Blueprint $table) {
                $table->id();
                $table->string('name');
                $table->string('email')->unique();
                $table->timestamp('email_verified_at')->nullable();
                $table->string('password');
                $table->string('role')->default('user');
                $table->string('status')->default('active');
                $table->rememberToken();
                $table->timestamps();
            });
        }

        // Table categories (si elle n'existe pas déjà)  
        if (!Schema::hasTable('categories')) {
            Schema::create('categories', function (Blueprint $table) {
                $table->id();
                $table->string('name');
                $table->string('slug')->unique();
                $table->text('description')->nullable();
                $table->string('image')->nullable();
                $table->string('color', 7)->default('#3b82f6');
                $table->string('icon')->nullable();
                $table->string('type')->default('recipe');
                $table->boolean('is_active')->default(true);
                $table->timestamps();
            });
        }

        // Table recipes (si elle n'existe pas déjà)
        if (!Schema::hasTable('recipes')) {
            Schema::create('recipes', function (Blueprint $table) {
                $table->id();
                $table->string('title');
                $table->text('description');
                $table->longText('short_description')->nullable();
                $table->json('ingredients');
                $table->json('instructions');
                $table->integer('preparation_time')->default(0);
                $table->integer('cooking_time')->default(0);
                $table->integer('resting_time')->default(0);
                $table->integer('servings')->default(1);
                $table->enum('difficulty', ['easy', 'medium', 'hard'])->default('easy');
                $table->enum('meal_type', ['breakfast', 'lunch', 'dinner', 'snack', 'dessert', 'aperitif'])->nullable();
                $table->enum('diet_type', ['none', 'vegetarian', 'vegan', 'gluten_free', 'dairy_free', 'keto', 'paleo'])->default('none');
                $table->foreignId('category_id')->constrained()->onDelete('cascade');
                $table->string('subcategory')->nullable();
                $table->string('featured_image')->nullable();
                $table->json('gallery')->nullable();
                $table->text('video_url')->nullable();
                $table->string('video_thumbnail')->nullable();
                $table->text('summary_video')->nullable();
                $table->integer('calories_per_serving')->nullable();
                $table->decimal('protein_grams', 5, 2)->nullable();
                $table->decimal('carbs_grams', 5, 2)->nullable();
                $table->decimal('fat_grams', 5, 2)->nullable();
                $table->decimal('fiber_grams', 5, 2)->nullable();
                $table->enum('cost_level', ['low', 'medium', 'high'])->default('medium');
                $table->enum('season', ['all', 'spring', 'summer', 'autumn', 'winter'])->default('all');
                $table->string('origin_country')->nullable();
                $table->string('region')->nullable();
                $table->json('required_equipment')->nullable();
                $table->json('cooking_methods')->nullable();
                $table->json('tags')->nullable();
                $table->boolean('is_featured')->default(false);
                $table->boolean('is_published')->default(false);
                $table->text('meta_description')->nullable();
                $table->string('slug')->unique();
                $table->string('chef_name')->nullable();
                $table->text('chef_notes')->nullable();
                $table->bigInteger('views_count')->default(0);
                $table->bigInteger('likes_count')->default(0);
                $table->bigInteger('favorites_count')->default(0);
                $table->bigInteger('comments_count')->default(0);
                $table->decimal('rating_average', 3, 2)->default(0);
                $table->integer('rating_count')->default(0);
                $table->timestamps();
                $table->softDeletes();
                $table->index(['is_published', 'is_featured']);
                $table->index(['difficulty', 'meal_type']);
                $table->index(['category_id', 'is_published']);
            });
        }

        // Table tips (si elle n'existe pas déjà)
        if (!Schema::hasTable('tips')) {
            Schema::create('tips', function (Blueprint $table) {
                $table->id();
                $table->string('title');
                $table->text('description');
                $table->longText('content');
                $table->string('featured_image')->nullable();
                $table->json('gallery')->nullable();
                $table->string('video_url')->nullable();
                $table->string('video_thumbnail')->nullable();
                $table->text('summary_video')->nullable();
                $table->string('slug')->unique();
                $table->boolean('is_featured')->default(false);
                $table->boolean('is_published')->default(false);
                $table->json('tags')->nullable();
                $table->bigInteger('views_count')->default(0);
                $table->bigInteger('likes_count')->default(0);
                $table->bigInteger('favorites_count')->default(0);
                $table->bigInteger('comments_count')->default(0);
                $table->timestamps();
                $table->softDeletes();
            });
        }

        // Table events (si elle n'existe pas déjà)
        if (!Schema::hasTable('events')) {
            Schema::create('events', function (Blueprint $table) {
                $table->id();
                $table->string('title');
                $table->text('description');
                $table->longText('content');
                $table->string('featured_image')->nullable();
                $table->json('gallery')->nullable();
                $table->string('video_url')->nullable();
                $table->string('video_thumbnail')->nullable();
                $table->datetime('start_date');
                $table->datetime('end_date')->nullable();
                $table->string('location')->nullable();
                $table->decimal('price', 8, 2)->nullable();
                $table->string('slug')->unique();
                $table->boolean('is_featured')->default(false);
                $table->boolean('is_published')->default(false);
                $table->json('tags')->nullable();
                $table->bigInteger('views_count')->default(0);
                $table->bigInteger('likes_count')->default(0);
                $table->bigInteger('favorites_count')->default(0);
                $table->bigInteger('comments_count')->default(0);
                $table->foreignId('event_category_id')->nullable()->constrained()->onDelete('set null');
                $table->timestamps();
                $table->softDeletes();
            });
        }

        // Table event_categories (si elle n'existe pas déjà)
        if (!Schema::hasTable('event_categories')) {
            Schema::create('event_categories', function (Blueprint $table) {
                $table->id();
                $table->string('name');
                $table->string('slug')->unique();
                $table->text('description')->nullable();
                $table->string('color', 7)->default('#3b82f6');
                $table->string('icon')->nullable();
                $table->boolean('is_active')->default(true);
                $table->timestamps();
            });
        }

        // Table dinor_tv (si elle n'existe pas déjà)
        if (!Schema::hasTable('dinor_tv')) {
            Schema::create('dinor_tv', function (Blueprint $table) {
                $table->id();
                $table->string('title');
                $table->text('description');
                $table->string('video_url');
                $table->string('thumbnail')->nullable();
                $table->integer('duration')->nullable();
                $table->string('slug')->unique();
                $table->boolean('is_featured')->default(false);
                $table->boolean('is_published')->default(false);
                $table->json('tags')->nullable();
                $table->bigInteger('views_count')->default(0);
                $table->bigInteger('likes_count')->default(0);
                $table->bigInteger('favorites_count')->default(0);
                $table->timestamps();
                $table->softDeletes();
            });
        }

        // Table pages (si elle n'existe pas déjà)
        if (!Schema::hasTable('pages')) {
            Schema::create('pages', function (Blueprint $table) {
                $table->id();
                $table->string('title');
                $table->text('content');
                $table->string('slug')->unique();
                $table->boolean('is_published')->default(false);
                $table->text('meta_description')->nullable();
                $table->string('meta_keywords')->nullable();
                $table->string('featured_image')->nullable();
                $table->string('embed_url')->nullable();
                $table->string('external_url')->nullable();
                $table->timestamps();
            });
        }

        // Table media_files (si elle n'existe pas déjà)
        if (!Schema::hasTable('media_files')) {
            Schema::create('media_files', function (Blueprint $table) {
                $table->id();
                $table->string('filename');
                $table->string('original_name');
                $table->string('mime_type');
                $table->integer('size');
                $table->string('path');
                $table->string('disk')->default('public');
                $table->json('metadata')->nullable();
                $table->timestamps();
            });
        }

        // Table admin_users (si elle n'existe pas déjà)
        if (!Schema::hasTable('admin_users')) {
            Schema::create('admin_users', function (Blueprint $table) {
                $table->id();
                $table->string('name');
                $table->string('email')->unique();
                $table->timestamp('email_verified_at')->nullable();
                $table->string('password');
                $table->string('role')->default('admin');
                $table->boolean('is_active')->default(true);
                $table->rememberToken();
                $table->timestamps();
            });
        }

        // Table likes (si elle n'existe pas déjà)
        if (!Schema::hasTable('likes')) {
            Schema::create('likes', function (Blueprint $table) {
                $table->id();
                $table->foreignId('user_id')->constrained()->onDelete('cascade');
                $table->morphs('likeable');
                $table->timestamps();
                $table->unique(['user_id', 'likeable_id', 'likeable_type']);
            });
        }

        // Table comments (si elle n'existe pas déjà)
        if (!Schema::hasTable('comments')) {
            Schema::create('comments', function (Blueprint $table) {
                $table->id();
                $table->morphs('commentable');
                $table->foreignId('user_id')->constrained()->onDelete('cascade');
                $table->text('content');
                $table->boolean('is_approved')->default(true);
                $table->timestamps();
                $table->index(['commentable_type', 'commentable_id']);
            });
        }

        // Table ingredients (si elle n'existe pas déjà)
        if (!Schema::hasTable('ingredients')) {
            Schema::create('ingredients', function (Blueprint $table) {
                $table->id();
                $table->string('name');
                $table->string('slug')->unique();
                $table->text('description')->nullable();
                $table->string('image')->nullable();
                $table->string('category')->nullable();
                $table->string('unit')->nullable();
                $table->decimal('calories_per_100g', 8, 2)->nullable();
                $table->json('nutritional_info')->nullable();
                $table->boolean('is_active')->default(true);
                $table->timestamps();
            });
        }

        // Table pwa_menu_items (si elle n'existe pas déjà)
        if (!Schema::hasTable('pwa_menu_items')) {
            Schema::create('pwa_menu_items', function (Blueprint $table) {
                $table->id();
                $table->string('title');
                $table->string('url');
                $table->string('icon')->nullable();
                $table->integer('order')->default(0);
                $table->boolean('is_active')->default(true);
                $table->boolean('is_external')->default(false);
                $table->string('target')->default('_self');
                $table->timestamps();
            });
        }

        // Table banners (si elle n'existe pas déjà)
        if (!Schema::hasTable('banners')) {
            Schema::create('banners', function (Blueprint $table) {
                $table->id();
                $table->string('title')->nullable();
                $table->text('description')->nullable();
                $table->string('image');
                $table->string('link_url')->nullable();
                $table->boolean('is_active')->default(true);
                $table->integer('order')->default(0);
                $table->datetime('start_date')->nullable();
                $table->datetime('end_date')->nullable();
                $table->string('content_type')->nullable();
                $table->json('content_data')->nullable();
                $table->string('demo_video_url')->nullable();
                $table->timestamps();
            });
        }

        // Table user_favorites (si elle n'existe pas déjà)
        if (!Schema::hasTable('user_favorites')) {
            Schema::create('user_favorites', function (Blueprint $table) {
                $table->id();
                $table->foreignId('user_id')->constrained()->onDelete('cascade');
                $table->morphs('favoritable');
                $table->timestamps();
                $table->unique(['user_id', 'favoritable_id', 'favoritable_type']);
            });
        }

        // Table push_notifications (si elle n'existe pas déjà)
        if (!Schema::hasTable('push_notifications')) {
            Schema::create('push_notifications', function (Blueprint $table) {
                $table->id();
                $table->string('title');
                $table->text('message');
                $table->string('icon')->nullable();
                $table->string('url')->nullable();
                $table->json('data')->nullable();
                $table->boolean('is_sent')->default(false);
                $table->datetime('scheduled_at')->nullable();
                $table->datetime('sent_at')->nullable();
                $table->timestamps();
            });
        }

        // Table teams (si elle n'existe pas déjà)
        if (!Schema::hasTable('teams')) {
            Schema::create('teams', function (Blueprint $table) {
                $table->id();
                $table->string('name');
                $table->string('slug')->unique();
                $table->string('logo')->nullable();
                $table->string('country')->nullable();
                $table->string('city')->nullable();
                $table->boolean('is_active')->default(true);
                $table->timestamps();
            });
        }

        // Table football_matches (si elle n'existe pas déjà)
        if (!Schema::hasTable('football_matches')) {
            Schema::create('football_matches', function (Blueprint $table) {
                $table->id();
                $table->foreignId('home_team_id')->constrained('teams')->onDelete('cascade');
                $table->foreignId('away_team_id')->constrained('teams')->onDelete('cascade');
                $table->datetime('match_date');
                $table->integer('home_score')->nullable();
                $table->integer('away_score')->nullable();
                $table->enum('status', ['scheduled', 'live', 'finished', 'cancelled'])->default('scheduled');
                $table->string('venue')->nullable();
                $table->text('description')->nullable();
                $table->foreignId('tournament_id')->nullable()->constrained()->onDelete('set null');
                $table->timestamps();
            });
        }

        // Table predictions (si elle n'existe pas déjà)
        if (!Schema::hasTable('predictions')) {
            Schema::create('predictions', function (Blueprint $table) {
                $table->id();
                $table->foreignId('user_id')->constrained()->onDelete('cascade');
                $table->foreignId('match_id')->constrained('football_matches')->onDelete('cascade');
                $table->integer('predicted_home_score');
                $table->integer('predicted_away_score');
                $table->integer('points_earned')->default(0);
                $table->decimal('bet_amount', 8, 2)->nullable();
                $table->timestamps();
                $table->unique(['user_id', 'match_id']);
            });
        }

        // Table leaderboards (si elle n'existe pas déjà)
        if (!Schema::hasTable('leaderboards')) {
            Schema::create('leaderboards', function (Blueprint $table) {
                $table->id();
                $table->foreignId('user_id')->constrained()->onDelete('cascade');
                $table->integer('total_points')->default(0);
                $table->integer('matches_predicted')->default(0);
                $table->integer('exact_predictions')->default(0);
                $table->integer('rank')->nullable();
                $table->timestamps();
                $table->unique('user_id');
            });
        }

        // Table tournaments (si elle n'existe pas déjà)
        if (!Schema::hasTable('tournaments')) {
            Schema::create('tournaments', function (Blueprint $table) {
                $table->id();
                $table->string('name');
                $table->string('slug')->unique();
                $table->text('description')->nullable();
                $table->string('logo')->nullable();
                $table->date('start_date');
                $table->date('end_date');
                $table->enum('status', ['upcoming', 'active', 'completed'])->default('upcoming');
                $table->json('rules')->nullable();
                $table->boolean('is_active')->default(true);
                $table->timestamps();
            });
        }

        // Table tournament_participants (si elle n'existe pas déjà)
        if (!Schema::hasTable('tournament_participants')) {
            Schema::create('tournament_participants', function (Blueprint $table) {
                $table->id();
                $table->foreignId('tournament_id')->constrained()->onDelete('cascade');
                $table->foreignId('user_id')->constrained()->onDelete('cascade');
                $table->datetime('joined_at');
                $table->timestamps();
                $table->unique(['tournament_id', 'user_id']);
            });
        }

        // Table tournament_leaderboards (si elle n'existe pas déjà)
        if (!Schema::hasTable('tournament_leaderboards')) {
            Schema::create('tournament_leaderboards', function (Blueprint $table) {
                $table->id();
                $table->foreignId('tournament_id')->constrained()->onDelete('cascade');
                $table->foreignId('user_id')->constrained()->onDelete('cascade');
                $table->integer('points')->default(0);
                $table->integer('rank')->nullable();
                $table->timestamps();
                $table->unique(['tournament_id', 'user_id']);
            });
        }

        // Table notifications (si elle n'existe pas déjà)
        if (!Schema::hasTable('notifications')) {
            Schema::create('notifications', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->string('type');
                $table->morphs('notifiable');
                $table->text('data');
                $table->timestamp('read_at')->nullable();
                $table->timestamps();
                $table->index(['notifiable_type', 'notifiable_id']);
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Suppression des tables dans l'ordre inverse (pour respecter les contraintes de clés étrangères)
        Schema::dropIfExists('notifications');
        Schema::dropIfExists('tournament_leaderboards');
        Schema::dropIfExists('tournament_participants');
        Schema::dropIfExists('tournaments');
        Schema::dropIfExists('leaderboards');
        Schema::dropIfExists('predictions');
        Schema::dropIfExists('football_matches');
        Schema::dropIfExists('teams');
        Schema::dropIfExists('push_notifications');
        Schema::dropIfExists('user_favorites');
        Schema::dropIfExists('banners');
        Schema::dropIfExists('pwa_menu_items');
        Schema::dropIfExists('ingredients');
        Schema::dropIfExists('comments');
        Schema::dropIfExists('likes');
        Schema::dropIfExists('admin_users');
        Schema::dropIfExists('media_files');
        Schema::dropIfExists('pages');
        Schema::dropIfExists('dinor_tv');
        Schema::dropIfExists('event_categories');
        Schema::dropIfExists('events');
        Schema::dropIfExists('tips');
        Schema::dropIfExists('recipes');
        Schema::dropIfExists('categories');
        Schema::dropIfExists('users');
    }
};
