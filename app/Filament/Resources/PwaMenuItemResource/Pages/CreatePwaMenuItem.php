<?php

namespace App\Filament\Resources\PwaMenuItemResource\Pages;

use App\Filament\Resources\PwaMenuItemResource;
use Filament\Resources\Pages\CreateRecord;

class CreatePwaMenuItem extends CreateRecord
{
    protected static string $resource = PwaMenuItemResource::class;

    protected function getRedirectUrl(): string
    {
        return $this->getResource()::getUrl('index');
    }

    protected function getCreatedNotificationTitle(): ?string
    {
        return 'Élément de menu créé avec succès';
    }
} 