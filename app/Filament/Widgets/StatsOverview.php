<?php

namespace App\Filament\Widgets;

use App\Models\Recipe;
use App\Models\Event;
use App\Models\Page;
use App\Models\Tip;
use App\Models\MediaFile;
use App\Models\User;
use App\Models\Like;
use App\Models\Comment;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class StatsOverview extends BaseWidget
{
    protected function getStats(): array
    {
        return [
            Stat::make('Utilisateurs', User::count())
                ->description('Utilisateurs inscrits')
                ->descriptionIcon('heroicon-m-users')
                ->color('success'),

            Stat::make(__('dinor.recipes'), Recipe::count())
                ->description('Total des recettes')
                ->descriptionIcon('heroicon-m-cake')
                ->color('primary'),
            
            Stat::make(__('dinor.events'), Event::count())
                ->description('Événements planifiés')
                ->descriptionIcon('heroicon-m-calendar')
                ->color('info'),

            Stat::make('Likes', Like::count())
                ->description('Total des likes')
                ->descriptionIcon('heroicon-m-heart')
                ->color('danger'),

            Stat::make('Commentaires', Comment::count())
                ->description('Total des commentaires')
                ->descriptionIcon('heroicon-m-chat-bubble-left-right')
                ->color('warning'),

            Stat::make('Astuces', Tip::count())
                ->description('Astuces publiées')
                ->descriptionIcon('heroicon-m-light-bulb')
                ->color('primary'),

            Stat::make('Pages', Page::count())
                ->description('Pages du site')
                ->descriptionIcon('heroicon-m-document-text')
                ->color('info'),

            Stat::make('En attente', Comment::where('is_approved', false)->count())
                ->description('Commentaires non approuvés')
                ->descriptionIcon('heroicon-m-clock')
                ->color('gray'),
        ];
    }
} 