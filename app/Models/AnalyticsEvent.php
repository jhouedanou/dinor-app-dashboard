<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AnalyticsEvent extends Model
{
    use HasFactory;

    protected $fillable = [
        'event_type',
        'event_data',
        'session_id',
        'user_id',
        'page_path',
        'user_agent',
        'ip_address',
        'device_info',
        'timestamp'
    ];

    protected $casts = [
        'event_data' => 'array',
        'device_info' => 'array',
        'timestamp' => 'datetime'
    ];

    // Scopes pour faciliter les requêtes
    public function scopeEventType($query, $type)
    {
        return $query->where('event_type', $type);
    }

    public function scopeToday($query)
    {
        return $query->whereDate('timestamp', today());
    }

    public function scopeThisWeek($query)
    {
        return $query->whereBetween('timestamp', [now()->startOfWeek(), now()->endOfWeek()]);
    }

    public function scopeThisMonth($query)
    {
        return $query->whereMonth('timestamp', now()->month)
                    ->whereYear('timestamp', now()->year);
    }

    public function scopeLastDays($query, $days = 7)
    {
        return $query->where('timestamp', '>=', now()->subDays($days));
    }

    public function scopeForSession($query, $sessionId)
    {
        return $query->where('session_id', $sessionId);
    }

    public function scopeForUser($query, $userId)
    {
        return $query->where('user_id', $userId);
    }

    // Relations possibles
    public function user()
    {
        return $this->belongsTo(\App\Models\User::class, 'user_id');
    }

    // Méthodes utilitaires
    public function getFormattedTimestampAttribute()
    {
        return $this->timestamp->format('d/m/Y H:i:s');
    }

    public function getDeviceTypeAttribute()
    {
        if (!$this->device_info || !is_array($this->device_info)) {
            return 'Unknown';
        }

        return $this->device_info['isMobile'] ?? false ? 'Mobile' : 'Desktop';
    }

    public function getBrowserAttribute()
    {
        if (!$this->user_agent) {
            return 'Unknown';
        }

        // Simple browser detection
        if (str_contains($this->user_agent, 'Chrome')) return 'Chrome';
        if (str_contains($this->user_agent, 'Firefox')) return 'Firefox';
        if (str_contains($this->user_agent, 'Safari') && !str_contains($this->user_agent, 'Chrome')) return 'Safari';
        if (str_contains($this->user_agent, 'Edge')) return 'Edge';
        
        return 'Other';
    }
}
