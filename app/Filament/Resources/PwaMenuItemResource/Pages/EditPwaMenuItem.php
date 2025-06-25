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
            Actions\DeleteAction::make(),
        ];
    }
    
    protected function getRedirectUrl(): string
    {
        return $this->getResource()::getUrl('index');
    }
} 