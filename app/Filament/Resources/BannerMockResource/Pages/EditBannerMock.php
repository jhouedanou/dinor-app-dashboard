<?php

namespace App\Filament\Resources\BannerMockResource\Pages;

use App\Filament\Resources\BannerMockResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditBannerMock extends EditRecord
{
    protected static string $resource = BannerMockResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make(),
        ];
    }
} 