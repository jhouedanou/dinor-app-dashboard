#!/bin/bash

echo "🔧 CORRECTION CONFIGURATION FILAMENT"
echo "===================================="

cd /home/forge/new.dinorapp.com

echo ""
echo "1️⃣ Restauration de la configuration AdminPanelProvider..."

# Restaurer le provider avec la configuration correcte
cat > app/Providers/Filament/AdminPanelProvider.php << 'EOF'
<?php

namespace App\Providers\Filament;

use Filament\Http\Middleware\Authenticate;
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
            ->login()
            ->authGuard('admin')
            ->colors([
                'primary' => Color::Blue,
            ])
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
                Authenticate::class,
            ]);
    }
}
EOF

echo "✅ AdminPanelProvider restauré"

echo ""
echo "2️⃣ Réinitialisation du mot de passe admin..."
php artisan tinker --execute="
\$admin = App\Models\AdminUser::where('email', 'admin@dinor.app')->first();
if (\$admin) {
    \$admin->password = bcrypt('Dinor2024!Admin');
    \$admin->save();
    echo 'Mot de passe réinitialisé pour: ' . \$admin->email;
} else {
    echo 'Admin non trouvé';
}
"

echo ""
echo "3️⃣ Nettoyage des caches..."
php artisan config:clear
php artisan route:clear
php artisan view:clear
php artisan cache:clear

echo ""
echo "4️⃣ Recompilation des assets..."
php artisan filament:assets

echo ""
echo "✅ Configuration corrigée !"
echo ""
echo "🌐 Testez maintenant : https://new.dinorapp.com/admin"
echo "🔐 Login : admin@dinor.app / Dinor2024!Admin" 