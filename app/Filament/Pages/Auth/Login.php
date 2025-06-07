<?php

namespace App\Filament\Pages\Auth;

use Filament\Forms\Components\TextInput;
use Filament\Forms\Form;
use Filament\Pages\Auth\Login as BaseLogin;
use Illuminate\Validation\ValidationException;

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

    public function getTitle(): string
    {
        return __('dinor.login_title');
    }

    public function getHeading(): string
    {
        return __('dinor.login_title');
    }

    protected function throwFailureValidationException(): never
    {
        throw ValidationException::withMessages([
            'data.email' => __('dinor.invalid_credentials'),
        ]);
    }
} 