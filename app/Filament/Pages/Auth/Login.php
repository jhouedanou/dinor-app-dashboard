<?php

namespace App\Filament\Pages\Auth;

use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Actions\Action;
use Filament\Forms\Form;
use Filament\Pages\Auth\Login as BaseLogin;
use Illuminate\Contracts\Support\Htmlable;
use Filament\Http\Responses\Auth\Contracts\LoginResponse;

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

    public function getTitle(): string|Htmlable
    {
        return __('dinor.login_title');
    }

    public function getHeading(): string|Htmlable
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
            \Log::info('LOGIN ATTEMPT START', [
                'email' => $data['email'],
                'guard' => $this->getAuthGuard(),
                'admin_users_count' => \App\Models\AdminUser::count(),
                'user_exists' => \App\Models\AdminUser::where('email', $data['email'])->exists(),
                'ip' => request()->ip(),
                'user_agent' => request()->userAgent(),
            ]);
        } catch (\Exception $e) {
            \Log::error('Error in getCredentialsFromFormData: ' . $e->getMessage());
        }
        
        return [
            'email' => $data['email'],
            'password' => $data['password'],
        ];
    }

    public function authenticate(): ?LoginResponse
    {
        try {
            \Log::info('AUTHENTICATE METHOD CALLED', [
                'form_data' => $this->form->getState(),
                'guard' => $this->getAuthGuard(),
            ]);

            $result = parent::authenticate();
            
            \Log::info('AUTHENTICATION SUCCESS', [
                'authenticated' => Auth::guard($this->getAuthGuard())->check(),
                'user_id' => Auth::guard($this->getAuthGuard())->id(),
            ]);
            
            return $result;
            
        } catch (\Exception $e) {
            \Log::error('AUTHENTICATION ERROR', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
                'guard' => $this->getAuthGuard(),
            ]);
            
            throw $e;
        }
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
        
        // Utiliser la méthode parent pour générer l'erreur de validation standard
        parent::throwFailureValidationException();
    }
} 