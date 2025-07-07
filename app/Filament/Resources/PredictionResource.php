<?php

namespace App\Filament\Resources;

use App\Filament\Resources\PredictionResource\Pages;
use App\Filament\Resources\PredictionResource\RelationManagers;
use App\Models\Prediction;
use App\Models\User;
use App\Models\FootballMatch;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class PredictionResource extends Resource
{
    protected static ?string $model = Prediction::class;

    protected static ?string $navigationIcon = 'heroicon-o-chart-bar';
    protected static ?string $navigationGroup = 'Pronostics';
    protected static ?string $navigationLabel = 'Prédictions';
    protected static ?string $modelLabel = 'Prédiction';
    protected static ?string $pluralModelLabel = 'Prédictions';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Informations de la prédiction')
                    ->schema([
                        Forms\Components\Select::make('user_id')
                            ->label('Utilisateur')
                            ->relationship('user', 'name')
                            ->required()
                            ->searchable(),
                        
                        Forms\Components\Select::make('football_match_id')
                            ->label('Match')
                            ->relationship('footballMatch', 'id')
                            ->getOptionLabelFromRecordUsing(function ($record) {
                                return $record->homeTeam->name . ' vs ' . $record->awayTeam->name . ' - ' . $record->match_date->format('d/m/Y H:i');
                            })
                            ->required()
                            ->searchable(),
                        
                        Forms\Components\Grid::make(2)
                            ->schema([
                                Forms\Components\TextInput::make('predicted_home_score')
                                    ->label('Score domicile prédit')
                                    ->numeric()
                                    ->minValue(0)
                                    ->required(),
                                
                                Forms\Components\TextInput::make('predicted_away_score')
                                    ->label('Score extérieur prédit')
                                    ->numeric()
                                    ->minValue(0)
                                    ->required(),
                            ]),
                        
                        Forms\Components\Select::make('predicted_winner')
                            ->label('Gagnant prédit')
                            ->options([
                                'home' => 'Domicile',
                                'away' => 'Extérieur',
                                'draw' => 'Match nul',
                            ])
                            ->required(),
                        
                        Forms\Components\TextInput::make('points_earned')
                            ->label('Points gagnés')
                            ->numeric()
                            ->minValue(0)
                            ->default(0),
                        
                        Forms\Components\Toggle::make('is_calculated')
                            ->label('Points calculés')
                            ->default(false),
                    ])->columns(2),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('user.name')
                    ->label('Utilisateur')
                    ->sortable()
                    ->searchable(),
                
                Tables\Columns\TextColumn::make('footballMatch.homeTeam.name')
                    ->label('Équipe domicile')
                    ->sortable()
                    ->searchable(),
                
                Tables\Columns\TextColumn::make('footballMatch.awayTeam.name')
                    ->label('Équipe extérieure')
                    ->sortable()
                    ->searchable(),
                
                Tables\Columns\TextColumn::make('predicted_score')
                    ->label('Score prédit')
                    ->formatStateUsing(function ($record) {
                        return $record->predicted_home_score . ' - ' . $record->predicted_away_score;
                    }),
                
                Tables\Columns\TextColumn::make('actual_score')
                    ->label('Score réel')
                    ->formatStateUsing(function ($record) {
                        $match = $record->footballMatch;
                        if ($match->home_score !== null && $match->away_score !== null) {
                            return $match->home_score . ' - ' . $match->away_score;
                        }
                        return '-';
                    }),
                
                Tables\Columns\TextColumn::make('predicted_winner')
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
                
                Tables\Columns\TextColumn::make('points_earned')
                    ->label('Points')
                    ->sortable()
                    ->badge()
                    ->color(function ($state) {
                        if ($state >= 3) return 'success';
                        if ($state >= 1) return 'warning';
                        return 'gray';
                    }),
                
                Tables\Columns\IconColumn::make('is_calculated')
                    ->label('Calculé')
                    ->boolean(),
                
                Tables\Columns\TextColumn::make('footballMatch.match_date')
                    ->label('Date du match')
                    ->dateTime('d/m/Y H:i')
                    ->sortable(),
                
                Tables\Columns\TextColumn::make('created_at')
                    ->label('Date de prédiction')
                    ->dateTime('d/m/Y H:i')
                    ->sortable(),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                Tables\Filters\SelectFilter::make('is_calculated')
                    ->label('Statut calcul')
                    ->options([
                        '1' => 'Calculées',
                        '0' => 'En attente',
                    ]),
                
                Tables\Filters\SelectFilter::make('predicted_winner')
                    ->label('Gagnant prédit')
                    ->options([
                        'home' => 'Domicile',
                        'away' => 'Extérieur',
                        'draw' => 'Match nul',
                    ]),
                
                Tables\Filters\Filter::make('points_earned')
                    ->form([
                        Forms\Components\TextInput::make('min_points')
                            ->label('Points minimum')
                            ->numeric(),
                        Forms\Components\TextInput::make('max_points')
                            ->label('Points maximum')
                            ->numeric(),
                    ])
                    ->query(function (Builder $query, array $data): Builder {
                        return $query
                            ->when(
                                $data['min_points'],
                                fn (Builder $query, $min): Builder => $query->where('points_earned', '>=', $min),
                            )
                            ->when(
                                $data['max_points'],
                                fn (Builder $query, $max): Builder => $query->where('points_earned', '<=', $max),
                            );
                    }),
            ])
            ->actions([
                Tables\Actions\ViewAction::make(),
                Tables\Actions\EditAction::make(),
                Tables\Actions\Action::make('calculate_points')
                    ->label('Calculer points')
                    ->icon('heroicon-o-calculator')
                    ->color('warning')
                    ->visible(fn ($record) => !$record->is_calculated && $record->footballMatch->status === 'finished')
                    ->action(function ($record) {
                        $record->calculatePoints();
                        \Filament\Notifications\Notification::make()
                            ->title('Points calculés avec succès')
                            ->success()
                            ->send();
                    }),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                    Tables\Actions\BulkAction::make('calculate_bulk_points')
                        ->label('Calculer points en masse')
                        ->icon('heroicon-o-calculator')
                        ->color('warning')
                        ->action(function ($records) {
                            $calculated = 0;
                            foreach ($records as $record) {
                                if (!$record->is_calculated && $record->footballMatch->status === 'finished') {
                                    $record->calculatePoints();
                                    $calculated++;
                                }
                            }
                            \Filament\Notifications\Notification::make()
                                ->title("$calculated prédictions calculées")
                                ->success()
                                ->send();
                        }),
                ]),
            ]);
    }

    public static function getRelations(): array
    {
        return [
            //
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListPredictions::route('/'),
            'create' => Pages\CreatePrediction::route('/create'),
            'view' => Pages\ViewPrediction::route('/{record}'),
            'edit' => Pages\EditPrediction::route('/{record}/edit'),
        ];
    }
    
    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery()
            ->with(['user', 'footballMatch.homeTeam', 'footballMatch.awayTeam']);
    }
}
