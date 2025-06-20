<?php

namespace App\Filament\Pages\Auth;

use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Actions\Action;
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
                    ->revealable()
                    ->required()
                    ->extraInputAttributes(['tabindex' => 2])
            ]);
    }

    public function getTitle()
    {
        return __('dinor.login_title');
    }

    public function getHeading()
    {
        return __('dinor.login_title');
    }

    protected function getAuthGuard(): string
    {
        return 'admin';
    }

    protected function getCredentialsFromFormData(array $data): array
    {
        try {
            \Log::info('LOGIN ATTEMPT', [
                'email' => $data['email'],
                'guard' => $this->getAuthGuard(),
                'admin_users_count' => \App\Models\AdminUser::count(),
                'user_exists' => \App\Models\AdminUser::where('email', $data['email'])->exists(),
            ]);
        } catch (\Exception $e) {
            // Ignore log errors to prevent authentication failures
        }
        
        return [
            'email' => $data['email'],
            'password' => $data['password'],
        ];
    }

    protected function throwFailureValidationException(): never
    {
        try {
            \Log::error('LOGIN FAILED', [
                'guard' => $this->getAuthGuard(),
                'attempted_email' => $this->form->getState()['email'] ?? 'unknown',
            ]);
        } catch (\Exception $e) {
            // Ignore log errors to prevent authentication failures
        }
        
        // Rediriger vers la page d'erreur personnalisée
        $this->redirect(route('admin.login.error'));
        
        parent::throwFailureValidationException();
    }
} 