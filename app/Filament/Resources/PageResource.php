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
use App\Traits\HasCacheInvalidation;

class PageResource extends Resource
{
    use HasCacheInvalidation;
    protected static ?string $model = Page::class;
    protected static ?string $navigationIcon = 'heroicon-o-document-text';
    protected static ?string $navigationLabel = 'Pages';
    protected static ?string $navigationGroup = 'Contenu';
    protected static ?int $navigationSort = 5;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Configuration de la page')
                    ->description('Configurez simplement le nom du menu et l\'URL à afficher')
                    ->schema([
                        Forms\Components\TextInput::make('title')
                            ->label('Nom du menu')
                            ->required()
                            ->maxLength(255)
                            ->helperText('Nom qui apparaîtra dans le menu de navigation de la PWA')
                            ->placeholder('Ex: À propos, Contact, Boutique...'),
                        
                        Forms\Components\TextInput::make('url')
                            ->label('URL à afficher')
                            ->required()
                            ->url()
                            ->helperText('Page web qui s\'ouvrira dans un iframe dans l\'application')
                            ->placeholder('https://example.com'),

                        Forms\Components\Toggle::make('is_published')
                            ->label('Activer cette page')
                            ->default(true)
                            ->helperText('Afficher dans le menu de l\'application mobile'),

                        Forms\Components\TextInput::make('order')
                            ->label('Position dans le menu')
                            ->numeric()
                            ->default(0)
                            ->helperText('Ordre d\'affichage (0 = en premier)'),
                    ])->columns(2),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('title')
                    ->label('Nom du menu')
                    ->searchable()
                    ->sortable()
                    ->weight('bold'),

                Tables\Columns\TextColumn::make('url')
                    ->label('URL')
                    ->searchable()
                    ->copyable()
                    ->copyMessage('URL copiée!')
                    ->limit(50)
                    ->tooltip(fn ($record) => $record->url),
                    
                Tables\Columns\IconColumn::make('is_published')
                    ->label('Visible')
                    ->boolean()
                    ->trueIcon('heroicon-o-eye')
                    ->falseIcon('heroicon-o-eye-slash'),

                Tables\Columns\TextColumn::make('order')
                    ->label('Position')
                    ->sortable()
                    ->alignCenter()
                    ->badge()
                    ->color('primary'),
                    
                Tables\Columns\TextColumn::make('updated_at')
                    ->label('Modifié le')
                    ->dateTime('d/m/Y H:i')
                    ->sortable()
                    ->since()
                    ->toggleable(),
            ])
            ->filters([
                Tables\Filters\TernaryFilter::make('is_published')
                    ->label('Statut')
                    ->boolean()
                    ->trueLabel('Pages visibles')
                    ->falseLabel('Pages masquées')
                    ->native(false),
            ])
            ->actions([
                Tables\Actions\Action::make('open_url')
                    ->label('Ouvrir')
                    ->icon('heroicon-o-arrow-top-right-on-square')
                    ->color('gray')
                    ->url(fn (Page $record): string => $record->url ?? '#')
                    ->openUrlInNewTab()
                    ->visible(fn (Page $record): bool => !empty($record->url)),

                Tables\Actions\EditAction::make()
                    ->label('Modifier')
                    ->icon('heroicon-o-pencil-square'),
                    
                Tables\Actions\DeleteAction::make()
                    ->label('Supprimer')
                    ->icon('heroicon-o-trash')
                    ->successNotificationTitle('Page supprimée avec succès'),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make()
                        ->label('Supprimer sélectionnées')
                        ->successNotificationTitle('Pages supprimées avec succès'),

                    Tables\Actions\BulkAction::make('show')
                        ->label('Rendre visibles')
                        ->icon('heroicon-o-eye')
                        ->color('success')
                        ->action(fn ($records) => $records->each->update(['is_published' => true]))
                        ->deselectRecordsAfterCompletion()
                        ->successNotificationTitle('Pages rendues visibles'),

                    Tables\Actions\BulkAction::make('hide')
                        ->label('Masquer')
                        ->icon('heroicon-o-eye-slash')
                        ->color('warning')
                        ->action(fn ($records) => $records->each->update(['is_published' => false]))
                        ->deselectRecordsAfterCompletion()
                        ->successNotificationTitle('Pages masquées'),
                ]),
            ])
            ->headerActions([
                Tables\Actions\CreateAction::make()
                    ->label('Créer une page')
                    ->icon('heroicon-o-plus')
                    ->color('primary')
                    ->form([
                        Forms\Components\TextInput::make('title')
                            ->label('Nom du menu')
                            ->required()
                            ->maxLength(255)
                            ->helperText('Nom qui apparaîtra dans le menu de navigation de la PWA')
                            ->placeholder('Ex: À propos, Contact, Boutique...'),
                        
                        Forms\Components\TextInput::make('url')
                            ->label('URL à afficher')
                            ->required()
                            ->url()
                            ->helperText('Page web qui s\'ouvrira dans un iframe dans l\'application')
                            ->placeholder('https://example.com'),

                        Forms\Components\Toggle::make('is_published')
                            ->label('Activer cette page')
                            ->default(true)
                            ->helperText('Afficher dans le menu de l\'application mobile'),

                        Forms\Components\TextInput::make('order')
                            ->label('Position dans le menu')
                            ->numeric()
                            ->default(0)
                            ->helperText('Ordre d\'affichage (0 = en premier)'),
                    ])
                    ->modalHeading('Créer une nouvelle page')
                    ->modalSubmitActionLabel('Créer la page')
                    ->successNotificationTitle('Page créée avec succès')
                    ->after(function () {
                        static::invalidateCache();
                    }),
                    
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
            ->defaultSort('order', 'asc')
            ->reorderable('order')
            ->emptyStateHeading('Aucune page créée')
            ->emptyStateDescription('Créez votre première page pour commencer.')
            ->emptyStateIcon('heroicon-o-document-text');
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
    
    public static function getNavigationBadge(): ?string
    {
        return static::getModel()::count();
    }
}