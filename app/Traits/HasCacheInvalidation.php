<?php

namespace App\Traits;

use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;
use Filament\Notifications\Notification;
use App\Traits\HasPwaRebuild;

trait HasCacheInvalidation
{
    use HasPwaRebuild;
    
    public static function invalidateCache(): void
    {
        try {
            // Clear Laravel cache tags
            Cache::tags(['pwa', 'recipes', 'events', 'tips', 'dinor-tv', 'pages'])->flush();
            
            // Also clear general cache
            Cache::forget('dashboard_data');
            Cache::forget('pwa_menu_items');
            
            // Déclencher le rebuild automatique de la PWA
            static::triggerPwaRebuild();
                
        } catch (\Exception $e) {
            Notification::make()
                ->title('Erreur lors du vidage du cache')
                ->danger()
                ->body('Une erreur s\'est produite: ' . $e->getMessage())
                ->send();
        }
    }
}