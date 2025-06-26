<?php

namespace App\Http\Controllers\PWA;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Log;

class CacheController extends Controller
{
    private const CACHE_PREFIX = 'pwa_';
    private const DEFAULT_TTL = 300; // 5 minutes

    /**
     * Configuration du cache PWA
     */
    private function getCacheConfig(): array
    {
        return [
            'recipes' => ['ttl' => 600, 'tags' => ['pwa', 'recipes']],
            'tips' => ['ttl' => 600, 'tags' => ['pwa', 'tips']],
            'events' => ['ttl' => 300, 'tags' => ['pwa', 'events']],
            'videos' => ['ttl' => 900, 'tags' => ['pwa', 'videos']],
            'categories' => ['ttl' => 1800, 'tags' => ['pwa', 'categories']],
            'homepage' => ['ttl' => 300, 'tags' => ['pwa', 'homepage']]
        ];
    }

    /**
     * Obtenir une clé de cache avec préfixe
     */
    private function getCacheKey(string $type, array $params = []): string
    {
        $key = self::CACHE_PREFIX . $type;
        if (!empty($params)) {
            ksort($params);
            $key .= '_' . md5(serialize($params));
        }
        return $key;
    }

    /**
     * Mettre en cache une réponse
     */
    public function set(Request $request)
    {
        try {
            $type = $request->input('type');
            $data = $request->input('data');
            $params = $request->input('params', []);

            if (!$type || !$data) {
                return response()->json([
                    'success' => false,
                    'message' => 'Type et data requis'
                ], 400);
            }

            $config = $this->getCacheConfig();
            $cacheConfig = $config[$type] ?? ['ttl' => self::DEFAULT_TTL, 'tags' => ['pwa']];
            
            $cacheKey = $this->getCacheKey($type, $params);
            
            // Stocker avec TTL et tags
            Cache::tags($cacheConfig['tags'])->put($cacheKey, [
                'data' => $data,
                'timestamp' => now(),
                'params' => $params
            ], $cacheConfig['ttl']);

            return response()->json([
                'success' => true,
                'message' => 'Données mises en cache',
                'cache_key' => $cacheKey,
                'ttl' => $cacheConfig['ttl']
            ]);

        } catch (\Exception $e) {
            Log::error('Erreur cache PWA set: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la mise en cache'
            ], 500);
        }
    }

    /**
     * Récupérer depuis le cache
     */
    public function get(Request $request)
    {
        try {
            $type = $request->input('type');
            $params = $request->input('params', []);

            if (!$type) {
                return response()->json([
                    'success' => false,
                    'message' => 'Type requis'
                ], 400);
            }

            $cacheKey = $this->getCacheKey($type, $params);
            $cached = Cache::get($cacheKey);

            if ($cached) {
                return response()->json([
                    'success' => true,
                    'data' => $cached['data'],
                    'cached_at' => $cached['timestamp'],
                    'from_cache' => true
                ]);
            }

            return response()->json([
                'success' => false,
                'message' => 'Non trouvé en cache'
            ], 404);

        } catch (\Exception $e) {
            Log::error('Erreur cache PWA get: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la récupération du cache'
            ], 500);
        }
    }

    /**
     * Invalider le cache par type
     */
    public function invalidate(Request $request)
    {
        try {
            $type = $request->input('type');

            if (!$type) {
                return response()->json([
                    'success' => false,
                    'message' => 'Type requis'
                ], 400);
            }

            $config = $this->getCacheConfig();
            $cacheConfig = $config[$type] ?? ['tags' => ['pwa']];

            // Invalider tous les caches avec ces tags
            Cache::tags($cacheConfig['tags'])->flush();

            return response()->json([
                'success' => true,
                'message' => "Cache {$type} invalidé"
            ]);

        } catch (\Exception $e) {
            Log::error('Erreur cache PWA invalidate: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de l\'invalidation du cache'
            ], 500);
        }
    }

    /**
     * Vider tout le cache PWA
     */
    public function clear(Request $request)
    {
        try {
            // Vider tous les caches PWA
            Cache::tags(['pwa'])->flush();

            return response()->json([
                'success' => true,
                'message' => 'Tout le cache PWA a été vidé'
            ]);

        } catch (\Exception $e) {
            Log::error('Erreur cache PWA clear: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors du vidage du cache'
            ], 500);
        }
    }

    /**
     * Statistiques du cache PWA
     */
    public function stats(Request $request)
    {
        try {
            $types = array_keys($this->getCacheConfig());
            $stats = [];

            foreach ($types as $type) {
                // Compter les clés de cache pour ce type
                $pattern = self::CACHE_PREFIX . $type . '*';
                $stats[$type] = [
                    'total_keys' => 0, // Simplified pour cette démo
                    'type' => $type
                ];
            }

            return response()->json([
                'success' => true,
                'data' => $stats,
                'timestamp' => now()
            ]);

        } catch (\Exception $e) {
            Log::error('Erreur cache PWA stats: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la récupération des statistiques'
            ], 500);
        }
    }

    /**
     * Précharger le cache pour les données essentielles
     */
    public function warmup(Request $request)
    {
        try {
            // Données essentielles à précharger
            $essentialData = [
                'recipes' => ['limit' => 4, 'sort_by' => 'created_at', 'sort_order' => 'desc'],
                'tips' => ['limit' => 4, 'sort_by' => 'created_at', 'sort_order' => 'desc'],
                'events' => ['limit' => 4, 'sort_by' => 'created_at', 'sort_order' => 'desc'],
                'videos' => ['limit' => 4, 'sort_by' => 'created_at', 'sort_order' => 'desc']
            ];

            $results = [];

            foreach ($essentialData as $type => $params) {
                // Ici on ferait normalement les appels API pour récupérer les données
                // Pour cette démo, on simule la mise en cache
                $cacheKey = $this->getCacheKey($type, $params);
                $config = $this->getCacheConfig();
                $cacheConfig = $config[$type];

                Cache::tags($cacheConfig['tags'])->put($cacheKey, [
                    'data' => [], // Serait rempli avec les vraies données
                    'timestamp' => now(),
                    'params' => $params
                ], $cacheConfig['ttl']);

                $results[$type] = 'cached';
            }

            return response()->json([
                'success' => true,
                'message' => 'Cache préchauffé',
                'data' => $results
            ]);

        } catch (\Exception $e) {
            Log::error('Erreur cache PWA warmup: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors du préchauffage du cache'
            ], 500);
        }
    }
}