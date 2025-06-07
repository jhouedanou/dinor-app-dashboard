<?php

namespace App\Filament\Resources;

use App\Filament\Resources\PageResource\Pages;
use App\Models\Page;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class PageResource extends Resource
{
    protected static ?string $model = Page::class;
    protected static ?string $navigationIcon = 'heroicon-o-document-text';
    protected static ?string $navigationLabel = 'Pages';
    protected static ?string $navigationGroup = 'Contenu';
    protected static ?int $navigationSort = 5;

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
                            ->unique(Page::class, 'slug', ignoreRecord: true),

                        Forms\Components\Select::make('parent_id')
                            ->label('Page parent')
                            ->options(fn () => Page::published()->rootPages()->pluck('title', 'id'))
                            ->searchable()
                            ->placeholder('Aucune (page racine)'),

                        Forms\Components\Select::make('template')
                            ->label('Template')
                            ->options([
                                'default' => 'Par défaut',
                                'full_width' => 'Pleine largeur',
                                'landing' => 'Page d\'atterrissage',
                                'blog' => 'Blog',
                                'contact' => 'Contact',
                                'about' => 'À propos',
                            ])
                            ->default('default'),

                        Forms\Components\TextInput::make('order')
                            ->label('Ordre d\'affichage')
                            ->numeric()
                            ->default(0),

                        Forms\Components\FileUpload::make('featured_image')
                            ->label('Image mise en avant')
                            ->image()
                            ->directory('pages')
                            ->maxSize(5120)
                            ->imageEditor(),
                    ])->columns(2),

                Forms\Components\Section::make('Contenu')
                    ->schema([
                        Forms\Components\RichEditor::make('content')
                            ->label('Contenu')
                            ->required()
                            ->columnSpanFull()
                            ->toolbarButtons([
                                'attachFiles',
                                'blockquote',
                                'bold',
                                'bulletList',
                                'codeBlock',
                                'h2',
                                'h3',
                                'italic',
                                'link',
                                'orderedList',
                                'redo',
                                'strike',
                                'table',
                                'undo',
                            ]),
                    ]),

                Forms\Components\Section::make('SEO et métadonnées')
                    ->schema([
                        Forms\Components\TextInput::make('meta_title')
                            ->label('Titre META')
                            ->maxLength(60)
                            ->helperText('Optimisé pour les moteurs de recherche (60 caractères max)'),

                        Forms\Components\Textarea::make('meta_description')
                            ->label('Description META')
                            ->maxLength(160)
                            ->rows(3)
                            ->helperText('Description pour les moteurs de recherche (160 caractères max)'),

                        Forms\Components\Textarea::make('meta_keywords')
                            ->label('Mots-clés META')
                            ->rows(2)
                            ->helperText('Mots-clés séparés par des virgules'),
                    ])->columns(1),

                Forms\Components\Section::make('Paramètres')
                    ->schema([
                        Forms\Components\Toggle::make('is_published')
                            ->label('Publié')
                            ->default(false),

                        Forms\Components\Toggle::make('is_homepage')
                            ->label('Page d\'accueil')
                            ->default(false)
                            ->helperText('Définir cette page comme page d\'accueil du site'),
                    ])->columns(2),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\ImageColumn::make('featured_image')
                    ->label('Image')
                    ->circular(),
                    
                Tables\Columns\TextColumn::make('title')
                    ->label('Titre')
                    ->searchable()
                    ->sortable(),

                Tables\Columns\TextColumn::make('slug')
                    ->label('URL')
                    ->searchable()
                    ->copyable()
                    ->copyMessage('URL copiée!')
                    ->prefix(url('/page/')),

                Tables\Columns\TextColumn::make('parent.title')
                    ->label('Page parent')
                    ->placeholder('Page racine'),

                Tables\Columns\TextColumn::make('template')
                    ->label('Template')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'default' => 'gray',
                        'full_width' => 'info',
                        'landing' => 'success',
                        'blog' => 'warning',
                        'contact' => 'primary',
                        'about' => 'secondary',
                        default => 'gray',
                    }),

                Tables\Columns\TextColumn::make('order')
                    ->label('Ordre')
                    ->sortable(),
                    
                Tables\Columns\IconColumn::make('is_homepage')
                    ->label('Accueil')
                    ->boolean(),
                    
                Tables\Columns\IconColumn::make('is_published')
                    ->label('Publié')
                    ->boolean(),

                Tables\Columns\TextColumn::make('children_count')
                    ->label('Sous-pages')
                    ->counts('children')
                    ->sortable(),
                    
                Tables\Columns\TextColumn::make('created_at')
                    ->label('Créé le')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),

                Tables\Columns\TextColumn::make('updated_at')
                    ->label('Modifié le')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('template')
                    ->label('Template')
                    ->options([
                        'default' => 'Par défaut',
                        'full_width' => 'Pleine largeur',
                        'landing' => 'Page d\'atterrissage',
                        'blog' => 'Blog',
                        'contact' => 'Contact',
                        'about' => 'À propos',
                    ]),

                Tables\Filters\Filter::make('root_pages')
                    ->label('Pages racines')
                    ->query(fn (Builder $query): Builder => $query->rootPages()),

                Tables\Filters\Filter::make('child_pages')
                    ->label('Sous-pages')
                    ->query(fn (Builder $query): Builder => $query->whereNotNull('parent_id')),

                Tables\Filters\Filter::make('is_homepage')
                    ->label('Page d\'accueil')
                    ->query(fn (Builder $query): Builder => $query->where('is_homepage', true)),

                Tables\Filters\Filter::make('is_published')
                    ->label('Pages publiées')
                    ->query(fn (Builder $query): Builder => $query->where('is_published', true)),

                Tables\Filters\TrashedFilter::make(),
            ])
            ->actions([
                Tables\Actions\Action::make('view_page')
                    ->label('Voir')
                    ->icon('heroicon-o-eye')
                    ->url(fn (Page $record): string => $record->url)
                    ->openUrlInNewTab()
                    ->visible(fn (Page $record): bool => $record->is_published),

                Tables\Actions\ViewAction::make(),
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),

                Tables\Actions\Action::make('duplicate')
                    ->label('Dupliquer')
                    ->icon('heroicon-o-document-duplicate')
                    ->action(function (Page $record) {
                        $newPage = $record->replicate();
                        $newPage->title = $record->title . ' (Copie)';
                        $newPage->slug = $record->slug . '-copie';
                        $newPage->is_published = false;
                        $newPage->is_homepage = false;
                        $newPage->save();
                        
                        return redirect()->route('filament.admin.resources.pages.edit', $newPage);
                    }),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                    Tables\Actions\ForceDeleteBulkAction::make(),
                    Tables\Actions\RestoreBulkAction::make(),

                    Tables\Actions\BulkAction::make('publish')
                        ->label('Publier')
                        ->icon('heroicon-o-eye')
                        ->action(fn ($records) => $records->each->update(['is_published' => true]))
                        ->deselectRecordsAfterCompletion(),

                    Tables\Actions\BulkAction::make('unpublish')
                        ->label('Dépublier')
                        ->icon('heroicon-o-eye-slash')
                        ->action(fn ($records) => $records->each->update(['is_published' => false]))
                        ->deselectRecordsAfterCompletion(),
                ]),
            ])
            ->defaultSort('order', 'asc')
            ->reorderable('order');
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
            'index' => Pages\ListPages::route('/'),
            'create' => Pages\CreatePage::route('/create'),
            'view' => Pages\ViewPage::route('/{record}'),
            'edit' => Pages\EditPage::route('/{record}/edit'),
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