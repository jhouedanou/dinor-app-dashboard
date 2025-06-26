<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Artisan;

class ClearFilamentCache extends Command
{
    protected $signature = 'filament:clear-cache';
    protected $description = 'Clear all caches related to Filament and Livewire components';

    public function handle()
    {
        $this->info('🚀 Vidage des caches Filament et Livewire...');

        // Clear Laravel caches
        Artisan::call('cache:clear');
        $this->info('✅ Cache général vidé');

        Artisan::call('config:clear');
        $this->info('✅ Cache de configuration vidé');

        Artisan::call('view:clear');
        $this->info('✅ Cache des vues vidé');

        Artisan::call('route:clear');
        $this->info('✅ Cache des routes vidé');

        // Clear Livewire specific cache
        if (class_exists('\Livewire\Livewire')) {
            try {
                Artisan::call('livewire:discover');
                $this->info('✅ Composants Livewire redécouverts');
            } catch (\Exception $e) {
                $this->warn('⚠️  Erreur lors de la découverte Livewire: ' . $e->getMessage());
            }
        }

        // Clear PWA related caches
        Cache::tags(['pwa', 'recipes', 'events', 'tips', 'dinor-tv', 'pages'])->flush();
        $this->info('✅ Caches PWA vidés');

        // Rebuild optimized caches
        Artisan::call('config:cache');
        Artisan::call('route:cache');
        Artisan::call('view:cache');
        $this->info('✅ Caches optimisés reconstruits');

        $this->info('🎉 Tous les caches ont été vidés avec succès!');
        
        return 0;
    }
}