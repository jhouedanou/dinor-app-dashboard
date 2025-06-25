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

class DinorTvResource extends Resource
{
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

                        Forms\Components\Textarea::make('description')
                            ->label('Description (optionnelle)')
                            ->maxLength(500)
                            ->rows(3)
                            ->helperText('Description courte du contenu'),

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

                Tables\Columns\TextColumn::make('description')
                    ->label('Description')
                    ->limit(60)
                    ->placeholder('Aucune description'),

                Tables\Columns\IconColumn::make('is_featured')
                    ->label('Mise en avant')
                    ->boolean()
                    ->trueIcon('heroicon-o-star')
                    ->falseIcon('heroicon-o-star'),
                    
                Tables\Columns\IconColumn::make('is_published')
                    ->label('Visible')
                    ->boolean()
                    ->trueIcon('heroicon-o-eye')
                    ->falseIcon('heroicon-o-eye-slash'),

                Tables\Columns\TextColumn::make('view_count')
                    ->label('Vues')
                    ->numeric()
                    ->alignCenter()
                    ->default(0),
                    
                Tables\Columns\TextColumn::make('updated_at')
                    ->label('Modifié le')
                    ->dateTime('d/m/Y H:i')
                    ->sortable()
                    ->since(),
            ])
            ->filters([
                Tables\Filters\Filter::make('is_published')
                    ->label('Contenus visibles')
                    ->query(fn (Builder $query): Builder => $query->where('is_published', true)),

                Tables\Filters\Filter::make('is_featured')
                    ->label('Contenus mis en avant')
                    ->query(fn (Builder $query): Builder => $query->where('is_featured', true)),
            ])
            ->actions([
                Tables\Actions\Action::make('open_url')
                    ->label('Ouvrir URL')
                    ->icon('heroicon-o-arrow-top-right-on-square')
                    ->url(fn (DinorTv $record): string => $record->video_url)
                    ->openUrlInNewTab(),

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

                    Tables\Actions\BulkAction::make('feature')
                        ->label('Mettre en avant')
                        ->icon('heroicon-o-star')
                        ->action(fn ($records) => $records->each->update(['is_featured' => true]))
                        ->deselectRecordsAfterCompletion(),
                ]),
            ])
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
}