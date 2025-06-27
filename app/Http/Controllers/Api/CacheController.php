<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Illuminate\Http\JsonResponse;

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
            
            if (!$key) {
                return response()->json([
                    'success' => false,
                    'message' => 'Cache key is required'
                ], 400);
            }
            
            Cache::put($key, $value, $ttl);
            
            return response()->json([
                'success' => true,
                'message' => 'Cache set successfully',
                'key' => $key
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
            // Clear specific cache keys
            $keys = [
                'pwa_recipes',
                'pwa_events', 
                'pwa_tips',
                'pwa_banners_recipes',
                'pwa_banners_events',
                'pwa_banners_tips'
            ];
            
            foreach ($keys as $key) {
                Cache::forget($key);
            }
            
            return response()->json([
                'success' => true,
                'message' => 'Cache invalidated successfully'
            ]);
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
            // Clear all caches
            Cache::flush();
            
            return response()->json([
                'success' => true,
                'message' => 'All caches cleared successfully'
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
     * Statistiques du cache
     */
    public function stats(Request $request): JsonResponse
    {
        try {
            return response()->json([
                'success' => true,
                'data' => [
                    'cache_driver' => config('cache.default'),
                    'timestamp' => now()->toISOString()
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error retrieving cache stats',
                'error' => $e->getMessage()
            ], 500);
        }
    }
    
    /**
     * Préchargement du cache
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
}