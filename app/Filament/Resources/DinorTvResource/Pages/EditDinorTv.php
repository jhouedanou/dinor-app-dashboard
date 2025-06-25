<?php

namespace App\Filament\Resources\DinorTvResource\Pages;

use App\Filament\Resources\DinorTvResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditDinorTv extends EditRecord
{
    protected static string $resource = DinorTvResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make(),
        ];
    }
}