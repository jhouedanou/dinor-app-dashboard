<?php

namespace App\Providers\Filament;

use App\Http\Middleware\FilamentAdminAuth;
use Filament\Http\Middleware\DisableBladeIconComponents;
use Filament\Http\Middleware\DispatchServingFilamentEvent;
use Filament\Pages;
use Filament\Panel;
use Filament\PanelProvider;
use Filament\Support\Colors\Color;
use Filament\Widgets;
use Illuminate\Cookie\Middleware\AddQueuedCookiesToResponse;
use Illuminate\Cookie\Middleware\EncryptCookies;
use Illuminate\Foundation\Http\Middleware\VerifyCsrfToken;
use Illuminate\Routing\Middleware\SubstituteBindings;
use Illuminate\Session\Middleware\AuthenticateSession;
use Illuminate\Session\Middleware\StartSession;
use Illuminate\View\Middleware\ShareErrorsFromSession;

class AdminPanelProvider extends PanelProvider
{
    public function panel(Panel $panel): Panel
    {
        return $panel
            ->default()
            ->id('admin')
            ->path('/admin')
            ->login(\App\Filament\Pages\Auth\Login::class)
            ->authGuard('admin')
            ->brandName('Dinor Dashboard')
            ->brandLogo('/images/dinor-logo.png')
            ->brandLogoHeight('2rem')
            ->favicon('/pwa/icons/icon-32x32.png')
            ->colors([
                'primary' => [
                    50 => '#fefbf3',
                    100 => '#fdf3e1',
                    200 => '#fae4c2',
                    300 => '#f5ce98',
                    400 => '#efb26c',
                    500 => '#9F7C20',
                    600 => '#8d6b1c',
                    700 => '#7a5b18',
                    800 => '#664b14',
                    900 => '#523c10',
                    950 => '#2f2208',
                ],
                'danger' => [
                    50 => '#fef2f2',
                    100 => '#fee2e2',
                    200 => '#fecaca',
                    300 => '#fca5a5',
                    400 => '#f87171',
                    500 => '#E33734',
                    600 => '#AD1311',
                    700 => '#9B1515',
                    800 => '#7f1d1d',
                    900 => '#701a1a',
                    950 => '#450a0a',
                ],
            ])
            // ->spa() // Désactivé temporairement pour éviter les rechargements multiples
            ->darkMode()
            ->resources([
                \App\Filament\Resources\RecipeResource::class,
                \App\Filament\Resources\CategoryResource::class,
                \App\Filament\Resources\TipResource::class,
                \App\Filament\Resources\EventResource::class,
                \App\Filament\Resources\EventCategoryResource::class,
                \App\Filament\Resources\PageResource::class,
                \App\Filament\Resources\DinorTvResource::class,
                \App\Filament\Resources\UserResource::class,
                \App\Filament\Resources\IngredientResource::class,
                \App\Filament\Resources\MediaFileResource::class,
                \App\Filament\Resources\LikeResource::class,
                \App\Filament\Resources\CommentResource::class,
                \App\Filament\Resources\BannerResource::class,
                \App\Filament\Resources\PwaMenuItemResource::class,
                \App\Filament\Resources\PushNotificationResource::class,
            ])
            ->discoverResources(app_path('Filament/Resources'), 'App\\Filament\\Resources')
            ->discoverPages(app_path('Filament/Pages'), 'App\\Filament\\Pages')
            ->pages([
                Pages\Dashboard::class,
            ])
            ->discoverWidgets(app_path('Filament/Widgets'), 'App\\Filament\\Widgets')
            ->widgets([
                Widgets\AccountWidget::class,
                Widgets\FilamentInfoWidget::class,
                \App\Filament\Widgets\CategoryStats::class,
            ])
            ->middleware([
                EncryptCookies::class,
                AddQueuedCookiesToResponse::class,
                StartSession::class,
                AuthenticateSession::class,
                ShareErrorsFromSession::class,
                VerifyCsrfToken::class,
                SubstituteBindings::class,
                DisableBladeIconComponents::class,
                DispatchServingFilamentEvent::class,
                \App\Http\Middleware\DisablePwaForAdmin::class,
            ])
            ->authMiddleware([
                FilamentAdminAuth::class,
            ])
            ->navigationGroups([
                'Contenu',
                'Communication',
                'Administration', 
                'Interactions',
                'Gestion',
                'Configuration PWA',
            ])
            ->databaseNotifications()
            ->viteTheme('resources/css/filament/admin/theme.css')
            ->spa(false); // Désactiver SPA et utiliser les assets compilés
    }
} 