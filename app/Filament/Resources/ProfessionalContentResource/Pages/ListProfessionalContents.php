<?php

namespace App\Filament\Resources\ProfessionalContentResource\Pages;

use App\Filament\Resources\ProfessionalContentResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListProfessionalContents extends ListRecords
{
    protected static string $resource = ProfessionalContentResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}
