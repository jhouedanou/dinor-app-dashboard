<?php

namespace App\Filament\Resources;

use App\Filament\Resources\IngredientResource\Pages;
use App\Models\Ingredient;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class IngredientResource extends Resource
{
    /**
     * @var string
     */
    protected static $model = Ingredient::class;
    
    /**
     * @var string
     */
    protected static $navigationIcon = 'heroicon-o-cube';
    
    /**
     * @var string
     */
    protected static $navigationLabel = 'Ingrédients';
    
    /**
     * @var string
     */
    protected static $navigationGroup = 'Contenu';
    
    /**
     * @var int
     */
    protected static $navigationSort = 2;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Informations de base')
                    ->schema([
                        Forms\Components\TextInput::make('name')
                            ->label('Nom de l\'ingrédient')
                            ->required()
                            ->maxLength(255),
                        
                        Forms\Components\Select::make('category')
                            ->label('Catégorie')
                            ->options(array_keys(Ingredient::getCategories()))
                            ->required()
                            ->live()
                            ->afterStateUpdated(function ($set) {
                                $set('subcategory', null);
                            }),
                            
                        Forms\Components\Select::make('subcategory')
                            ->label('Sous-catégorie')
                            ->options(function ($get) {
                                $category = $get('category');
                                if (!$category) return [];
                                $categories = Ingredient::getCategories();
                                return array_combine(
                                    $categories[$category] ?? [],
                                    $categories[$category] ?? []
                                );
                            })
                            ->visible(function ($get) {
                                return filled($get('category'));
                            }),
                            
                        Forms\Components\Select::make('unit')
                            ->label('Unité de mesure')
                            ->options(Ingredient::getUnits())
                            ->required(),
                            
                        Forms\Components\TextInput::make('recommended_brand')
                            ->label('Marque recommandée')
                            ->maxLength(255),
                            
                        Forms\Components\TextInput::make('average_price')
                            ->label('Prix moyen (€)')
                            ->numeric()
                            ->prefix('€')
                            ->step(0.01),
                            
                        Forms\Components\Textarea::make('description')
                            ->label('Description')
                            ->rows(3),
                            
                        Forms\Components\FileUpload::make('image')
                            ->label('Image')
                            ->image()
                            ->disk('public')
                            ->directory('ingredients')
                            ->visibility('public')
                            ->maxSize(2048)
                            ->imageEditor(),
                            
                        Forms\Components\Toggle::make('is_active')
                            ->label('Actif')
                            ->default(true),
                    ])->columns(2),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\ImageColumn::make('image')
                    ->label('Image')
                    ->disk('public')
                    ->size(40)
                    ->circular(),
                    
                Tables\Columns\TextColumn::make('name')
                    ->label('Nom')
                    ->searchable()
                    ->sortable(),
                    
                Tables\Columns\TextColumn::make('category')
                    ->label('Catégorie')
                    ->searchable()
                    ->sortable()
                    ->badge(),
                    
                Tables\Columns\TextColumn::make('subcategory')
                    ->label('Sous-catégorie')
                    ->searchable()
                    ->badge()
                    ->color('gray'),
                    
                Tables\Columns\TextColumn::make('unit')
                    ->label('Unité')
                    ->badge()
                    ->color('success'),
                    
                Tables\Columns\TextColumn::make('recommended_brand')
                    ->label('Marque')
                    ->searchable()
                    ->limit(20),
                    
                Tables\Columns\TextColumn::make('average_price')
                    ->label('Prix moyen')
                    ->money('EUR')
                    ->sortable(),
                    
                Tables\Columns\IconColumn::make('is_active')
                    ->label('Actif')
                    ->boolean()
                    ->sortable(),
                    
                Tables\Columns\TextColumn::make('created_at')
                    ->label('Créé le')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(true),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('category')
                    ->label('Catégorie')
                    ->options(array_combine(
                        array_keys(Ingredient::getCategories()),
                        array_keys(Ingredient::getCategories())
                    )),
                    
                Tables\Filters\SelectFilter::make('unit')
                    ->label('Unité')
                    ->options(Ingredient::getUnits()),
                    
                Tables\Filters\TernaryFilter::make('is_active')
                    ->label('Statut')
                    ->boolean()
                    ->trueLabel('Actifs seulement')
                    ->falseLabel('Inactifs seulement')
                    ->native(false),
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ])
            ->defaultSort('name');
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListIngredients::route('/'),
            'create' => Pages\CreateIngredient::route('/create'),
            'edit' => Pages\EditIngredient::route('/{record}/edit'),
        ];
    }

    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery()
            ->withoutGlobalScopes();
    }
} 