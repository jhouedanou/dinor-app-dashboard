<?php

namespace App\Filament\Resources;

use App\Filament\Resources\TournamentResource\Pages;
use App\Filament\Resources\TournamentResource\RelationManagers;
use App\Models\Tournament;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class TournamentResource extends Resource
{
    protected static ?string $model = Tournament::class;

    protected static ?string $navigationIcon = 'heroicon-o-trophy';
    
    protected static ?string $navigationLabel = 'Tournois';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Informations générales')
                    ->schema([
                        Forms\Components\TextInput::make('name')
                            ->label('Nom du tournoi')
                            ->required()
                            ->maxLength(255),
                        Forms\Components\Textarea::make('description')
                            ->label('Description')
                            ->rows(3),
                    ]),
                    
                Forms\Components\Section::make('Dates et délais')
                    ->schema([
                        Forms\Components\DateTimePicker::make('start_date')
                            ->label('Date de début')
                            ->required(),
                        Forms\Components\DateTimePicker::make('end_date')
                            ->label('Date de fin')
                            ->required(),
                        Forms\Components\DateTimePicker::make('registration_start')
                            ->label('Début des inscriptions'),
                        Forms\Components\DateTimePicker::make('registration_end')
                            ->label('Fin des inscriptions'),
                    ])->columns(2),
                    
                Forms\Components\Section::make('Configuration')
                    ->schema([
                        Forms\Components\Select::make('status')
                            ->label('Statut')
                            ->options([
                                'upcoming' => 'À venir',
                                'registration_open' => 'Inscriptions ouvertes',
                                'registration_closed' => 'Inscriptions fermées',
                                'active' => 'En cours',
                                'finished' => 'Terminé',
                                'cancelled' => 'Annulé',
                            ])
                            ->required(),
                        Forms\Components\TextInput::make('max_participants')
                            ->label('Nombre max de participants')
                            ->numeric(),
                        Forms\Components\Toggle::make('is_featured')
                            ->label('Mis en avant'),
                        Forms\Components\Toggle::make('is_public')
                            ->label('Public')
                            ->default(true),
                    ])->columns(2),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('name')
                    ->label('Nom')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\BadgeColumn::make('status')
                    ->label('Statut')
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'upcoming' => 'À venir',
                        'registration_open' => 'Inscriptions ouvertes',
                        'registration_closed' => 'Inscriptions fermées',
                        'active' => 'En cours',
                        'finished' => 'Terminé',
                        'cancelled' => 'Annulé',
                        default => $state,
                    }),
                Tables\Columns\TextColumn::make('start_date')
                    ->label('Date de début')
                    ->dateTime('d/m/Y H:i')
                    ->sortable(),
                Tables\Columns\TextColumn::make('end_date')
                    ->label('Date de fin')
                    ->dateTime('d/m/Y H:i')
                    ->sortable(),
                Tables\Columns\IconColumn::make('is_featured')
                    ->label('Mis en avant')
                    ->boolean(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->label('Statut')
                    ->options([
                        'upcoming' => 'À venir',
                        'registration_open' => 'Inscriptions ouvertes',
                        'registration_closed' => 'Inscriptions fermées',
                        'active' => 'En cours',
                        'finished' => 'Terminé',
                        'cancelled' => 'Annulé',
                    ]),
            ])
            ->actions([
                Tables\Actions\ViewAction::make(),
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
            'index' => Pages\ListTournaments::route('/'),
            'create' => Pages\CreateTournament::route('/create'),
            'view' => Pages\ViewTournament::route('/{record}'),
            'edit' => Pages\EditTournament::route('/{record}/edit'),
        ];
    }
}
