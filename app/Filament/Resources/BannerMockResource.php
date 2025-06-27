<?php

namespace App\Filament\Resources;

use App\Filament\Resources\BannerMockResource\Pages;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class BannerMockResource extends Resource
{
    protected static ?string $model = null; 

    protected static ?string $navigationIcon = 'heroicon-o-megaphone';

    protected static ?string $navigationLabel = 'Bannières (Demo)';

    protected static ?string $modelLabel = 'Bannière';

    protected static ?string $pluralModelLabel = 'Bannières';

    protected static ?string $navigationGroup = 'Configuration PWA';

    protected static ?int $navigationSort = 5;

    protected static ?string $slug = 'banners-demo';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Contenu de la bannière')
                    ->description('Configurez le contenu principal de votre bannière')
                    ->schema([
                        Forms\Components\Select::make('type_contenu')
                            ->label('Type de contenu')
                            ->options([
                                'recipes' => 'Recettes',
                                'tips' => 'Astuces',
                                'events' => 'Événements',
                                'dinor_tv' => 'Dinor TV',
                                'pages' => 'Pages',
                                'home' => 'Accueil'
                            ])
                            ->required()
                            ->helperText('Type de contenu pour cette bannière'),

                        Forms\Components\TextInput::make('titre')
                            ->label('Titre de la bannière')
                            ->required()
                            ->maxLength(255)
                            ->placeholder('Ex: Nos Délicieuses Recettes')
                            ->helperText('Titre principal de la bannière'),

                        Forms\Components\TextInput::make('sous_titre')
                            ->label('Sous-titre')
                            ->maxLength(255)
                            ->placeholder('Ex: Découvrez la cuisine ivoirienne')
                            ->helperText('Sous-titre de la bannière'),

                        Forms\Components\Select::make('section')
                            ->label('Section')
                            ->options([
                                'header' => 'En-tête',
                                'hero' => 'Bannière principale',
                                'featured' => 'Contenu mis en avant',
                                'footer' => 'Pied de page'
                            ])
                            ->required()
                            ->helperText('Section où afficher la bannière'),

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
                            ->placeholder('Ex: /recipes')
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
                Tables\Columns\TextColumn::make('titre')
                    ->label('Titre')
                    ->searchable()
                    ->sortable()
                    ->weight('bold'),

                Tables\Columns\TextColumn::make('type_contenu')
                    ->label('Type')
                    ->badge()
                    ->color('primary'),

                Tables\Columns\TextColumn::make('section')
                    ->label('Section')
                    ->badge()
                    ->color('gray'),

                Tables\Columns\ColorColumn::make('background_color')
                    ->label('Couleur')
                    ->alignCenter(),

                Tables\Columns\IconColumn::make('is_active')
                    ->label('Active')
                    ->boolean()
                    ->alignCenter(),
            ])
            ->filters([])
            ->actions([
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ])
            ->emptyStateHeading('Aucune bannière configurée')
            ->emptyStateDescription('Créez votre première bannière pour commencer.')
            ->emptyStateIcon('heroicon-o-megaphone');
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListBannerMocks::route('/'),
            'create' => Pages\CreateBannerMock::route('/create'),
            'edit' => Pages\EditBannerMock::route('/{record}/edit'),
        ];
    }

    public static function canCreate(): bool
    {
        return false; // Désactiver la création pour la demo
    }
} 