<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('events', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->text('description');
            $table->longText('content')->nullable();
            $table->text('short_description')->nullable();
            
            // Dates et heures
            $table->date('start_date');
            $table->date('end_date')->nullable();
            $table->time('start_time')->nullable();
            $table->time('end_time')->nullable();
            $table->string('timezone')->default('UTC');
            $table->boolean('is_all_day')->default(false);
            $table->json('recurring_pattern')->nullable(); // Pour les événements récurrents
            
            // Localisation
            $table->string('location')->nullable();
            $table->text('address')->nullable();
            $table->string('city')->nullable();
            $table->string('country')->nullable();
            $table->string('postal_code')->nullable();
            $table->decimal('latitude', 10, 8)->nullable();
            $table->decimal('longitude', 11, 8)->nullable();
            $table->boolean('is_online')->default(false);
            $table->string('online_meeting_url')->nullable();
            $table->text('directions')->nullable();
            $table->string('parking_info')->nullable();
            $table->string('public_transport_info')->nullable();
            
            $table->foreignId('category_id')->constrained()->onDelete('cascade');
            
            // Images et médias
            $table->string('featured_image')->nullable();
            $table->json('gallery')->nullable();
            $table->string('video_url')->nullable();
            $table->string('live_stream_url')->nullable();
            $table->string('promotional_video')->nullable();
            
            // Inscription et participation
            $table->string('registration_url')->nullable();
            $table->datetime('registration_start')->nullable();
            $table->datetime('registration_end')->nullable();
            $table->boolean('requires_registration')->default(false);
            $table->boolean('requires_approval')->default(false);
            $table->integer('max_participants')->nullable();
            $table->integer('current_participants')->default(0);
            $table->integer('waiting_list_count')->default(0);
            $table->integer('min_participants')->nullable();
            
            // Tarification
            $table->decimal('price', 8, 2)->default(0);
            $table->string('currency', 3)->default('XOF');
            $table->boolean('is_free')->default(true);
            $table->decimal('early_bird_price', 8, 2)->nullable();
            $table->datetime('early_bird_deadline')->nullable();
            $table->decimal('student_price', 8, 2)->nullable();
            $table->decimal('group_price', 8, 2)->nullable();
            $table->integer('group_min_size')->nullable();
            $table->text('pricing_notes')->nullable();
            
            // Contact et organisateur
            $table->json('contact_info')->nullable();
            $table->string('organizer_name')->nullable();
            $table->string('organizer_email')->nullable();
            $table->string('organizer_phone')->nullable();
            $table->string('organizer_website')->nullable();
            
            // Informations pratiques
            $table->enum('dress_code', ['casual', 'business', 'formal', 'costume', 'uniform'])->nullable();
            $table->text('what_to_bring')->nullable();
            $table->text('what_is_provided')->nullable();
            $table->text('accessibility_info')->nullable();
            $table->boolean('wheelchair_accessible')->default(false);
            $table->enum('age_restriction', ['all_ages', '18_plus', '21_plus', 'family_friendly', 'adults_only'])->default('all_ages');
            $table->text('food_provided')->nullable();
            $table->text('special_requirements')->nullable();
            
            // Type d'événement
            $table->enum('event_type', [
                'conference', 'workshop', 'seminar', 'cooking_class', 'tasting', 
                'festival', 'competition', 'networking', 'exhibition', 'party',
                'charity', 'educational', 'cultural', 'sports', 'other'
            ])->default('other');
            $table->enum('event_format', ['in_person', 'online', 'hybrid'])->default('in_person');
            
            // Statut et publication
            $table->boolean('is_featured')->default(false);
            $table->boolean('is_published')->default(false);
            $table->enum('status', ['draft', 'active', 'cancelled', 'postponed', 'completed'])->default('draft');
            $table->text('cancellation_reason')->nullable();
            $table->datetime('published_at')->nullable();
            
            // Météo et saison (pour événements extérieurs)
            $table->boolean('weather_dependent')->default(false);
            $table->text('weather_policy')->nullable();
            $table->text('backup_plan')->nullable();
            
            // Métadonnées
            $table->json('tags')->nullable();
            $table->string('slug')->unique();
            $table->text('meta_description')->nullable();
            $table->string('meta_keywords')->nullable();
            
            // Statistiques
            $table->bigInteger('views_count')->default(0);
            $table->bigInteger('likes_count')->default(0);
            $table->bigInteger('shares_count')->default(0);
            $table->bigInteger('favorites_count')->default(0);
            
            // Feedback
            $table->decimal('rating_average', 3, 2)->default(0);
            $table->integer('rating_count')->default(0);
            $table->boolean('allow_reviews')->default(true);
            
            $table->timestamps();
            $table->softDeletes();
            
            // Index pour optimiser les requêtes
            $table->index(['start_date', 'is_published']);
            $table->index(['category_id', 'status']);
            $table->index(['is_featured', 'is_published']);
            $table->index(['event_type', 'event_format']);
            $table->index(['city', 'country']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('events');
    }
}; 