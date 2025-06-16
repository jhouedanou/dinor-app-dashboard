<?php

namespace App\Filament\Pages\Auth;

use Filament\Forms\Components\TextInput;
use Filament\Forms\Form;
use Filament\Pages\Auth\Login as BaseLogin;
use Illuminate\Contracts\Support\Htmlable;

class Login extends BaseLogin
{
    public function form(Form $form): Form
    {
        return $form
            ->schema([
                TextInput::make('email')
                    ->label(__('dinor.email'))
                    ->email()
                    ->required()
                    ->autocomplete()
                    ->autofocus()
                    ->extraInputAttributes(['tabindex' => 1]),
                TextInput::make('password')
                    ->label(__('dinor.password'))
                    ->password()
                    ->required()
                    ->extraInputAttributes(['tabindex' => 2]),
            ]);
    }

    public function getTitle(): string | Htmlable
    {
        return __('dinor.login_title');
    }

    public function getHeading(): string | Htmlable
    {
        return __('dinor.login_title');
    }

    protected function getAuthGuard(): string
    {
        return 'web';
    }

    protected function getCredentialsFromFormData(array $data): array
    {
        \Log::info('LOGIN ATTEMPT', [
            'email' => $data['email'],
            'guard' => $this->getAuthGuard(),
            'admin_users_count' => \App\Models\AdminUser::count(),
            'user_exists' => \App\Models\AdminUser::where('email', $data['email'])->exists(),
        ]);
        
        return [
            'email' => $data['email'],
            'password' => $data['password'],
        ];
    }

    protected function throwFailureValidationException(): never
    {
        \Log::error('LOGIN FAILED', [
            'guard' => $this->getAuthGuard(),
            'attempted_email' => $this->form->getState()['email'] ?? 'unknown',
        ]);
        
        parent::throwFailureValidationException();
    }
} 