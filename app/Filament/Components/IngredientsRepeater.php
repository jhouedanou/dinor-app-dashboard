<?php

namespace App\Filament\Components;

use App\Models\Ingredient;
use Filament\Forms\Components\Component;
use Filament\Forms\Components\Repeater;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Actions\Action;

class IngredientsRepeater extends Component
{
    public static function make($name = 'ingredients')
    {
        return Repeater::make($name)
            ->label('Ingrédients')
            ->schema([
                Select::make('ingredient_id')
                    ->label('Ingrédient')
                    ->options(Ingredient::active()->pluck('name', 'id'))
                    ->searchable()
                    ->preload()
                    ->live()
                    ->afterStateUpdated(function ($state, $set) {
                        if ($state) {
                            $ingredient = Ingredient::find($state);
                            if ($ingredient) {
                                $set('unit', $ingredient->unit);
                            }
                        }
                    })
                    ->createOptionAction(
                        Action::make('createIngredient')
                            ->label('Créer un nouvel ingrédient')
                            ->form([
                                TextInput::make('name')
                                    ->label('Nom')
                                    ->required(),
                                Select::make('category')
                                    ->label('Catégorie')
                                    ->options(array_keys(Ingredient::getCategories()))
                                    ->required(),
                                Select::make('unit')
                                    ->label('Unité')
                                    ->options(Ingredient::getUnits())
                                    ->required(),
                            ])
                            ->action(function (array $data, $set, $get) {
                                $ingredient = Ingredient::create($data);
                                $set('ingredient_id', $ingredient->id);
                                $set('unit', $ingredient->unit);
                            })
                    ),
                    
                TextInput::make('quantity')
                    ->label('Quantité')
                    ->required()
                    ->numeric()
                    ->step(0.1)
                    ->minValue(0),
                    
                Select::make('unit')
                    ->label('Unité')
                    ->options(Ingredient::getUnits())
                    ->required(),
                    
                TextInput::make('notes')
                    ->label('Notes')
                    ->placeholder('Ex: finement haché, à température ambiante...')
                    ->maxLength(255),
            ])
            ->columns(4)
            ->collapsible()
            ->itemLabel(function ($state) {
                $ingredientName = 'Ingrédient';
                if (isset($state['ingredient_id'])) {
                    $ingredient = Ingredient::find($state['ingredient_id']);
                    if ($ingredient) {
                        $ingredientName = $ingredient->name;
                    }
                }
                
                $quantity = $state['quantity'] ?? '';
                $unit = $state['unit'] ?? '';
                
                return "{$quantity} {$unit} {$ingredientName}";
            })
            ->defaultItems(1)
            ->addActionLabel('Ajouter un ingrédient')
            ->reorderable()
            ->cloneable();
    }
} 