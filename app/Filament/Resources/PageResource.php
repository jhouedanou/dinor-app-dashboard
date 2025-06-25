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
                Forms\Components\Section::make('Page Embed/Iframe')
                    ->description('Ajoutez une URL qui sera affichée dans un embed/iframe dans la PWA')
                    ->schema([
                        Forms\Components\TextInput::make('title')
                            ->label('Titre de la page')
                            ->required()
                            ->maxLength(255)
                            ->helperText('Nom affiché dans l\'application mobile'),
                        
                        Forms\Components\TextInput::make('url')
                            ->label('URL pour Embed/Iframe')
                            ->required()
                            ->url()
                            ->helperText('URL complète à afficher dans un embed/iframe dans la PWA (ex: https://example.com)')
                            ->placeholder('https://'),

                        Forms\Components\Textarea::make('description')
                            ->label('Description (optionnelle)')
                            ->maxLength(500)
                            ->rows(3)
                            ->helperText('Description courte de la page'),

                        Forms\Components\Toggle::make('is_published')
                            ->label('Visible dans l\'app')
                            ->default(true)
                            ->helperText('Afficher cette page dans l\'application mobile'),

                        Forms\Components\TextInput::make('order')
                            ->label('Ordre d\'affichage')
                            ->numeric()
                            ->default(0)
                            ->helperText('Ordre dans la liste (0 = premier)'),
                    ])->columns(1),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('title')
                    ->label('Titre')
                    ->searchable()
                    ->sortable()
                    ->weight('bold'),

                Tables\Columns\TextColumn::make('url')
                    ->label('URL Embed')
                    ->searchable()
                    ->copyable()
                    ->copyMessage('URL copiée!')
                    ->limit(50)
                    ->tooltip(fn ($record) => $record->url),

                Tables\Columns\TextColumn::make('description')
                    ->label('Description')
                    ->limit(60)
                    ->placeholder('Aucune description'),
                    
                Tables\Columns\IconColumn::make('is_published')
                    ->label('Visible')
                    ->boolean()
                    ->trueIcon('heroicon-o-eye')
                    ->falseIcon('heroicon-o-eye-slash'),

                Tables\Columns\TextColumn::make('order')
                    ->label('Ordre')
                    ->sortable()
                    ->alignCenter(),
                    
                Tables\Columns\TextColumn::make('updated_at')
                    ->label('Modifié le')
                    ->dateTime('d/m/Y H:i')
                    ->sortable()
                    ->since(),
            ])
            ->filters([
                Tables\Filters\Filter::make('is_published')
                    ->label('Pages visibles')
                    ->query(fn (Builder $query): Builder => $query->where('is_published', true)),
            ])
            ->actions([
                Tables\Actions\Action::make('open_url')
                    ->label('Ouvrir')
                    ->icon('heroicon-o-arrow-top-right-on-square')
                    ->url(fn (Page $record): string => $record->url ?? '#')
                    ->openUrlInNewTab()
                    ->visible(fn (Page $record): bool => !empty($record->url)),

                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),

                    Tables\Actions\BulkAction::make('show')
                        ->label('Rendre visible')
                        ->icon('heroicon-o-eye')
                        ->action(fn ($records) => $records->each->update(['is_published' => true]))
                        ->deselectRecordsAfterCompletion(),

                    Tables\Actions\BulkAction::make('hide')
                        ->label('Masquer')
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