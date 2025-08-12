<?php

namespace App\Filament\Resources\RecipeResource\Pages;

use App\Filament\Resources\RecipeResource;
use Filament\Actions;
use Filament\Resources\Pages\ViewRecord;
use Filament\Infolists;
use Filament\Infolists\Infolist;

class ViewRecipe extends ViewRecord
{
    protected static string $resource = RecipeResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\EditAction::make(),
        ];
    }

    public function infolist(Infolist $infolist): Infolist
    {
        return $infolist
            ->schema([
                Infolists\Components\Section::make('Informations générales')
                    ->schema([
                        Infolists\Components\TextEntry::make('title')
                            ->label('Titre'),
                        Infolists\Components\TextEntry::make('category.name')
                            ->label('Catégorie')
                            ->badge(),
                        Infolists\Components\TextEntry::make('difficulty')
                            ->label('Difficulté')
                            ->badge()
                            ->formatStateUsing(function ($state) {
                                return match($state) {
                                    'easy' => 'Facile',
                                    'medium' => 'Moyen',
                                    'hard' => 'Difficile',
                                    default => $state
                                };
                            }),
                        Infolists\Components\TextEntry::make('servings')
                            ->label('Portions'),
                    ])->columns(2),

                Infolists\Components\Section::make('Description')
                    ->schema([
                        Infolists\Components\TextEntry::make('description')
                            ->label('Description')
                            ->columnSpanFull(),
                    ]),

                Infolists\Components\Section::make('Images et Médias')
                    ->schema([
                        Infolists\Components\ImageEntry::make('featured_image')
                            ->label('Image principale')
                            ->disk('public'),
                        Infolists\Components\RepeatableEntry::make('gallery')
                            ->label('Galerie d\'images')
                            ->schema([
                                Infolists\Components\ImageEntry::make('')
                                    ->disk('public')
                                    ->hiddenLabel(),
                            ])
                            ->columns(3)
                            ->columnSpanFull()
                            ->visible(fn ($record) => !empty($record->gallery)),
                    ])->columns(1),

                Infolists\Components\Section::make('Temps de préparation')
                    ->schema([
                        Infolists\Components\TextEntry::make('preparation_time')
                            ->label('Préparation')
                            ->suffix(' min'),
                        Infolists\Components\TextEntry::make('cooking_time')
                            ->label('Cuisson')
                            ->suffix(' min'),
                        Infolists\Components\TextEntry::make('resting_time')
                            ->label('Repos')
                            ->suffix(' min'),
                        Infolists\Components\TextEntry::make('total_time')
                            ->label('Temps total')
                            ->suffix(' min'),
                    ])->columns(4),

                Infolists\Components\Section::make('Ingrédients')
                    ->schema([
                        Infolists\Components\RepeatableEntry::make('ingredients')
                            ->label('Liste des ingrédients')
                            ->schema([
                                Infolists\Components\TextEntry::make('name')
                                    ->label('Ingrédient'),
                                Infolists\Components\TextEntry::make('quantity')
                                    ->label('Quantité'),
                                Infolists\Components\TextEntry::make('unit')
                                    ->label('Unité'),
                            ])
                            ->columns(3)
                            ->columnSpanFull(),

                        Infolists\Components\RepeatableEntry::make('dinor_ingredients')
                            ->label('Produits Dinor')
                            ->schema([
                                Infolists\Components\TextEntry::make('name')
                                    ->label('Produit'),
                                Infolists\Components\TextEntry::make('quantity')
                                    ->label('Quantité'),
                                Infolists\Components\TextEntry::make('description')
                                    ->label('Description'),
                                Infolists\Components\TextEntry::make('purchase_url')
                                    ->label('Acheter')
                                    ->url(fn ($state) => is_string($state) ? $state : null)
                                    ->openUrlInNewTab(),
                            ])
                            ->columns(4)
                            ->columnSpanFull()
                            ->visible(fn ($record) => !empty($record->dinor_ingredients)),
                    ]),

                Infolists\Components\Section::make('Instructions')
                    ->schema([
                        Infolists\Components\RepeatableEntry::make('instructions')
                            ->label('Étapes de préparation')
                            ->schema([
                                Infolists\Components\TextEntry::make('step')
                                    ->label('Étape')
                                    ->hiddenLabel(),
                            ])
                            ->columnSpanFull(),
                    ]),

                Infolists\Components\Section::make('Métadonnées')
                    ->schema([
                        Infolists\Components\TextEntry::make('tags')
                            ->badge()
                            ->separator(','),
                        Infolists\Components\IconEntry::make('is_featured')
                            ->label('Vedette')
                            ->boolean(),
                        Infolists\Components\IconEntry::make('is_published')
                            ->label('Publié')
                            ->boolean(),
                        Infolists\Components\TextEntry::make('views_count')
                            ->label('Vues'),
                        Infolists\Components\TextEntry::make('likes_count')
                            ->label('Likes'),
                        Infolists\Components\TextEntry::make('created_at')
                            ->label('Créé le')
                            ->dateTime(),
                    ])->columns(3),
            ]);
    }
} 