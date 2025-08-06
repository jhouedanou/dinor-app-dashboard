<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\FirebaseAnalyticsService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
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
                    'GET /api/v1/analytics/export' => 'Exporter les données CSV'
                ],
                'cache_duration' => '15 minutes',
                'last_updated' => Carbon::now()->toISOString()
            ]
        ]);
    }
}