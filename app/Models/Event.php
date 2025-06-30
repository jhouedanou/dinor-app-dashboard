<?php

namespace App\Models;

use App\Traits\Likeable;
use App\Traits\Commentable;
use App\Traits\Favoritable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Event extends Model
{
    use HasFactory, SoftDeletes, Likeable, Commentable, Favoritable;

    protected $fillable = [
        'title',
        'description',
        'content',
        'short_description',
        'start_date',
        'end_date',
        'start_time',
        'end_time',
        'timezone',
        'is_all_day',
        'recurring_pattern',
        'location',
        'address',
        'city',
        'country',
        'postal_code',
        'latitude',
        'longitude',
        'is_online',
        'online_meeting_url',
        'directions',
        'parking_info',
        'public_transport_info',
        'category_id',
        'event_category_id',
        'featured_image',
        'gallery',
        'video_url',
        'live_stream_url',
        'promotional_video',
        'registration_url',
        'registration_start',
        'registration_end',
        'requires_registration',
        'requires_approval',
        'max_participants',
        'current_participants',
        'waiting_list_count',
        'min_participants',
        'price',
        'currency',
        'is_free',
        'early_bird_price',
        'early_bird_deadline',
        'student_price',
        'group_price',
        'group_min_size',
        'pricing_notes',
        'contact_info',
        'organizer_name',
        'organizer_email',
        'organizer_phone',
        'organizer_website',
        'dress_code',
        'what_to_bring',
        'what_is_provided',
        'accessibility_info',
        'wheelchair_accessible',
        'age_restriction',
        'food_provided',
        'special_requirements',
        'event_type',
        'event_format',
        'is_featured',
        'is_published',
        'status',
        'cancellation_reason',
        'published_at',
        'weather_dependent',
        'weather_policy',
        'backup_plan',
        'tags',
        'slug',
        'meta_description',
        'meta_keywords',
        'views_count',
        'likes_count',
        'shares_count',
        'favorites_count',
        'rating_average',
        'rating_count',
        'allow_reviews'
    ];

    protected $casts = [
        'start_date' => 'date',
        'end_date' => 'date',
        'start_time' => 'datetime',
        'end_time' => 'datetime',
        'registration_start' => 'datetime',
        'registration_end' => 'datetime',
        'early_bird_deadline' => 'datetime',
        'published_at' => 'datetime',
        'recurring_pattern' => 'array',
        'gallery' => 'array',
        'contact_info' => 'array',
        'tags' => 'array',
        'is_all_day' => 'boolean',
        'is_online' => 'boolean',
        'requires_registration' => 'boolean',
        'requires_approval' => 'boolean',
        'is_free' => 'boolean',
        'wheelchair_accessible' => 'boolean',
        'weather_dependent' => 'boolean',
        'is_featured' => 'boolean',
        'is_published' => 'boolean',
        'allow_reviews' => 'boolean',
        'max_participants' => 'integer',
        'current_participants' => 'integer',
        'waiting_list_count' => 'integer',
        'min_participants' => 'integer',
        'group_min_size' => 'integer',
        'price' => 'decimal:2',
        'early_bird_price' => 'decimal:2',
        'student_price' => 'decimal:2',
        'group_price' => 'decimal:2',
        'latitude' => 'decimal:8',
        'longitude' => 'decimal:8',
        'views_count' => 'integer',
        'likes_count' => 'integer',
        'shares_count' => 'integer',
        'favorites_count' => 'integer',
        'rating_average' => 'decimal:2',
        'rating_count' => 'integer'
    ];

    protected $appends = [
        'featured_image_url',
        'gallery_urls'
    ];

    public function category()
    {
        return $this->belongsTo(Category::class);
    }

    public function eventCategory()
    {
        return $this->belongsTo(EventCategory::class, 'event_category_id');
    }

    public function mediaFiles()
    {
        return $this->morphMany(MediaFile::class, 'model');
    }

    public function featuredImage()
    {
        return $this->morphOne(MediaFile::class, 'model')->where('collection_name', 'featured_image');
    }

    public function galleryImages()
    {
        return $this->morphMany(MediaFile::class, 'model')->where('collection_name', 'gallery');
    }

    public function videoFiles()
    {
        return $this->morphMany(MediaFile::class, 'model')->where('collection_name', 'videos');
    }

    public function promotionalVideos()
    {
        return $this->morphMany(MediaFile::class, 'model')->where('collection_name', 'promotional');
    }

    public function getFeaturedImageUrlAttribute()
    {
        return $this->featured_image ? asset('storage/' . $this->featured_image) : null;
    }

    public function getGalleryUrlsAttribute()
    {
        if (!$this->gallery) return [];
        
        return array_map(function($image) {
            return asset('storage/' . $image);
        }, $this->gallery);
    }

    public function scopePublished($query)
    {
        return $query->where('is_published', true);
    }

    public function scopeFeatured($query)
    {
        return $query->where('is_featured', true);
    }

    public function scopeUpcoming($query)
    {
        return $query->where('start_date', '>=', now()->toDateString());
    }

    public function scopeActive($query)
    {
        return $query->where('status', 'active');
    }

    public function scopeByEventType($query, $eventType)
    {
        return $query->where('event_type', $eventType);
    }

    public function scopeByEventFormat($query, $format)
    {
        return $query->where('event_format', $format);
    }

    public function scopeByCity($query, $city)
    {
        return $query->where('city', $city);
    }

    public function scopeByCountry($query, $country)
    {
        return $query->where('country', $country);
    }

    public function scopeFreeEvents($query)
    {
        return $query->where('is_free', true);
    }

    public function scopePaidEvents($query)
    {
        return $query->where('is_free', false);
    }

    public function scopeOnlineEvents($query)
    {
        return $query->where('is_online', true);
    }

    public function scopeAccessible($query)
    {
        return $query->where('wheelchair_accessible', true);
    }

    public function getIsFullAttribute()
    {
        return $this->max_participants && $this->current_participants >= $this->max_participants;
    }

    public function getAvailableSpotsAttribute()
    {
        return $this->max_participants ? $this->max_participants - $this->current_participants : null;
    }

    public function getIsRegistrationOpenAttribute()
    {
        $now = now();
        
        if ($this->registration_start && $now < $this->registration_start) {
            return false;
        }
        
        if ($this->registration_end && $now > $this->registration_end) {
            return false;
        }
        
        return !$this->is_full;
    }

    public function getEffectivePriceAttribute()
    {
        if ($this->is_free) return 0;
        
        $now = now();
        
        // Early bird pricing
        if ($this->early_bird_price && $this->early_bird_deadline && $now <= $this->early_bird_deadline) {
            return $this->early_bird_price;
        }
        
        return $this->price;
    }

    public function getEventTypeLabelsAttribute()
    {
        return match($this->event_type) {
            'conference' => 'Conférence',
            'workshop' => 'Atelier',
            'seminar' => 'Séminaire',
            'cooking_class' => 'Cours de cuisine',
            'tasting' => 'Dégustation',
            'festival' => 'Festival',
            'competition' => 'Concours',
            'networking' => 'Réseautage',
            'exhibition' => 'Exposition',
            'party' => 'Fête',
            'charity' => 'Charité',
            'educational' => 'Éducatif',
            'cultural' => 'Culturel',
            'sports' => 'Sport',
            default => 'Autre'
        };
    }

    public function getEventFormatLabelAttribute()
    {
        return match($this->event_format) {
            'in_person' => 'En présentiel',
            'online' => 'En ligne',
            'hybrid' => 'Hybride',
            default => 'Non défini'
        };
    }

    public function getStatusLabelAttribute()
    {
        return match($this->status) {
            'draft' => 'Brouillon',
            'active' => 'Actif',
            'cancelled' => 'Annulé',
            'postponed' => 'Reporté',
            'completed' => 'Terminé',
            default => 'Non défini'
        };
    }

    public function incrementViews()
    {
        $this->increment('views_count');
    }

    public function incrementLikes()
    {
        $this->increment('likes_count');
    }

    public function incrementShares()
    {
        $this->increment('shares_count');
    }

    public function incrementFavorites()
    {
        $this->increment('favorites_count');
    }

    public function getFullAddressAttribute()
    {
        $addressParts = array_filter([
            $this->address,
            $this->city,
            $this->postal_code,
            $this->country
        ]);
        
        return implode(', ', $addressParts);
    }

    /**
     * Get all likes for this event
     */
    public function likes()
    {
        return $this->morphMany(Like::class, 'likeable');
    }

    /**
     * Get all comments for this event
     */
    public function comments()
    {
        return $this->morphMany(Comment::class, 'commentable');
    }

    /**
     * Get approved comments only
     */
    public function approvedComments()
    {
        return $this->morphMany(Comment::class, 'commentable')->approved();
    }

    /**
     * Get current likes count
     */
    public function getCurrentLikesCountAttribute(): int
    {
        return $this->likes()->count();
    }

    /**
     * Get approved comments count
     */
    public function getApprovedCommentsCountAttribute(): int
    {
        return $this->approvedComments()->count();
    }

    /**
     * Check if user has liked this event
     */
    public function isLikedBy(string $userIdentifier): bool
    {
        return Like::hasLiked($this, $userIdentifier);
    }

    /**
     * Toggle like for this event
     */
    public function toggleLike($userId = null, $ipAddress = null, $userAgent = null)
    {
        return Like::toggle($this, $userId, $ipAddress, $userAgent);
    }
} 