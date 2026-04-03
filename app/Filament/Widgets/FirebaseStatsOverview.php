<?php

namespace App\Filament\Widgets;

use App\Models\Recipe;
use App\Models\Event;
use App\Models\Page;
use App\Models\Tip;
use App\Models\User;
use App\Models\Like;
use App\Models\Comment;
use App\Services\FirebaseAnalyticsService;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;
use Carbon\Carbon;

class FirebaseStatsOverview extends BaseWidget
{
    protected static ?int $sort = 0;

    protected FirebaseAnalyticsService $analyticsService;

    public function __construct()
    {
        $this->analyticsService = new FirebaseAnalyticsService();
    }

    protected function getStats(): array
    {
        $firebaseStats = $this->analyticsService->getAppStatistics();
        $realTimeMetrics = $this->analyticsService->getRealTimeMetrics();
        $contentStats = $this->analyticsService->getContentStatistics();

        $usersThisMonth = User::whereMonth('created_at', now()->month)->count();
        $recipesThisWeek = Recipe::where('created_at', '>=', now()->subDays(7))->count();

        return [
            Stat::make('Utilisateurs Actifs', number_format($firebaseStats['active_users_30d']))
                ->description("{$firebaseStats['total_users']} utilisateurs total - +{$usersThisMonth} ce mois")
                ->descriptionIcon('heroicon-m-arrow-trending-up')
                ->color('success')
                ->chart($this->getUsersChart()),

            Stat::make('Sessions Aujourd\'hui', number_format($realTimeMetrics['sessions_today']))
                ->description("{$realTimeMetrics['current_users']} utilisateurs en ligne maintenant")
                ->descriptionIcon('heroicon-m-users')
                ->color('primary')
                ->chart($this->getSessionsChart()),

            Stat::make('Engagement', number_format($contentStats['content_engagement']['total_likes']))
                ->description("{$contentStats['content_engagement']['total_comments']} commentaires - {$contentStats['content_engagement']['total_favorites']} favoris")
                ->descriptionIcon('heroicon-m-heart')
                ->color('danger')
                ->chart($this->getLikesChart()),

            Stat::make('Recettes', Recipe::count())
                ->description("+{$recipesThisWeek} cette semaine - " . number_format($this->getRecipeViews()) . " vues")
                ->descriptionIcon($recipesThisWeek > 0 ? 'heroicon-m-arrow-trending-up' : 'heroicon-m-cake')
                ->color('warning')
                ->chart($this->getRecipesChart()),

            Stat::make('Performance', round($realTimeMetrics['avg_session_duration_today'], 1) . 'min')
                ->description("Duree session - {$realTimeMetrics['bounce_rate_today']}% rebond")
                ->descriptionIcon('heroicon-m-clock')
                ->color('info'),

            Stat::make('Activite', number_format($realTimeMetrics['page_views_today']))
                ->description("Pages vues - +{$realTimeMetrics['new_users_today']} nouveaux utilisateurs")
                ->descriptionIcon('heroicon-m-chart-bar')
                ->color('purple'),

            Stat::make('Top Contenu', $this->getTopContentName())
                ->description($this->getTopContentViews() . ' vues - Contenu le plus populaire')
                ->descriptionIcon('heroicon-m-fire')
                ->color('orange'),

            Stat::make('En Attente', Comment::where('is_approved', false)->count())
                ->description('Commentaires a moderer - ' . Comment::count() . ' total')
                ->descriptionIcon('heroicon-m-clock')
                ->color(Comment::where('is_approved', false)->count() > 0 ? 'warning' : 'success'),
        ];
    }

    private function getUsersChart(): array
    {
        $days = [];
        for ($i = 6; $i >= 0; $i--) {
            $date = now()->subDays($i);
            $days[] = User::whereDate('created_at', $date)->count();
        }
        return $days;
    }

    private function getSessionsChart(): array
    {
        $engagementMetrics = $this->analyticsService->getEngagementMetrics();
        $dailyUsers = $engagementMetrics['daily_users_chart'] ?? [];

        if (!empty($dailyUsers['sessions'])) {
            return array_slice($dailyUsers['sessions'], -7);
        }

        // Fallback: nouveaux utilisateurs par jour
        $days = [];
        for ($i = 6; $i >= 0; $i--) {
            $days[] = User::whereDate('created_at', now()->subDays($i))->count();
        }
        return $days;
    }

    private function getLikesChart(): array
    {
        $days = [];
        for ($i = 6; $i >= 0; $i--) {
            $date = now()->subDays($i);
            $days[] = Like::whereDate('created_at', $date)->count();
        }
        return $days;
    }

    private function getRecipesChart(): array
    {
        $days = [];
        for ($i = 6; $i >= 0; $i--) {
            $date = now()->subDays($i);
            $days[] = Recipe::whereDate('created_at', $date)->count();
        }
        return $days;
    }

    private function getRecipeViews(): int
    {
        return (int) Recipe::sum('views_count');
    }

    private function getTopContentName(): string
    {
        $contentStats = $this->analyticsService->getContentStatistics();

        if (!empty($contentStats['most_viewed_content'])) {
            $topContent = $contentStats['most_viewed_content'][0];
            return substr($topContent['title'], 0, 20) . (strlen($topContent['title']) > 20 ? '...' : '');
        }

        return 'Aucun contenu';
    }

    private function getTopContentViews(): string
    {
        $contentStats = $this->analyticsService->getContentStatistics();

        if (!empty($contentStats['most_viewed_content'])) {
            return number_format($contentStats['most_viewed_content'][0]['views']);
        }

        return '0';
    }
}
