<?php

namespace App\Filament\Resources;

use App\Filament\Resources\LikeResource\Pages;
use App\Models\Like;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class LikeResource extends Resource
{
    protected static ?string $model = Like::class;

    protected static ?string $navigationIcon = 'heroicon-o-heart';

    protected static ?string $navigationLabel = 'Likes';

    protected static ?string $modelLabel = 'Like';

    protected static ?string $pluralModelLabel = 'Likes';

    protected static ?string $navigationGroup = 'Interactions';

    protected static ?int $navigationSort = 1;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Informations du like')
                    ->schema([
                        Forms\Components\TextInput::make('likeable_type')
                            ->label('Type de contenu')
                            ->disabled(),
                        
                        Forms\Components\TextInput::make('likeable_id')
                            ->label('ID du contenu')
                            ->disabled(),
                        
                        Forms\Components\TextInput::make('ip_address')
                            ->label('Adresse IP')
                            ->disabled(),
                        
                        Forms\Components\Textarea::make('user_agent')
                            ->label('User Agent')
                            ->disabled()
                            ->rows(2),
                    ])->columns(2),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('user.name')
                    ->label('Utilisateur')
                    ->searchable()
                    ->sortable()
                    ->placeholder('Utilisateur anonyme'),

                Tables\Columns\TextColumn::make('likeable_type')
                    ->label('Type de contenu')
                    ->formatStateUsing(fn (string $state): string => match($state) {
                        'App\Models\Recipe' => 'Recette',
                        'App\Models\Event' => 'Événement',
                        'App\Models\DinorTv' => 'Dinor TV',
                        'App\Models\Tip' => 'Astuce',
                        default => $state
                    })
                    ->badge()
                    ->color(fn (string $state): string => match($state) {
                        'App\Models\Recipe' => 'success',
                        'App\Models\Event' => 'warning',
                        'App\Models\DinorTv' => 'info',
                        'App\Models\Tip' => 'primary',
                        default => 'gray'
                    }),

                Tables\Columns\TextColumn::make('likeable_id')
                    ->label('ID du contenu')
                    ->sortable(),

                Tables\Columns\TextColumn::make('ip_address')
                    ->label('Adresse IP')
                    ->searchable()
                    ->toggleable(isToggledHiddenByDefault: true),

                Tables\Columns\TextColumn::make('created_at')
                    ->label('Créé le')
                    ->dateTime('d/m/Y H:i')
                    ->sortable(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('likeable_type')
                    ->label('Type de contenu')
                    ->options([
                        'App\Models\Recipe' => 'Recettes',
                        'App\Models\Event' => 'Événements',
                        'App\Models\DinorTv' => 'Dinor TV',
                        'App\Models\Tip' => 'Astuces',
                    ]),
            ])
            ->actions([
                Tables\Actions\ViewAction::make(),
                Tables\Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
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
            'index' => Pages\ListLikes::route('/'),
            'view' => Pages\ViewLike::route('/{record}'),
        ];
    }

    public static function canCreate(): bool
    {
        return false;
    }

    public static function getNavigationBadge(): ?string
    {
        return static::getModel()::count();
    }
} 