<?php

namespace App\Filament\Resources\DinorTvResource\Pages;

use App\Filament\Resources\DinorTvResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListDinorTvs extends ListRecords
{
    protected static string $resource = DinorTvResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}