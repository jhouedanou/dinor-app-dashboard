<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;

class CacheController extends Controller
{
    public function invalidate(Request $request)
    {
        // Clear Laravel cache tags
        Cache::tags(['pwa', 'recipes', 'events', 'tips'])->flush();
        
        return response()->json([
            'success' => true,
            'message' => 'Cache invalidated successfully'
        ]);
    }
    
    public function clear(Request $request)
    {
        // Clear all caches
        Cache::flush();
        
        return response()->json([
            'success' => true,
            'message' => 'All caches cleared successfully'
        ]);
    }
}