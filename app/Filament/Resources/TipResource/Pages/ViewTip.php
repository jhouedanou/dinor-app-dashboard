<?php

namespace App\Filament\Resources\TipResource\Pages;

use App\Filament\Resources\TipResource;
use Filament\Actions;
use Filament\Resources\Pages\ViewRecord;
use Filament\Infolists;
use Filament\Infolists\Infolist;

class ViewTip extends ViewRecord
{
    protected static string $resource = TipResource::class;

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
                        Infolists\Components\TextEntry::make('difficulty_level')
                            ->label('Niveau de difficulté')
                            ->badge()
                            ->formatStateUsing(function ($state) {
                                return match($state) {
                                    'beginner' => 'Débutant',
                                    'intermediate' => 'Intermédiaire',
                                    'advanced' => 'Avancé',
                                    default => $state
                                };
                            }),
                        Infolists\Components\TextEntry::make('estimated_time')
                            ->label('Temps estimé')
                            ->suffix(' minutes'),
                    ])->columns(2),

                Infolists\Components\Section::make('Contenu')
                    ->schema([
                        Infolists\Components\TextEntry::make('content')
                            ->label('Contenu')
                            ->html()
                            ->columnSpanFull(),
                    ]),

                Infolists\Components\Section::make('Images')
                    ->schema([
                        Infolists\Components\ImageEntry::make('image')
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
                            ->columnSpanFull(),
                    ])->columns(1),

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
                        Infolists\Components\TextEntry::make('updated_at')
                            ->label('Modifié le')
                            ->dateTime(),
                    ])->columns(3),
            ]);
    }
}