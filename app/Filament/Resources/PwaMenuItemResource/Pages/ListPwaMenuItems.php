<?php

namespace App\Filament\Resources\PwaMenuItemResource\Pages;

use App\Filament\Resources\PwaMenuItemResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListPwaMenuItems extends ListRecords
{
    protected static string $resource = PwaMenuItemResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make()
                ->label('Nouvel élément'),
        ];
    }
} 