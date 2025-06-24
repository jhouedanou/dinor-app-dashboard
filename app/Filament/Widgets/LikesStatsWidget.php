<?php

namespace App\Filament\Widgets;

use App\Models\Like;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class LikesStatsWidget extends BaseWidget
{
    protected function getStats(): array
    {
        $totalLikes = Like::count();
        $recipeLikes = Like::where('likeable_type', 'App\Models\Recipe')->count();
        $eventLikes = Like::where('likeable_type', 'App\Models\Event')->count();
        $tipLikes = Like::where('likeable_type', 'App\Models\Tip')->count();
        $videoLikes = Like::where('likeable_type', 'App\Models\DinorTv')->count();

        // Calculer le pourcentage de croissance (derniers 30 jours vs 30 jours précédents)
        $lastMonth = Like::where('created_at', '>=', now()->subDays(30))->count();
        $previousMonth = Like::whereBetween('created_at', [now()->subDays(60), now()->subDays(30)])->count();
        $growthPercentage = $previousMonth > 0 ? (($lastMonth - $previousMonth) / $previousMonth) * 100 : 0;

        return [
            Stat::make('Total des Likes', $totalLikes)
                ->description($lastMonth . ' likes ce mois')
                ->descriptionIcon($growthPercentage >= 0 ? 'heroicon-m-arrow-trending-up' : 'heroicon-m-arrow-trending-down')
                ->color($growthPercentage >= 0 ? 'success' : 'danger')
                ->chart($this->getLikesChart()),

            Stat::make('Likes Recettes', $recipeLikes)
                ->description($this->getPercentage($recipeLikes, $totalLikes) . '% du total')
                ->descriptionIcon('heroicon-m-chart-pie')
                ->color('success'),

            Stat::make('Likes Événements', $eventLikes)
                ->description($this->getPercentage($eventLikes, $totalLikes) . '% du total')
                ->descriptionIcon('heroicon-m-calendar-days')
                ->color('warning'),

            Stat::make('Likes Astuces', $tipLikes)
                ->description($this->getPercentage($tipLikes, $totalLikes) . '% du total')
                ->descriptionIcon('heroicon-m-light-bulb')
                ->color('primary'),

            Stat::make('Likes Vidéos', $videoLikes)
                ->description($this->getPercentage($videoLikes, $totalLikes) . '% du total')
                ->descriptionIcon('heroicon-m-play')
                ->color('info'),
        ];
    }

    private function getPercentage(int $value, int $total): string
    {
        if ($total == 0) return '0';
        return number_format(($value / $total) * 100, 1);
    }

    private function getLikesChart(): array
    {
        // Générer un graphique des likes des 7 derniers jours
        $days = [];
        for ($i = 6; $i >= 0; $i--) {
            $date = now()->subDays($i);
            $count = Like::whereDate('created_at', $date)->count();
            $days[] = $count;
        }
        return $days;
    }

    protected static ?int $sort = 2;

    protected static ?string $pollingInterval = '30s';
}