<?php

namespace App\Filament\Resources\TournamentResource\Pages;

use App\Filament\Resources\TournamentResource;
use Filament\Actions;
use Filament\Resources\Pages\CreateRecord;

class CreateTournament extends CreateRecord
{
    protected static string $resource = TournamentResource::class;

    protected function mutateFormDataBeforeCreate(array $data): array
    {
        // Essayer différentes méthodes pour obtenir l'ID utilisateur connecté
        $userId = null;
        
        // Méthode 1: Guard admin de Filament
        if (auth('admin')->check()) {
            $userId = auth('admin')->id();
        }
        // Méthode 2: Guard par défaut
        elseif (auth()->check()) {
            $userId = auth()->id();
        }
        // Méthode 3: Utiliser Filament auth helper
        elseif (class_exists('\Filament\Facades\Filament') && \Filament\Facades\Filament::auth()->check()) {
            $userId = \Filament\Facades\Filament::auth()->id();
        }
        // Méthode 4: Fallback vers ID 1 si aucune méthode ne fonctionne
        else {
            $userId = 1;
        }
        
        $data['created_by'] = $userId;
        
        // Log pour déboguer
        \Log::info('Creating tournament with created_by: ' . $data['created_by'] . ' (method used: ' . 
                   (auth('admin')->check() ? 'admin guard' : 
                   (auth()->check() ? 'default guard' : 
                   (class_exists('\Filament\Facades\Filament') && \Filament\Facades\Filament::auth()->check() ? 'filament helper' : 'fallback'))) . ')');
        
        return $data;
    }
}
