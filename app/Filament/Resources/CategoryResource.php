<?php

namespace App\Filament\Resources;

use App\Filament\Resources\CategoryResource\Pages;
use App\Models\Category;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Str;

class CategoryResource extends Resource
{
    protected static ?string $model = Category::class;
    protected static ?string $navigationIcon = 'heroicon-o-tag';
    protected static ?string $navigationLabel = 'Catégories';
    protected static ?string $navigationGroup = 'Contenu';
    protected static ?int $navigationSort = 2;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Informations générales')
                    ->schema([
                        Forms\Components\TextInput::make('name')
                            ->label('Nom')
                            ->required()
                            ->maxLength(255)
                            ->live()
                            ->afterStateUpdated(function ($context, $state, $set) {
                                if ($context === 'create') {
                                    $set('slug', Str::slug($state));
                                }
                            }),

                        Forms\Components\TextInput::make('slug')
                            ->label('Slug URL')
                            ->required()
                            ->maxLength(255)
                            ->unique(Category::class, 'slug'),

                        Forms\Components\Select::make('type')
                            ->label('Type de catégorie')
                            ->options([
                                'general' => 'Générale',
                                'recipe' => 'Recette',
                                'event' => 'Événement',
                            ])
                            ->default('general')
                            ->required()
                            ->helperText('Définit à quel type de contenu cette catégorie est associée'),

                        Forms\Components\Textarea::make('description')
                            ->label('Description')
                            ->rows(3)
                            ->maxLength(500),

                        Forms\Components\FileUpload::make('image')
                            ->label('Image')
                            ->image()
                            ->disk('public')
                            ->directory('categories')
                            ->visibility('public')
                            ->maxSize(2048)
                            ->imageEditor(),

                        Forms\Components\ColorPicker::make('color')
                            ->label('Couleur')
                            ->rgba(),

                        Forms\Components\TextInput::make('icon')
                            ->label('Icône (Heroicon)')
                            ->placeholder('Ex: heroicon-o-cake')
                            ->helperText('Utilisez les noms d\'icônes Heroicon (ex: heroicon-o-cake, heroicon-o-fire, etc.)'),

                        Forms\Components\Toggle::make('is_active')
                            ->label('Actif')
                            ->default(true)
                            ->helperText('Seules les catégories actives apparaissent dans les listes de sélection'),
                    ])->columns(2),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\ImageColumn::make('image')
                    ->label('Image')
                    ->circular()
                    ->size(50)
                    ->defaultImageUrl(url('/images/placeholder.jpg')),

                Tables\Columns\TextColumn::make('name')
                    ->label('Nom')
                    ->searchable()
                    ->sortable(),

                Tables\Columns\TextColumn::make('slug')
                    ->label('Slug')
                    ->searchable()
                    ->toggleable(),

                Tables\Columns\TextColumn::make('type')
                    ->label('Type')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'general' => 'gray',
                        'recipe' => 'success',
                        'event' => 'warning',
                        default => 'gray',
                    })
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'general' => 'Générale',
                        'recipe' => 'Recette',
                        'event' => 'Événement',
                        default => $state,
                    })
                    ->sortable(),

                Tables\Columns\ColorColumn::make('color')
                    ->label('Couleur')
                    ->copyable()
                    ->toggleable(),

                Tables\Columns\TextColumn::make('icon')
                    ->label('Icône')
                    ->toggleable(),

                Tables\Columns\TextColumn::make('recipes_count')
                    ->label('Recettes')
                    ->counts('recipes')
                    ->sortable(),

                Tables\Columns\ToggleColumn::make('is_active')
                    ->label('Actif')
                    ->sortable(),

                Tables\Columns\TextColumn::make('created_at')
                    ->label('Créé le')
                    ->dateTime('d/m/Y H:i')
                    ->sortable()
                    ->toggleable(),

                Tables\Columns\TextColumn::make('updated_at')
                    ->label('Modifié le')
                    ->dateTime('d/m/Y H:i')
                    ->sortable()
                    ->toggleable(),
            ])
            ->filters([
                Tables\Filters\TernaryFilter::make('is_active')
                    ->label('Statut')
                    ->boolean()
                    ->trueLabel('Actives seulement')
                    ->falseLabel('Inactives seulement')
                    ->native(false),
                    
                Tables\Filters\SelectFilter::make('type')
                    ->label('Type')
                    ->options([
                        'general' => 'Générale',
                        'recipe' => 'Recette',
                        'event' => 'Événement',
                    ])
                    ->native(false),
            ])
            ->actions([
                Tables\Actions\ViewAction::make(),
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make()
                    ->requiresConfirmation()
                    ->modalHeading('Supprimer la catégorie')
                    ->modalDescription(function ($record) {
                        $recipesCount = $record->recipes()->count();
                        $tipsCount = $record->tips()->count();
                        $eventsCount = $record->events()->count();
                        
                        $message = 'Êtes-vous sûr de vouloir supprimer cette catégorie ?';
                        
                        if ($recipesCount + $tipsCount + $eventsCount > 0) {
                            $message .= "\n\nCela supprimera également :";
                            if ($recipesCount > 0) $message .= "\n• {$recipesCount} recette(s)";
                            if ($tipsCount > 0) $message .= "\n• {$tipsCount} astuce(s)";
                            if ($eventsCount > 0) $message .= "\n• {$eventsCount} événement(s)";
                        }
                        
                        return $message;
                    })
                    ->modalSubmitActionLabel('Oui, supprimer'),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make()
                        ->requiresConfirmation()
                        ->modalHeading('Supprimer les catégories sélectionnées')
                        ->modalDescription(function ($records) {
                            $totalRecipes = 0;
                            $totalTips = 0;
                            $totalEvents = 0;
                            
                            foreach ($records as $record) {
                                $totalRecipes += $record->recipes()->count();
                                $totalTips += $record->tips()->count(); 
                                $totalEvents += $record->events()->count();
                            }
                            
                            $message = 'Êtes-vous sûr de vouloir supprimer ces catégories ?';
                            
                            if ($totalRecipes + $totalTips + $totalEvents > 0) {
                                $message .= "\n\nCela supprimera également :";
                                if ($totalRecipes > 0) $message .= "\n• {$totalRecipes} recette(s)";
                                if ($totalTips > 0) $message .= "\n• {$totalTips} astuce(s)";
                                if ($totalEvents > 0) $message .= "\n• {$totalEvents} événement(s)";
                            }
                            
                            return $message;
                        })
                        ->modalSubmitActionLabel('Oui, supprimer tout'),
                    Tables\Actions\BulkAction::make('activate')
                        ->label('Activer')
                        ->icon('heroicon-o-check-circle')
                        ->action(function ($records) {
                            $records->each->update(['is_active' => true]);
                        })
                        ->deselectRecordsAfterCompletion(),
                    Tables\Actions\BulkAction::make('deactivate')
                        ->label('Désactiver')
                        ->icon('heroicon-o-x-circle')
                        ->action(function ($records) {
                            $records->each->update(['is_active' => false]);
                        })
                        ->deselectRecordsAfterCompletion(),
                ]),
            ])
            ->defaultSort('name');
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListCategories::route('/'),
            'create' => Pages\CreateCategory::route('/create'),
            'view' => Pages\ViewCategory::route('/{record}'),
            'edit' => Pages\EditCategory::route('/{record}/edit'),
        ];
    }

    public static function getNavigationBadge(): ?string
    {
        return static::getModel()::count();
    }
} 