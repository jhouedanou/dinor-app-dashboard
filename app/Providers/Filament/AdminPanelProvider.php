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
            ->spa()
            ->darkMode()
            ->discoverResources(in: app_path('Filament/Resources'), for: 'App\\Filament\\Resources')
            ->discoverPages(in: app_path('Filament/Pages'), for: 'App\\Filament\\Pages')
            ->pages([
                Pages\Dashboard::class,
            ])
            ->discoverWidgets(in: app_path('Filament/Widgets'), for: 'App\\Filament\\Widgets')
            ->widgets([
                Widgets\AccountWidget::class,
                Widgets\FilamentInfoWidget::class,
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
            ])
            ->authMiddleware([
                FilamentAdminAuth::class,
            ])
            ->navigationGroups([
                'Contenu',
                'Interactions',
                'Gestion',
            ])
            ->databaseNotifications()
            ->viteTheme('resources/css/filament/admin/theme.css');
    }
} 