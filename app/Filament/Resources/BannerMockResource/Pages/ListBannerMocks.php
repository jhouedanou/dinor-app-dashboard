<?php

namespace App\Filament\Resources\BannerMockResource\Pages;

use App\Filament\Resources\BannerMockResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListBannerMocks extends ListRecords
{
    protected static string $resource = BannerMockResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\Action::make('info')
                ->label('Information')
                ->icon('heroicon-o-information-circle')
                ->color('info')
                ->modal()
                ->modalHeading('Configuration des Bannières')
                ->modalDescription('Système de bannières Dinor')
                ->modalContent(view('filament.banners.info-modal'))
                ->modalSubmitAction(false)
                ->modalCancelActionLabel('Fermer'),
        ];
    }

    public function getTitle(): string
    {
        return 'Gestion des Bannières';
    }

    protected function getHeaderWidgets(): array
    {
        return [];
    }

    protected function getTableRecordsPerPageSelectOptions(): array
    {
        return [25, 50, 100];
    }
} 