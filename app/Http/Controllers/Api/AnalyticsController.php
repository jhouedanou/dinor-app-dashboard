<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\FirebaseAnalyticsService;
use App\Models\AnalyticsEvent;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Carbon\Carbon;

class AnalyticsController extends Controller
{
    protected FirebaseAnalyticsService $analyticsService;

    public function __construct(FirebaseAnalyticsService $analyticsService)
    {
        $this->analyticsService = $analyticsService;
    }

    /**
     * Récupérer toutes les statistiques pour l'API
     */
    public function index(): JsonResponse
    {
        try {
            $data = $this->analyticsService->getDashboardMetrics();
            
            return response()->json([
                'success' => true,
                'data' => $data
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => 'Erreur lors de la récupération des statistiques',
                'message' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Statistiques d'application pour l'app mobile
     */
    public function appStatistics(): JsonResponse
    {
        try {
            $stats = $this->analyticsService->getAppStatistics();
            
            return response()->json([
                'success' => true,
                'data' => $stats
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => 'Erreur lors de la récupération des statistiques d\'application',
                'message' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Statistiques de contenu pour l'app mobile
     */
    public function contentStatistics(): JsonResponse
    {
        try {
            $stats = $this->analyticsService->getContentStatistics();
            
            return response()->json([
                'success' => true,
                'data' => $stats
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => 'Erreur lors de la récupération des statistiques de contenu',
                'message' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Métriques d'engagement
     */
    public function engagementMetrics(): JsonResponse
    {
        try {
            $metrics = $this->analyticsService->getEngagementMetrics();
            
            return response()->json([
                'success' => true,
                'data' => $metrics
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => 'Erreur lors de la récupération des métriques d\'engagement',
                'message' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Métriques temps réel
     */
    public function realTimeMetrics(): JsonResponse
    {
        try {
            $metrics = $this->analyticsService->getRealTimeMetrics();
            
            return response()->json([
                'success' => true,
                'data' => $metrics
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => 'Erreur lors de la récupération des métriques temps réel',
                'message' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Statistiques par plateforme
     */
    public function platformStatistics(): JsonResponse
    {
        try {
            $stats = $this->analyticsService->getPlatformStatistics();
            
            return response()->json([
                'success' => true,
                'data' => $stats
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => 'Erreur lors de la récupération des statistiques de plateforme',
                'message' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Statistiques géographiques
     */
    public function geographicStatistics(): JsonResponse
    {
        try {
            $stats = $this->analyticsService->getGeographicStatistics();
            
            return response()->json([
                'success' => true,
                'data' => $stats
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => 'Erreur lors de la récupération des statistiques géographiques',
                'message' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Vider le cache Firebase Analytics
     */
    public function clearCache(): JsonResponse
    {
        try {
            $this->analyticsService->clearCache();
            
            return response()->json([
                'success' => true,
                'message' => 'Cache Firebase Analytics vidé avec succès'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => 'Erreur lors de la suppression du cache',
                'message' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Exporter les données analytics (pour le bouton export du widget)
     */
    public function export(Request $request)
    {
        try {
            $data = $this->analyticsService->getDashboardMetrics();
            
            // Définir les en-têtes pour le téléchargement CSV
            $filename = 'firebase_analytics_' . Carbon::now()->format('Y-m-d_H-i') . '.csv';
            
            $headers = [
                'Content-Type' => 'text/csv; charset=UTF-8',
                'Content-Disposition' => "attachment; filename=\"{$filename}\"",
            ];

            $callback = function () use ($data) {
                $file = fopen('php://output', 'w');
                
                // BOM pour UTF-8
                fputs($file, "\xEF\xBB\xBF");
                
                // En-têtes CSV
                fputcsv($file, [
                    'Métrique',
                    'Valeur',
                    'Type',
                    'Date_Export'
                ], ';');
                
                $exportDate = Carbon::now()->format('Y-m-d H:i:s');
                
                // Statistiques d'application
                if (isset($data['app_stats'])) {
                    $appStats = $data['app_stats'];
                    fputcsv($file, ['Utilisateurs Totaux', $appStats['total_users'], 'Utilisateurs', $exportDate], ';');
                    fputcsv($file, ['Utilisateurs Actifs 30j', $appStats['active_users_30d'], 'Utilisateurs', $exportDate], ';');
                    fputcsv($file, ['Utilisateurs Actifs 7j', $appStats['active_users_7d'], 'Utilisateurs', $exportDate], ';');
                    fputcsv($file, ['Sessions 30j', $appStats['total_sessions_30d'], 'Sessions', $exportDate], ';');
                    fputcsv($file, ['Durée Session Moyenne', round($appStats['avg_session_duration'], 2) . ' min', 'Performance', $exportDate], ';');
                    fputcsv($file, ['Taux de Rebond', $appStats['bounce_rate'] . '%', 'Performance', $exportDate], ';');
                }
                
                // Données temps réel
                if (isset($data['realtime'])) {
                    $realtime = $data['realtime'];
                    fputcsv($file, ['Utilisateurs Actuels', $realtime['current_users'], 'Temps Réel', $exportDate], ';');
                    fputcsv($file, ['Sessions Aujourd\'hui', $realtime['sessions_today'], 'Temps Réel', $exportDate], ';');
                    fputcsv($file, ['Nouveaux Utilisateurs', $realtime['new_users_today'], 'Temps Réel', $exportDate], ';');
                    fputcsv($file, ['Pages Vues', $realtime['page_views_today'], 'Temps Réel', $exportDate], ';');
                }
                
                // Engagement
                if (isset($data['content_stats']['content_engagement'])) {
                    $engagement = $data['content_stats']['content_engagement'];
                    fputcsv($file, ['Total Likes', $engagement['total_likes'], 'Engagement', $exportDate], ';');
                    fputcsv($file, ['Total Partages', $engagement['total_shares'], 'Engagement', $exportDate], ';');
                    fputcsv($file, ['Total Commentaires', $engagement['total_comments'], 'Engagement', $exportDate], ';');
                    fputcsv($file, ['Total Favoris', $engagement['total_favorites'], 'Engagement', $exportDate], ';');
                }
                
                // Plateformes
                if (isset($data['platforms'])) {
                    foreach ($data['platforms'] as $platform => $stats) {
                        fputcsv($file, ["Utilisateurs {$platform}", $stats['users'], 'Plateforme', $exportDate], ';');
                        fputcsv($file, ["Sessions {$platform}", $stats['sessions'], 'Plateforme', $exportDate], ';');
                        fputcsv($file, ["Pourcentage {$platform}", $stats['percentage'] . '%', 'Plateforme', $exportDate], ';');
                    }
                }
                
                fclose($file);
            };

            return response()->stream($callback, 200, $headers);
            
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => 'Erreur lors de l\'export des données',
                'message' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Recevoir un événement d'analytics depuis le frontend
     */
    public function trackEvent(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'event_type' => 'required|string|max:100',
            'timestamp' => 'required|integer',
            'session_id' => 'required|string|max:255',
            'user_id' => 'nullable|string|max:255',
            'page_path' => 'nullable|string|max:500',
            'device_info' => 'nullable|array'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            // Créer l'événement dans la base de données
            $event = AnalyticsEvent::create([
                'event_type' => $request->input('event_type'),
                'event_data' => $request->except(['event_type', 'timestamp', 'session_id', 'user_id', 'page_path', 'device_info']),
                'session_id' => $request->input('session_id'),
                'user_id' => $request->input('user_id'),
                'page_path' => $request->input('page_path'),
                'user_agent' => $request->header('User-Agent'),
                'ip_address' => $request->ip(),
                'device_info' => $request->input('device_info', []),
                'timestamp' => Carbon::createFromTimestamp($request->input('timestamp') / 1000)
            ]);

            // Log pour debugging (optionnel)
            if (config('app.debug')) {
                \Log::info('Analytics Event Tracked', [
                    'id' => $event->id,
                    'type' => $event->event_type,
                    'session' => $event->session_id,
                    'user' => $event->user_id
                ]);
            }

            return response()->json([
                'success' => true,
                'event_id' => $event->id
            ]);

        } catch (\Exception $e) {
            \Log::error('Analytics Event Tracking Failed', [
                'error' => $e->getMessage(),
                'event_type' => $request->input('event_type'),
                'session_id' => $request->input('session_id')
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to track event'
            ], 500);
        }
    }

    /**
     * Obtenir les métriques depuis la base de données
     */
    public function getDashboardMetrics(Request $request)
    {
        try {
            $period = $request->input('period', '7d'); // 1d, 7d, 30d
            $startDate = $this->getStartDate($period);

            $metrics = [
                'total_events' => AnalyticsEvent::where('timestamp', '>=', $startDate)->count(),
                'unique_sessions' => AnalyticsEvent::where('timestamp', '>=', $startDate)->distinct('session_id')->count('session_id'),
                'unique_users' => AnalyticsEvent::where('timestamp', '>=', $startDate)->whereNotNull('user_id')->distinct('user_id')->count('user_id'),
                'page_views' => AnalyticsEvent::where('timestamp', '>=', $startDate)->where('event_type', 'page_view')->count(),
                'top_events' => $this->getTopEventsFromDb($startDate, 10),
                'top_pages' => $this->getTopPagesFromDb($startDate, 10),
                'hourly_activity' => $this->getHourlyActivityFromDb($startDate),
                'device_breakdown' => $this->getDeviceBreakdownFromDb($startDate)
            ];

            return response()->json([
                'success' => true,
                'data' => $metrics,
                'period' => $period,
                'start_date' => $startDate->toISOString()
            ]);

        } catch (\Exception $e) {
            \Log::error('Analytics Dashboard Metrics Failed', [
                'error' => $e->getMessage()
            ]);

            // Fallback vers les données simulées Firebase
            return response()->json([
                'success' => true,
                'data' => $this->analyticsService->getDashboardMetrics(),
                'source' => 'firebase_simulation'
            ]);
        }
    }

    /**
     * Obtenir les statistiques en temps réel depuis la DB
     */
    public function getRealTimeMetrics()
    {
        try {
            $now = now();
            $lastHour = $now->copy()->subHour();
            $today = $now->copy()->startOfDay();

            $metrics = [
                'current_active_sessions' => AnalyticsEvent::where('timestamp', '>=', $now->copy()->subMinutes(30))->distinct('session_id')->count('session_id'),
                'events_last_hour' => AnalyticsEvent::where('timestamp', '>=', $lastHour)->count(),
                'page_views_today' => AnalyticsEvent::where('timestamp', '>=', $today)->where('event_type', 'page_view')->count(),
                'unique_visitors_today' => AnalyticsEvent::where('timestamp', '>=', $today)->distinct('session_id')->count('session_id'),
                'top_events_now' => $this->getTopEventsFromDb($lastHour, 5),
                'latest_activities' => $this->getLatestActivitiesFromDb(20)
            ];

            return response()->json([
                'success' => true,
                'data' => $metrics,
                'timestamp' => $now->toISOString()
            ]);

        } catch (\Exception $e) {
            \Log::error('Analytics Real-time Metrics Failed', [
                'error' => $e->getMessage()
            ]);

            // Fallback vers Firebase
            return response()->json([
                'success' => true,
                'data' => $this->analyticsService->getRealTimeMetrics(),
                'source' => 'firebase_simulation'
            ]);
        }
    }

    // Méthodes privées pour les requêtes DB
    private function getStartDate($period)
    {
        switch ($period) {
            case '1d':
                return now()->subDay();
            case '7d':
                return now()->subWeek();
            case '30d':
                return now()->subMonth();
            default:
                return now()->subWeek();
        }
    }

    private function getTopEventsFromDb($startDate, $limit = 10)
    {
        return AnalyticsEvent::selectRaw('event_type, COUNT(*) as count')
            ->where('timestamp', '>=', $startDate)
            ->groupBy('event_type')
            ->orderBy('count', 'desc')
            ->limit($limit)
            ->get()
            ->toArray();
    }

    private function getTopPagesFromDb($startDate, $limit = 10)
    {
        return AnalyticsEvent::selectRaw('page_path, COUNT(*) as views')
            ->where('timestamp', '>=', $startDate)
            ->where('event_type', 'page_view')
            ->whereNotNull('page_path')
            ->groupBy('page_path')
            ->orderBy('views', 'desc')
            ->limit($limit)
            ->get()
            ->toArray();
    }

    private function getHourlyActivityFromDb($startDate)
    {
        return AnalyticsEvent::selectRaw('EXTRACT(hour FROM timestamp) as hour, COUNT(*) as events')
            ->where('timestamp', '>=', $startDate)
            ->groupByRaw('EXTRACT(hour FROM timestamp)')
            ->orderBy('hour')
            ->get()
            ->toArray();
    }

    private function getDeviceBreakdownFromDb($startDate)
    {
        return AnalyticsEvent::selectRaw('device_info->>\'isMobile\' as is_mobile, COUNT(*) as count')
            ->where('timestamp', '>=', $startDate)
            ->whereNotNull('device_info')
            ->groupByRaw('device_info->>\'isMobile\'')
            ->get()
            ->toArray();
    }

    private function getLatestActivitiesFromDb($limit = 20)
    {
        return AnalyticsEvent::select('event_type', 'page_path', 'session_id', 'user_id', 'timestamp')
            ->orderBy('timestamp', 'desc')
            ->limit($limit)
            ->get()
            ->toArray();
    }

    /**
     * Informations sur l'API Analytics
     */
    public function info(): JsonResponse
    {
        return response()->json([
            'success' => true,
            'data' => [
                'service' => 'Firebase Analytics API',
                'version' => '1.0.0',
                'endpoints' => [
                    'GET /api/v1/analytics' => 'Toutes les statistiques',
                    'GET /api/v1/analytics/app-statistics' => 'Statistiques d\'application',
                    'GET /api/v1/analytics/content-statistics' => 'Statistiques de contenu',
                    'GET /api/v1/analytics/engagement' => 'Métriques d\'engagement',
                    'GET /api/v1/analytics/realtime' => 'Données temps réel',
                    'GET /api/v1/analytics/platforms' => 'Statistiques par plateforme',
                    'GET /api/v1/analytics/geographic' => 'Statistiques géographiques',
                    'POST /api/v1/analytics/clear-cache' => 'Vider le cache',
                    'GET /api/v1/analytics/export' => 'Exporter les données CSV',
                    'POST /api/analytics/event' => 'Enregistrer un événement'
                ],
                'cache_duration' => '15 minutes',
                'last_updated' => Carbon::now()->toISOString()
            ]
        ]);
    }
}