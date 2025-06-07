<?php

namespace App\Filament\Widgets;

use App\Models\Recipe;
use App\Models\Event;
use App\Models\Page;
use App\Models\MediaFile;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class StatsOverview extends BaseWidget
{
    protected function getStats(): array
    {
        return [
            Stat::make(__('dinor.recipes'), Recipe::count())
                ->description('Total des recettes')
                ->descriptionIcon('heroicon-m-cake')
                ->color('success'),
            
            Stat::make(__('dinor.events'), Event::count())
                ->description('Événements planifiés')
                ->descriptionIcon('heroicon-m-calendar')
                ->color('info'),
            
            Stat::make(__('dinor.pages'), Page::count())
                ->description('Pages publiées')
                ->descriptionIcon('heroicon-m-document-text')
                ->color('warning'),
            
            Stat::make(__('dinor.media'), MediaFile::count())
                ->description('Fichiers médias')
                ->descriptionIcon('heroicon-m-photo')
                ->color('primary'),
        ];
    }
} 