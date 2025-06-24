<?php

namespace App\Filament\Widgets;

use App\Models\Like;
use Filament\Widgets\ChartWidget;

class LikesDistributionChart extends ChartWidget
{
    protected static ?string $heading = 'Répartition des Likes par Type de Contenu';

    protected static ?int $sort = 4;

    protected function getData(): array
    {
        $recipeLikes = Like::where('likeable_type', 'App\Models\Recipe')->count();
        $eventLikes = Like::where('likeable_type', 'App\Models\Event')->count();
        $tipLikes = Like::where('likeable_type', 'App\Models\Tip')->count();
        $videoLikes = Like::where('likeable_type', 'App\Models\DinorTv')->count();

        return [
            'datasets' => [
                [
                    'label' => 'Likes par catégorie',
                    'data' => [$recipeLikes, $eventLikes, $tipLikes, $videoLikes],
                    'backgroundColor' => [
                        '#10b981', // Recettes - vert
                        '#f59e0b', // Événements - jaune
                        '#3b82f6', // Astuces - bleu
                        '#8b5cf6', // Vidéos - violet
                    ],
                    'borderColor' => [
                        '#059669',
                        '#d97706',
                        '#2563eb',
                        '#7c3aed',
                    ],
                    'borderWidth' => 2,
                ],
            ],
            'labels' => ['Recettes', 'Événements', 'Astuces', 'Vidéos'],
        ];
    }

    protected function getType(): string
    {
        return 'doughnut';
    }

    protected function getOptions(): array
    {
        return [
            'plugins' => [
                'legend' => [
                    'display' => true,
                    'position' => 'bottom',
                ],
            ],
            'maintainAspectRatio' => false,
        ];
    }

    protected static ?string $pollingInterval = '60s';

    protected static bool $isLazy = false;
}