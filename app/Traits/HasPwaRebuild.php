<?php

namespace App\Traits;

use Illuminate\Support\Facades\Process;
use Illuminate\Support\Facades\Log;
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
            
            // 3. En production, déclencher le rebuild en arrière-plan
            if (app()->environment('production')) {
                static::triggerProductionRebuild();
            } else {
                // En développement, juste vider les caches
                static::clearDevCaches();
            }
            
            // 4. Notification de succès
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
    }
    
    /**
     * Vide les caches côté serveur
     */
    private static function clearServerCaches(): void
    {
        // Vider les caches Laravel
        \Illuminate\Support\Facades\Cache::tags(['pwa', 'recipes', 'events', 'tips', 'dinor-tv', 'pages'])->flush();
        
        // Vider le cache général
        \Illuminate\Support\Facades\Cache::forget('dashboard_data');
        \Illuminate\Support\Facades\Cache::forget('pwa_menu_items');
    }
    
    /**
     * Déclenche le rebuild en production (en arrière-plan)
     */
    private static function triggerProductionRebuild(): void
    {
        // Créer un job en arrière-plan pour rebuilder la PWA
        $command = 'cd ' . base_path() . ' && ./rebuild-pwa.sh > /dev/null 2>&1 &';
        
        if (function_exists('exec')) {
            exec($command);
        } else {
            // Fallback: utiliser Process Laravel
            Process::path(base_path())
                ->timeout(300) // 5 minutes timeout
                ->run('./rebuild-pwa.sh');
        }
    }
    
    /**
     * Vide les caches en développement
     */
    private static function clearDevCaches(): void
    {
        // En développement, juste vider les caches
        if (function_exists('exec')) {
            exec('cd ' . base_path() . ' && npm run pwa:clear-cache 2>/dev/null &');
        }
    }
}