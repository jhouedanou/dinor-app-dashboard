<?php

namespace App\Filament\Resources\PwaMenuItemResource\Pages;

use App\Filament\Resources\PwaMenuItemResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditPwaMenuItem extends EditRecord
{
    protected static string $resource = PwaMenuItemResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make()
                ->requiresConfirmation(),
        ];
    }

    protected function getRedirectUrl(): string
    {
        return $this->getResource()::getUrl('index');
    }

    protected function getSavedNotificationTitle(): ?string
    {
        return 'Élément de menu modifié avec succès';
    }
} 