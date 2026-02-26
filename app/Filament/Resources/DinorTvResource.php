<?php

namespace App\Filament\Resources;

use App\Filament\Resources\DinorTvResource\Pages;
use App\Models\DinorTv;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use App\Traits\HasCacheInvalidation;

class DinorTvResource extends Resource
{
    use HasCacheInvalidation;
    protected static ?string $model = DinorTv::class;
    protected static ?string $navigationIcon = 'heroicon-o-play-circle';
    protected static ?string $navigationLabel = 'Dinor TV';
    protected static ?string $navigationGroup = 'Contenu';
    protected static ?int $navigationSort = 6;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Contenu Embed/Iframe')
                    ->description('Ajoutez une URL qui sera affichée dans un embed/iframe dans la PWA')
                    ->schema([
                        Forms\Components\TextInput::make('title')
                            ->label('Titre du contenu')
                            ->required()
                            ->maxLength(255)
                            ->helperText('Nom affiché dans l\'application mobile'),
                        
                        Forms\Components\TextInput::make('video_url')
                            ->label('URL pour Embed/Iframe')
                            ->required()
                            ->url()
                            ->helperText('URL complète à afficher dans un embed/iframe dans la PWA (ex: https://www.youtube.com/embed/...)')
                            ->placeholder('https://'),

                        Forms\Components\TextInput::make('short_description')
                            ->label('Description courte')
                            ->maxLength(500)
                            ->helperText('Description courte affichée dans les listes'),

                        Forms\Components\Textarea::make('description')
                            ->label('Description complète')
                            ->maxLength(2000)
                            ->rows(4)
                            ->helperText('Description détaillée du contenu'),
                    ]),

                Forms\Components\Section::make('Images et visuels')
                    ->description('Gérez les différentes images associées au contenu')
                    ->schema([
                        Forms\Components\FileUpload::make('thumbnail')
                            ->label('Miniature (legacy)')
                            ->image()
                            ->disk('public')
                            ->directory('dinor-tv-thumbnails')
                            ->acceptedFileTypes(['image/jpeg', 'image/png', 'image/gif', 'image/webp'])
                            ->rules([new \App\Rules\SafeFile()])
                            ->maxSize(2048)
                            ->helperText('Image d\'aperçu legacy (utiliser Image principale de préférence - max 2MB)'),

                        Forms\Components\FileUpload::make('featured_image')
                            ->label('Image principale')
                            ->image()
                            ->disk('public')
                            ->directory('dinor-tv-featured')
                            ->acceptedFileTypes(['image/jpeg', 'image/png', 'image/gif', 'image/webp'])
                            ->rules([new \App\Rules\SafeFile()])
                            ->maxSize(2048)
                            ->helperText('Image principale du contenu (JPEG, PNG, GIF, WebP - max 2MB)'),

                        Forms\Components\SpatieMediaLibraryFileUpload::make('featured_media')
                            ->label('Images mises en avant (Spatie)')
                            ->collection('featured_images')
                            ->multiple()
                            ->image()
                            ->maxSize(2048)
                            ->acceptedFileTypes(['image/jpeg', 'image/png', 'image/gif', 'image/webp'])
                            ->rules([new \App\Rules\SafeFile()])
                            ->reorderable()
                            ->helperText('Images uploadées via Spatie Media Library (max 2MB)'),

                        Forms\Components\FileUpload::make('poster_image')
                            ->label('Image poster')
                            ->image()
                            ->disk('public')
                            ->directory('dinor-tv-posters')
                            ->acceptedFileTypes(['image/jpeg', 'image/png', 'image/gif', 'image/webp'])
                            ->rules([new \App\Rules\SafeFile()])
                            ->maxSize(2048)
                            ->helperText('Image de type poster/affiche (format portrait recommandé - max 2MB)'),

                        Forms\Components\FileUpload::make('banner_image')
                            ->label('Image bannière')
                            ->image()
                            ->disk('public')
                            ->directory('dinor-tv-banners')
                            ->acceptedFileTypes(['image/jpeg', 'image/png', 'image/gif', 'image/webp'])
                            ->rules([new \App\Rules\SafeFile()])
                            ->maxSize(2048)
                            ->helperText('Image bannière (format paysage 16:9 recommandé - max 2MB)'),

                        Forms\Components\SpatieMediaLibraryFileUpload::make('gallery_media')
                            ->label('Galerie d\'images (Spatie)')
                            ->collection('gallery')
                            ->multiple()
                            ->image()
                            ->maxSize(2048)
                            ->acceptedFileTypes(['image/jpeg', 'image/png', 'image/gif', 'image/webp'])
                            ->rules([new \App\Rules\SafeFile()])
                            ->reorderable()
                            ->helperText('Galerie d\'images pour ce contenu (max 2MB)'),

                        Forms\Components\Repeater::make('gallery')
                            ->label('Galerie d\'images (URLs)')
                            ->schema([
                                Forms\Components\TextInput::make('url')
                                    ->label('URL de l\'image')
                                    ->url()
                                    ->required(),
                                Forms\Components\TextInput::make('alt')
                                    ->label('Texte alternatif')
                                    ->maxLength(255),
                            ])
                            ->collapsed()
                            ->itemLabel(fn (array $state): ?string => $state['url'] ?? null)
                            ->addActionLabel('Ajouter une image')
                            ->helperText('Images de la galerie via URLs externes'),

                        Forms\Components\KeyValue::make('image_metadata')
                            ->label('Métadonnées des images')
                            ->helperText('Informations supplémentaires sur les images (crédits, sources, etc.)'),
                    ]),

                Forms\Components\Section::make('Configuration')
                    ->schema([

                        Forms\Components\Toggle::make('is_published')
                            ->label('Visible dans l\'app')
                            ->default(true)
                            ->helperText('Afficher ce contenu dans l\'application mobile'),

                        Forms\Components\Toggle::make('is_featured')
                            ->label('Contenu mis en avant')
                            ->default(false)
                            ->helperText('Afficher en premier dans l\'application'),
                    ])->columns(1),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\ImageColumn::make('featured_image')
                    ->label('Image')
                    ->getStateUsing(function ($record) {
                        return $record->featured_image_url ?? $record->thumbnail;
                    })
                    ->circular()
                    ->size(60)
                    ->defaultImageUrl('/images/default-video-thumb.jpg'),

                Tables\Columns\TextColumn::make('title')
                    ->label('Titre')
                    ->searchable()
                    ->sortable()
                    ->weight('bold'),

                Tables\Columns\TextColumn::make('video_url')
                    ->label('URL Embed')
                    ->searchable()
                    ->copyable()
                    ->copyMessage('URL copiée!')
                    ->limit(50)
                    ->tooltip(fn ($record) => $record->video_url),

                Tables\Columns\TextColumn::make('short_description')
                    ->label('Description courte')
                    ->limit(60)
                    ->placeholder('Aucune description')
                    ->toggleable(isToggledHiddenByDefault: true),

                Tables\Columns\ViewColumn::make('images_status')
                    ->label('Images')
                    ->view('filament.tables.columns.dinor-tv-images-status')
                    ->toggleable(),

                Tables\Columns\IconColumn::make('is_featured')
                    ->label('Mise en avant')
                    ->boolean()
                    ->trueIcon('heroicon-o-star')
                    ->falseIcon('heroicon-o-star')
                    ->trueColor('warning')
                    ->falseColor('gray'),
                    
                Tables\Columns\IconColumn::make('is_published')
                    ->label('Visible')
                    ->boolean()
                    ->trueIcon('heroicon-o-eye')
                    ->falseIcon('heroicon-o-eye-slash'),

                Tables\Columns\TextColumn::make('view_count')
                    ->label('Vues')
                    ->numeric()
                    ->alignCenter()
                    ->default(0)
                    ->toggleable(),
                    
                Tables\Columns\TextColumn::make('updated_at')
                    ->label('Modifié le')
                    ->dateTime('d/m/Y H:i')
                    ->sortable()
                    ->since()
                    ->toggleable(),
            ])
            ->filters([
                Tables\Filters\TernaryFilter::make('is_published')
                    ->label('Statut de publication')
                    ->boolean()
                    ->trueLabel('Contenus visibles')
                    ->falseLabel('Contenus masqués')
                    ->native(false),

                Tables\Filters\TernaryFilter::make('is_featured')
                    ->label('Mise en avant')
                    ->boolean()
                    ->trueLabel('Mis en avant seulement')
                    ->falseLabel('Non mis en avant')
                    ->native(false),
            ])
            ->actions([
                Tables\Actions\Action::make('open_url')
                    ->label('Ouvrir')
                    ->icon('heroicon-o-arrow-top-right-on-square')
                    ->color('gray')
                    ->url(fn (DinorTv $record): string => $record->video_url)
                    ->openUrlInNewTab(),

                Tables\Actions\EditAction::make()
                    ->label('Modifier')
                    ->icon('heroicon-o-pencil-square'),
                    
                Tables\Actions\DeleteAction::make()
                    ->label('Supprimer')
                    ->icon('heroicon-o-trash')
                    ->successNotificationTitle('Contenu supprimé avec succès'),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make()
                        ->label('Supprimer sélectionnés')
                        ->successNotificationTitle('Contenus supprimés avec succès'),

                    Tables\Actions\BulkAction::make('publish')
                        ->label('Publier')
                        ->icon('heroicon-o-check-circle')
                        ->color('success')
                        ->action(fn ($records) => $records->each->update(['is_published' => true]))
                        ->deselectRecordsAfterCompletion()
                        ->successNotificationTitle('Contenus publiés'),

                    Tables\Actions\BulkAction::make('unpublish')
                        ->label('Masquer')
                        ->icon('heroicon-o-eye-slash')
                        ->color('warning')
                        ->action(fn ($records) => $records->each->update(['is_published' => false]))
                        ->deselectRecordsAfterCompletion()
                        ->successNotificationTitle('Contenus masqués'),

                    Tables\Actions\BulkAction::make('feature')
                        ->label('Mettre en avant')
                        ->icon('heroicon-o-star')
                        ->color('warning')
                        ->action(fn ($records) => $records->each->update(['is_featured' => true]))
                        ->deselectRecordsAfterCompletion()
                        ->successNotificationTitle('Contenus mis en avant'),

                    Tables\Actions\BulkAction::make('unfeature')
                        ->label('Retirer de la mise en avant')
                        ->icon('heroicon-o-star')
                        ->color('gray')
                        ->action(fn ($records) => $records->each->update(['is_featured' => false]))
                        ->deselectRecordsAfterCompletion()
                        ->successNotificationTitle('Contenus retirés de la mise en avant'),
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
            ])
            ->emptyStateHeading('Aucun contenu Dinor TV créé')
            ->emptyStateDescription('Créez votre premier contenu vidéo pour commencer.')
            ->emptyStateIcon('heroicon-o-play-circle')
            ->defaultSort('is_featured', 'desc')
            ->defaultSort('updated_at', 'desc');
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
            'index' => Pages\ListDinorTvs::route('/'),
            'create' => Pages\CreateDinorTv::route('/create'),
            'edit' => Pages\EditDinorTv::route('/{record}/edit'),
        ];
    }
    
    public static function getNavigationBadge(): ?string
    {
        return static::getModel()::count();
    }
}