<?php

namespace App\Filament\Resources\BannerMockResource\Pages;

use App\Filament\Resources\BannerMockResource;
use Filament\Actions;
use Filament\Resources\Pages\CreateRecord;

class CreateBannerMock extends CreateRecord
{
    protected static string $resource = BannerMockResource::class;
} 