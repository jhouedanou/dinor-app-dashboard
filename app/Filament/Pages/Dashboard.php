<?php

namespace App\Filament\Pages;

use Filament\Pages\Dashboard as BaseDashboard;

class Dashboard extends BaseDashboard
{
    protected static ?string $navigationIcon = 'heroicon-o-home';

    protected static string $view = 'filament.pages.dashboard';

    public function getTitle(): string 
    {
        return __('dinor.dashboard');
    }

    public function getHeading(): string
    {
        return __('dinor.welcome') . ' sur ' . __('dinor.dashboard') . ' Dinor';
    }

    public function getWidgets(): array
    {
        return [
            \App\Filament\Widgets\LikesStatsWidget::class,
            \App\Filament\Widgets\PopularContentWidget::class,
            \App\Filament\Widgets\CommentsStatsWidget::class,
            \App\Filament\Widgets\RecentActivityWidget::class,
        ];
    }
} 