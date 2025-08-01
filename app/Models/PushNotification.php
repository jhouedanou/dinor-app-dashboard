<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PushNotification extends Model
{
    use HasFactory;

    protected $fillable = [
        'title',
        'message',
        'icon',
        'url',
        'content_type',
        'content_id',
        'target_audience',
        'target_data',
        'onesignal_id',
        'status',
        'scheduled_at',
        'sent_at',
        'statistics',
        'created_by',
    ];

    protected $casts = [
        'target_data' => 'array',
        'statistics' => 'array',
        'scheduled_at' => 'datetime',
        'sent_at' => 'datetime',
    ];

    public function creator(): BelongsTo
    {
        return $this->belongsTo(AdminUser::class, 'created_by');
    }

    public function scopeDraft($query)
    {
        return $query->where('status', 'draft');
    }

    public function scopeScheduled($query)
    {
        return $query->where('status', 'scheduled');
    }

    public function scopeSent($query)
    {
        return $query->where('status', 'sent');
    }

    public function scopePending($query)
    {
        return $query->where('status', 'scheduled')
                    ->where('scheduled_at', '<=', now());
    }

    /**
     * Génère l'URL de deep link en fonction du type de contenu
     */
    public function getDeepLinkUrl(): ?string
    {
        if ($this->content_type === 'custom') {
            return $this->url;
        }

        if (!$this->content_type || !$this->content_id) {
            return null;
        }

        return match($this->content_type) {
            'recipe' => "dinor://recipe/{$this->content_id}",
            'tip' => "dinor://tip/{$this->content_id}",
            'event' => "dinor://event/{$this->content_id}",
            'dinor_tv' => "dinor://dinor-tv/{$this->content_id}",
            'page' => "dinor://page/{$this->content_id}",
            default => null,
        };
    }

    /**
     * Obtient le nom du contenu lié
     */
    public function getContentName(): ?string
    {
        if (!$this->content_type || !$this->content_id) {
            return null;
        }

        return match($this->content_type) {
            'recipe' => Recipe::find($this->content_id)?->title,
            'tip' => Tip::find($this->content_id)?->title,
            'event' => Event::find($this->content_id)?->title,
            'dinor_tv' => DinorTv::find($this->content_id)?->title,
            'page' => Page::find($this->content_id)?->title,
            default => null,
        };
    }
}
