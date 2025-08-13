<?php

namespace App\Filament\Resources;

use App\Filament\Resources\SplashScreenResource\Pages;
use App\Filament\Resources\SplashScreenResource\RelationManagers;
use App\Models\SplashScreen;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class SplashScreenResource extends Resource
{
    protected static ?string $model = SplashScreen::class;

    protected static ?string $navigationIcon = 'heroicon-o-device-phone-mobile';

    protected static ?string $navigationGroup = 'Interface';

    protected static ?string $modelLabel = 'Écran de chargement';

    protected static ?string $pluralModelLabel = 'Écrans de chargement';

    protected static ?int $navigationSort = 10;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Configuration générale')
                    ->schema([
                        Forms\Components\Toggle::make('is_active')
                            ->label('Actif')
                            ->helperText('Seul un écran de chargement peut être actif à la fois')
                            ->default(false),
                            
                        Forms\Components\TextInput::make('title')
                            ->label('Titre principal')
                            ->maxLength(255)
                            ->default(''),
                            
                        Forms\Components\TextInput::make('subtitle')
                            ->label('Sous-titre')
                            ->maxLength(255)
                            ->default(''),
                            
                        Forms\Components\TextInput::make('duration')
                            ->label('Durée (millisecondes)')
                            ->numeric()
                            ->default(2500)
                            ->suffix('ms')
                            ->helperText('Durée d\'affichage en millisecondes'),
                    ]),

                Forms\Components\Section::make('Apparence du logo')
                    ->schema([
                        Forms\Components\Select::make('logo_type')
                            ->label('Type de logo')
                            ->options([
                                'default' => 'Logo par défaut',
                                'custom' => 'Logo personnalisé',
                                'none' => 'Aucun logo',
                            ])
                            ->default('default')
                            ->live(),
                            
                        Forms\Components\SpatieMediaLibraryFileUpload::make('logo')
                            ->label('Logo personnalisé')
                            ->collection('logo')
                            ->image()
                            ->imageEditor()
                            ->visible(fn ($get) => $get('logo_type') === 'custom'),
                            
                        Forms\Components\TextInput::make('logo_size')
                            ->label('Taille du logo (pixels)')
                            ->numeric()
                            ->default(80)
                            ->suffix('px')
                            ->visible(fn ($get) => $get('logo_type') !== 'none'),
                    ]),

                Forms\Components\Section::make('Arrière-plan')
                    ->schema([
                        Forms\Components\Select::make('background_type')
                            ->label('Type d\'arrière-plan')
                            ->options([
                                'gradient' => 'Dégradé',
                                'solid' => 'Couleur unie',
                                'image' => 'Image',
                            ])
                            ->default('gradient')
                            ->live(),
                            
                        Forms\Components\ColorPicker::make('background_color_start')
                            ->label('Couleur de début')
                            ->default('#E53E3E')
                            ->visible(fn ($get) => in_array($get('background_type'), ['gradient', 'solid'])),
                            
                        Forms\Components\ColorPicker::make('background_color_end')
                            ->label('Couleur de fin')
                            ->default('#C53030')
                            ->visible(fn ($get) => $get('background_type') === 'gradient'),
                            
                        Forms\Components\Select::make('background_gradient_direction')
                            ->label('Direction du dégradé')
                            ->options([
                                'top_left' => 'Haut-gauche vers bas-droite',
                                'top_right' => 'Haut-droite vers bas-gauche', 
                                'bottom_left' => 'Bas-gauche vers haut-droite',
                                'bottom_right' => 'Bas-droite vers haut-gauche',
                                'vertical' => 'Vertical (haut vers bas)',
                                'horizontal' => 'Horizontal (gauche vers droite)',
                            ])
                            ->default('top_left')
                            ->visible(fn ($get) => $get('background_type') === 'gradient'),
                            
                        Forms\Components\SpatieMediaLibraryFileUpload::make('background_image')
                            ->label('Image d\'arrière-plan')
                            ->collection('background_image')
                            ->image()
                            ->imageEditor()
                            ->visible(fn ($get) => $get('background_type') === 'image'),
                    ]),

                Forms\Components\Section::make('Couleurs et animations')
                    ->schema([
                        Forms\Components\ColorPicker::make('text_color')
                            ->label('Couleur du texte')
                            ->default('#FFFFFF'),
                            
                        Forms\Components\ColorPicker::make('progress_bar_color')
                            ->label('Couleur de la barre de progression')
                            ->default('#F4D03F'),
                            
                        Forms\Components\Select::make('animation_type')
                            ->label('Type d\'animation')
                            ->options([
                                'default' => 'Animations complètes (bulles + icônes)',
                                'minimal' => 'Animation minimale',
                                'none' => 'Aucune animation',
                            ])
                            ->default('default'),
                    ]),

                Forms\Components\Section::make('Programmation (optionnel)')
                    ->description('Planifier l\'activation de cet écran de chargement pour une période spécifique')
                    ->schema([
                        Forms\Components\DateTimePicker::make('schedule_start')
                            ->label('Date/heure de début')
                            ->helperText('Laisser vide pour activation immédiate'),
                            
                        Forms\Components\DateTimePicker::make('schedule_end')
                            ->label('Date/heure de fin') 
                            ->helperText('Laisser vide pour activation permanente'),
                    ])
                    ->collapsible(),
                    
                Forms\Components\Section::make('Métadonnées')
                    ->schema([
                        Forms\Components\KeyValue::make('meta_data')
                            ->label('Données supplémentaires')
                            ->helperText('Paramètres avancés au format clé-valeur'),
                    ])
                    ->collapsible()
                    ->collapsed(),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\ToggleColumn::make('is_active')
                    ->label('Actif')
                    ->sortable(),
                    
                Tables\Columns\TextColumn::make('title')
                    ->label('Titre')
                    ->searchable()
                    ->sortable(),
                    
                Tables\Columns\TextColumn::make('duration')
                    ->label('Durée')
                    ->suffix(' ms')
                    ->sortable(),
                    
                Tables\Columns\TextColumn::make('background_type')
                    ->label('Type d\'arrière-plan')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'gradient' => 'success',
                        'solid' => 'warning',
                        'image' => 'info',
                    }),
                    
                Tables\Columns\TextColumn::make('schedule_start')
                    ->label('Début programmé')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
                    
                Tables\Columns\TextColumn::make('schedule_end')
                    ->label('Fin programmée')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
                    
                Tables\Columns\TextColumn::make('created_at')
                    ->label('Créé le')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                Tables\Filters\TernaryFilter::make('is_active')
                    ->label('Statut')
                    ->boolean()
                    ->trueLabel('Actifs seulement')
                    ->falseLabel('Inactifs seulement')
                    ->native(false),
                    
                Tables\Filters\SelectFilter::make('background_type')
                    ->label('Type d\'arrière-plan')
                    ->options([
                        'gradient' => 'Dégradé',
                        'solid' => 'Couleur unie', 
                        'image' => 'Image',
                    ]),
            ])
            ->actions([
                Tables\Actions\ViewAction::make(),
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ])
            ->defaultSort('created_at', 'desc');
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
            'index' => Pages\ListSplashScreens::route('/'),
            'create' => Pages\CreateSplashScreen::route('/create'),
            'edit' => Pages\EditSplashScreen::route('/{record}/edit'),
        ];
    }
}
