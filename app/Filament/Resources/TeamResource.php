<?php

namespace App\Filament\Resources;

use App\Filament\Resources\TeamResource\Pages;
use App\Filament\Resources\TeamResource\RelationManagers;
use App\Models\Team;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class TeamResource extends Resource
{
    protected static ?string $model = Team::class;

    protected static ?string $navigationIcon = 'heroicon-o-user-group';
    protected static ?string $navigationGroup = 'Pronostics';
    protected static ?string $navigationLabel = 'Équipes';
    protected static ?string $modelLabel = 'Équipe';
    protected static ?string $pluralModelLabel = 'Équipes';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\TextInput::make('name')
                    ->label('Nom de l\'équipe')
                    ->required()
                    ->maxLength(255),
                
                Forms\Components\TextInput::make('short_name')
                    ->label('Nom court')
                    ->maxLength(10)
                    ->helperText('Acronyme ou nom court (ex: PSG, OM)'),
                
                Forms\Components\Select::make('country')
                    ->label('Pays')
                    ->options([
                        'FRA' => 'France',
                        'ESP' => 'Espagne',
                        'ITA' => 'Italie',
                        'GER' => 'Allemagne',
                        'ENG' => 'Angleterre',
                        'POR' => 'Portugal',
                        'NED' => 'Pays-Bas',
                        'BEL' => 'Belgique',
                    ])
                    ->searchable(),
                
                Forms\Components\FileUpload::make('logo')
                    ->label('Logo')
                    ->image()
                    ->directory('teams/logos')
                    ->disk('public'),
                
                Forms\Components\ColorPicker::make('color_primary')
                    ->label('Couleur principale'),
                
                Forms\Components\ColorPicker::make('color_secondary')
                    ->label('Couleur secondaire'),
                
                Forms\Components\TextInput::make('founded_year')
                    ->label('Année de fondation')
                    ->numeric()
                    ->minValue(1800)
                    ->maxValue(date('Y')),
                
                Forms\Components\Textarea::make('description')
                    ->label('Description')
                    ->rows(3),
                
                Forms\Components\Toggle::make('is_active')
                    ->label('Équipe active')
                    ->default(true),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\ImageColumn::make('logo')
                    ->label('Logo')
                    ->disk('public')
                    ->size(40),
                
                Tables\Columns\TextColumn::make('name')
                    ->label('Nom')
                    ->searchable()
                    ->sortable(),
                
                Tables\Columns\TextColumn::make('short_name')
                    ->label('Nom court')
                    ->searchable(),
                
                Tables\Columns\TextColumn::make('country')
                    ->label('Pays')
                    ->badge(),
                
                Tables\Columns\IconColumn::make('is_active')
                    ->label('Active')
                    ->boolean(),
                
                Tables\Columns\TextColumn::make('created_at')
                    ->label('Créée le')
                    ->dateTime('d/m/Y H:i')
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->defaultSort('name')
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
            'index' => Pages\ListTeams::route('/'),
            'create' => Pages\CreateTeam::route('/create'),
            'edit' => Pages\EditTeam::route('/{record}/edit'),
        ];
    }
}
