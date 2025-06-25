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
    protected static ?string $modelLabel = 'Élément de menu';
    protected static ?string $pluralModelLabel = 'Éléments de menu';
    protected static ?string $navigationGroup = 'Configuration PWA';
    protected static ?int $navigationSort = 10;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Configuration de l\'élément de menu')
                    ->description('Configurez l\'apparence et le comportement de cet élément dans le menu de navigation PWA')
                    ->schema([
                        Forms\Components\TextInput::make('label')
                            ->label('Libellé')
                            ->required()
                            ->maxLength(255)
                            ->helperText('Texte affiché sous l\'icône dans le menu'),

                        Forms\Components\Select::make('icon')
                            ->label('Icône')
                            ->required()
                            ->options([
                                'heroicon-o-home' => '🏠 Accueil',
                                'heroicon-o-cake' => '🍰 Recettes',
                                'heroicon-o-light-bulb' => '💡 Astuces',
                                'heroicon-o-play-circle' => '▶️ Vidéo',
                                'heroicon-o-calendar-days' => '📅 Calendrier',
                                'heroicon-o-document-text' => '📄 Pages',
                                'heroicon-o-heart' => '❤️ Favoris',
                                'heroicon-o-star' => '⭐ Étoile',
                                'heroicon-o-fire' => '🔥 Tendance',
                                'heroicon-o-bolt' => '⚡ Éclair',
                                'heroicon-o-map-pin' => '📍 Localisation',
                                'heroicon-o-phone' => '📞 Contact',
                                'heroicon-o-user' => '👤 Profil',
                                'heroicon-o-cog-6-tooth' => '⚙️ Paramètres',
                            ])
                            ->searchable()
                            ->helperText('Icône affichée dans le menu de navigation'),

                        Forms\Components\Select::make('route')
                            ->label('Route/Section')
                            ->required()
                            ->options([
                                'home' => 'Accueil',
                                'recipes' => 'Recettes',
                                'tips' => 'Astuces',
                                'dinor-tv' => 'Dinor TV',
                                'events' => 'Événements',
                                'pages' => 'Pages personnalisées',
                            ])
                            ->helperText('Section de l\'application à afficher'),

                        Forms\Components\ColorPicker::make('color')
                            ->label('Couleur de l\'icône')
                            ->default('#E1251B')
                            ->helperText('Couleur de l\'icône dans le menu'),

                        Forms\Components\TextInput::make('order')
                            ->label('Ordre d\'affichage')
                            ->numeric()
                            ->default(0)
                            ->helperText('Position dans le menu (1 = premier)'),

                        Forms\Components\Toggle::make('is_active')
                            ->label('Élément actif')
                            ->default(true)
                            ->helperText('L\'élément apparaît dans le menu'),
                    ])->columns(2),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('order')
                    ->label('#')
                    ->sortable()
                    ->alignCenter()
                    ->badge()
                    ->color('primary'),

                Tables\Columns\TextColumn::make('label')
                    ->label('Libellé')
                    ->searchable()
                    ->sortable()
                    ->weight('bold'),

                Tables\Columns\TextColumn::make('icon')
                    ->label('Icône')
                    ->badge()
                    ->color('gray'),

                Tables\Columns\TextColumn::make('route')
                    ->label('Section')
                    ->badge()
                    ->color('success'),

                Tables\Columns\ColorColumn::make('color')
                    ->label('Couleur')
                    ->copyable(),

                Tables\Columns\IconColumn::make('is_active')
                    ->label('Actif')
                    ->boolean()
                    ->trueIcon('heroicon-o-check-circle')
                    ->falseIcon('heroicon-o-x-circle')
                    ->trueColor('success')
                    ->falseColor('danger'),
            ])
            ->filters([
                Tables\Filters\TernaryFilter::make('is_active')
                    ->label('Statut')
                    ->boolean()
                    ->trueLabel('Actifs seulement')
                    ->falseLabel('Inactifs seulement')
                    ->native(false),
            ])
            ->actions([
                Tables\Actions\EditAction::make()
                    ->label('Modifier')
                    ->icon('heroicon-o-pencil-square'),
                    
                Tables\Actions\DeleteAction::make()
                    ->label('Supprimer')
                    ->icon('heroicon-o-trash')
                    ->successNotificationTitle('Élément supprimé avec succès'),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make()
                        ->label('Supprimer sélectionnés')
                        ->successNotificationTitle('Éléments supprimés avec succès'),

                    Tables\Actions\BulkAction::make('activate')
                        ->label('Activer')
                        ->icon('heroicon-o-check-circle')
                        ->color('success')
                        ->action(fn ($records) => $records->each->update(['is_active' => true]))
                        ->deselectRecordsAfterCompletion()
                        ->successNotificationTitle('Éléments activés'),

                    Tables\Actions\BulkAction::make('deactivate')
                        ->label('Désactiver')
                        ->icon('heroicon-o-x-circle')
                        ->color('warning')
                        ->action(fn ($records) => $records->each->update(['is_active' => false]))
                        ->deselectRecordsAfterCompletion()
                        ->successNotificationTitle('Éléments désactivés'),
                ]),
            ])
            ->defaultSort('order', 'asc')
            ->reorderable('order')
            ->emptyStateHeading('Aucun élément de menu configuré')
            ->emptyStateDescription('Configurez les éléments du menu de navigation PWA.')
            ->emptyStateIcon('heroicon-o-bars-3-bottom-left');
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
    
    public static function getNavigationBadge(): ?string
    {
        return static::getModel()::active()->count();
    }
} 