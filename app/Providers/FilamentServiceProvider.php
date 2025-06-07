<?php

namespace App\Providers;

use Filament\Facades\Filament;
use Filament\Navigation\NavigationGroup;
use Illuminate\Support\ServiceProvider;
use Filament\Http\Middleware\Authenticate;
use Filament\Http\Middleware\DisableBladeIconComponents;
use Filament\Http\Middleware\DispatchServingFilamentEvent;
use Filament\Navigation\NavigationItem;
use Filament\Pages;
use Filament\Resources;
use Filament\Widgets;
use Illuminate\Cookie\Middleware\AddQueuedCookiesToResponse;
use Illuminate\Cookie\Middleware\EncryptCookies;
use Illuminate\Foundation\Http\Middleware\VerifyCsrfToken;
use Illuminate\Routing\Middleware\SubstituteBindings;
use Illuminate\Session\Middleware\AuthenticateSession;
use Illuminate\Session\Middleware\StartSession;
use Illuminate\View\Middleware\ShareErrorsFromSession;
use App\Models\AdminUser;

class FilamentServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        //
    }

    public function boot(): void
    {
        Filament::serving(function () {
            // Configuration de l'authentification
            Filament::registerUserMenuItems([
                'logout' => NavigationItem::make()
                    ->label(__('dinor.logout'))
                    ->url(route('filament.auth.logout'))
                    ->icon('heroicon-s-logout'),
            ]);

            // Configuration des groupes de navigation
            Filament::registerNavigationGroups([
                NavigationGroup::make()
                    ->label(__('dinor.recipes'))
                    ->icon('heroicon-o-cake'),
                NavigationGroup::make()
                    ->label(__('dinor.events'))
                    ->icon('heroicon-o-calendar'),
                NavigationGroup::make()
                    ->label(__('dinor.media'))
                    ->icon('heroicon-o-photograph'),
                NavigationGroup::make()
                    ->label('Contenu')
                    ->icon('heroicon-o-document-text'),
            ]);
        });

        // Configuration de l'authentification
        Filament::authenticateUsing(function ($credentials) {
            $user = AdminUser::where('email', $credentials['email'])
                ->where('is_active', true)
                ->first();

            if ($user && \Hash::check($credentials['password'], $user->password)) {
                $user->updateLastLogin();
                return $user;
            }

            return null;
        });

        Filament::currentUserUsing(function () {
            return auth()->user();
        });
    }
} 