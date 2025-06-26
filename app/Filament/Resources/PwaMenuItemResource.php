<?php

namespace App\Filament\Resources;

use App\Filament\Resources\PwaMenuItemResource\Pages;
use App\Models\PwaMenuItem;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class PwaMenuItemResource extends Resource
{
    protected static ?string $model = PwaMenuItem::class;

    protected static ?string $navigationIcon = 'heroicon-o-bars-3-bottom-left';

    protected static ?string $navigationLabel = 'Menu PWA';

    protected static ?string $modelLabel = 'Élément de menu PWA';

    protected static ?string $pluralModelLabel = 'Éléments de menu PWA';

    protected static ?string $navigationGroup = 'Configuration PWA';

    protected static ?int $navigationSort = 10;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Informations générales')
                    ->schema([
                        Forms\Components\TextInput::make('name')
                            ->label('Nom technique')
                            ->required()
                            ->unique(ignoreRecord: true)
                            ->placeholder('Ex: home, recipes, tips...')
                            ->helperText('Nom unique utilisé en interne (sans espaces)')
                            ->rules(['alpha_dash']),

                        Forms\Components\TextInput::make('label')
                            ->label('Libellé')
                            ->required()
                            ->placeholder('Ex: Accueil, Recettes, Astuces...')
                            ->helperText('Texte affiché à l\'utilisateur'),

                        Forms\Components\Select::make('icon')
                            ->label('Icône')
                            ->required()
                            ->options(PwaMenuItem::AVAILABLE_ICONS)
                            ->searchable()
                            ->preload()
                            ->helperText('Icône Material Design affichée dans la navigation'),

                        Forms\Components\TextInput::make('order')
                            ->label('Ordre d\'affichage')
                            ->numeric()
                            ->default(0)
                            ->required()
                            ->helperText('Ordre d\'affichage dans la navigation (plus petit = premier)'),

                        Forms\Components\Toggle::make('is_active')
                            ->label('Actif')
                            ->default(true)
                            ->helperText('Afficher cet élément dans la navigation'),
                    ])->columns(2),

                Forms\Components\Section::make('Action et navigation')
                    ->schema([
                        Forms\Components\Select::make('action_type')
                            ->label('Type d\'action')
                            ->required()
                            ->options(PwaMenuItem::ACTION_TYPES)
                            ->default('route')
                            ->live()
                            ->helperText('Type d\'action à effectuer lors du clic'),

                        Forms\Components\TextInput::make('path')
                            ->label('Chemin de navigation')
                            ->placeholder('Ex: /, /recipes, /tips...')
                            ->helperText('Chemin interne de l\'application')
                            ->visible(fn (Forms\Get $get): bool => $get('action_type') === 'route'),

                        Forms\Components\Textarea::make('web_url')
                            ->label('URL web')
                            ->placeholder('Ex: https://example.com')
                            ->helperText('URL à ouvrir (pour les types web_embed et external_link)')
                            ->visible(fn (Forms\Get $get): bool => in_array($get('action_type'), ['web_embed', 'external_link']))
                            ->rows(2),

                        Forms\Components\Textarea::make('description')
                            ->label('Description')
                            ->placeholder('Description de cet élément de menu pour l\'administration')
                            ->helperText('Description visible uniquement dans l\'administration')
                            ->rows(3),
                    ]),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('order')
                    ->label('Ordre')
                    ->sortable()
                    ->badge()
                    ->color('gray'),

                Tables\Columns\TextColumn::make('label')
                    ->label('Libellé')
                    ->searchable()
                    ->sortable()
                    ->weight('bold'),

                Tables\Columns\TextColumn::make('icon')
                    ->label('Icône')
                    ->badge()
                    ->color('primary')
                    ->formatStateUsing(fn (string $state): string => $state . ' (' . (PwaMenuItem::AVAILABLE_ICONS[$state] ?? 'Inconnue') . ')'),

                Tables\Columns\TextColumn::make('action_type')
                    ->label('Type')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'route' => 'success',
                        'web_embed' => 'info',
                        'external_link' => 'warning',
                        default => 'gray',
                    })
                    ->formatStateUsing(fn (string $state): string => PwaMenuItem::ACTION_TYPES[$state] ?? $state),

                Tables\Columns\TextColumn::make('path')
                    ->label('Chemin')
                    ->limit(30)
                    ->tooltip(function (Tables\Columns\TextColumn $column): ?string {
                        $state = $column->getState();
                        return strlen($state) > 30 ? $state : null;
                    }),

                Tables\Columns\IconColumn::make('is_active')
                    ->label('Actif')
                    ->boolean()
                    ->sortable(),

                Tables\Columns\TextColumn::make('created_at')
                    ->label('Créé le')
                    ->dateTime('d/m/Y H:i')
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('action_type')
                    ->label('Type d\'action')
                    ->options(PwaMenuItem::ACTION_TYPES),
                
                Tables\Filters\TernaryFilter::make('is_active')
                    ->label('Statut')
                    ->boolean()
                    ->trueLabel('Actifs uniquement')
                    ->falseLabel('Inactifs uniquement')
                    ->native(false),
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make()
                    ->requiresConfirmation(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make()
                        ->requiresConfirmation(),
                ]),
            ])
            ->defaultSort('order');
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
            'index' => Pages\ListPwaMenuItems::route('/'),
            'create' => Pages\CreatePwaMenuItem::route('/create'),
            'edit' => Pages\EditPwaMenuItem::route('/{record}/edit'),
        ];
    }

    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery()
            ->orderBy('order');
    }
} 