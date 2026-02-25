<?php

namespace App\Filament\Resources;

use App\Filament\Resources\RecipeResource\Pages;
use App\Filament\Components\IngredientsRepeater;
use App\Filament\Components\InstructionsField;
use App\Filament\Components\CategorySelect;
use App\Filament\Components\DinorIngredientsRepeater;
use App\Models\Recipe;
use App\Models\Category;
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
                Forms\Components\Section::make('Informations générales')
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
                            ->helperText('Se génère automatiquement à partir du titre. Modifiable manuellement.'),
                        
                        CategorySelect::make('category_id'),
                            
                        Forms\Components\TextInput::make('subcategory')
                            ->label('Sous-catégorie')
                            ->placeholder('Exemple: Plat principal, Entrée froide...')
                            ->maxLength(255),
                            
                        Forms\Components\Textarea::make('description')
                            ->label('Description')
                            ->required()
                            ->rows(3),
                            
                        Forms\Components\FileUpload::make('featured_image')
                            ->label('Image principale')
                            ->image()
                            ->disk('public')
                            ->directory('recipes/featured')
                            ->visibility('public')
                            ->maxSize(2048)
                            ->acceptedFileTypes(['image/jpeg', 'image/png', 'image/gif', 'image/webp'])
                            ->imageEditor()
                            ->imageEditorAspectRatios([
                                '16:9',
                                '4:3',
                                '1:1',
                            ]),

                        Forms\Components\FileUpload::make('gallery')
                            ->label('Galerie d\'images')
                            ->image()
                            ->multiple()
                            ->disk('public')
                            ->directory('recipes/gallery')
                            ->visibility('public')
                            ->maxSize(2048)
                            ->acceptedFileTypes(['image/jpeg', 'image/png', 'image/gif', 'image/webp'])
                            ->maxFiles(10)
                            ->imageEditor()
                            ->reorderable(),

                        Forms\Components\FileUpload::make('video_thumbnail')
                            ->label('Miniature de la vidéo')
                            ->image()
                            ->disk('public')
                            ->directory('recipes/video-thumbnails')
                            ->visibility('public')
                            ->maxSize(2048)
                            ->acceptedFileTypes(['image/jpeg', 'image/png', 'image/gif', 'image/webp']),
                            
                        Forms\Components\TextInput::make('video_url')
                            ->label('URL Vidéo principale')
                            ->url()
                            ->helperText('URL de la vidéo de la recette (YouTube, Vimeo, etc.)'),
                            
                        Forms\Components\TextInput::make('summary_video_url')
                            ->label('URL Vidéo résumé')
                            ->url()
                            ->helperText('URL de la vidéo résumé (YouTube, Vimeo, etc.)'),
                    ])->columns(2),

                Forms\Components\Section::make('Détails de la recette')
                    ->schema([
                        DinorIngredientsRepeater::make('dinor_ingredients'),
                        IngredientsRepeater::make('ingredients'),
                        InstructionsField::make('instructions'),
                    ]),

                Forms\Components\Section::make('Temps et portions')
                    ->schema([
                        Forms\Components\TextInput::make('preparation_time')
                            ->label('Temps de préparation (min)')
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
                    ])->columns(4),

                Forms\Components\Section::make('Caractéristiques')
                    ->schema([
                        Forms\Components\Select::make('difficulty')
                            ->label('Difficulté')
                            ->options([
                                'beginner' => 'Débutant',
                                'easy' => 'Facile',
                                'medium' => 'Intermédiaire',
                                'hard' => 'Difficile',
                                'expert' => 'Expert',
                            ])
                            ->default('beginner'),

                        Forms\Components\Select::make('meal_type')
                            ->label('Type de repas')
                            ->options([
                                'breakfast' => 'Petit déjeuner',
                                'lunch' => 'Déjeuner', 
                                'dinner' => 'Dîner',
                                'snack' => 'Collation',
                                'dessert' => 'Dessert',
                                'aperitif' => 'Apéritif',
                            ]),

                        Forms\Components\Select::make('diet_type')
                            ->label('Régime alimentaire')
                            ->options([
                                'none' => 'Aucun régime spécial',
                                'vegetarian' => 'Végétarien',
                                'vegan' => 'Végétalien',
                                'gluten_free' => 'Sans gluten',
                                'dairy_free' => 'Sans lactose',
                                'keto' => 'Keto',
                                'paleo' => 'Paléo',
                            ])
                            ->default('none'),

                        Forms\Components\Select::make('cost_level')
                            ->label('Niveau de coût')
                            ->options([
                                'low' => 'Économique',
                                'medium' => 'Moyen',
                                'high' => 'Élevé',
                            ])
                            ->default('medium'),

                        Forms\Components\Select::make('season')
                            ->label('Saison')
                            ->options([
                                'all' => 'Toute l\'année',
                                'spring' => 'Printemps',
                                'summer' => 'Été',
                                'autumn' => 'Automne',
                                'winter' => 'Hiver',
                            ])
                            ->default('all'),

                        Forms\Components\TextInput::make('origin_country')
                            ->label('Pays d\'origine'),
                    ])->columns(3),

                Forms\Components\Section::make('Informations nutritionnelles')
                    ->schema([
                        Forms\Components\TextInput::make('calories_per_serving')
                            ->label('Calories par portion')
                            ->numeric(),

                        Forms\Components\TextInput::make('protein_grams')
                            ->label('Protéines (g)')
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

                Forms\Components\Section::make('Équipement')
                    ->schema([
                        Forms\Components\TagsInput::make('required_equipment')
                            ->label('Équipement nécessaire')
                            ->placeholder('Four, mixeur, poêle...'),

                        Forms\Components\TagsInput::make('cooking_methods')
                            ->label('Méthodes de cuisson')
                            ->placeholder('Cuisson au four, à la poêle, à la vapeur...'),
                    ])->columns(2),

                Forms\Components\Section::make('Chef et notes')
                    ->schema([
                        Forms\Components\TextInput::make('chef_name')
                            ->label('Nom du chef'),

                        Forms\Components\Textarea::make('chef_notes')
                            ->label('Notes du chef')
                            ->rows(3),
                    ])->columns(2),

                Forms\Components\Section::make('Paramètres')
                    ->schema([
                        Forms\Components\TagsInput::make('tags')
                            ->label('Tags')
                            ->placeholder('Ajoutez des tags...'),
                            
                        Forms\Components\Toggle::make('is_featured')
                            ->label('Recette vedette'),
                            
                        Forms\Components\Toggle::make('is_published')
                            ->label('Publié')
                            ->default(false),
                    ])->columns(3),
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
                    ->label('Catégorie')
                    ->badge()
                    ->sortable(),
                    
                Tables\Columns\TextColumn::make('difficulty')
                    ->label('Difficulté')
                    ->badge()
                    ->color(function ($state) {
                        switch ($state) {
                            case 'beginner':
                                return 'info';
                            case 'easy':
                                return 'success';
                            case 'medium':
                                return 'warning';
                            case 'hard':
                                return 'danger';
                            case 'expert':
                                return 'gray';
                            default:
                                return 'gray';
                        }
                    }),
                    
                Tables\Columns\TextColumn::make('total_time')
                    ->label('Temps total')
                    ->suffix(' min')
                    ->sortable(),
                    
                Tables\Columns\IconColumn::make('is_featured')
                    ->label('Vedette')
                    ->boolean(),
                    
                Tables\Columns\IconColumn::make('is_published')
                    ->label('Publié')
                    ->boolean(),
                    
                Tables\Columns\TextColumn::make('created_at')
                    ->label('Créé le')
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
                        // Supprimer les relations polymorphes avant la suppression principale
                        $record->likes()->delete();
                        $record->comments()->delete();
                    })
                    ->successNotificationTitle('Recette supprimée avec succès')
                    ->after(function () {
                        static::triggerPwaRebuild();
                    }),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make()
                        ->label('Supprimer sélectionnées')
                        ->before(function ($records) {
                            // Supprimer les relations polymorphes pour chaque enregistrement
                            foreach ($records as $record) {
                                $record->likes()->delete();
                                $record->comments()->delete();
                            }
                        })
                        ->successNotificationTitle('Recettes supprimées avec succès'),
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
                    ->modalDescription('Cette action va forcer la mise à jour du contenu dans l\'application mobile. Continuer ?')
                    ->modalSubmitActionLabel('Vider le cache'),
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
            'index' => Pages\ListRecipes::route('/'),
            'create' => Pages\CreateRecipe::route('/create'),
            'view' => Pages\ViewRecipe::route('/{record}'),
            'edit' => Pages\EditRecipe::route('/{record}/edit'),
        ];
    }
    
    public static function getEloquentQuery(): Builder
    {
        // Suppression directe, pas de soft delete
        return parent::getEloquentQuery();
    }
} 