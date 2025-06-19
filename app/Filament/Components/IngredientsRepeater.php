<?php

namespace App\Filament\Components;

use App\Models\Ingredient;
use Filament\Forms\Components\Actions\Action;
use Filament\Forms\Components\Component;
use Filament\Forms\Components\Grid;
use Filament\Forms\Components\Repeater;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Get;
use Filament\Forms\Set;
use Filament\Notifications\Notification;

class IngredientsRepeater extends Component
{
    public static function make(string $name = 'ingredients'): Repeater
    {
        return Repeater::make($name)
            ->label('Ingrédients')
            ->schema([
                Grid::make(4)
                    ->schema([
                        Select::make('ingredient_id')
                            ->label('Ingrédient')
                            ->options(function () {
                                return Ingredient::active()
                                    ->orderBy('name')
                                    ->get()
                                    ->groupBy('category')
                                    ->map(function ($ingredients) {
                                        return $ingredients->pluck('name', 'id');
                                    })
                                    ->toArray();
                            })
                            ->searchable()
                            ->preload()
                            ->allowHtml()
                            ->getSearchResultsUsing(function (string $search) {
                                return Ingredient::active()
                                    ->where('name', 'like', "%{$search}%")
                                    ->orderBy('name')
                                    ->limit(20)
                                    ->get()
                                    ->mapWithKeys(function ($ingredient) {
                                        return [
                                            $ingredient->id => sprintf(
                                                '<div class="flex justify-between items-center">
                                                    <span>%s</span>
                                                    <span class="text-xs text-gray-500">%s</span>
                                                </div>',
                                                $ingredient->name,
                                                $ingredient->category
                                            )
                                        ];
                                    })
                                    ->toArray();
                            })
                            ->live()
                            ->afterStateUpdated(function (Get $get, Set $set, $state) {
                                if ($state) {
                                    $ingredient = Ingredient::find($state);
                                    if ($ingredient) {
                                        $set('name', $ingredient->name);
                                        $set('unit', $ingredient->unit);
                                        $set('recommended_brand', $ingredient->recommended_brand);
                                    }
                                }
                            })
                            ->suffixAction(
                                Action::make('add_ingredient')
                                    ->icon('heroicon-m-plus')
                                    ->label('Nouvel ingrédient')
                                    ->form([
                                        TextInput::make('name')
                                            ->label('Nom de l\'ingrédient')
                                            ->required()
                                            ->maxLength(255),
                                        
                                        Select::make('category')
                                            ->label('Catégorie')
                                            ->options(array_keys(Ingredient::getCategories()))
                                            ->required()
                                            ->live()
                                            ->afterStateUpdated(function ($set) {
                                                $set('subcategory', null);
                                            }),
                                            
                                        Select::make('subcategory')
                                            ->label('Sous-catégorie')
                                            ->options(function (Get $get) {
                                                $category = $get('category');
                                                if (!$category) return [];
                                                $categories = Ingredient::getCategories();
                                                return array_combine(
                                                    $categories[$category] ?? [],
                                                    $categories[$category] ?? []
                                                );
                                            })
                                            ->visible(function (Get $get) {
                                                return filled($get('category'));
                                            }),
                                            
                                        Select::make('unit')
                                            ->label('Unité de mesure')
                                            ->options(Ingredient::getUnits())
                                            ->required(),
                                            
                                        TextInput::make('recommended_brand')
                                            ->label('Marque recommandée')
                                            ->maxLength(255),
                                    ])
                                    ->action(function (array $data, Get $get, Set $set) {
                                        // Créer le nouvel ingrédient
                                        $ingredient = Ingredient::create($data);
                                        
                                        // Mettre à jour le champ select et les autres champs
                                        $set('ingredient_id', $ingredient->id);
                                        $set('name', $ingredient->name);
                                        $set('unit', $ingredient->unit);
                                        $set('recommended_brand', $ingredient->recommended_brand);
                                        
                                        Notification::make()
                                            ->title('Ingrédient ajouté avec succès!')
                                            ->success()
                                            ->send();
                                    })
                                    ->modalHeading('Ajouter un nouvel ingrédient')
                                    ->modalWidth('lg')
                            )
                            ->columnSpan(2),
                            
                        TextInput::make('quantity')
                            ->label('Quantité')
                            ->required()
                            ->numeric()
                            ->step(0.01)
                            ->columnSpan(1),
                            
                        Select::make('unit')
                            ->label('Unité')
                            ->options(Ingredient::getUnits())
                            ->required()
                            ->columnSpan(1),
                    ]),
                    
                // Champs cachés pour stocker les informations
                TextInput::make('name')
                    ->hidden(),
                TextInput::make('recommended_brand')
                    ->hidden(),
            ])
            ->defaultItems(1)
            ->reorderable()
            ->collapsible()
            ->cloneable()
            ->addActionLabel('Ajouter un ingrédient')
            ->deleteAction(function (Action $action) {
                return $action
                    ->requiresConfirmation()
                    ->modalHeading('Supprimer cet ingrédient ?')
                    ->modalDescription('Êtes-vous sûr de vouloir supprimer cet ingrédient de la recette ?');
            });
    }
} 