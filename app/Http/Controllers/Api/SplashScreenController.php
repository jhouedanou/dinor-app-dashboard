<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\SplashScreen;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Cache;

class SplashScreenController extends Controller
{
    /**
     * Get the active splash screen configuration
     */
    public function getActive(): JsonResponse
    {
        // Cache la configuration pour 15 minutes
        $splashScreen = Cache::remember('splash_screen_active', 900, function () {
            return SplashScreen::getActive();
        });

        if (!$splashScreen) {
            // Configuration par défaut si aucune n'est définie
            return response()->json([
                'success' => true,
                'data' => [
                    'is_active' => true,
                    'title' => '',
                    'subtitle' => '',
                    'duration' => 2500,
                    'background_type' => 'gradient',
                    'background_color_start' => '#E53E3E',
                    'background_color_end' => '#C53030',
                    'background_gradient_direction' => 'top_left',
                    'logo_type' => 'default',
                    'logo_size' => 80,
                    'logo_url' => null,
                    'text_color' => '#FFFFFF',
                    'progress_bar_color' => '#F4D03F',
                    'animation_type' => 'default',
                    'background_image_url' => null,
                ]
            ]);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'is_active' => $splashScreen->is_active,
                'title' => $splashScreen->title ?? '',
                'subtitle' => $splashScreen->subtitle ?? '',
                'duration' => $splashScreen->duration ?? 2500,
                'background_type' => $splashScreen->background_type,
                'background_color_start' => $splashScreen->background_color_start,
                'background_color_end' => $splashScreen->background_color_end,
                'background_gradient_direction' => $splashScreen->background_gradient_direction,
                'logo_type' => $splashScreen->logo_type,
                'logo_size' => $splashScreen->logo_size ?? 80,
                'logo_url' => $splashScreen->logo_url,
                'text_color' => $splashScreen->text_color ?? '#FFFFFF',
                'progress_bar_color' => $splashScreen->progress_bar_color ?? '#F4D03F',
                'animation_type' => $splashScreen->animation_type ?? 'default',
                'background_image_url' => $splashScreen->background_image_url,
                'schedule_start' => $splashScreen->schedule_start,
                'schedule_end' => $splashScreen->schedule_end,
                'meta_data' => $splashScreen->meta_data,
            ]
        ]);
    }

    /**
     * Clear splash screen cache (for admin use)
     */
    public function clearCache(): JsonResponse
    {
        Cache::forget('splash_screen_active');
        
        return response()->json([
            'success' => true,
            'message' => 'Cache du splash screen vidé avec succès'
        ]);
    }
}
