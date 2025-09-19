<?php

namespace App\Filament\Widgets;

use Filament\Widgets\Widget;
use App\Models\UserFavorite;
use Illuminate\Support\Collection;
use Carbon\Carbon;

class PopularContentWidget extends Widget
{
    protected static string $view = 'filament.widgets.popular-content-widget';
    
    protected static ?int $sort = 2;
    
    protected static ?string $heading = 'Contenus Populaires (Favoris)';
    
    protected static ?string $description = 'Les contenus les plus ajoutés en favoris par les utilisateurs';
    
    protected static bool $isLazy = true;

    /**
     * Récupérer les données pour le widget
     */
    public function getData(): array
    {
        $period = $this->getPeriod();
        
        return [
            'popular_content' => $this->getPopularContent($period),
            'favorites_stats' => $this->getFavoritesStats($period),
            'period_label' => $this->getPeriodLabel($period),
            'total_favorites' => $this->getTotalFavorites($period),
        ];
    }

    /**
     * Récupérer les contenus les plus populaires
     */
    protected function getPopularContent(string $period = '30d', int $limit = 8): Collection
    {
        $query = UserFavorite::selectRaw('
                favoritable_type,
                favoritable_id,
                COUNT(*) as favorites_count
            ')
            ->with(['favoritable'])
            ->groupBy('favoritable_type', 'favoritable_id')
            ->orderBy('favorites_count', 'desc')
            ->limit($limit);

        if ($period !== 'all') {
            $startDate = $this->getStartDate($period);
            $query->where('created_at', '>=', $startDate);
        }

        return $query->get()->map(function ($favorite) {
            $content = $favorite->favoritable;
            if (!$content) return null;

            return [
                'id' => $favorite->favoritable_id,
                'type' => $this->getContentTypeLabel($favorite->favoritable_type),
                'type_slug' => $this->getContentTypeSlug($favorite->favoritable_type),
                'title' => $content->title ?? $content->name ?? 'Sans titre',
                'favorites_count' => $favorite->favorites_count,
                'image' => $content->image ?? $content->thumbnail ?? null,
                'created_at' => $content->created_at ?? null,
                'category' => $content->category->name ?? null,
                'model_type' => $favorite->favoritable_type,
                'url' => $this->getContentAdminUrl($favorite->favoritable_type, $favorite->favoritable_id),
            ];
        })->filter()->values();
    }

    /**
     * Obtenir les statistiques générales des favoris
     */
    protected function getFavoritesStats(string $period = '30d'): array
    {
        $query = UserFavorite::query();
        
        if ($period !== 'all') {
            $startDate = $this->getStartDate($period);
            $query->where('created_at', '>=', $startDate);
        }

        $totalFavorites = $query->count();
        $uniqueUsers = $query->distinct('user_id')->count('user_id');

        // Répartition par type
        $favoritesByType = UserFavorite::selectRaw('
            favoritable_type,
            COUNT(*) as count
        ')
        ->when($period !== 'all', function($q) use ($period) {
            return $q->where('created_at', '>=', $this->getStartDate($period));
        })
        ->groupBy('favoritable_type')
        ->orderBy('count', 'desc')
        ->get()
        ->map(function($item) {
            return [
                'type' => $this->getContentTypeLabel($item->favoritable_type),
                'count' => $item->count,
                'percentage' => 0 // Sera calculé dans la vue
            ];
        });

        return [
            'total_favorites' => $totalFavorites,
            'unique_users' => $uniqueUsers,
            'avg_per_user' => $uniqueUsers > 0 ? round($totalFavorites / $uniqueUsers, 2) : 0,
            'by_type' => $favoritesByType,
        ];
    }

    /**
     * Total des favoris pour la période
     */
    protected function getTotalFavorites(string $period = '30d'): int
    {
        $query = UserFavorite::query();
        
        if ($period !== 'all') {
            $startDate = $this->getStartDate($period);
            $query->where('created_at', '>=', $startDate);
        }

        return $query->count();
    }

    /**
     * Obtenir la période depuis les paramètres de la requête
     */
    protected function getPeriod(): string
    {
        return request()->input('period', '30d');
    }

    /**
     * Obtenir la date de début selon la période
     */
    protected function getStartDate(string $period): Carbon
    {
        return match($period) {
            '7d' => Carbon::now()->subWeek(),
            '30d' => Carbon::now()->subMonth(),
            '90d' => Carbon::now()->subMonths(3),
            default => Carbon::now()->subMonth()
        };
    }

    /**
     * Obtenir le label de la période
     */
    protected function getPeriodLabel(string $period): string
    {
        return match($period) {
            '7d' => 'Derniers 7 jours',
            '30d' => 'Derniers 30 jours', 
            '90d' => 'Derniers 90 jours',
            'all' => 'Depuis le début',
            default => 'Derniers 30 jours'
        };
    }

    /**
     * Convertir le type de modèle en label lisible
     */
    protected function getContentTypeLabel(string $modelType): string
    {
        return match($modelType) {
            'App\\Models\\Recipe' => 'Recette',
            'App\\Models\\Tip' => 'Conseil',
            'App\\Models\\Event' => 'Événement',
            'App\\Models\\DinorTv' => 'Vidéo DinorTV',
            default => 'Contenu'
        };
    }

    /**
     * Convertir le type de modèle en slug
     */
    protected function getContentTypeSlug(string $modelType): string
    {
        return match($modelType) {
            'App\\Models\\Recipe' => 'recipe',
            'App\\Models\\Tip' => 'tip',
            'App\\Models\\Event' => 'event',
            'App\\Models\\DinorTv' => 'dinor_tv',
            default => 'content'
        };
    }

    /**
     * Générer l'URL d'administration pour le contenu
     */
    protected function getContentAdminUrl(string $modelType, int $id): ?string
    {
        $resourceMap = [
            'App\\Models\\Recipe' => 'recipes',
            'App\\Models\\Tip' => 'tips', 
            'App\\Models\\Event' => 'events',
            'App\\Models\\DinorTv' => 'dinor-tvs'
        ];

        $resource = $resourceMap[$modelType] ?? null;
        
        if ($resource) {
            return route("filament.admin.resources.{$resource}.view", $id);
        }

        return null;
    }

    /**
     * Déterminer si le widget peut être chargé
     */
    public static function canView(): bool
    {
        return auth()->check();
    }

    /**
     * Gérer la mise à jour du widget via AJAX
     */
    public function refreshData(): array 
    {
        return $this->getData();
    }
}