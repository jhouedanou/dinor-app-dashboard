<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use App\Models\Recipe;
use App\Models\Event;
use App\Models\Tip;
use App\Models\DinorTv;
use App\Models\Page;
use App\Models\PwaMenuItem;
use App\Models\Banner;
use App\Models\Category;
use App\Observers\PwaContentObserver;

class PwaServiceProvider extends ServiceProvider
{
    /**
     * Register services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap services.
     */
    public function boot(): void
    {
        // Enregistrer l'observer pour tous les modèles qui affectent la PWA
        Recipe::observe(PwaContentObserver::class);
        Event::observe(PwaContentObserver::class);
        Tip::observe(PwaContentObserver::class);
        DinorTv::observe(PwaContentObserver::class);
        Page::observe(PwaContentObserver::class);
        PwaMenuItem::observe(PwaContentObserver::class);
        Banner::observe(PwaContentObserver::class);
        Category::observe(PwaContentObserver::class);
    }
}