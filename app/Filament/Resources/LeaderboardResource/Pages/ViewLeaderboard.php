<?php

namespace App\Filament\Resources\LeaderboardResource\Pages;

use App\Filament\Resources\LeaderboardResource;
use Filament\Actions;
use Filament\Resources\Pages\ViewRecord;
use Filament\Infolists;
use Filament\Infolists\Infolist;

class ViewLeaderboard extends ViewRecord
{
    protected static string $resource = LeaderboardResource::class;

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
                Infolists\Components\Section::make('Classement')
                    ->schema([
                        Infolists\Components\TextEntry::make('rank')
                            ->label('Rang')
                            ->badge()
                            ->color(function ($state) {
                                if ($state == 1) return 'warning'; // Or
                                if ($state == 2) return 'gray'; // Argent
                                if ($state == 3) return 'success'; // Bronze
                                if ($state <= 10) return 'info';
                                return 'gray';
                            }),
                        Infolists\Components\TextEntry::make('user.name')
                            ->label('Utilisateur'),
                        Infolists\Components\TextEntry::make('user.email')
                            ->label('Email'),
                    ])->columns(3),

                Infolists\Components\Section::make('Statistiques')
                    ->schema([
                        Infolists\Components\TextEntry::make('total_points')
                            ->label('Points totaux')
                            ->badge()
                            ->color('success'),
                        Infolists\Components\TextEntry::make('total_predictions')
                            ->label('Nombre de prédictions'),
                        Infolists\Components\TextEntry::make('correct_predictions')
                            ->label('Prédictions correctes')
                            ->color('success'),
                        Infolists\Components\TextEntry::make('accuracy_percentage')
                            ->label('Précision')
                            ->suffix('%')
                            ->badge()
                            ->color(function ($state) {
                                if ($state >= 80) return 'success';
                                if ($state >= 60) return 'warning';
                                if ($state >= 40) return 'gray';
                                return 'danger';
                            }),
                        Infolists\Components\TextEntry::make('points_per_prediction')
                            ->label('Points par prédiction')
                            ->formatStateUsing(function ($record) {
                                if ($record->total_predictions > 0) {
                                    return round($record->total_points / $record->total_predictions, 2);
                                }
                                return '0';
                            })
                            ->badge()
                            ->color('info'),
                        Infolists\Components\TextEntry::make('success_rate')
                            ->label('Taux de réussite')
                            ->formatStateUsing(function ($record) {
                                if ($record->total_predictions > 0) {
                                    return round(($record->correct_predictions / $record->total_predictions) * 100, 1) . '%';
                                }
                                return '0%';
                            })
                            ->badge(),
                    ])->columns(3),

                Infolists\Components\Section::make('Historique')
                    ->schema([
                        Infolists\Components\TextEntry::make('created_at')
                            ->label('Première entrée')
                            ->dateTime('d/m/Y H:i'),
                        Infolists\Components\TextEntry::make('updated_at')
                            ->label('Dernière mise à jour')
                            ->dateTime('d/m/Y H:i'),
                    ])->columns(2),
            ]);
    }
} 