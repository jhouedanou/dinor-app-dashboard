<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Facades\Schema;

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
    }

    /**
     * Enregistrer les packages de développement seulement s'ils sont disponibles
     */
    private function registerDevelopmentPackages(): void
    {
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