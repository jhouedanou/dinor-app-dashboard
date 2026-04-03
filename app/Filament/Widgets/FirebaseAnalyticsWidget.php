<?php

namespace App\Filament\Widgets;

use App\Services\FirebaseAnalyticsService;
use Filament\Widgets\Widget;
use Carbon\Carbon;

class FirebaseAnalyticsWidget extends Widget
{
    protected static string $view = 'filament.widgets.firebase-analytics';
    
    protected static ?int $sort = 1; // Premier dans la liste, remplace les pronostics
    
    protected static ?string $heading = '📊 Statistiques Firebase Analytics';
    
    protected int | string | array $columnSpan = 'full';
    
    // Refresh toutes les 5 minutes
    protected static ?string $pollingInterval = '5m';

    protected FirebaseAnalyticsService $analyticsService;

    public function __construct()
    {
        $this->analyticsService = new FirebaseAnalyticsService();
    }

    public function getViewData(): array
    {
        return [
            'dashboardMetrics' => $this->getDashboardMetrics(),
            'appStats' => $this->getAppStatistics(),
            'contentStats' => $this->getContentStatistics(),
            'engagementMetrics' => $this->getEngagementMetrics(),
            'realTimeMetrics' => $this->getRealTimeMetrics(),
            'platformStats' => $this->getPlatformStatistics(),
            'geographicStats' => $this->getGeographicStatistics(),
            'trends' => $this->getTrends(),
            'topContent' => $this->getTopContent()
        ];
    }

    private function getDashboardMetrics(): array
    {
        return $this->analyticsService->getDashboardMetrics();
    }

    private function getAppStatistics(): array
    {
        $stats = $this->analyticsService->getAppStatistics();
        
        return [
            'overview' => [
                'total_users' => $stats['total_users'],
                'active_users_30d' => $stats['active_users_30d'],
                'active_users_7d' => $stats['active_users_7d'],
                'active_users_1d' => $stats['active_users_1d'],
                'growth_rate' => $stats['growth_rate']
            ],
            'new_users' => [
                'monthly' => $stats['new_users_30d'],
                'weekly' => $stats['new_users_7d'],
                'daily' => $stats['new_users_1d']
            ],
            'sessions' => [
                'total_30d' => $stats['total_sessions_30d'],
                'avg_duration' => $stats['avg_session_duration'],
                'bounce_rate' => $stats['bounce_rate'],
                'pages_per_session' => $stats['pages_per_session']
            ],
            'retention' => [
                '1_day' => $stats['user_retention_1d'],
                '7_days' => $stats['user_retention_7d'],
                '30_days' => $stats['user_retention_30d']
            ]
        ];
    }

    private function getContentStatistics(): array
    {
        $stats = $this->analyticsService->getContentStatistics();
        
        return [
            'top_pages' => $stats['most_viewed_pages'],
            'top_content' => $stats['most_viewed_content'],
            'engagement' => $stats['content_engagement'],
            'search_terms' => $stats['popular_search_terms']
        ];
    }

    private function getEngagementMetrics(): array
    {
        $metrics = $this->analyticsService->getEngagementMetrics();
        
        return [
            'daily_users_chart' => $this->formatChartData($metrics['daily_active_users']),
            'session_durations' => $metrics['session_duration'],
            'user_actions' => $metrics['user_actions'],
            'content_interactions' => $metrics['content_interactions']
        ];
    }

    private function getRealTimeMetrics(): array
    {
        return $this->analyticsService->getRealTimeMetrics();
    }

    private function getPlatformStatistics(): array
    {
        return $this->analyticsService->getPlatformStatistics();
    }

    private function getGeographicStatistics(): array
    {
        return $this->analyticsService->getGeographicStatistics();
    }

    private function getTrends(): array
    {
        $appStats = $this->analyticsService->getAppStatistics();
        $engagementMetrics = $this->analyticsService->getEngagementMetrics();

        // Calculer les tendances réelles basées sur les données
        $userActions = $engagementMetrics['user_actions'] ?? [];
        $contentInteractions = $engagementMetrics['content_interactions'] ?? [];

        // Tendance sessions: comparer les sessions des 7 derniers jours vs 7 jours précédents
        $sessionsGrowth = $this->calculateRealGrowth('sessions');
        $engagementGrowth = $this->calculateRealGrowth('engagement');
        $contentGrowth = $this->calculateRealGrowth('content');

        return [
            'users_trend' => $this->calculateTrend('users', $appStats['growth_rate']),
            'sessions_trend' => $this->calculateTrend('sessions', $sessionsGrowth),
            'engagement_trend' => $this->calculateTrend('engagement', $engagementGrowth),
            'content_trend' => $this->calculateTrend('content', $contentGrowth)
        ];
    }

    private function calculateRealGrowth(string $metric): float
    {
        try {
            $now = now();
            $currentPeriod = $now->copy()->subDays(7);
            $previousPeriod = $now->copy()->subDays(14);

            switch ($metric) {
                case 'sessions':
                    $current = \App\Models\AnalyticsEvent::where('timestamp', '>=', $currentPeriod)
                        ->distinct('session_id')->count('session_id');
                    $previous = \App\Models\AnalyticsEvent::whereBetween('timestamp', [$previousPeriod, $currentPeriod])
                        ->distinct('session_id')->count('session_id');
                    break;
                case 'engagement':
                    $current = \App\Models\Like::where('created_at', '>=', $currentPeriod)->count()
                        + \App\Models\Comment::where('created_at', '>=', $currentPeriod)->count();
                    $previous = \App\Models\Like::whereBetween('created_at', [$previousPeriod, $currentPeriod])->count()
                        + \App\Models\Comment::whereBetween('created_at', [$previousPeriod, $currentPeriod])->count();
                    break;
                case 'content':
                    $current = \App\Models\AnalyticsEvent::where('timestamp', '>=', $currentPeriod)
                        ->where('event_type', 'page_view')->count();
                    $previous = \App\Models\AnalyticsEvent::whereBetween('timestamp', [$previousPeriod, $currentPeriod])
                        ->where('event_type', 'page_view')->count();
                    break;
                default:
                    return 0;
            }

            if ($previous === 0) {
                return $current > 0 ? 1.0 : 0;
            }

            return round(($current - $previous) / $previous, 2);
        } catch (\Exception $e) {
            return 0;
        }
    }

    private function getTopContent(): array
    {
        $contentStats = $this->analyticsService->getContentStatistics();
        
        return [
            'recipes' => array_filter($contentStats['most_viewed_content'], fn($item) => $item['type'] === 'recipe'),
            'tips' => array_filter($contentStats['most_viewed_content'], fn($item) => $item['type'] === 'tip'),
            'events' => array_filter($contentStats['most_viewed_content'], fn($item) => $item['type'] === 'event'),
            'videos' => array_filter($contentStats['most_viewed_content'], fn($item) => $item['type'] === 'video')
        ];
    }

    private function formatChartData(array $dailyUsers): array
    {
        return [
            'labels' => array_map(fn($item) => Carbon::parse($item['date'])->format('d/m'), $dailyUsers),
            'users' => array_map(fn($item) => $item['users'], $dailyUsers),
            'sessions' => array_map(fn($item) => $item['sessions'], $dailyUsers)
        ];
    }

    private function calculateTrend(string $metric, float $growthRate): array
    {
        $isPositive = $growthRate > 0;
        $percentage = abs($growthRate * 100);
        
        return [
            'direction' => $isPositive ? 'up' : 'down',
            'percentage' => round($percentage, 1),
            'icon' => $isPositive ? 'heroicon-m-arrow-trending-up' : 'heroicon-m-arrow-trending-down',
            'color' => $isPositive ? 'success' : 'danger',
            'description' => $this->getTrendDescription($metric, $isPositive, $percentage)
        ];
    }

    private function getTrendDescription(string $metric, bool $isPositive, float $percentage): string
    {
        $direction = $isPositive ? 'hausse' : 'baisse';
        $period = 'ce mois';
        
        return match($metric) {
            'users' => "Utilisateurs en {$direction} de {$percentage}% {$period}",
            'sessions' => "Sessions en {$direction} de {$percentage}% {$period}",
            'engagement' => "Engagement en {$direction} de {$percentage}% {$period}",
            'content' => "Consultations en {$direction} de {$percentage}% {$period}",
            default => "{$direction} de {$percentage}% {$period}"
        };
    }

    /**
     * Actions disponibles pour ce widget
     */
    protected function getHeaderActions(): array
    {
        return [
            \Filament\Actions\Action::make('refresh')
                ->label('Actualiser')
                ->icon('heroicon-m-arrow-path')
                ->action(function () {
                    $this->analyticsService->clearCache();
                    $this->dispatch('$refresh');
                }),
            
            \Filament\Actions\Action::make('export')
                ->label('Exporter')
                ->icon('heroicon-m-arrow-down-tray')
                ->url(route('admin.analytics.export'))
                ->openUrlInNewTab(),
        ];
    }

    /**
     * Récupérer les insights automatiques
     */
    public function getInsights(): array
    {
        $appStats = $this->analyticsService->getAppStatistics();
        $contentStats = $this->analyticsService->getContentStatistics();
        $realTime = $this->analyticsService->getRealTimeMetrics();
        
        $insights = [];
        
        // Insight sur la croissance
        if ($appStats['growth_rate'] > 0.1) {
            $insights[] = [
                'type' => 'success',
                'title' => 'Croissance forte',
                'message' => "L'application connaît une croissance de {$appStats['growth_rate']}% ce mois.",
                'icon' => 'heroicon-m-arrow-trending-up'
            ];
        }
        
        // Insight sur l'engagement
        if ($realTime['avg_session_duration_today'] > 5) {
            $insights[] = [
                'type' => 'info',
                'title' => 'Engagement élevé',
                'message' => "Durée de session moyenne élevée: {$realTime['avg_session_duration_today']} min.",
                'icon' => 'heroicon-m-clock'
            ];
        }
        
        // Insight sur le contenu populaire
        $topContent = $contentStats['most_viewed_content'][0] ?? null;
        if ($topContent && $topContent['views'] > 400) {
            $insights[] = [
                'type' => 'warning',
                'title' => 'Contenu viral',
                'message' => "'{$topContent['title']}' génère {$topContent['views']} vues.",
                'icon' => 'heroicon-m-fire'
            ];
        }
        
        return $insights;
    }

    /**
     * Récupérer les alertes importantes
     */
    public function getAlerts(): array
    {
        $realTime = $this->analyticsService->getRealTimeMetrics();
        $alerts = [];
        
        // Alerte trafic élevé
        if ($realTime['current_users'] > 70) {
            $alerts[] = [
                'type' => 'info',
                'message' => "Trafic élevé: {$realTime['current_users']} utilisateurs actifs",
                'icon' => 'heroicon-m-users'
            ];
        }
        
        // Alerte bounce rate
        if ($realTime['bounce_rate_today'] > 50) {
            $alerts[] = [
                'type' => 'warning',
                'message' => "Taux de rebond élevé: {$realTime['bounce_rate_today']}%",
                'icon' => 'heroicon-m-exclamation-triangle'
            ];
        }
        
        return $alerts;
    }
}