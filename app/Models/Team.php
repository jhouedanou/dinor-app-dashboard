<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Team extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'short_name',
        'country',
        'logo',
        'color_primary',
        'color_secondary',
        'is_active',
        'founded_year',
        'description'
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'founded_year' => 'integer'
    ];

    protected $appends = [
        'logo_url'
    ];

    public function getLogoUrlAttribute()
    {
        return $this->logo ? asset('storage/' . $this->logo) : null;
    }

    public function homeMatches()
    {
        return $this->hasMany(FootballMatch::class, 'home_team_id');
    }

    public function awayMatches()
    {
        return $this->hasMany(FootballMatch::class, 'away_team_id');
    }

    public function matches()
    {
        return FootballMatch::where('home_team_id', $this->id)
                          ->orWhere('away_team_id', $this->id);
    }

    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }
}
