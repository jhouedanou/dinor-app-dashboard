<?php

namespace App\Filament\Resources;

use App\Filament\Resources\RecipeResource\Pages;
use App\Filament\Components\IngredientsRepeater;
use App\Filament\Components\InstructionsField;
use App\Filament\Components\CategorySelect;
use App\Filament\Components\DinorIngredientsRepeater;
use App\Models\Recipe;
use App\Models\Category;
use App\Models\Unit;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;
use App\Traits\HasCacheInvalidation;

class RecipeResource extends Resource
{
    use HasCacheInvalidation;
    public static ?string $model = Recipe::class;
    public static ?string $navigationIcon = 'heroicon-o-cake';
    public static ?string $navigationLabel = 'Recettes';
    public static ?string $navigationGroup = 'Contenu';
    public static ?int $navigationSort = 1;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Wizard::make([
                    // Etape 1 : Informations generales
                    Forms\Components\Wizard\Step::make('Informations generales')
                        ->icon('heroicon-o-information-circle')
                        ->schema([
                            Forms\Components\TextInput::make('title')
                                ->label('Titre')
                                ->required()
                                ->maxLength(255)
                                ->live(onBlur: true)
                                ->afterStateUpdated(function ($context, $state, $set, $get) {
                                    if ($context === 'create' && empty($get('slug'))) {
                                        $set('slug', \Str::slug($state));
                                    }
                                }),

                            Forms\Components\TextInput::make('slug')
                                ->label('Slug URL')
                                ->required()
                                ->maxLength(255)
                                ->unique(Recipe::class, 'slug', ignoreRecord: true)
                                ->disabled()
                                ->dehydrated()
                                ->helperText('Genere automatiquement a partir du titre.'),

                            CategorySelect::make('category_id'),

                            Forms\Components\TextInput::make('subcategory')
                                ->label('Sous-categorie')
                                ->placeholder('Exemple: Plat principal, Entree froide...')
                                ->maxLength(255),

                            Forms\Components\Textarea::make('description')
                                ->label('Description')
                                ->required()
                                ->rows(3),

                            Forms\Components\Grid::make(2)->schema([
                                Forms\Components\Select::make('difficulty')
                                    ->label('Difficulte')
                                    ->options([
                                        'beginner' => 'Debutant',
                                        'easy' => 'Facile',
                                        'medium' => 'Intermediaire',
                                        'hard' => 'Difficile',
                                        'expert' => 'Expert',
                                    ])
                                    ->default('beginner'),

                                Forms\Components\Select::make('meal_type')
                                    ->label('Type de repas')
                                    ->options([
                                        'breakfast' => 'Petit dejeuner',
                                        'lunch' => 'Dejeuner',
                                        'dinner' => 'Diner',
                                        'snack' => 'Collation',
                                        'dessert' => 'Dessert',
                                        'aperitif' => 'Aperitif',
                                    ]),

                                Forms\Components\Select::make('diet_type')
                                    ->label('Regime alimentaire')
                                    ->options([
                                        'none' => 'Aucun regime special',
                                        'vegetarian' => 'Vegetarien',
                                        'vegan' => 'Vegetalien',
                                        'gluten_free' => 'Sans gluten',
                                        'dairy_free' => 'Sans lactose',
                                        'keto' => 'Keto',
                                        'paleo' => 'Paleo',
                                    ])
                                    ->default('none'),

                                Forms\Components\Select::make('cost_level')
                                    ->label('Niveau de cout')
                                    ->options([
                                        'low' => 'Economique',
                                        'medium' => 'Moyen',
                                        'high' => 'Eleve',
                                    ])
                                    ->default('medium'),
                            ]),
                        ])->columns(2),

                    // Etape 2 : Medias
                    Forms\Components\Wizard\Step::make('Medias')
                        ->icon('heroicon-o-photo')
                        ->schema([
                            Forms\Components\FileUpload::make('featured_image')
                                ->label('Image principale')
                                ->image()
                                ->disk('public')
                                ->directory('recipes/featured')
                                ->visibility('public')
                                ->maxSize(2048)
                                ->acceptedFileTypes(['image/jpeg', 'image/png', 'image/gif', 'image/webp'])
                                ->rules([new \App\Rules\SafeFile()])
                                ->imageEditor()
                                ->imageEditorAspectRatios(['16:9', '4:3', '1:1']),

                            Forms\Components\FileUpload::make('gallery')
                                ->label('Galerie d\'images')
                                ->image()
                                ->multiple()
                                ->disk('public')
                                ->directory('recipes/gallery')
                                ->visibility('public')
                                ->maxSize(2048)
                                ->acceptedFileTypes(['image/jpeg', 'image/png', 'image/gif', 'image/webp'])
                                ->rules([new \App\Rules\SafeFile()])
                                ->maxFiles(10)
                                ->imageEditor()
                                ->reorderable(),

                            Forms\Components\FileUpload::make('video_thumbnail')
                                ->label('Miniature de la video')
                                ->image()
                                ->disk('public')
                                ->directory('recipes/video-thumbnails')
                                ->visibility('public')
                                ->maxSize(2048)
                                ->acceptedFileTypes(['image/jpeg', 'image/png', 'image/gif', 'image/webp'])
                                ->rules([new \App\Rules\SafeFile()]),

                            Forms\Components\TextInput::make('video_url')
                                ->label('URL Video principale')
                                ->url()
                                ->helperText('URL de la video de la recette (YouTube, Vimeo, etc.)'),

                            Forms\Components\TextInput::make('summary_video_url')
                                ->label('URL Video resume')
                                ->url()
                                ->helperText('URL de la video resume (YouTube, Vimeo, etc.)'),

                            Forms\Components\FileUpload::make('audio_guide')
                                ->label('Guide audio general')
                                ->disk('public')
                                ->directory('recipes/audio-guides')
                                ->visibility('public')
                                ->acceptedFileTypes(['audio/mpeg', 'audio/mp3', 'audio/wav', 'audio/ogg', 'audio/mp4', 'audio/x-m4a'])
                                ->maxSize(10240)
                                ->helperText('Audio general de la recette (max 10 Mo). Vous pouvez aussi ajouter un audio par etape dans les instructions.'),
                        ])->columns(2),

                    // Etape 3 : Ingredients
                    Forms\Components\Wizard\Step::make('Ingredients')
                        ->icon('heroicon-o-beaker')
                        ->schema([
                            DinorIngredientsRepeater::make('dinor_ingredients'),
                            IngredientsRepeater::make('ingredients'),
                        ]),

                    // Etape 4 : Instructions
                    Forms\Components\Wizard\Step::make('Instructions')
                        ->icon('heroicon-o-list-bullet')
                        ->schema([
                            InstructionsField::make('instructions'),
                        ]),

                    // Etape 5 : Temps et portions
                    Forms\Components\Wizard\Step::make('Temps et portions')
                        ->icon('heroicon-o-clock')
                        ->schema([
                            Forms\Components\Grid::make(4)->schema([
                                Forms\Components\TextInput::make('preparation_time')
                                    ->label('Temps de preparation (min)')
                                    ->numeric()
                                    ->default(0),

                                Forms\Components\TextInput::make('cooking_time')
                                    ->label('Temps de cuisson (min)')
                                    ->numeric()
                                    ->default(0),

                                Forms\Components\TextInput::make('resting_time')
                                    ->label('Temps de repos (min)')
                                    ->numeric()
                                    ->default(0),

                                Forms\Components\TextInput::make('servings')
                                    ->label('Nombre de portions')
                                    ->numeric()
                                    ->default(1),
                            ]),

                            Forms\Components\Section::make('Informations nutritionnelles')
                                ->schema([
                                    Forms\Components\TextInput::make('calories_per_serving')
                                        ->label('Calories par portion')
                                        ->numeric(),

                                    Forms\Components\TextInput::make('protein_grams')
                                        ->label('Proteines (g)')
                                        ->numeric()
                                        ->step(0.1),

                                    Forms\Components\TextInput::make('carbs_grams')
                                        ->label('Glucides (g)')
                                        ->numeric()
                                        ->step(0.1),

                                    Forms\Components\TextInput::make('fat_grams')
                                        ->label('Lipides (g)')
                                        ->numeric()
                                        ->step(0.1),

                                    Forms\Components\TextInput::make('fiber_grams')
                                        ->label('Fibres (g)')
                                        ->numeric()
                                        ->step(0.1),
                                ])->columns(5),
                        ]),

                    // Etape 6 : Details et publication
                    Forms\Components\Wizard\Step::make('Details et publication')
                        ->icon('heroicon-o-cog-6-tooth')
                        ->schema([
                            Forms\Components\Grid::make(3)->schema([
                                Forms\Components\Select::make('season')
                                    ->label('Saison')
                                    ->options([
                                        'all' => 'Toute l\'annee',
                                        'spring' => 'Printemps',
                                        'summer' => 'Ete',
                                        'autumn' => 'Automne',
                                        'winter' => 'Hiver',
                                    ])
                                    ->default('all'),

                                Forms\Components\TextInput::make('origin_country')
                                    ->label('Pays d\'origine'),

                                Forms\Components\TextInput::make('chef_name')
                                    ->label('Nom du chef'),
                            ]),

                            Forms\Components\Textarea::make('chef_notes')
                                ->label('Notes du chef')
                                ->rows(3),

                            Forms\Components\Grid::make(2)->schema([
                                Forms\Components\TagsInput::make('required_equipment')
                                    ->label('Equipement necessaire')
                                    ->placeholder('Four, mixeur, poele...'),

                                Forms\Components\TagsInput::make('cooking_methods')
                                    ->label('Methodes de cuisson')
                                    ->placeholder('Cuisson au four, a la poele, a la vapeur...'),
                            ]),

                            Forms\Components\TagsInput::make('tags')
                                ->label('Tags')
                                ->placeholder('Ajoutez des tags...'),

                            Forms\Components\Grid::make(2)->schema([
                                Forms\Components\Toggle::make('is_featured')
                                    ->label('Recette vedette'),

                                Forms\Components\Toggle::make('is_published')
                                    ->label('Publie')
                                    ->default(false),
                            ]),
                        ]),
                ])
                ->skippable()
                ->columnSpanFull(),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\ImageColumn::make('featured_image')
                    ->label('Image')
                    ->disk('public')
                    ->circular(),

                Tables\Columns\TextColumn::make('title')
                    ->label('Titre')
                    ->searchable()
                    ->sortable(),

                Tables\Columns\TextColumn::make('category.name')
                    ->label('Categorie')
                    ->badge()
                    ->sortable(),

                Tables\Columns\TextColumn::make('difficulty')
                    ->label('Difficulte')
                    ->badge()
                    ->color(function ($state) {
                        return match ($state) {
                            'beginner' => 'info',
                            'easy' => 'success',
                            'medium' => 'warning',
                            'hard' => 'danger',
                            'expert' => 'gray',
                            default => 'gray',
                        };
                    }),

                Tables\Columns\TextColumn::make('total_time')
                    ->label('Temps total')
                    ->suffix(' min')
                    ->sortable(),

                Tables\Columns\IconColumn::make('is_featured')
                    ->label('Vedette')
                    ->boolean(),

                Tables\Columns\IconColumn::make('is_published')
                    ->label('Publie')
                    ->boolean(),

                Tables\Columns\TextColumn::make('created_at')
                    ->label('Cree le')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(true),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('category')
                    ->relationship('category', 'name'),
                Tables\Filters\SelectFilter::make('difficulty'),
                Tables\Filters\Filter::make('is_featured')
                    ->query(function (Builder $query) {
                        return $query->where('is_featured', true);
                    }),
                Tables\Filters\Filter::make('is_published')
                    ->query(function (Builder $query) {
                        return $query->where('is_published', true);
                    }),
            ])
            ->defaultSort('created_at', 'desc')
            ->actions([
                Tables\Actions\ViewAction::make(),
                Tables\Actions\EditAction::make()
                    ->url(fn (Recipe $record): string => static::getUrl('edit', ['record' => $record])),
                Tables\Actions\DeleteAction::make()
                    ->before(function ($record) {
                        $record->likes()->delete();
                        $record->comments()->delete();
                    })
                    ->successNotificationTitle('Recette supprimee avec succes')
                    ->after(function () {
                        static::triggerPwaRebuild();
                    }),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make()
                        ->label('Supprimer selectionnees')
                        ->before(function ($records) {
                            foreach ($records as $record) {
                                $record->likes()->delete();
                                $record->comments()->delete();
                            }
                        })
                        ->successNotificationTitle('Recettes supprimees avec succes'),
                ]),
            ])
            ->headerActions([
                Tables\Actions\Action::make('clear_cache')
                    ->label('Vider le cache PWA')
                    ->icon('heroicon-o-arrow-path')
                    ->color('info')
                    ->action(function () {
                        static::invalidateCache();
                    })
                    ->requiresConfirmation()
                    ->modalHeading('Vider le cache PWA')
                    ->modalDescription('Cette action va forcer la mise a jour du contenu dans l\'application mobile. Continuer ?')
                    ->modalSubmitActionLabel('Vider le cache'),
            ]);
    }

    public static function getRelations(): array
    {
        return [];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListRecipes::route('/'),
            'create' => Pages\CreateRecipe::route('/create'),
            'view' => Pages\ViewRecipe::route('/{record}'),
            'edit' => Pages\EditRecipe::route('/{record}/edit'),
        ];
    }

    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery();
    }
}
