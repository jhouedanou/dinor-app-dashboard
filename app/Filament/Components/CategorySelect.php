<?php

namespace App\Filament\Components;

use App\Models\Category;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Modal;
use Filament\Forms\Components\Actions\Action;
use Filament\Forms\Get;
use Filament\Forms\Set;
use Illuminate\Support\Str;

class CategorySelect
{
    public static function make(string $name = 'category_id'): Select
    {
        return Select::make($name)
            ->label('Catégorie')
            ->options(function () {
                return Category::active()->pluck('name', 'id');
            })
            ->searchable()
            ->required()
            ->live()
            ->afterStateUpdated(function (Set $set) {
                $set('subcategory', null);
            })
            ->suffixAction(
                Action::make('add_category')
                    ->label('+')
                    ->icon('heroicon-o-plus')
                    ->color('success')
                    ->size('sm')
                    ->modalHeading('Ajouter une nouvelle catégorie')
                    ->modalDescription('Créez une nouvelle catégorie pour les recettes')
                    ->form([
                        TextInput::make('name')
                            ->label('Nom de la catégorie')
                            ->required()
                            ->maxLength(255)
                            ->live()
                            ->afterStateUpdated(function ($state, Set $set) {
                                if ($state) {
                                    $set('slug', Str::slug($state));
                                }
                            }),
                        
                        TextInput::make('slug')
                            ->label('Slug URL')
                            ->required()
                            ->maxLength(255)
                            ->unique('App\Models\Category', 'slug'),
                        
                        TextInput::make('description')
                            ->label('Description')
                            ->maxLength(500),
                        
                        TextInput::make('color')
                            ->label('Couleur (hex)')
                            ->placeholder('#FF0000')
                            ->maxLength(7)
                            ->default('#3b82f6')
                            ->required(),
                        
                        TextInput::make('icon')
                            ->label('Icône Heroicon')
                            ->placeholder('heroicon-o-cake')
                            ->helperText('Ex: heroicon-o-cake, heroicon-o-fire'),
                    ])
                    ->action(function (array $data, Set $set, Get $get) {
                        // Créer la nouvelle catégorie
                        $category = Category::create([
                            'name' => $data['name'],
                            'slug' => $data['slug'],
                            'description' => $data['description'] ?? null,
                            'color' => $data['color'] ?? '#3b82f6', // Couleur par défaut
                            'icon' => $data['icon'] ?? null,
                            'is_active' => true,
                        ]);

                        // Mettre à jour la liste des options
                        $options = Category::active()->pluck('name', 'id');
                        
                        // Sélectionner automatiquement la nouvelle catégorie
                        $set('category_id', $category->id);
                        
                        // Notification de succès
                        \Filament\Notifications\Notification::make()
                            ->title('Catégorie créée avec succès')
                            ->body("La catégorie '{$category->name}' a été ajoutée et sélectionnée.")
                            ->success()
                            ->send();
                    })
                    ->modalSubmitActionLabel('Créer la catégorie')
                    ->modalCancelActionLabel('Annuler')
            );
    }
} 