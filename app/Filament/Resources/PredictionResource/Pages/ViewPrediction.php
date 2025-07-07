<?php

namespace App\Filament\Resources\PredictionResource\Pages;

use App\Filament\Resources\PredictionResource;
use Filament\Actions;
use Filament\Resources\Pages\ViewRecord;
use Filament\Infolists;
use Filament\Infolists\Infolist;

class ViewPrediction extends ViewRecord
{
    protected static string $resource = PredictionResource::class;

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
                Infolists\Components\Section::make('Informations du match')
                    ->schema([
                        Infolists\Components\TextEntry::make('footballMatch.homeTeam.name')
                            ->label('Équipe domicile'),
                        Infolists\Components\TextEntry::make('footballMatch.awayTeam.name')
                            ->label('Équipe extérieure'),
                        Infolists\Components\TextEntry::make('footballMatch.match_date')
                            ->label('Date du match')
                            ->dateTime('d/m/Y H:i'),
                        Infolists\Components\TextEntry::make('footballMatch.status')
                            ->label('Statut du match')
                            ->badge()
                            ->color(fn (string $state): string => match ($state) {
                                'scheduled' => 'warning',
                                'live' => 'success',
                                'finished' => 'gray',
                                'cancelled' => 'danger',
                            }),
                    ])->columns(2),

                Infolists\Components\Section::make('Prédiction')
                    ->schema([
                        Infolists\Components\TextEntry::make('user.name')
                            ->label('Utilisateur'),
                        Infolists\Components\TextEntry::make('predicted_score')
                            ->label('Score prédit')
                            ->formatStateUsing(function ($record) {
                                return $record->predicted_home_score . ' - ' . $record->predicted_away_score;
                            }),
                        Infolists\Components\TextEntry::make('predicted_winner')
                            ->label('Gagnant prédit')
                            ->badge()
                            ->color(fn (string $state): string => match ($state) {
                                'home' => 'success',
                                'away' => 'danger',
                                'draw' => 'warning',
                            })
                            ->formatStateUsing(fn (string $state): string => match ($state) {
                                'home' => 'Domicile',
                                'away' => 'Extérieur',
                                'draw' => 'Match nul',
                            }),
                        Infolists\Components\TextEntry::make('created_at')
                            ->label('Date de prédiction')
                            ->dateTime('d/m/Y H:i'),
                    ])->columns(2),

                Infolists\Components\Section::make('Résultat')
                    ->schema([
                        Infolists\Components\TextEntry::make('actual_score')
                            ->label('Score réel')
                            ->formatStateUsing(function ($record) {
                                $match = $record->footballMatch;
                                if ($match->home_score !== null && $match->away_score !== null) {
                                    return $match->home_score . ' - ' . $match->away_score;
                                }
                                return 'Match non terminé';
                            }),
                        Infolists\Components\TextEntry::make('points_earned')
                            ->label('Points gagnés')
                            ->badge()
                            ->color(function ($state) {
                                if ($state >= 3) return 'success';
                                if ($state >= 1) return 'warning';
                                return 'gray';
                            }),
                        Infolists\Components\IconEntry::make('is_calculated')
                            ->label('Points calculés')
                            ->boolean(),
                    ])->columns(3),

                Infolists\Components\Section::make('Informations techniques')
                    ->schema([
                        Infolists\Components\TextEntry::make('ip_address')
                            ->label('Adresse IP'),
                        Infolists\Components\TextEntry::make('user_agent')
                            ->label('User Agent')
                            ->limit(50),
                        Infolists\Components\TextEntry::make('updated_at')
                            ->label('Dernière mise à jour')
                            ->dateTime('d/m/Y H:i'),
                    ])->columns(1)
                    ->collapsible(),
            ]);
    }
} 