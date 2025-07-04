<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Facades\Schema;
use App\Models\Comment;
use App\Observers\CommentObserver;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        // Enregistrer conditionnellement les packages de développement
        $this->registerDevelopmentPackages();
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        // Fix for older MySQL versions
        Schema::defaultStringLength(191);
        
        // Register model observers
        Comment::observe(CommentObserver::class);
        
        // Forcer la désactivation des tags de cache pour éviter les erreurs
        $this->disableCacheTaggingForFilament();
    }
    
    /**
     * Désactiver le cache tagging pour Filament
     */
    private function disableCacheTaggingForFilament(): void
    {
        // Override la méthode tags pour retourner le cache normal
        \Illuminate\Support\Facades\Cache::macro('tags', function ($tags = []) {
            // Retourner l'instance de cache normale sans tags
            return \Illuminate\Support\Facades\Cache::store();
        });
    }

    /**
     * Enregistrer les packages de développement seulement s'ils sont disponibles
     */
    private function registerDevelopmentPackages(): void
    {
        // Spatie Ignition - maintenant en production aussi
        if (class_exists(\Spatie\LaravelIgnition\IgnitionServiceProvider::class)) {
            $this->app->register(\Spatie\LaravelIgnition\IgnitionServiceProvider::class);
        }

        // Collision (gestion d'erreurs améliorée) - seulement en développement
        if ($this->app->environment('local', 'testing') && class_exists(\NunoMaduro\Collision\Adapters\Laravel\CollisionServiceProvider::class)) {
            $this->app->register(\NunoMaduro\Collision\Adapters\Laravel\CollisionServiceProvider::class);
        }

        // Autres packages de développement qui pourraient causer des problèmes
        if ($this->app->environment('local', 'testing')) {
            // Laravel Debugbar
            if (class_exists(\Barryvdh\Debugbar\ServiceProvider::class)) {
                $this->app->register(\Barryvdh\Debugbar\ServiceProvider::class);
            }

            // Laravel IDE Helper
            if (class_exists(\Barryvdh\LaravelIdeHelper\IdeHelperServiceProvider::class)) {
                $this->app->register(\Barryvdh\LaravelIdeHelper\IdeHelperServiceProvider::class);
            }
        }
    }
} 