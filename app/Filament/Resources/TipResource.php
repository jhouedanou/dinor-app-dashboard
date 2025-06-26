<?php

namespace App\Filament\Resources;

use App\Filament\Resources\TipResource\Pages;
use App\Models\Tip;
use App\Models\Category;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class TipResource extends Resource
{
    protected static ?string $model = Tip::class;

    protected static ?string $navigationIcon = 'heroicon-o-light-bulb';

    protected static ?string $navigationLabel = 'Astuces';

    protected static ?string $modelLabel = 'Astuce';

    protected static ?string $pluralModelLabel = 'Astuces';

    protected static ?string $navigationGroup = 'Contenu';

    protected static ?int $navigationSort = 2;

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
                            ->unique(Tip::class, 'slug', ignoreRecord: true)
                            ->helperText('Se génère automatiquement à partir du titre. Modifiable manuellement.'),

                        Forms\Components\Select::make('category_id')
                            ->label('Catégorie')
                            ->relationship('category', 'name')
                            ->required()
                            ->createOptionForm([
                                Forms\Components\TextInput::make('name')
                                    ->label('Nom')
                                    ->required()
                                    ->maxLength(255),
                                Forms\Components\Textarea::make('description')
                                    ->label('Description'),
                            ]),

                        Forms\Components\RichEditor::make('content')
                            ->label('Contenu')
                            ->required()
                            ->columnSpanFull(),
                    ])->columns(2),

                Forms\Components\Section::make('Médias')
                    ->schema([
                        Forms\Components\FileUpload::make('image')
                            ->label('Image principale')
                            ->image()
                            ->disk('public')
                            ->directory('tips/featured')
                            ->visibility('public')
                            ->maxSize(5120)
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
                            ->directory('tips/gallery')
                            ->visibility('public')
                            ->maxSize(3072)
                            ->maxFiles(10)
                            ->imageEditor()
                            ->reorderable(),

                        Forms\Components\TextInput::make('video_url')
                            ->label('URL Vidéo')
                            ->url(),
                    ])->columns(2),

                Forms\Components\Section::make('Détails')
                    ->schema([
                        Forms\Components\Select::make('difficulty_level')
                            ->label('Niveau de difficulté')
                            ->options([
                                'beginner' => 'Débutant',
                                'intermediate' => 'Intermédiaire',
                                'advanced' => 'Avancé',
                            ])
                            ->default('beginner'),

                        Forms\Components\TextInput::make('estimated_time')
                            ->label('Temps estimé (minutes)')
                            ->numeric()
                            ->default(5),

                        Forms\Components\TagsInput::make('tags')
                            ->label('Tags')
                            ->placeholder('Ajoutez des tags...'),
                    ])->columns(3),

                Forms\Components\Section::make('Publication')
                    ->schema([
                        Forms\Components\Toggle::make('is_featured')
                            ->label('Astuce vedette'),

                        Forms\Components\Toggle::make('is_published')
                            ->label('Publié')
                            ->default(false),
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
                    ->circular(),

                Tables\Columns\TextColumn::make('title')
                    ->label('Titre')
                    ->searchable()
                    ->sortable(),

                Tables\Columns\TextColumn::make('category.name')
                    ->label('Catégorie')
                    ->badge()
                    ->sortable(),

                Tables\Columns\TextColumn::make('difficulty_level')
                    ->label('Difficulté')
                    ->badge()
                    ->color(function ($state) {
                        switch ($state) {
                            case 'beginner':
                                return 'success';
                            case 'intermediate':
                                return 'warning';
                            case 'advanced':
                                return 'danger';
                            default:
                                return 'gray';
                        }
                    })
                    ->formatStateUsing(function ($state) {
                        switch ($state) {
                            case 'beginner':
                                return 'Débutant';
                            case 'intermediate':
                                return 'Intermédiaire';
                            case 'advanced':
                                return 'Avancé';
                            default:
                                return $state;
                        }
                    }),

                Tables\Columns\TextColumn::make('estimated_time')
                    ->label('Temps estimé')
                    ->suffix(' min')
                    ->sortable(),

                Tables\Columns\IconColumn::make('is_featured')
                    ->label('Vedette')
                    ->boolean(),

                Tables\Columns\IconColumn::make('is_published')
                    ->label('Publié')
                    ->boolean(),

                Tables\Columns\TextColumn::make('views_count')
                    ->label('Vues')
                    ->sortable(),

                Tables\Columns\TextColumn::make('likes_count')
                    ->label('Likes')
                    ->sortable(),

                Tables\Columns\TextColumn::make('created_at')
                    ->label('Créé le')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(),
            ])
            ->actions([
                Tables\Actions\ViewAction::make()
                    ->label('Voir')
                    ->icon('heroicon-o-eye'),
                    
                Tables\Actions\EditAction::make()
                    ->label('Modifier')
                    ->icon('heroicon-o-pencil-square'),
                    
                Tables\Actions\DeleteAction::make()
                    ->label('Supprimer')
                    ->icon('heroicon-o-trash')
                    ->before(function ($record) {
                        // Supprimer les relations polymorphes avant la suppression principale
                        $record->likes()->delete();
                        $record->comments()->delete();
                    })
                    ->successNotificationTitle('Astuce supprimée avec succès'),
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
                        ->successNotificationTitle('Astuces supprimées avec succès'),

                    Tables\Actions\BulkAction::make('publish')
                        ->label('Publier')
                        ->icon('heroicon-o-check-circle')
                        ->color('success')
                        ->action(fn ($records) => $records->each->update(['is_published' => true]))
                        ->deselectRecordsAfterCompletion()
                        ->successNotificationTitle('Astuces publiées'),

                    Tables\Actions\BulkAction::make('unpublish')
                        ->label('Dépublier')
                        ->icon('heroicon-o-x-circle')
                        ->color('warning')
                        ->action(fn ($records) => $records->each->update(['is_published' => false]))
                        ->deselectRecordsAfterCompletion()
                        ->successNotificationTitle('Astuces dépubliées'),

                    Tables\Actions\BulkAction::make('feature')
                        ->label('Marquer en vedette')
                        ->icon('heroicon-o-star')
                        ->color('warning')
                        ->action(fn ($records) => $records->each->update(['is_featured' => true]))
                        ->deselectRecordsAfterCompletion()
                        ->successNotificationTitle('Astuces marquées en vedette'),
                ]),
            ])
            ->filters([
                Tables\Filters\TernaryFilter::make('is_published')
                    ->label('Statut de publication')
                    ->boolean()
                    ->trueLabel('Publiées seulement')
                    ->falseLabel('Non publiées seulement')
                    ->native(false),

                Tables\Filters\TernaryFilter::make('is_featured')
                    ->label('Astuces vedettes')
                    ->boolean()
                    ->trueLabel('Vedettes seulement')
                    ->falseLabel('Non vedettes seulement')
                    ->native(false),

                Tables\Filters\SelectFilter::make('category_id')
                    ->label('Catégorie')
                    ->relationship('category', 'name')
                    ->native(false),

                Tables\Filters\SelectFilter::make('difficulty_level')
                    ->label('Niveau de difficulté')
                    ->options([
                        'beginner' => 'Débutant',
                        'intermediate' => 'Intermédiaire',
                        'advanced' => 'Avancé',
                    ])
                    ->native(false),


            ])
            ->emptyStateHeading('Aucune astuce créée')
            ->emptyStateDescription('Créez votre première astuce pour commencer.')
            ->emptyStateIcon('heroicon-o-light-bulb')
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
            'index' => Pages\ListTips::route('/'),
            'create' => Pages\CreateTip::route('/create'),
            'view' => Pages\ViewTip::route('/{record}'),
            'edit' => Pages\EditTip::route('/{record}/edit'),
        ];
    }

    public static function getEloquentQuery(): Builder
    {
        // Suppression directe, pas de soft delete
        return parent::getEloquentQuery();
    }

    public static function getNavigationBadge(): ?string
    {
        return static::getModel()::count();
    }
}