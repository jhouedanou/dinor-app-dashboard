<?php

namespace App\Filament\Resources;

use App\Filament\Resources\MediaFileResource\Pages;
use App\Models\MediaFile;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class MediaFileResource extends Resource
{
    protected static ?string $model = MediaFile::class;
    protected static ?string $navigationIcon = 'heroicon-o-photo';
    protected static ?string $navigationLabel = 'Médiathèque';
    protected static ?string $navigationGroup = 'Gestion';
    protected static ?int $navigationSort = 10;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Informations du fichier')
                    ->schema([
                        Forms\Components\FileUpload::make('path')
                            ->label('Image')
                            ->required()
                            ->image()
                            ->directory('media')
                            ->preserveFilenames()
                            ->maxSize(2048) // 2MB
                            ->acceptedFileTypes([
                                'image/jpeg',
                                'image/png',
                                'image/gif',
                                'image/webp',
                            ])
                            ->live()
                            ->afterStateUpdated(function ($state, callable $set) {
                                if ($state) {
                                    $filename = pathinfo($state, PATHINFO_FILENAME);
                                    $set('name', $filename);
                                    $set('title', $filename);
                                }
                            }),
                            
                        Forms\Components\TextInput::make('name')
                            ->label('Nom')
                            ->required()
                            ->maxLength(255),
                            
                        Forms\Components\TextInput::make('title')
                            ->label('Titre')
                            ->maxLength(255),
                            
                        Forms\Components\Select::make('type')
                            ->label('Type de média')
                            ->options([
                                'image' => 'Image',
                                'video' => 'Vidéo',
                                'audio' => 'Audio',
                                'document' => 'Document',
                                'other' => 'Autre',
                            ])
                            ->required(),
                            
                        Forms\Components\Select::make('collection_name')
                            ->label('Collection')
                            ->options([
                                'featured_image' => 'Image principale',
                                'gallery' => 'Galerie',
                                'videos' => 'Vidéos',
                                'promotional' => 'Promotionnel',
                                'thumbnails' => 'Miniatures',
                                'documents' => 'Documents',
                            ])
                            ->placeholder('Sélectionner une collection'),
                    ])->columns(2),

                Forms\Components\Section::make('Métadonnées')
                    ->schema([
                        Forms\Components\Textarea::make('description')
                            ->label('Description')
                            ->rows(3),
                            
                        Forms\Components\TextInput::make('alt_text')
                            ->label('Texte alternatif')
                            ->maxLength(255)
                            ->helperText('Important pour l\'accessibilité et le SEO'),
                            
                        Forms\Components\Textarea::make('caption')
                            ->label('Légende')
                            ->rows(2),
                            
                        Forms\Components\TagsInput::make('tags')
                            ->label('Tags')
                            ->placeholder('Ajoutez des tags pour organiser vos médias'),
                    ])->columns(2),

                Forms\Components\Section::make('Paramètres')
                    ->schema([
                        Forms\Components\Toggle::make('is_public')
                            ->label('Public')
                            ->default(true)
                            ->helperText('Les fichiers publics sont accessibles via URL directe'),
                            
                        Forms\Components\Toggle::make('is_featured')
                            ->label('Mis en avant')
                            ->default(false),
                            
                        Forms\Components\Toggle::make('is_optimized')
                            ->label('Optimisé')
                            ->default(false)
                            ->helperText('Indique si le fichier a été optimisé pour le web'),
                    ])->columns(3),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\ImageColumn::make('path')
                    ->label('Aperçu')
                    ->circular()
                    ->defaultImageUrl(url('/images/placeholder.png'))
                    ->visibility('visible'),
                    
                Tables\Columns\TextColumn::make('name')
                    ->label('Nom')
                    ->searchable()
                    ->sortable(),
                    
                Tables\Columns\TextColumn::make('type')
                    ->label('Type')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'image' => 'success',
                        'video' => 'info',
                        'audio' => 'warning',
                        'document' => 'gray',
                        default => 'gray',
                    }),
                    
                Tables\Columns\TextColumn::make('collection_name')
                    ->label('Collection')
                    ->badge()
                    ->placeholder('Non assigné'),
                    
                Tables\Columns\TextColumn::make('formatted_size')
                    ->label('Taille')
                    ->sortable('size'),
                    
                Tables\Columns\TextColumn::make('mime_type')
                    ->label('Format')
                    ->searchable()
                    ->toggleable(isToggledHiddenByDefault: true),
                    
                Tables\Columns\IconColumn::make('is_public')
                    ->label('Public')
                    ->boolean(),
                    
                Tables\Columns\IconColumn::make('is_featured')
                    ->label('Vedette')
                    ->boolean(),
                    
                Tables\Columns\TextColumn::make('view_count')
                    ->label('Vues')
                    ->numeric()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
                    
                Tables\Columns\TextColumn::make('download_count')
                    ->label('Téléchargements')
                    ->numeric()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
                    
                Tables\Columns\TextColumn::make('created_at')
                    ->label('Créé le')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('type')
                    ->label('Type')
                    ->options([
                        'image' => 'Images',
                        'video' => 'Vidéos',
                        'audio' => 'Audios',
                        'document' => 'Documents',
                        'other' => 'Autres',
                    ]),
                    
                Tables\Filters\SelectFilter::make('collection_name')
                    ->label('Collection')
                    ->options([
                        'featured_image' => 'Images principales',
                        'gallery' => 'Galerie',
                        'videos' => 'Vidéos',
                        'promotional' => 'Promotionnel',
                        'thumbnails' => 'Miniatures',
                        'documents' => 'Documents',
                    ]),
                    
                Tables\Filters\Filter::make('is_public')
                    ->label('Fichiers publics')
                    ->query(fn (Builder $query): Builder => $query->where('is_public', true)),
                    
                Tables\Filters\Filter::make('is_featured')
                    ->label('Fichiers vedettes')
                    ->query(fn (Builder $query): Builder => $query->where('is_featured', true)),
                    
                Tables\Filters\TrashedFilter::make(),
            ])
            ->actions([
                Tables\Actions\Action::make('view')
                    ->label('Voir')
                    ->icon('heroicon-o-eye')
                    ->url(fn (MediaFile $record): string => $record->url)
                    ->openUrlInNewTab(),
                    
                Tables\Actions\Action::make('download')
                    ->label('Télécharger')
                    ->icon('heroicon-o-arrow-down-tray')
                    ->action(function (MediaFile $record) {
                        $record->incrementDownloads();
                        return response()->download(storage_path('app/public/' . $record->path));
                    }),
                    
                Tables\Actions\ViewAction::make(),
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                    Tables\Actions\ForceDeleteBulkAction::make(),
                    Tables\Actions\RestoreBulkAction::make(),
                    
                    Tables\Actions\BulkAction::make('mark_as_featured')
                        ->label('Marquer comme vedette')
                        ->icon('heroicon-o-star')
                        ->action(fn ($records) => $records->each->update(['is_featured' => true])),
                        
                    Tables\Actions\BulkAction::make('mark_as_public')
                        ->label('Rendre public')
                        ->icon('heroicon-o-globe-alt')
                        ->action(fn ($records) => $records->each->update(['is_public' => true])),
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
            'index' => Pages\ListMediaFiles::route('/'),
            'create' => Pages\CreateMediaFile::route('/create'),
            'view' => Pages\ViewMediaFile::route('/{record}'),
            'edit' => Pages\EditMediaFile::route('/{record}/edit'),
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