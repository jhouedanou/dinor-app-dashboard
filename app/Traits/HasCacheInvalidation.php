<?php

namespace App\Traits;

use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;
use Filament\Notifications\Notification;

trait HasCacheInvalidation
{
    public static function invalidateCache(): void
    {
        try {
            // Clear Laravel cache tags
            Cache::tags(['pwa', 'recipes', 'events', 'tips', 'dinor-tv', 'pages'])->flush();
            
            // Also clear general cache
            Cache::forget('dashboard_data');
            Cache::forget('pwa_menu_items');
            
            // Send notification
            Notification::make()
                ->title('Cache vidé avec succès')
                ->success()
                ->body('Le cache de la PWA a été invalidé. Le nouveau contenu apparaîtra immédiatement.')
                ->send();
                
        } catch (\Exception $e) {
            Notification::make()
                ->title('Erreur lors du vidage du cache')
                ->danger()
                ->body('Une erreur s\'est produite: ' . $e->getMessage())
                ->send();
        }
    }
}