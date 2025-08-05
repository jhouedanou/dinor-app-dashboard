<?php

namespace App\Filament\Resources\ProfessionalContentResource\Pages;

use App\Filament\Resources\ProfessionalContentResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditProfessionalContent extends EditRecord
{
    protected static string $resource = ProfessionalContentResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make(),
        ];
    }
}
