<?php

namespace App\Filament\Resources;

use App\Filament\Resources\LeaderboardResource\Pages;
use App\Filament\Resources\LeaderboardResource\RelationManagers;
use App\Models\Leaderboard;
use App\Models\User;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class LeaderboardResource extends Resource
{
    protected static ?string $model = Leaderboard::class;

    protected static ?string $navigationIcon = 'heroicon-o-trophy';
    protected static ?string $navigationGroup = 'Pronostics';
    protected static ?string $navigationLabel = 'Classement';
    protected static ?string $modelLabel = 'Classement';
    protected static ?string $pluralModelLabel = 'Classements';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Informations du classement')
                    ->schema([
                        Forms\Components\Select::make('user_id')
                            ->label('Utilisateur')
                            ->relationship('user', 'name')
                            ->required()
                            ->searchable(),
                        
                        Forms\Components\TextInput::make('rank')
                            ->label('Rang')
                            ->numeric()
                            ->minValue(1)
                            ->required(),
                        
                        Forms\Components\TextInput::make('total_points')
                            ->label('Points totaux')
                            ->numeric()
                            ->minValue(0)
                            ->default(0),
                        
                        Forms\Components\TextInput::make('total_predictions')
                            ->label('Nombre de prédictions')
                            ->numeric()
                            ->minValue(0)
                            ->default(0),
                        
                        Forms\Components\TextInput::make('correct_scores')
                            ->label('Scores exacts')
                            ->numeric()
                            ->minValue(0)
                            ->default(0),
                        
                        Forms\Components\TextInput::make('correct_winners')
                            ->label('Gagnants corrects')
                            ->numeric()
                            ->minValue(0)
                            ->default(0),
                        
                        Forms\Components\TextInput::make('accuracy_percentage')
                            ->label('Pourcentage de précision')
                            ->numeric()
                            ->minValue(0)
                            ->maxValue(100)
                            ->step(0.1)
                            ->suffix('%'),
                    ])->columns(2),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('rank')
                    ->label('Rang')
                    ->sortable()
                    ->badge()
                    ->color(function ($state) {
                        if ($state == 1) return 'warning'; // Or
                        if ($state == 2) return 'gray'; // Argent
                        if ($state == 3) return 'success'; // Bronze
                        if ($state <= 10) return 'info';
                        return 'gray';
                    }),
                
                Tables\Columns\TextColumn::make('user.name')
                    ->label('Utilisateur')
                    ->sortable()
                    ->searchable(),
                
                Tables\Columns\TextColumn::make('total_points')
                    ->label('Points')
                    ->sortable()
                    ->badge()
                    ->color('success'),
                
                Tables\Columns\TextColumn::make('total_predictions')
                    ->label('Prédictions')
                    ->sortable(),
                
                Tables\Columns\TextColumn::make('correct_predictions')
                    ->label('Correctes')
                    ->sortable()
                    ->color('success'),
                
                Tables\Columns\TextColumn::make('accuracy_percentage')
                    ->label('Précision')
                    ->sortable()
                    ->suffix('%')
                    ->badge()
                    ->color(function ($state) {
                        if ($state >= 80) return 'success';
                        if ($state >= 60) return 'warning';
                        if ($state >= 40) return 'gray';
                        return 'danger';
                    }),
                
                Tables\Columns\TextColumn::make('points_per_prediction')
                    ->label('Points/Prédiction')
                    ->formatStateUsing(function ($record) {
                        if ($record->total_predictions > 0) {
                            return round($record->total_points / $record->total_predictions, 2);
                        }
                        return '0';
                    })
                    ->badge()
                    ->color('info'),
                
                Tables\Columns\TextColumn::make('updated_at')
                    ->label('Dernière MAJ')
                    ->dateTime('d/m/Y H:i')
                    ->sortable(),
            ])
            ->defaultSort('rank', 'asc')
            ->filters([
                Tables\Filters\Filter::make('top_10')
                    ->label('Top 10')
                    ->query(fn (Builder $query): Builder => $query->where('rank', '<=', 10)),
                
                Tables\Filters\Filter::make('top_50')
                    ->label('Top 50')
                    ->query(fn (Builder $query): Builder => $query->where('rank', '<=', 50)),
                
                Tables\Filters\Filter::make('high_accuracy')
                    ->label('Haute précision (>70%)')
                    ->query(fn (Builder $query): Builder => $query->where('accuracy_percentage', '>', 70)),
                
                Tables\Filters\Filter::make('active_players')
                    ->label('Joueurs actifs (>5 prédictions)')
                    ->query(fn (Builder $query): Builder => $query->where('total_predictions', '>', 5)),
                
                Tables\Filters\Filter::make('points_range')
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
                                fn (Builder $query, $min): Builder => $query->where('total_points', '>=', $min),
                            )
                            ->when(
                                $data['max_points'],
                                fn (Builder $query, $max): Builder => $query->where('total_points', '<=', $max),
                            );
                    }),
            ])
            ->actions([
                Tables\Actions\ViewAction::make(),
                Tables\Actions\EditAction::make(),
                Tables\Actions\Action::make('recalculate')
                    ->label('Recalculer')
                    ->icon('heroicon-o-arrow-path')
                    ->color('warning')
                    ->action(function ($record) {
                        // Logique pour recalculer le classement d'un utilisateur
                        $user = $record->user;
                        $predictions = $user->predictions()->where('is_calculated', true)->get();
                        
                        $totalPoints = $predictions->sum('points_earned');
                        $totalPredictions = $predictions->count();
                        $correctPredictions = $predictions->where('points_earned', '>', 0)->count();
                        $accuracy = $totalPredictions > 0 ? round(($correctPredictions / $totalPredictions) * 100, 1) : 0;
                        
                        $record->update([
                            'total_points' => $totalPoints,
                            'total_predictions' => $totalPredictions,
                            'correct_predictions' => $correctPredictions,
                            'accuracy_percentage' => $accuracy,
                            'updated_at' => now()
                        ]);
                        
                        \Filament\Notifications\Notification::make()
                            ->title('Classement recalculé avec succès')
                            ->success()
                            ->send();
                    }),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                    Tables\Actions\BulkAction::make('recalculate_all')
                        ->label('Recalculer tous')
                        ->icon('heroicon-o-arrow-path')
                        ->color('warning')
                        ->action(function ($records) {
                            $updated = 0;
                            foreach ($records as $record) {
                                $user = $record->user;
                                $predictions = $user->predictions()->where('is_calculated', true)->get();
                                
                                $totalPoints = $predictions->sum('points_earned');
                                $totalPredictions = $predictions->count();
                                $correctPredictions = $predictions->where('points_earned', '>', 0)->count();
                                $accuracy = $totalPredictions > 0 ? round(($correctPredictions / $totalPredictions) * 100, 1) : 0;
                                
                                $record->update([
                                    'total_points' => $totalPoints,
                                    'total_predictions' => $totalPredictions,
                                    'correct_predictions' => $correctPredictions,
                                    'accuracy_percentage' => $accuracy,
                                    'updated_at' => now()
                                ]);
                                $updated++;
                            }
                            
                            \Filament\Notifications\Notification::make()
                                ->title("$updated classements recalculés")
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
            'index' => Pages\ListLeaderboards::route('/'),
            'create' => Pages\CreateLeaderboard::route('/create'),
            'view' => Pages\ViewLeaderboard::route('/{record}'),
            'edit' => Pages\EditLeaderboard::route('/{record}/edit'),
        ];
    }
    
    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery()
            ->with(['user']);
    }
}
