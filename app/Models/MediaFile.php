<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Facades\Storage;

class MediaFile extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'name',
        'filename',
        'path',
        'disk',
        'mime_type',
        'type',
        'size',
        'metadata',
        'model_type',
        'model_id',
        'collection_name',
        'uploaded_by',
        'alt_text',
        'description',
        'tags',
        'thumbnail_path',
        'responsive_images',
        'title',
        'caption',
        'is_optimized',
        'is_public',
        'is_featured',
        'download_count',
        'view_count'
    ];

    protected $casts = [
        'metadata' => 'array',
        'tags' => 'array',
        'responsive_images' => 'array',
        'is_optimized' => 'boolean',
        'is_public' => 'boolean',
        'is_featured' => 'boolean',
        'download_count' => 'integer',
        'view_count' => 'integer',
        'size' => 'integer'
    ];

    /**
     * Relation polymorphique avec d'autres modèles
     */
    public function model()
    {
        return $this->morphTo();
    }

    /**
     * Scope pour filtrer par type de média
     */
    public function scopeOfType($query, $type)
    {
        return $query->where('type', $type);
    }

    /**
     * Scope pour les images uniquement
     */
    public function scopeImages($query)
    {
        return $query->where('type', 'image');
    }

    /**
     * Scope pour les vidéos uniquement
     */
    public function scopeVideos($query)
    {
        return $query->where('type', 'video');
    }

    /**
     * Scope pour les fichiers publics
     */
    public function scopePublic($query)
    {
        return $query->where('is_public', true);
    }

    /**
     * Scope pour une collection spécifique
     */
    public function scopeInCollection($query, $collection)
    {
        return $query->where('collection_name', $collection);
    }

    /**
     * Obtenir l'URL complète du fichier
     */
    public function getUrlAttribute()
    {
        return Storage::disk($this->disk)->url($this->path);
    }

    /**
     * Obtenir l'URL de la miniature
     */
    public function getThumbnailUrlAttribute()
    {
        if ($this->thumbnail_path) {
            return Storage::disk($this->disk)->url($this->thumbnail_path);
        }
        
        // Si c'est une image et qu'il n'y a pas de miniature, retourner l'image originale
        if ($this->type === 'image') {
            return $this->url;
        }
        
        return null;
    }

    /**
     * Obtenir la taille formatée
     */
    public function getFormattedSizeAttribute()
    {
        $bytes = $this->size;
        $units = ['B', 'KB', 'MB', 'GB', 'TB'];
        
        for ($i = 0; $bytes > 1024 && $i < count($units) - 1; $i++) {
            $bytes /= 1024;
        }
        
        return round($bytes, 2) . ' ' . $units[$i];
    }

    /**
     * Vérifier si le fichier est une image
     */
    public function isImage()
    {
        return $this->type === 'image' || str_starts_with($this->mime_type, 'image/');
    }

    /**
     * Vérifier si le fichier est une vidéo
     */
    public function isVideo()
    {
        return $this->type === 'video' || str_starts_with($this->mime_type, 'video/');
    }

    /**
     * Vérifier si le fichier existe physiquement
     */
    public function exists()
    {
        return Storage::disk($this->disk)->exists($this->path);
    }

    /**
     * Supprimer le fichier physique
     */
    public function deleteFile()
    {
        if ($this->exists()) {
            Storage::disk($this->disk)->delete($this->path);
        }
        
        // Supprimer aussi la miniature si elle existe
        if ($this->thumbnail_path && Storage::disk($this->disk)->exists($this->thumbnail_path)) {
            Storage::disk($this->disk)->delete($this->thumbnail_path);
        }
        
        // Supprimer les images responsives
        if ($this->responsive_images) {
            foreach ($this->responsive_images as $responsiveImage) {
                if (isset($responsiveImage['path']) && Storage::disk($this->disk)->exists($responsiveImage['path'])) {
                    Storage::disk($this->disk)->delete($responsiveImage['path']);
                }
            }
        }
    }

    /**
     * Incrémenter le compteur de vues
     */
    public function incrementViews()
    {
        $this->increment('view_count');
    }

    /**
     * Incrémenter le compteur de téléchargements
     */
    public function incrementDownloads()
    {
        $this->increment('download_count');
    }

    /**
     * Obtenir les dimensions de l'image (si applicable)
     */
    public function getDimensionsAttribute()
    {
        if ($this->isImage() && isset($this->metadata['width']) && isset($this->metadata['height'])) {
            return $this->metadata['width'] . 'x' . $this->metadata['height'];
        }
        
        return null;
    }

    /**
     * Obtenir la durée de la vidéo (si applicable)
     */
    public function getDurationAttribute()
    {
        if ($this->isVideo() && isset($this->metadata['duration'])) {
            return $this->metadata['duration'];
        }
        
        return null;
    }

    /**
     * Event: supprimer les fichiers physiques lors de la suppression du modèle
     */
    protected static function boot()
    {
        parent::boot();
        
        static::deleting(function ($mediaFile) {
            $mediaFile->deleteFile();
        });
    }
} 