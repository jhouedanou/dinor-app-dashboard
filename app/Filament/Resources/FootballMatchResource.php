<?php

namespace App\Filament\Resources;

use App\Filament\Resources\FootballMatchResource\Pages;
use App\Filament\Resources\FootballMatchResource\RelationManagers;
use App\Models\FootballMatch;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class FootballMatchResource extends Resource
{
    protected static ?string $model = FootballMatch::class;

    protected static ?string $navigationIcon = 'heroicon-o-trophy';
    protected static ?string $navigationGroup = 'Pronostics';
    protected static ?string $navigationLabel = 'Matchs';
    protected static ?string $modelLabel = 'Match';
    protected static ?string $pluralModelLabel = 'Matchs';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Select::make('home_team_id')
                    ->label('Équipe à domicile')
                    ->relationship('homeTeam', 'name')
                    ->required()
                    ->searchable(),
                
                Forms\Components\Select::make('away_team_id')
                    ->label('Équipe extérieure')
                    ->relationship('awayTeam', 'name')
                    ->required()
                    ->searchable(),
                
                Forms\Components\DateTimePicker::make('match_date')
                    ->label('Date du match')
                    ->required()
                    ->seconds(false),
                
                Forms\Components\DateTimePicker::make('predictions_close_at')
                    ->label('Fermeture des pronostics')
                    ->helperText('Laisser vide pour fermer automatiquement au début du match')
                    ->seconds(false),
                
                Forms\Components\Select::make('status')
                    ->label('Statut')
                    ->options([
                        'scheduled' => 'Programmé',
                        'live' => 'En cours',
                        'finished' => 'Terminé',
                        'cancelled' => 'Annulé',
                    ])
                    ->default('scheduled')
                    ->required(),
                
                Forms\Components\Grid::make(2)
                    ->schema([
                        Forms\Components\TextInput::make('home_score')
                            ->label('Score domicile')
                            ->numeric()
                            ->minValue(0),
                        
                        Forms\Components\TextInput::make('away_score')
                            ->label('Score extérieur')
                            ->numeric()
                            ->minValue(0),
                    ]),
                
                Forms\Components\TextInput::make('competition')
                    ->label('Compétition')
                    ->placeholder('Ligue 1, Champions League, etc.'),
                
                Forms\Components\TextInput::make('round')
                    ->label('Journée/Phase')
                    ->placeholder('Journée 15, 1/8 finale, etc.'),
                
                Forms\Components\TextInput::make('venue')
                    ->label('Lieu')
                    ->placeholder('Parc des Princes, Camp Nou, etc.'),
                
                Forms\Components\Textarea::make('notes')
                    ->label('Notes')
                    ->rows(3),
                
                Forms\Components\Grid::make(2)
                    ->schema([
                        Forms\Components\Toggle::make('is_active')
                            ->label('Match actif')
                            ->default(true),
                        
                        Forms\Components\Toggle::make('predictions_enabled')
                            ->label('Pronostics autorisés')
                            ->default(true),
                    ]),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('homeTeam.name')
                    ->label('Équipe domicile')
                    ->sortable(),
                
                Tables\Columns\TextColumn::make('awayTeam.name')
                    ->label('Équipe extérieure')
                    ->sortable(),
                
                Tables\Columns\TextColumn::make('match_date')
                    ->label('Date')
                    ->dateTime('d/m/Y H:i')
                    ->sortable(),
                
                Tables\Columns\TextColumn::make('status')
                    ->label('Statut')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'scheduled' => 'warning',
                        'live' => 'success',
                        'finished' => 'gray',
                        'cancelled' => 'danger',
                    }),
                
                Tables\Columns\TextColumn::make('home_score')
                    ->label('Score')
                    ->formatStateUsing(function ($record) {
                        if ($record->home_score !== null && $record->away_score !== null) {
                            return $record->home_score . ' - ' . $record->away_score;
                        }
                        return '-';
                    }),
                
                Tables\Columns\TextColumn::make('competition')
                    ->label('Compétition')
                    ->searchable(),
                
                Tables\Columns\IconColumn::make('predictions_enabled')
                    ->label('Pronostics')
                    ->boolean(),
            ])
            ->defaultSort('match_date', 'desc')
            ->filters([
                //
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
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
            'index' => Pages\ListFootballMatches::route('/'),
            'create' => Pages\CreateFootballMatch::route('/create'),
            'edit' => Pages\EditFootballMatch::route('/{record}/edit'),
        ];
    }
}
