<?php

namespace App\Filament\Resources;

use App\Filament\Resources\BannerResource\Pages;
use App\Filament\Resources\BannerResource\RelationManagers;
use App\Models\Banner;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class BannerResource extends Resource
{
    protected static ?string $model = Banner::class;

    protected static ?string $navigationIcon = 'heroicon-o-megaphone';

    protected static ?string $navigationLabel = 'Bannières';

    protected static ?string $modelLabel = 'Bannière';

    protected static ?string $pluralModelLabel = 'Bannières';

    protected static ?string $navigationGroup = 'Configuration PWA';

    protected static ?int $navigationSort = 5;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Contenu de la bannière')
                    ->description('Configurez le contenu principal de votre bannière')
                    ->schema([
                        Forms\Components\TextInput::make('title')
                            ->label('Titre')
                            ->required()
                            ->maxLength(255)
                            ->placeholder('Ex: Bienvenue sur Dinor')
                            ->helperText('Titre principal affiché sur la bannière'),

                        Forms\Components\Textarea::make('description')
                            ->label('Description')
                            ->maxLength(500)
                            ->rows(3)
                            ->placeholder('Ex: Découvrez les saveurs authentiques de la Côte d\'Ivoire')
                            ->helperText('Texte descriptif sous le titre'),

                        Forms\Components\FileUpload::make('image_url')
                            ->label('Image de fond')
                            ->image()
                            ->directory('banners')
                            ->acceptedFileTypes(['image/jpeg', 'image/png', 'image/webp'])
                            ->maxSize(2048)
                            ->helperText('Image de fond de la bannière (optionnel)')
                            ->columnSpanFull(),
                    ])->columns(2),

                Forms\Components\Section::make('Apparence')
                    ->description('Personnalisez les couleurs et l\'apparence')
                    ->schema([
                        Forms\Components\ColorPicker::make('background_color')
                            ->label('Couleur de fond')
                            ->default('#E1251B')
                            ->helperText('Couleur de fond principale'),

                        Forms\Components\ColorPicker::make('text_color')
                            ->label('Couleur du texte')
                            ->default('#FFFFFF')
                            ->helperText('Couleur du titre et de la description'),

                        Forms\Components\Select::make('position')
                            ->label('Position')
                            ->options([
                                'home' => 'Page d\'accueil uniquement',
                                'all_pages' => 'Toutes les pages',
                                'specific' => 'Pages spécifiques'
                            ])
                            ->default('home')
                            ->required()
                            ->helperText('Où afficher cette bannière'),
                    ])->columns(2),

                Forms\Components\Section::make('Bouton d\'action (optionnel)')
                    ->description('Ajoutez un bouton d\'appel à l\'action')
                    ->schema([
                        Forms\Components\TextInput::make('button_text')
                            ->label('Texte du bouton')
                            ->maxLength(50)
                            ->placeholder('Ex: Découvrir nos recettes')
                            ->helperText('Texte affiché sur le bouton'),

                        Forms\Components\TextInput::make('button_url')
                            ->label('URL du bouton')
                            ->url()
                            ->placeholder('Ex: /pwa/recipes')
                            ->helperText('Lien vers lequel le bouton redirige'),

                        Forms\Components\ColorPicker::make('button_color')
                            ->label('Couleur du bouton')
                            ->default('#FFFFFF')
                            ->helperText('Couleur de fond du bouton'),
                    ])->columns(2),

                Forms\Components\Section::make('Configuration')
                    ->description('Paramètres d\'affichage et d\'ordre')
                    ->schema([
                        Forms\Components\Toggle::make('is_active')
                            ->label('Bannière active')
                            ->default(true)
                            ->helperText('Afficher cette bannière dans l\'application'),

                        Forms\Components\TextInput::make('order')
                            ->label('Ordre d\'affichage')
                            ->numeric()
                            ->default(0)
                            ->helperText('Ordre d\'affichage (0 = premier)'),
                    ])->columns(2),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('title')
                    ->label('Titre')
                    ->searchable()
                    ->sortable()
                    ->weight('bold'),

                Tables\Columns\TextColumn::make('description')
                    ->label('Description')
                    ->limit(50)
                    ->tooltip(function ($record) {
                        return $record->description;
                    }),

                Tables\Columns\ColorColumn::make('background_color')
                    ->label('Couleur')
                    ->alignCenter(),

                Tables\Columns\SelectColumn::make('position')
                    ->label('Position')
                    ->options([
                        'home' => 'Accueil',
                        'all_pages' => 'Toutes les pages',
                        'specific' => 'Spécifiques'
                    ])
                    ->selectablePlaceholder(false),

                Tables\Columns\IconColumn::make('is_active')
                    ->label('Active')
                    ->boolean()
                    ->alignCenter(),

                Tables\Columns\TextColumn::make('order')
                    ->label('Ordre')
                    ->sortable()
                    ->alignCenter(),

                Tables\Columns\TextColumn::make('created_at')
                    ->label('Créée le')
                    ->dateTime('d/m/Y H:i')
                    ->sortable()
                    ->toggleable(),
            ])
            ->filters([
                Tables\Filters\TernaryFilter::make('is_active')
                    ->label('Statut')
                    ->boolean()
                    ->trueLabel('Actives uniquement')
                    ->falseLabel('Inactives uniquement')
                    ->native(false),

                Tables\Filters\SelectFilter::make('position')
                    ->label('Position')
                    ->options([
                        'home' => 'Page d\'accueil',
                        'all_pages' => 'Toutes les pages',
                        'specific' => 'Pages spécifiques'
                    ])
                    ->native(false),
            ])
            ->actions([
                Tables\Actions\EditAction::make()
                    ->label('Modifier'),
                    
                Tables\Actions\DeleteAction::make()
                    ->label('Supprimer'),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make()
                        ->label('Supprimer sélectionnées'),

                    Tables\Actions\BulkAction::make('activate')
                        ->label('Activer')
                        ->icon('heroicon-o-check-circle')
                        ->color('success')
                        ->action(fn ($records) => $records->each->update(['is_active' => true]))
                        ->deselectRecordsAfterCompletion(),

                    Tables\Actions\BulkAction::make('deactivate')
                        ->label('Désactiver')
                        ->icon('heroicon-o-x-circle')
                        ->color('warning')
                        ->action(fn ($records) => $records->each->update(['is_active' => false]))
                        ->deselectRecordsAfterCompletion(),
                ]),
            ])
            ->defaultSort('order', 'asc')
            ->reorderable('order')
            ->emptyStateHeading('Aucune bannière créée')
            ->emptyStateDescription('Créez votre première bannière pour personnaliser l\'accueil.')
            ->emptyStateIcon('heroicon-o-megaphone');
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
            'index' => Pages\ListBanners::route('/'),
            'create' => Pages\CreateBanner::route('/create'),
            'edit' => Pages\EditBanner::route('/{record}/edit'),
        ];
    }
    
    public static function getNavigationBadge(): ?string
    {
        return static::getModel()::active()->count();
    }
}
