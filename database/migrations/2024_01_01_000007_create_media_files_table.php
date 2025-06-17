<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('media_files', function (Blueprint $table) {
            $table->id();
            $table->string('name'); // Nom original du fichier
            $table->string('filename'); // Nom du fichier stocké
            $table->string('path'); // Chemin complet du fichier
            $table->string('disk')->default('public'); // Disque de stockage
            $table->string('mime_type'); // Type MIME
            $table->enum('type', ['image', 'video', 'audio', 'document', 'other']); // Type de média
            $table->bigInteger('size'); // Taille en bytes
            $table->json('metadata')->nullable(); // Métadonnées (dimensions, durée, etc.)
            
            // Relations polymorphiques
            $table->nullableMorphs('model'); // model_type, model_id
            $table->string('collection_name')->nullable(); // Pour grouper les médias
            
            // Informations d'upload
            $table->string('uploaded_by')->nullable(); // Utilisateur qui a uploadé
            $table->string('alt_text')->nullable(); // Texte alternatif pour images
            $table->text('description')->nullable(); // Description du média
            $table->json('tags')->nullable(); // Tags pour organiser
            
            // Optimisations pour images
            $table->string('thumbnail_path')->nullable(); // Miniature
            $table->json('responsive_images')->nullable(); // Versions responsive
            
            // SEO et accessibilité
            $table->string('title')->nullable(); // Titre pour SEO
            $table->text('caption')->nullable(); // Légende
            
            // Statut
            $table->boolean('is_optimized')->default(false); // Image optimisée
            $table->boolean('is_public')->default(true); // Accessible publiquement
            $table->boolean('is_featured')->default(false); // Image mise en avant
            
            // Statistiques
            $table->bigInteger('download_count')->default(0);
            $table->bigInteger('view_count')->default(0);
            
            $table->timestamps();
            $table->softDeletes();
            
            // Index pour optimiser les requêtes (model_type, model_id est créé automatiquement par nullableMorphs)
            $table->index(['type', 'is_public']);
            $table->index(['collection_name']);
            $table->index(['mime_type']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('media_files');
    }
}; 