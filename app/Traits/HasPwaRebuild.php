<?php

namespace App\Traits;

use Illuminate\Support\Facades\Process;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Cache;
use Filament\Notifications\Notification;

trait HasPwaRebuild
{
    /**
     * Déclenche un rebuild automatique de la PWA
     */
    public static function triggerPwaRebuild(): void
    {
        try {
            // 1. Mettre à jour la version PWA pour forcer le cache busting
            static::updatePwaVersion();
            
            // 2. Vider les caches côté serveur
            static::clearServerCaches();
            
            // 3. Invalider le cache PWA côté client
            static::invalidatePwaCache();
            
            // 4. En production, déclencher le rebuild en arrière-plan
            if (app()->environment('production')) {
                static::triggerProductionRebuild();
            } else {
                // En développement, juste vider les caches
                static::clearDevCaches();
            }
            
            // 5. Notification de succès
            Notification::make()
                ->title('PWA mise à jour')
                ->success()
                ->body('La PWA sera mise à jour dans quelques minutes. Les utilisateurs verront les changements au prochain rafraîchissement.')
                ->persistent()
                ->send();
                
        } catch (\Exception $e) {
            Log::error('Erreur lors du rebuild PWA: ' . $e->getMessage());
            
            Notification::make()
                ->title('Erreur de mise à jour PWA')
                ->danger()
                ->body('Une erreur s\'est produite lors de la mise à jour de la PWA. Vérifiez les logs.')
                ->send();
        }
    }
    
    /**
     * Met à jour la version PWA pour forcer le cache busting
     */
    private static function updatePwaVersion(): void
    {
        $versionFile = public_path('pwa/version.txt');
        $newVersion = time();
        
        file_put_contents($versionFile, $newVersion);
        
        // Mettre à jour aussi le fichier .env PWA
        $envFile = public_path('pwa/.env');
        file_put_contents($envFile, "PWA_VERSION={$newVersion}\nLAST_UPDATE=" . date('Y-m-d H:i:s'));
        
        // Mettre à jour la version dans le cache pour les clients
        Cache::put('pwa_version', $newVersion, 3600);
    }
    
    /**
     * Vide les caches côté serveur
     */
    private static function clearServerCaches(): void
    {
        try {
            // Vider les caches Laravel avec tags
            Cache::tags(['pwa', 'recipes', 'events', 'tips', 'dinor-tv', 'pages'])->flush();
            
            // Vider le cache général
            Cache::forget('dashboard_data');
            Cache::forget('pwa_menu_items');
            Cache::forget('api_recipes_cache');
            Cache::forget('api_events_cache');
            Cache::forget('api_tips_cache');
            
            Log::info('Caches serveur vidés avec succès');
        } catch (\Exception $e) {
            Log::warning('Impossible de vider les caches avec tags: ' . $e->getMessage());
            // Fallback: vider le cache général
            Cache::flush();
        }
    }
    
    /**
     * Invalider le cache PWA côté client
     */
    private static function invalidatePwaCache(): void
    {
        // Créer un endpoint pour notifier les clients PWA
        $invalidationData = [
            'timestamp' => time(),
            'version' => Cache::get('pwa_version', time()),
            'message' => 'Cache invalidation triggered'
        ];
        
        Cache::put('pwa_cache_invalidation', $invalidationData, 300); // 5 minutes
        
        Log::info('Cache PWA invalidation triggered', $invalidationData);
    }
    
    /**
     * Déclenche le rebuild en production (en arrière-plan)
     */
    private static function triggerProductionRebuild(): void
    {
        Process::path(base_path())
            ->timeout(300)
            ->start('./rebuild-pwa.sh');
    }
    
    /**
     * Vide les caches en développement
     */
    private static function clearDevCaches(): void
    {
        Process::path(base_path())
            ->timeout(60)
            ->start('npm run pwa:clear-cache');
    }
    
    /**
     * Invalider le cache pour un type de contenu spécifique
     */
    public static function invalidateContentCache(string $contentType): void
    {
        try {
            // Invalider le cache serveur
            Cache::tags(['pwa', $contentType])->flush();
            
            // Marquer l'invalidation pour les clients PWA
            $invalidationData = [
                'type' => $contentType,
                'timestamp' => time(),
                'action' => 'content_updated'
            ];
            
            Cache::put("pwa_invalidation_{$contentType}", $invalidationData, 300);
            
            Log::info("Cache invalidé pour le type: {$contentType}");
            
        } catch (\Exception $e) {
            Log::error("Erreur lors de l'invalidation du cache pour {$contentType}: " . $e->getMessage());
        }
    }
}