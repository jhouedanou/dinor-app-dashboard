<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PwaMenuItem extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'label',
        'icon',
        'path',
        'action_type',
        'web_url',
        'is_active',
        'order',
        'description'
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'order' => 'integer'
    ];

    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    public function scopeOrdered($query)
    {
        return $query->orderBy('order');
    }

    // Types d'actions possibles
    public const ACTION_TYPES = [
        'route' => 'Navigation interne',
        'web_embed' => 'Page web intégrée',
        'external_link' => 'Lien externe'
    ];

    // Icônes Material Design disponibles
    public const AVAILABLE_ICONS = [
        'home' => 'Accueil',
        'restaurant' => 'Restaurant/Recettes',
        'lightbulb' => 'Ampoule/Astuces',
        'event' => 'Événement',
        'play_circle' => 'Lecture/TV',
        'public' => 'Web/Globe',
        'favorite' => 'Favori/Cœur',
        'star' => 'Étoile',
        'person' => 'Personne/Profil',
        'settings' => 'Paramètres',
        'info' => 'Information',
        'help' => 'Aide',
        'shopping_cart' => 'Panier',
        'bookmark' => 'Signet',
        'search' => 'Recherche',
        'notifications' => 'Notifications',
        'menu' => 'Menu',
        'more_horiz' => 'Plus horizontal',
        'more_vert' => 'Plus vertical',
        'category' => 'Catégorie',
        'local_dining' => 'Restaurant local',
        'kitchen' => 'Cuisine',
        'cake' => 'Gâteau',
        'coffee' => 'Café',
        'wine_bar' => 'Bar à vin',
        'restaurant_menu' => 'Menu restaurant',
        'fastfood' => 'Fast food',
        'emoji_food_beverage' => 'Nourriture et boisson',
        'sports_bar' => 'Bar sportif',
        'local_cafe' => 'Café local',
        'tv' => 'Télévision',
        'video_library' => 'Bibliothèque vidéo',
        'movie' => 'Film',
        'live_tv' => 'TV en direct',
        'subscriptions' => 'Abonnements',
        'playlist_play' => 'Lecture playlist',
        'smart_display' => 'Affichage intelligent',
        'calendar_today' => 'Calendrier aujourd\'hui',
        'schedule' => 'Planification',
        'event_available' => 'Événement disponible',
        'celebration' => 'Célébration',
        'party_mode' => 'Mode fête',
        'tips_and_updates' => 'Conseils et mises à jour',
        'psychology' => 'Psychologie',
        'school' => 'École',
        'auto_awesome' => 'Auto génial',
        'insights' => 'Aperçus',
        'language' => 'Langue',
        'explore' => 'Explorer',
        'travel_explore' => 'Explorer voyage',
        'map' => 'Carte',
        'place' => 'Lieu',
        'room' => 'Salle',
        'store' => 'Magasin',
        'business' => 'Entreprise',
        'work' => 'Travail',
        'group' => 'Groupe',
        'groups' => 'Groupes',
        'account_circle' => 'Cercle compte',
        'face' => 'Visage',
        'badge' => 'Badge',
        'workspace_premium' => 'Espace de travail premium'
    ];

    public function getIconLabelAttribute()
    {
        return self::AVAILABLE_ICONS[$this->icon] ?? $this->icon;
    }

    public function getActionTypeLabelAttribute()
    {
        return self::ACTION_TYPES[$this->action_type] ?? $this->action_type;
    }
} 