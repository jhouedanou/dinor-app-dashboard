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
use App\Models\Banner;
use App\Models\Category;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;
use Carbon\Carbon;

class StatsOverview extends BaseWidget
{
    protected static ?int $sort = 1;
    
    protected function getStats(): array
    {
        // Calculer les statistiques avec des tendances
        $usersThisMonth = User::whereMonth('created_at', now()->month)->count();
        $recipesThisWeek = Recipe::where('created_at', '>=', now()->subDays(7))->count();
        $eventsActive = Event::where('start_date', '>=', now())->where('is_published', true)->count();
        $likesToday = Like::whereDate('created_at', today())->count();
        $commentsToday = Comment::whereDate('created_at', today())->count();
        $pendingComments = Comment::where('is_approved', false)->count();
        
        return [
            Stat::make('Utilisateurs', User::count())
                ->description($usersThisMonth > 0 ? "+{$usersThisMonth} ce mois" : 'Utilisateurs inscrits')
                ->descriptionIcon($usersThisMonth > 0 ? 'heroicon-m-arrow-trending-up' : 'heroicon-m-users')
                ->color('success')
                ->chart($this->getUsersChart()),

            Stat::make('Recettes', Recipe::count())
                ->description($recipesThisWeek > 0 ? "+{$recipesThisWeek} cette semaine" : 'Total des recettes')
                ->descriptionIcon($recipesThisWeek > 0 ? 'heroicon-m-arrow-trending-up' : 'heroicon-m-cake')
                ->color('primary')
                ->chart($this->getRecipesChart()),
            
            Stat::make('Événements', $eventsActive)
                ->description('Événements à venir')
                ->descriptionIcon('heroicon-m-calendar')
                ->color('info')
                ->chart($this->getEventsChart()),

            Stat::make('Likes', Like::count())
                ->description($likesToday > 0 ? "+{$likesToday} aujourd'hui" : 'Total des likes')
                ->descriptionIcon($likesToday > 0 ? 'heroicon-m-arrow-trending-up' : 'heroicon-m-heart')
                ->color('danger')
                ->chart($this->getLikesChart()),

            Stat::make('Commentaires', Comment::count())
                ->description($commentsToday > 0 ? "+{$commentsToday} aujourd'hui" : 'Total des commentaires')
                ->descriptionIcon($commentsToday > 0 ? 'heroicon-m-arrow-trending-up' : 'heroicon-m-chat-bubble-left-right')
                ->color('warning')
                ->chart($this->getCommentsChart()),

            Stat::make('En attente', $pendingComments)
                ->description('Commentaires à modérer')
                ->descriptionIcon('heroicon-m-clock')
                ->color($pendingComments > 0 ? 'warning' : 'success'),

            Stat::make('Astuces', Tip::count())
                ->description('Astuces publiées')
                ->descriptionIcon('heroicon-m-light-bulb')
                ->color('purple'),

            Stat::make('Contenu', $this->getTotalContent())
                ->description('Total des éléments')
                ->descriptionIcon('heroicon-m-document-duplicate')
                ->color('gray'),
        ];
    }
    
    private function getUsersChart(): array
    {
        $days = [];
        for ($i = 6; $i >= 0; $i--) {
            $date = now()->subDays($i);
            $count = User::whereDate('created_at', $date)->count();
            $days[] = $count;
        }
        return $days;
    }
    
    private function getRecipesChart(): array
    {
        $days = [];
        for ($i = 6; $i >= 0; $i--) {
            $date = now()->subDays($i);
            $count = Recipe::whereDate('created_at', $date)->count();
            $days[] = $count;
        }
        return $days;
    }
    
    private function getEventsChart(): array
    {
        $days = [];
        for ($i = 6; $i >= 0; $i--) {
            $date = now()->subDays($i);
            $count = Event::whereDate('created_at', $date)->count();
            $days[] = $count;
        }
        return $days;
    }
    
    private function getLikesChart(): array
    {
        $days = [];
        for ($i = 6; $i >= 0; $i--) {
            $date = now()->subDays($i);
            $count = Like::whereDate('created_at', $date)->count();
            $days[] = $count;
        }
        return $days;
    }
    
    private function getCommentsChart(): array
    {
        $days = [];
        for ($i = 6; $i >= 0; $i--) {
            $date = now()->subDays($i);
            $count = Comment::whereDate('created_at', $date)->count();
            $days[] = $count;
        }
        return $days;
    }
    
    private function getTotalContent(): int
    {
        return Recipe::count() + 
               Event::count() + 
               Tip::count() + 
               Page::count() + 
               Banner::count() + 
               Category::count();
    }
} 