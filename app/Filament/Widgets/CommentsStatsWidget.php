<?php

namespace App\Filament\Widgets;

use App\Models\Comment;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class CommentsStatsWidget extends BaseWidget
{
    protected function getStats(): array
    {
        $totalComments = Comment::count();
        $approvedComments = Comment::approved()->count();
        $pendingComments = Comment::pending()->count();
        
        $recipeComments = Comment::where('commentable_type', 'App\Models\Recipe')->count();
        $eventComments = Comment::where('commentable_type', 'App\Models\Event')->count();
        $tipComments = Comment::where('commentable_type', 'App\Models\Tip')->count();
        $videoComments = Comment::where('commentable_type', 'App\Models\DinorTv')->count();

        // Calculer le taux d'approbation
        $approvalRate = $totalComments > 0 ? ($approvedComments / $totalComments) * 100 : 0;

        return [
            Stat::make('Total Commentaires', $totalComments)
                ->description($approvedComments . ' approuvés')
                ->descriptionIcon('heroicon-m-check-circle')
                ->color('primary')
                ->chart($this->getCommentsChart()),

            Stat::make('En Attente', $pendingComments)
                ->description('Nécessitent modération')
                ->descriptionIcon('heroicon-m-clock')
                ->color($pendingComments > 0 ? 'warning' : 'success'),

            Stat::make('Taux d\'Approbation', number_format($approvalRate, 1) . '%')
                ->description($approvedComments . '/' . $totalComments . ' approuvés')
                ->descriptionIcon('heroicon-m-chart-bar')
                ->color($approvalRate >= 80 ? 'success' : ($approvalRate >= 60 ? 'warning' : 'danger')),

            Stat::make('Par Type', '')
                ->description("Recettes: {$recipeComments} | Événements: {$eventComments}")
                ->extraAttributes([
                    'class' => 'text-sm',
                ])
                ->color('info'),

            Stat::make('Astuces & Vidéos', '')
                ->description("Astuces: {$tipComments} | Vidéos: {$videoComments}")
                ->extraAttributes([
                    'class' => 'text-sm',
                ])
                ->color('info'),
        ];
    }

    private function getCommentsChart(): array
    {
        // Générer un graphique des commentaires des 7 derniers jours
        $days = [];
        for ($i = 6; $i >= 0; $i--) {
            $date = now()->subDays($i);
            $count = Comment::whereDate('created_at', $date)->count();
            $days[] = $count;
        }
        return $days;
    }

    protected static ?int $sort = 3;

    protected static ?string $pollingInterval = null;
}