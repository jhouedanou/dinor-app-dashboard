<?php

namespace App\Filament\Components;

use Filament\Forms\Components\Repeater;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Textarea;

class DinorIngredientsRepeater
{
    public static function make(string $name): Repeater
    {
        return Repeater::make($name)
            ->label('Ingrédients Dinor')
            ->schema([
                TextInput::make('name')
                    ->label('Nom du produit Dinor')
                    ->required()
                    ->placeholder('ex: Huile Dinor, Riz Dinor vietnamien jasmine')
                    ->maxLength(255),
                    
                TextInput::make('quantity')
                    ->label('Quantité')
                    ->placeholder('ex: 2 cuillères à soupe, 1 tasse')
                    ->maxLength(100),
                    
                TextInput::make('purchase_url')
                    ->label('Lien d\'achat')
                    ->url()
                    ->placeholder('https://shop.dinor.com/produit/...')
                    ->helperText('URL vers la page de vente du produit Dinor'),
                    
                Textarea::make('description')
                    ->label('Description (optionnel)')
                    ->placeholder('Pourquoi utiliser ce produit Dinor spécifiquement...')
                    ->rows(2)
                    ->maxLength(500),
            ])
            ->collapsible()
            ->cloneable()
            ->reorderable()
            ->addActionLabel('Ajouter un produit Dinor')
            ->defaultItems(0)
            ->minItems(0)
            ->maxItems(10)
            ->itemLabel(fn (array $state): ?string => $state['name'] ?? 'Produit Dinor')
            ->helperText('Ajoutez les produits Dinor utilisés dans cette recette avec leurs liens d\'achat');
    }
}