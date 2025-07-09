<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Auth;

class CacheMatches
{
    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next, $cacheTime = 300)
    {
        // Only cache GET requests
        if ($request->method() !== 'GET') {
            return $next($request);
        }

        // Generate cache key based on route, parameters, and user auth state
        $cacheKey = $this->generateCacheKey($request);
        
        // Check if we have cached response
        $cachedResponse = Cache::get($cacheKey);
        
        if ($cachedResponse) {
            return response()->json($cachedResponse)
                ->header('X-Cache', 'HIT')
                ->header('Cache-Control', 'public, max-age=' . $cacheTime);
        }

        // Process request
        $response = $next($request);
        
        // Only cache successful JSON responses
        if ($response->isSuccessful() && 
            $response->headers->get('Content-Type') === 'application/json') {
            
            $data = json_decode($response->getContent(), true);
            
            if (isset($data['success']) && $data['success']) {
                // Cache for specified time (default 5 minutes)
                Cache::put($cacheKey, $data, (int)$cacheTime);
                
                $response->header('X-Cache', 'MISS');
            }
        }
        
        $response->header('Cache-Control', 'public, max-age=' . $cacheTime);
        
        return $response;
    }

    /**
     * Generate cache key for the request
     */
    private function generateCacheKey(Request $request): string
    {
        $parts = [
            'matches',
            $request->path(),
            md5($request->getQueryString() ?? ''),
            Auth::check() ? 'auth_' . Auth::id() : 'guest'
        ];

        return implode('_', array_filter($parts));
    }

    /**
     * Clear cache for matches
     */
    public static function clearMatchesCache(): void
    {
        $patterns = [
            'matches_*',
            'tournament_matches_*',
            'user_prediction_*'
        ];

        foreach ($patterns as $pattern) {
            Cache::flush(); // For simplicity, we flush all cache
            // In production, you might want to use Redis with pattern-based deletion
        }
    }
} 