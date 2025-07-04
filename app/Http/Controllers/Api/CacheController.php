<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Log;

class CacheController extends Controller
{
    /**
     * Récupérer une valeur du cache PWA
     */
    public function get(Request $request): JsonResponse
    {
        try {
            $key = $request->input('key');
            
            if (!$key) {
                return response()->json([
                    'success' => false,
                    'message' => 'Cache key is required'
                ], 400);
            }
            
            $value = Cache::get($key);
            
            return response()->json([
                'success' => true,
                'data' => $value,
                'cached' => $value !== null
            ]);
            
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error retrieving cache',
                'error' => $e->getMessage()
            ], 500);
        }
    }
    
    /**
     * Définir une valeur dans le cache PWA
     */
    public function set(Request $request): JsonResponse
    {
        try {
            $key = $request->input('key');
            $value = $request->input('value');
            $ttl = $request->input('ttl', 3600); // 1 heure par défaut
            
            if (!$key || $value === null) {
                return response()->json([
                    'success' => false,
                    'message' => 'Key and value are required'
                ], 400);
            }
            
            Cache::put($key, $value, $ttl);
            
            return response()->json([
                'success' => true,
                'message' => 'Value cached successfully',
                'key' => $key,
                'ttl' => $ttl
            ]);
            
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error setting cache',
                'error' => $e->getMessage()
            ], 500);
        }
    }
    
    /**
     * Invalider le cache PWA
     */
    public function invalidate(Request $request): JsonResponse
    {
        try {
            $pattern = $request->input('pattern', '');
            
            if ($pattern) {
                // Invalider les clés qui correspondent au pattern
                $keys = Cache::get('pwa_cache_keys', []);
                $keysToRemove = array_filter($keys, function($key) use ($pattern) {
                    return str_contains($key, $pattern);
                });
                
                foreach ($keysToRemove as $key) {
                    Cache::forget($key);
                }
                
                return response()->json([
                    'success' => true,
                    'message' => 'Cache invalidated for pattern: ' . $pattern,
                    'invalidated_keys' => count($keysToRemove)
                ]);
            } else {
                // Vider tout le cache
                Cache::flush();
                
                return response()->json([
                    'success' => true,
                    'message' => 'All cache cleared'
                ]);
            }
            
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error invalidating cache',
                'error' => $e->getMessage()
            ], 500);
        }
    }
    
    /**
     * Vider tout le cache
     */
    public function clear(Request $request): JsonResponse
    {
        try {
            Cache::flush();
            
            return response()->json([
                'success' => true,
                'message' => 'All cache cleared successfully'
            ]);
            
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error clearing cache',
                'error' => $e->getMessage()
            ], 500);
        }
    }
    
    /**
     * Obtenir les statistiques du cache
     */
    public function stats(Request $request): JsonResponse
    {
        try {
            $stats = [
                'driver' => config('cache.default'),
                'prefix' => config('cache.prefix'),
                'stores' => array_keys(config('cache.stores')),
                'timestamp' => now()->toISOString()
            ];
            
            return response()->json([
                'success' => true,
                'stats' => $stats
            ]);
            
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la récupération des statistiques',
                'error' => $e->getMessage()
            ], 500);
        }
    }
    
    /**
     * Précharger le cache avec des données essentielles
     */
    public function warmup(Request $request): JsonResponse
    {
        try {
            // Précharger les données principales
            Cache::remember('pwa_recipes', 3600, function () {
                return \App\Models\Recipe::published()->limit(20)->get();
            });
            
            Cache::remember('pwa_events', 3600, function () {
                return \App\Models\Event::published()->limit(20)->get();
            });
            
            Cache::remember('pwa_tips', 3600, function () {
                return \App\Models\Tip::published()->limit(20)->get();
            });
            
            return response()->json([
                'success' => true,
                'message' => 'Cache warmed up successfully'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error warming up cache',
                'error' => $e->getMessage()
            ], 500);
        }
    }
    
    /**
     * Obtenir l'état du cache et les invalidations récentes
     */
    public function getStatus(Request $request): JsonResponse
    {
        try {
            $status = [
                'pwa_version' => Cache::get('pwa_version'),
                'last_invalidation' => Cache::get('pwa_cache_invalidation'),
                'content_invalidations' => [
                    'recipes' => Cache::get('pwa_invalidation_recipes'),
                    'events' => Cache::get('pwa_invalidation_events'),
                    'tips' => Cache::get('pwa_invalidation_tips'),
                    'dinor-tv' => Cache::get('pwa_invalidation_dinor-tv'),
                ],
                'cache_driver' => config('cache.default'),
                'timestamp' => time()
            ];
            
            return response()->json([
                'success' => true,
                'data' => $status
            ]);
            
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error getting cache status',
                'error' => $e->getMessage()
            ], 500);
        }
    }
    
    /**
     * Invalider le cache pour un type de contenu spécifique
     */
    public function invalidateContent(Request $request): JsonResponse
    {
        try {
            $contentTypes = $request->input('content_types', []);
            $patterns = $request->input('patterns', []);
            
            $invalidated = [];
            
            // Invalider par type de contenu
            foreach ($contentTypes as $type) {
                $pattern = $this->getPatternForContentType($type);
                if ($pattern) {
                    $this->invalidateCachePattern($pattern);
                    $invalidated[] = $type;
                }
            }
            
            // Invalider par patterns spécifiques
            foreach ($patterns as $pattern) {
                $this->invalidateCachePattern($pattern);
                $invalidated[] = $pattern;
            }
            
            // Si aucun type spécifié, invalider tout
            if (empty($contentTypes) && empty($patterns)) {
                $this->invalidateAllCache();
                $invalidated[] = 'all';
            }
            
            Log::info('Cache PWA invalidé', [
                'content_types' => $contentTypes,
                'patterns' => $patterns,
                'invalidated' => $invalidated
            ]);
            
            return response()->json([
                'success' => true,
                'message' => 'Cache invalidé avec succès',
                'invalidated' => $invalidated
            ]);
            
        } catch (\Exception $e) {
            Log::error('Erreur lors de l\'invalidation du cache PWA', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);
            
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de l\'invalidation du cache',
                'error' => $e->getMessage()
            ], 500);
        }
    }
    
    /**
     * Vider complètement le cache PWA
     */
    public function clearAll(Request $request): JsonResponse
    {
        try {
            $this->invalidateAllCache();
            
            Log::info('Cache PWA complètement vidé');
            
            return response()->json([
                'success' => true,
                'message' => 'Cache complètement vidé'
            ]);
            
        } catch (\Exception $e) {
            Log::error('Erreur lors du vidage du cache PWA', [
                'error' => $e->getMessage()
            ]);
            
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors du vidage du cache',
                'error' => $e->getMessage()
            ], 500);
        }
    }
    
    /**
     * Obtenir le pattern de cache pour un type de contenu
     */
    private function getPatternForContentType(string $type): ?string
    {
        $patterns = [
            'recipes' => '/api/v1/recipes',
            'tips' => '/api/v1/tips',
            'events' => '/api/v1/events',
            'videos' => '/api/v1/dinor-tv',
            'categories' => '/api/v1/categories',
            'users' => '/api/v1/users',
            'comments' => '/api/v1/comments',
            'likes' => '/api/v1/likes',
            'banners' => '/api/v1/banners'
        ];
        
        return $patterns[$type] ?? null;
    }
    
    /**
     * Invalider le cache pour un pattern donné
     */
    private function invalidateCachePattern(string $pattern): void
    {
        // Si on utilise Redis avec des tags
        if (config('cache.default') === 'redis') {
            try {
                Cache::tags($pattern)->flush();
            } catch (\Exception $e) {
                // Fallback : vider tout le cache
                Cache::flush();
            }
        } else {
            // Pour les autres drivers, on ne peut pas invalider par pattern
            // On vide tout le cache
            Cache::flush();
        }
        
        Log::info("Cache invalidé pour le pattern: {$pattern}");
    }
    
    /**
     * Invalider tout le cache
     */
    private function invalidateAllCache(): void
    {
        Cache::flush();
        Log::info('Tout le cache a été invalidé');
    }
}