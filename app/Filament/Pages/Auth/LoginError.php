<?php

namespace App\Filament\Pages\Auth;

use Filament\Pages\SimplePage;
use Filament\Forms\Components\Actions\Action;
use Filament\Support\Exceptions\Halt;
use Illuminate\Contracts\Support\Htmlable;

class LoginError extends SimplePage
{
    protected static $view = 'filament.pages.auth.login-error';

    public function getTitle()
    {
        return __('dinor.login_error_title');
    }

    public function getHeading()
    {
        return __('dinor.login_error_heading');
    }

    public function getSubheading()
    {
        return __('dinor.login_error_subheading');
    }

    public function hasLogo(): bool
    {
        return true;
    }

    protected function getFormActions(): array
    {
        return [
            Action::make('retourAccueil')
                ->label(__('dinor.return_to_login'))
                ->url(route('filament.admin.auth.login'))
                ->color('primary')
                ->size('lg'),
            
            Action::make('contactSupport')
                ->label(__('dinor.contact_support'))
                ->color('gray')
                ->outlined()
                ->url('mailto:support@dinorapp.com')
                ->icon('heroicon-o-envelope')
        ];
    }
} 