<?php

namespace App\Filament\Widgets;

use App\Models\Category;
use App\Models\Recipe;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class CategoryStats extends BaseWidget
{
    protected function getStats(): array
    {
        $totalCategories = Category::count();
        $activeCategories = Category::active()->count();
        $categoriesWithRecipes = Category::has('recipes')->count();
        $totalRecipes = Recipe::count();

        return [
            Stat::make('Total Catégories', $totalCategories)
                ->description('Toutes les catégories créées')
                ->descriptionIcon('heroicon-m-tag')
                ->color('primary'),

            Stat::make('Catégories Actives', $activeCategories)
                ->description('Catégories disponibles pour les recettes')
                ->descriptionIcon('heroicon-m-check-circle')
                ->color('success'),

            Stat::make('Catégories Utilisées', $categoriesWithRecipes)
                ->description('Catégories avec des recettes associées')
                ->descriptionIcon('heroicon-m-cake')
                ->color('info'),

            Stat::make('Recettes Total', $totalRecipes)
                ->description('Nombre total de recettes')
                ->descriptionIcon('heroicon-m-document-text')
                ->color('warning'),
        ];
    }
} 