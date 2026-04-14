<?php

namespace App\Services;

use App\Models\AnalyticsEvent;
use App\Models\User;
use App\Models\Like;
use App\Models\Comment;
use App\Models\Recipe;
use App\Models\Tip;
use App\Models\Event;
use App\Models\DinorTv;
use App\Models\UserFavorite;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Log;
use Carbon\Carbon;

class FirebaseAnalyticsService
{
    private const CACHE_PREFIX = 'firebase_analytics_';
    private const CACHE_DURATION = 900; // 15 minutes

    /**
     * Récupérer les statistiques d'utilisation de l'application
     */
    public function getAppStatistics(): array
    {
        return Cache::remember(self::CACHE_PREFIX . 'app_stats', self::CACHE_DURATION, function () {
            try {
                return $this->getRealAppStatistics();
            } catch (\Exception $e) {
                Log::warning('Erreur récupération stats app: ' . $e->getMessage());
                return $this->getEmptyAppStatistics();
            }
        });
    }

    /**
     * Récupérer les statistiques de contenu
     */
    public function getContentStatistics(): array
    {
        return Cache::remember(self::CACHE_PREFIX . 'content_stats', self::CACHE_DURATION, function () {
            return $this->getRealContentStatistics();
        });
    }

    /**
     * Récupérer les métriques d'engagement utilisateur
     */
    public function getEngagementMetrics(): array
    {
        return Cache::remember(self::CACHE_PREFIX . 'engagement', self::CACHE_DURATION, function () {
            try {
                return [
                    'daily_active_users' => $this->getRealDailyActiveUsers(),
                    'session_duration' => $this->getRealSessionDurations(),
                    'user_actions' => $this->getRealUserActions(),
                    'content_interactions' => $this->getRealContentInteractions(),
                    'daily_users_chart' => $this->getDailyUsersChart(),
                ];
            } catch (\Exception $e) {
                Log::warning('Erreur récupération engagement: ' . $e->getMessage());
                return [
                    'daily_active_users' => [],
                    'session_duration' => [],
                    'user_actions' => $this->getEmptyUserActions(),
                    'content_interactions' => $this->getEmptyContentInteractions(),
                    'daily_users_chart' => ['labels' => [], 'users' => [], 'sessions' => []],
                ];
            }
        });
    }

    /**
     * Récupérer les données temps réel depuis la table analytics_events
     */
    public function getRealTimeMetrics(): array
    {
        try {
            $now = now();
            $today = $now->copy()->startOfDay();

            $currentUsers = AnalyticsEvent::where('timestamp', '>=', $now->copy()->subMinutes(5))
                ->distinct('session_id')
                ->count('session_id');

            $sessionsToday = AnalyticsEvent::where('timestamp', '>=', $today)
                ->distinct('session_id')
                ->count('session_id');

            $newUsersToday = User::whereDate('created_at', today())->count();

            $pageViewsToday = AnalyticsEvent::where('timestamp', '>=', $today)
                ->where('event_type', 'page_view')
                ->count();

            // Durée moyenne de session aujourd'hui (en minutes)
            $avgSessionDuration = $this->calculateAvgSessionDuration($today);

            // Taux de rebond (sessions avec un seul événement / total sessions)
            $bounceRate = $this->calculateBounceRate($today);

            return [
                'current_users' => $currentUsers,
                'sessions_today' => $sessionsToday,
                'new_users_today' => $newUsersToday,
                'page_views_today' => $pageViewsToday,
                'avg_session_duration_today' => round($avgSessionDuration, 1),
                'bounce_rate_today' => round($bounceRate, 1),
                'top_events_today' => $this->getTopEventsToday()
            ];
        } catch (\Exception $e) {
            Log::warning('Erreur métriques temps réel: ' . $e->getMessage());
            return [
                'current_users' => 0,
                'sessions_today' => 0,
                'new_users_today' => User::whereDate('created_at', today())->count(),
                'page_views_today' => 0,
                'avg_session_duration_today' => 0,
                'bounce_rate_today' => 0,
                'top_events_today' => []
            ];
        }
    }

    /**
     * Statistiques réelles de l'application depuis la DB
     */
    private function getRealAppStatistics(): array
    {
        $now = now();
        $totalUsers = User::count();

        $activeUsers30d = AnalyticsEvent::where('timestamp', '>=', $now->copy()->subDays(30))
            ->distinct('session_id')->count('session_id');
        $activeUsers7d = AnalyticsEvent::where('timestamp', '>=', $now->copy()->subDays(7))
            ->distinct('session_id')->count('session_id');
        $activeUsers1d = AnalyticsEvent::where('timestamp', '>=', $now->copy()->subDay())
            ->distinct('session_id')->count('session_id');

        $newUsers30d = User::where('created_at', '>=', $now->copy()->subDays(30))->count();
        $newUsers7d = User::where('created_at', '>=', $now->copy()->subDays(7))->count();
        $newUsers1d = User::whereDate('created_at', today())->count();

        $totalSessions30d = AnalyticsEvent::where('timestamp', '>=', $now->copy()->subDays(30))
            ->distinct('session_id')->count('session_id');

        $avgSessionDuration = $this->calculateAvgSessionDuration($now->copy()->subDays(30));
        $bounceRate = $this->calculateBounceRate($now->copy()->subDays(30));

        // Pages par session
        $totalPageViews30d = AnalyticsEvent::where('timestamp', '>=', $now->copy()->subDays(30))
            ->where('event_type', 'page_view')->count();
        $pagesPerSession = $totalSessions30d > 0 ? round($totalPageViews30d / $totalSessions30d, 1) : 0;

        // Taux de croissance (nouveaux utilisateurs ce mois vs mois précédent)
        $previousMonthUsers = User::whereBetween('created_at', [$now->copy()->subDays(60), $now->copy()->subDays(30)])->count();
        $growthRate = $previousMonthUsers > 0 ? round(($newUsers30d - $previousMonthUsers) / $previousMonthUsers, 2) : 0;

        // Rétention approximative basée sur les sessions récurrentes
        $retention1d = $this->calculateRetention(1);
        $retention7d = $this->calculateRetention(7);
        $retention30d = $this->calculateRetention(30);

        return [
            'total_users' => $totalUsers,
            'active_users_30d' => $activeUsers30d,
            'active_users_7d' => $activeUsers7d,
            'active_users_1d' => $activeUsers1d,
            'new_users_30d' => $newUsers30d,
            'new_users_7d' => $newUsers7d,
            'new_users_1d' => $newUsers1d,
            'total_sessions_30d' => $totalSessions30d,
            'avg_session_duration' => round($avgSessionDuration, 1),
            'bounce_rate' => round($bounceRate, 1),
            'pages_per_session' => $pagesPerSession,
            'user_retention_1d' => $retention1d,
            'user_retention_7d' => $retention7d,
            'user_retention_30d' => $retention30d,
            'growth_rate' => $growthRate,
            'last_updated' => Carbon::now()->toISOString()
        ];
    }

    /**
     * Statistiques app vides (fallback)
     */
    private function getEmptyAppStatistics(): array
    {
        $totalUsers = User::count();
        $newUsers30d = User::where('created_at', '>=', now()->subDays(30))->count();

        return [
            'total_users' => $totalUsers,
            'active_users_30d' => 0,
            'active_users_7d' => 0,
            'active_users_1d' => 0,
            'new_users_30d' => $newUsers30d,
            'new_users_7d' => User::where('created_at', '>=', now()->subDays(7))->count(),
            'new_users_1d' => User::whereDate('created_at', today())->count(),
            'total_sessions_30d' => 0,
            'avg_session_duration' => 0,
            'bounce_rate' => 0,
            'pages_per_session' => 0,
            'user_retention_1d' => 0,
            'user_retention_7d' => 0,
            'user_retention_30d' => 0,
            'growth_rate' => 0,
            'last_updated' => Carbon::now()->toISOString()
        ];
    }

    /**
     * Récupérer les vraies statistiques de contenu depuis la base de données
     */
    private function getRealContentStatistics(): array
    {
        try {
            $topRecipes = Recipe::where('is_published', true)
                ->selectRaw("title, views_count as views, likes_count, 'recipe' as type")
                ->orderByDesc('views_count')
                ->limit(3)
                ->get()
                ->toArray();

            $topTips = Tip::where('is_published', true)
                ->selectRaw("title, views_count as views, likes_count, 'tip' as type")
                ->orderByDesc('views_count')
                ->limit(2)
                ->get()
                ->toArray();

            $topEvents = Event::where('is_published', true)
                ->selectRaw("title, views_count as views, likes_count, 'event' as type")
                ->orderByDesc('views_count')
                ->limit(2)
                ->get()
                ->toArray();

            $topVideos = DinorTv::where('is_published', true)
                ->selectRaw("title, view_count as views, 0 as likes_count, 'video' as type")
                ->orderByDesc('view_count')
                ->limit(2)
                ->get()
                ->toArray();

            $mostViewedContent = array_merge($topRecipes, $topTips, $topEvents, $topVideos);

            usort($mostViewedContent, function ($a, $b) {
                return ($b['views'] ?? 0) <=> ($a['views'] ?? 0);
            });

            $withViews = array_filter($mostViewedContent, fn($item) => ($item['views'] ?? 0) > 0);
            if (!empty($withViews)) {
                $mostViewedContent = array_values($withViews);
            }

            // Vrais totaux d'engagement
            $totalLikes = Recipe::sum('likes_count') +
                         Tip::sum('likes_count') +
                         Event::sum('likes_count');

            $totalComments = Recipe::sum('comments_count') +
                           Tip::sum('comments_count') +
                           Event::sum('comments_count');

            // Vues réelles des pages depuis analytics_events
            $recipeViews = (int) Recipe::sum('views_count');
            $tipViews = (int) Tip::sum('views_count');
            $eventViews = (int) Event::sum('views_count');
            $videoViews = (int) DinorTv::sum('view_count');

            // Page views depuis analytics_events si disponibles
            $pageViewsFromAnalytics = $this->getPageViewsFromAnalytics();

            // Termes de recherche depuis analytics_events
            $searchTerms = $this->getSearchTermsFromAnalytics();

            return [
                'most_viewed_pages' => [
                    ['page' => 'Accueil', 'views' => $pageViewsFromAnalytics['home'] ?? 0, 'unique_views' => $pageViewsFromAnalytics['home_unique'] ?? 0],
                    ['page' => 'Recettes', 'views' => $recipeViews, 'unique_views' => $pageViewsFromAnalytics['recipes_unique'] ?? 0],
                    ['page' => 'Astuces', 'views' => $tipViews, 'unique_views' => $pageViewsFromAnalytics['tips_unique'] ?? 0],
                    ['page' => 'Événements', 'views' => $eventViews, 'unique_views' => $pageViewsFromAnalytics['events_unique'] ?? 0],
                    ['page' => 'Dinor TV', 'views' => $videoViews, 'unique_views' => $pageViewsFromAnalytics['videos_unique'] ?? 0]
                ],
                'most_viewed_content' => array_slice($mostViewedContent, 0, 8),
                'content_engagement' => [
                    'total_likes' => $totalLikes,
                    'total_shares' => 0,
                    'total_comments' => $totalComments,
                    'total_favorites' => UserFavorite::count(),
                    'avg_time_on_content' => 0
                ],
                'popular_search_terms' => $searchTerms
            ];
        } catch (\Exception $e) {
            Log::error('Erreur récupération statistiques contenu: ' . $e->getMessage());

            return [
                'most_viewed_pages' => [],
                'most_viewed_content' => [],
                'content_engagement' => [
                    'total_likes' => 0,
                    'total_shares' => 0,
                    'total_comments' => 0,
                    'total_favorites' => 0,
                    'avg_time_on_content' => 0
                ],
                'popular_search_terms' => []
            ];
        }
    }

    /**
     * Récupérer les page views depuis analytics_events
     */
    private function getPageViewsFromAnalytics(): array
    {
        try {
            $pageViews = AnalyticsEvent::where('event_type', 'page_view')
                ->where('timestamp', '>=', now()->subDays(30))
                ->selectRaw("page_path, COUNT(*) as views, COUNT(DISTINCT session_id) as unique_views")
                ->groupBy('page_path')
                ->get()
                ->keyBy('page_path');

            return [
                'home' => $pageViews->filter(fn($v, $k) => $k === '/' || $k === '/home' || $k === 'home')->sum('views'),
                'home_unique' => $pageViews->filter(fn($v, $k) => $k === '/' || $k === '/home' || $k === 'home')->sum('unique_views'),
                'recipes_unique' => $pageViews->filter(fn($v, $k) => str_contains($k ?? '', 'recette') || str_contains($k ?? '', 'recipe'))->sum('unique_views'),
                'tips_unique' => $pageViews->filter(fn($v, $k) => str_contains($k ?? '', 'astuce') || str_contains($k ?? '', 'tip'))->sum('unique_views'),
                'events_unique' => $pageViews->filter(fn($v, $k) => str_contains($k ?? '', 'evenement') || str_contains($k ?? '', 'event'))->sum('unique_views'),
                'videos_unique' => $pageViews->filter(fn($v, $k) => str_contains($k ?? '', 'video') || str_contains($k ?? '', 'dinor-tv'))->sum('unique_views'),
            ];
        } catch (\Exception $e) {
            return [];
        }
    }

    /**
     * Récupérer les termes de recherche depuis analytics_events
     */
    private function getSearchTermsFromAnalytics(): array
    {
        try {
            $searches = AnalyticsEvent::where('event_type', 'search')
                ->where('timestamp', '>=', now()->subDays(30))
                ->selectRaw("event_data->>'query' as term, COUNT(*) as count")
                ->groupByRaw("event_data->>'query'")
                ->orderByDesc('count')
                ->limit(10)
                ->get();

            $terms = [];
            foreach ($searches as $search) {
                if ($search->term) {
                    $terms[$search->term] = $search->count;
                }
            }

            return $terms;
        } catch (\Exception $e) {
            return [];
        }
    }

    /**
     * Utilisateurs actifs quotidiens réels (30 derniers jours)
     */
    private function getRealDailyActiveUsers(): array
    {
        $data = [];

        for ($i = 29; $i >= 0; $i--) {
            $date = Carbon::now()->subDays($i);
            $startOfDay = $date->copy()->startOfDay();
            $endOfDay = $date->copy()->endOfDay();

            $users = AnalyticsEvent::whereBetween('timestamp', [$startOfDay, $endOfDay])
                ->distinct('session_id')
                ->count('session_id');

            $sessions = AnalyticsEvent::whereBetween('timestamp', [$startOfDay, $endOfDay])
                ->distinct('session_id')
                ->count('session_id');

            $data[] = [
                'date' => $date->format('Y-m-d'),
                'users' => $users,
                'sessions' => $sessions
            ];
        }

        return $data;
    }

    /**
     * Chart données pour les 30 derniers jours (users + sessions)
     */
    private function getDailyUsersChart(): array
    {
        $labels = [];
        $users = [];
        $sessions = [];

        for ($i = 29; $i >= 0; $i--) {
            $date = Carbon::now()->subDays($i);
            $startOfDay = $date->copy()->startOfDay();
            $endOfDay = $date->copy()->endOfDay();

            $labels[] = $date->format('d/m');

            $dayUsers = AnalyticsEvent::whereBetween('timestamp', [$startOfDay, $endOfDay])
                ->distinct('session_id')
                ->count('session_id');

            $daySessions = AnalyticsEvent::whereBetween('timestamp', [$startOfDay, $endOfDay])
                ->count();

            $users[] = $dayUsers;
            $sessions[] = $daySessions;
        }

        return [
            'labels' => $labels,
            'users' => $users,
            'sessions' => $sessions
        ];
    }

    /**
     * Durées de session réelles
     */
    private function getRealSessionDurations(): array
    {
        try {
            // Calculer la durée de chaque session (diff entre premier et dernier event)
            $sessions = AnalyticsEvent::where('timestamp', '>=', now()->subDays(30))
                ->selectRaw("session_id, MIN(timestamp) as first_event, MAX(timestamp) as last_event")
                ->groupBy('session_id')
                ->get();

            $durations = ['0-30s' => 0, '30s-1m' => 0, '1-3m' => 0, '3-10m' => 0, '10m+' => 0];

            foreach ($sessions as $session) {
                $durationSeconds = Carbon::parse($session->first_event)->diffInSeconds(Carbon::parse($session->last_event));

                if ($durationSeconds <= 30) $durations['0-30s']++;
                elseif ($durationSeconds <= 60) $durations['30s-1m']++;
                elseif ($durationSeconds <= 180) $durations['1-3m']++;
                elseif ($durationSeconds <= 600) $durations['3-10m']++;
                else $durations['10m+']++;
            }

            return $durations;
        } catch (\Exception $e) {
            return ['0-30s' => 0, '30s-1m' => 0, '1-3m' => 0, '3-10m' => 0, '10m+' => 0];
        }
    }

    /**
     * Actions utilisateur réelles
     */
    private function getRealUserActions(): array
    {
        try {
            $since = now()->subDays(30);

            return [
                'page_views' => AnalyticsEvent::where('timestamp', '>=', $since)->where('event_type', 'page_view')->count(),
                'button_clicks' => AnalyticsEvent::where('timestamp', '>=', $since)->where('event_type', 'button_click')->count(),
                'form_submissions' => AnalyticsEvent::where('timestamp', '>=', $since)->where('event_type', 'form_submit')->count(),
                'downloads' => AnalyticsEvent::where('timestamp', '>=', $since)->where('event_type', 'download')->count(),
                'searches' => AnalyticsEvent::where('timestamp', '>=', $since)->where('event_type', 'search')->count(),
                'social_shares' => AnalyticsEvent::where('timestamp', '>=', $since)->where('event_type', 'share')->count(),
                'favorites_added' => UserFavorite::where('created_at', '>=', $since)->count(),
                'comments_posted' => Comment::where('created_at', '>=', $since)->count()
            ];
        } catch (\Exception $e) {
            return $this->getEmptyUserActions();
        }
    }

    private function getEmptyUserActions(): array
    {
        return [
            'page_views' => 0,
            'button_clicks' => 0,
            'form_submissions' => 0,
            'downloads' => 0,
            'searches' => 0,
            'social_shares' => 0,
            'favorites_added' => UserFavorite::count(),
            'comments_posted' => Comment::count()
        ];
    }

    /**
     * Interactions de contenu réelles
     */
    private function getRealContentInteractions(): array
    {
        try {
            $since = now()->subDays(30);

            return [
                'recipes_viewed' => (int) Recipe::sum('views_count'),
                'tips_viewed' => (int) Tip::sum('views_count'),
                'events_viewed' => (int) Event::sum('views_count'),
                'videos_watched' => (int) DinorTv::sum('view_count'),
                'content_shared' => AnalyticsEvent::where('timestamp', '>=', $since)->where('event_type', 'share')->count(),
                'content_liked' => Like::where('created_at', '>=', $since)->count(),
                'content_favorited' => UserFavorite::where('created_at', '>=', $since)->count()
            ];
        } catch (\Exception $e) {
            return $this->getEmptyContentInteractions();
        }
    }

    private function getEmptyContentInteractions(): array
    {
        return [
            'recipes_viewed' => 0,
            'tips_viewed' => 0,
            'events_viewed' => 0,
            'videos_watched' => 0,
            'content_shared' => 0,
            'content_liked' => 0,
            'content_favorited' => 0
        ];
    }

    /**
     * Récupérer les événements les plus populaires aujourd'hui
     */
    private function getTopEventsToday(): array
    {
        try {
            return AnalyticsEvent::where('timestamp', '>=', now()->startOfDay())
                ->selectRaw('event_type as event, COUNT(*) as count')
                ->groupBy('event_type')
                ->orderByDesc('count')
                ->limit(5)
                ->get()
                ->toArray();
        } catch (\Exception $e) {
            return [];
        }
    }

    /**
     * Récupérer les statistiques par plateforme depuis analytics_events
     */
    public function getPlatformStatistics(): array
    {
        try {
            $since = now()->subDays(30);

            $mobileEvents = AnalyticsEvent::where('timestamp', '>=', $since)
                ->whereNotNull('device_info')
                ->whereRaw("device_info->>'isMobile' = 'true'");

            $desktopEvents = AnalyticsEvent::where('timestamp', '>=', $since)
                ->whereNotNull('device_info')
                ->whereRaw("(device_info->>'isMobile' = 'false' OR device_info->>'isMobile' IS NULL)");

            $mobileUsers = (clone $mobileEvents)->distinct('session_id')->count('session_id');
            $mobileSessions = (clone $mobileEvents)->count();
            $desktopUsers = (clone $desktopEvents)->distinct('session_id')->count('session_id');
            $desktopSessions = (clone $desktopEvents)->count();

            $total = $mobileUsers + $desktopUsers;

            return [
                'mobile' => [
                    'users' => $mobileUsers,
                    'sessions' => $mobileSessions,
                    'percentage' => $total > 0 ? round(($mobileUsers / $total) * 100) : 0
                ],
                'desktop' => [
                    'users' => $desktopUsers,
                    'sessions' => $desktopSessions,
                    'percentage' => $total > 0 ? round(($desktopUsers / $total) * 100) : 0
                ],
                'tablet' => [
                    'users' => 0,
                    'sessions' => 0,
                    'percentage' => 0
                ]
            ];
        } catch (\Exception $e) {
            Log::warning('Erreur stats plateforme: ' . $e->getMessage());
            return [
                'mobile' => ['users' => 0, 'sessions' => 0, 'percentage' => 0],
                'desktop' => ['users' => 0, 'sessions' => 0, 'percentage' => 0],
                'tablet' => ['users' => 0, 'sessions' => 0, 'percentage' => 0]
            ];
        }
    }

    /**
     * Récupérer les statistiques géographiques depuis analytics_events (basé sur IP/locale)
     */
    public function getGeographicStatistics(): array
    {
        try {
            $since = now()->subDays(30);

            // Essayer de récupérer les infos géographiques depuis event_data ou device_info
            $countries = AnalyticsEvent::where('timestamp', '>=', $since)
                ->whereNotNull('device_info')
                ->selectRaw("device_info->>'country' as country, COUNT(DISTINCT session_id) as users, COUNT(*) as sessions")
                ->groupByRaw("device_info->>'country'")
                ->havingRaw("device_info->>'country' IS NOT NULL")
                ->orderByDesc('users')
                ->limit(5)
                ->get()
                ->toArray();

            $cities = AnalyticsEvent::where('timestamp', '>=', $since)
                ->whereNotNull('device_info')
                ->selectRaw("device_info->>'city' as city, COUNT(DISTINCT session_id) as users")
                ->groupByRaw("device_info->>'city'")
                ->havingRaw("device_info->>'city' IS NOT NULL")
                ->orderByDesc('users')
                ->limit(5)
                ->get()
                ->toArray();

            return [
                'countries' => $countries,
                'cities' => $cities
            ];
        } catch (\Exception $e) {
            Log::warning('Erreur stats géographiques: ' . $e->getMessage());
            return [
                'countries' => [],
                'cities' => []
            ];
        }
    }

    /**
     * Calculer la durée moyenne de session en minutes
     */
    private function calculateAvgSessionDuration(Carbon $since): float
    {
        try {
            $sessions = AnalyticsEvent::where('timestamp', '>=', $since)
                ->selectRaw("session_id, MIN(timestamp) as first_event, MAX(timestamp) as last_event")
                ->groupBy('session_id')
                ->havingRaw('COUNT(*) > 1')
                ->get();

            if ($sessions->isEmpty()) {
                return 0;
            }

            $totalDuration = 0;
            foreach ($sessions as $session) {
                $totalDuration += Carbon::parse($session->first_event)->diffInSeconds(Carbon::parse($session->last_event));
            }

            return ($totalDuration / $sessions->count()) / 60; // en minutes
        } catch (\Exception $e) {
            return 0;
        }
    }

    /**
     * Calculer le taux de rebond (sessions avec 1 seul événement)
     */
    private function calculateBounceRate(Carbon $since): float
    {
        try {
            $totalSessions = AnalyticsEvent::where('timestamp', '>=', $since)
                ->distinct('session_id')
                ->count('session_id');

            if ($totalSessions === 0) {
                return 0;
            }

            $bouncedSessions = AnalyticsEvent::where('timestamp', '>=', $since)
                ->selectRaw('session_id, COUNT(*) as event_count')
                ->groupBy('session_id')
                ->havingRaw('COUNT(*) = 1')
                ->get()
                ->count();

            return ($bouncedSessions / $totalSessions) * 100;
        } catch (\Exception $e) {
            return 0;
        }
    }

    /**
     * Calculer la rétention (% de sessions qui reviennent après X jours)
     */
    private function calculateRetention(int $days): int
    {
        try {
            $periodStart = now()->subDays($days * 2);
            $periodMid = now()->subDays($days);

            // Sessions de la première période
            $firstPeriodSessions = AnalyticsEvent::whereBetween('timestamp', [$periodStart, $periodMid])
                ->distinct('session_id')
                ->pluck('session_id');

            if ($firstPeriodSessions->isEmpty()) {
                return 0;
            }

            // Combien sont revenues dans la seconde période
            $returnedSessions = AnalyticsEvent::where('timestamp', '>=', $periodMid)
                ->whereIn('session_id', $firstPeriodSessions)
                ->distinct('session_id')
                ->count('session_id');

            return (int) round(($returnedSessions / $firstPeriodSessions->count()) * 100);
        } catch (\Exception $e) {
            return 0;
        }
    }

    /**
     * Vider le cache Firebase Analytics
     */
    public function clearCache(): void
    {
        $keys = [
            'app_stats',
            'content_stats',
            'engagement'
        ];

        foreach ($keys as $key) {
            Cache::forget(self::CACHE_PREFIX . $key);
        }
    }

    /**
     * Récupérer toutes les métriques pour le dashboard
     */
    public function getDashboardMetrics(): array
    {
        return [
            'app_stats' => $this->getAppStatistics(),
            'content_stats' => $this->getContentStatistics(),
            'engagement' => $this->getEngagementMetrics(),
            'realtime' => $this->getRealTimeMetrics(),
            'platforms' => $this->getPlatformStatistics(),
            'geographic' => $this->getGeographicStatistics(),
            'last_updated' => Carbon::now()->toISOString()
        ];
    }
}
