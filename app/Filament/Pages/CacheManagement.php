<?php

namespace App\Filament\Pages;

use Filament\Pages\Page;
use Filament\Actions\Action;
use Filament\Forms\Components\Card;
use Filament\Forms\Components\TextInput;
use Filament\Notifications\Notification;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Artisan;
use App\Services\CacheService;

class CacheManagement extends Page
{
    protected static ?string $navigationIcon = 'heroicon-o-server-stack';
    
    protected static string $view = 'filament.pages.cache-management';
    
    protected static ?string $title = 'Gestion du Cache';
    
    protected static ?string $navigationLabel = 'Cache';
    
    protected static ?string $navigationGroup = 'Système';
    
    protected static ?int $navigationSort = 100;

    public function getActions(): array
    {
        return [
            Action::make('clearAllCache')
                ->label('Vider tout le cache')
                ->icon('heroicon-o-trash')
                ->color('danger')
                ->requiresConfirmation()
                ->modalHeading('Vider tout le cache')
                ->modalDescription('Cette action va vider tous les caches de l\'application. Êtes-vous sûr ?')
                ->action(function () {
                    $this->clearAllCache();
                }),
                
            Action::make('clearAppCache')
                ->label('Cache Application')
                ->icon('heroicon-o-cpu-chip')
                ->color('warning')
                ->action(function () {
                    $this->clearApplicationCache();
                }),
                
            Action::make('clearConfigCache')
                ->label('Cache Configuration')
                ->icon('heroicon-o-cog-6-tooth')
                ->color('info')
                ->action(function () {
                    $this->clearConfigCache();
                }),
                
            Action::make('clearViewCache')
                ->label('Cache Vues')
                ->icon('heroicon-o-eye')
                ->color('success')
                ->action(function () {
                    $this->clearViewCache();
                }),
        ];
    }

    public function clearAllCache(): void
    {
        try {
            $operations = [];
            
            // 1. Cache général
            Cache::flush();
            $operations[] = 'Cache général vidé';
            
            // 2. Cache de configuration
            try {
                Artisan::call('config:clear');
                $operations[] = 'Cache de configuration vidé';
            } catch (\Exception $e) {
                $operations[] = 'Erreur cache config: ' . $e->getMessage();
            }
            
            // 3. Cache des vues
            try {
                Artisan::call('view:clear');
                $operations[] = 'Cache des vues vidé';
            } catch (\Exception $e) {
                $operations[] = 'Erreur cache vues: ' . $e->getMessage();
            }
            
            // 4. Cache des routes
            try {
                Artisan::call('route:clear');
                $operations[] = 'Cache des routes vidé';
            } catch (\Exception $e) {
                $operations[] = 'Erreur cache routes: ' . $e->getMessage();
            }
            
            // 5. OPCache
            if (function_exists('opcache_reset')) {
                opcache_reset();
                $operations[] = 'OPCache réinitialisé';
            }
            
            Notification::make()
                ->title('Cache vidé avec succès')
                ->body(implode('<br>', $operations))
                ->success()
                ->send();
                
        } catch (\Exception $e) {
            Notification::make()
                ->title('Erreur lors du vidage du cache')
                ->body('Erreur: ' . $e->getMessage())
                ->danger()
                ->send();
        }
    }

    public function clearApplicationCache(): void
    {
        try {
            // Utiliser notre service de cache personnalisé
            $cacheService = new CacheService();
            $result = $cacheService->flushFilamentCache();
            
            if ($result['success']) {
                Notification::make()
                    ->title('Cache application vidé')
                    ->body($result['message'])
                    ->success()
                    ->send();
            } else {
                Notification::make()
                    ->title('Erreur')
                    ->body($result['message'])
                    ->danger()
                    ->send();
            }
        } catch (\Exception $e) {
            Notification::make()
                ->title('Erreur lors du vidage du cache application')
                ->body('Erreur: ' . $e->getMessage())
                ->danger()
                ->send();
        }
    }

    public function clearConfigCache(): void
    {
        try {
            Artisan::call('config:clear');
            
            Notification::make()
                ->title('Cache de configuration vidé')
                ->body('Le cache de configuration a été vidé avec succès')
                ->success()
                ->send();
        } catch (\Exception $e) {
            Notification::make()
                ->title('Erreur')
                ->body('Erreur: ' . $e->getMessage())
                ->danger()
                ->send();
        }
    }

    public function clearViewCache(): void
    {
        try {
            Artisan::call('view:clear');
            
            Notification::make()
                ->title('Cache des vues vidé')
                ->body('Le cache des vues a été vidé avec succès')
                ->success()
                ->send();
        } catch (\Exception $e) {
            Notification::make()
                ->title('Erreur')
                ->body('Erreur: ' . $e->getMessage())
                ->danger()
                ->send();
        }
    }
}