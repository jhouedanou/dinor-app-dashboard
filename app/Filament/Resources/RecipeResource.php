<?php

namespace App\Filament\Resources;

use App\Filament\Resources\RecipeResource\Pages;
use App\Models\Recipe;
use App\Models\Category;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class RecipeResource extends Resource
{
    protected static ?string $model = Recipe::class;
    protected static ?string $navigationIcon = 'heroicon-o-cake';
    protected static ?string $navigationLabel = 'Recettes';
    protected static ?string $navigationGroup = 'Contenu';
    protected static ?int $navigationSort = 1;

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
                            ->afterStateUpdated(fn (string $context, $state, callable $set) => 
                                $context === 'create' ? $set('slug', \Str::slug($state)) : null
                            ),
                        
                        Forms\Components\TextInput::make('slug')
                            ->label('Slug URL')
                            ->required()
                            ->maxLength(255)
                            ->unique(Recipe::class, 'slug', ignoreRecord: true),
                        
                        Forms\Components\Select::make('category_id')
                            ->label('Catégorie')
                            ->options(Category::active()->pluck('name', 'id'))
                            ->required()
                            ->searchable(),
                            
                        Forms\Components\Textarea::make('description')
                            ->label('Description')
                            ->required()
                            ->rows(3),
                            
                        Forms\Components\FileUpload::make('image')
                            ->label('Image principale')
                            ->image()
                            ->directory('recipes')
                            ->maxSize(2048),
                            
                        Forms\Components\TextInput::make('video_url')
                            ->label('URL Vidéo')
                            ->url(),
                    ])->columns(2),

                Forms\Components\Section::make('Détails de la recette')
                    ->schema([
                        Forms\Components\Repeater::make('ingredients')
                            ->label('Ingrédients')
                            ->schema([
                                Forms\Components\TextInput::make('name')
                                    ->label('Ingrédient')
                                    ->required(),
                                Forms\Components\TextInput::make('quantity')
                                    ->label('Quantité')
                                    ->required(),
                                Forms\Components\TextInput::make('unit')
                                    ->label('Unité')
                                    ->placeholder('g, kg, ml, l, cuillères...'),
                            ])->columns(3)
                            ->collapsible()
                            ->defaultItems(1),
                            
                        Forms\Components\Repeater::make('instructions')
                            ->label('Instructions')
                            ->schema([
                                Forms\Components\Textarea::make('step')
                                    ->label('Étape')
                                    ->required()
                                    ->rows(2),
                            ])
                            ->collapsible()
                            ->defaultItems(1),
                    ]),

                Forms\Components\Section::make('Paramètres')
                    ->schema([
                        Forms\Components\TextInput::make('preparation_time')
                            ->label('Temps de préparation (min)')
                            ->numeric()
                            ->default(0),
                            
                        Forms\Components\TextInput::make('cooking_time')
                            ->label('Temps de cuisson (min)')
                            ->numeric()
                            ->default(0),
                            
                        Forms\Components\TextInput::make('servings')
                            ->label('Nombre de portions')
                            ->numeric()
                            ->default(1),
                            
                        Forms\Components\Select::make('difficulty')
                            ->label('Difficulté')
                            ->options([
                                'easy' => 'Facile',
                                'medium' => 'Moyen',
                                'hard' => 'Difficile',
                            ])
                            ->default('easy'),
                            
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
                Tables\Columns\ImageColumn::make('image')
                    ->label('Image')
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
                    ->color(fn (string $state): string => match ($state) {
                        'easy' => 'success',
                        'medium' => 'warning',
                        'hard' => 'danger',
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
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('category')
                    ->relationship('category', 'name'),
                Tables\Filters\SelectFilter::make('difficulty'),
                Tables\Filters\Filter::make('is_featured')
                    ->query(fn (Builder $query): Builder => $query->where('is_featured', true)),
                Tables\Filters\Filter::make('is_published')
                    ->query(fn (Builder $query): Builder => $query->where('is_published', true)),
                Tables\Filters\TrashedFilter::make(),
            ])
            ->actions([
                Tables\Actions\ViewAction::make(),
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                    Tables\Actions\ForceDeleteBulkAction::make(),
                    Tables\Actions\RestoreBulkAction::make(),
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
            'index' => Pages\ListRecipes::route('/'),
            'create' => Pages\CreateRecipe::route('/create'),
            'view' => Pages\ViewRecipe::route('/{record}'),
            'edit' => Pages\EditRecipe::route('/{record}/edit'),
        ];
    }
    
    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery()
            ->withoutGlobalScopes([
                SoftDeletingScope::class,
            ]);
    }
} 