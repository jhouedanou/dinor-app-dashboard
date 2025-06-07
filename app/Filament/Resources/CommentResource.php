<?php

namespace App\Filament\Resources;

use App\Filament\Resources\CommentResource\Pages;
use App\Models\Comment;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class CommentResource extends Resource
{
    protected static ?string $model = Comment::class;

    protected static ?string $navigationIcon = 'heroicon-o-chat-bubble-left-right';

    protected static ?string $navigationLabel = 'Commentaires';

    protected static ?string $modelLabel = 'Commentaire';

    protected static ?string $pluralModelLabel = 'Commentaires';

    protected static ?string $navigationGroup = 'Interactions';

    protected static ?int $navigationSort = 2;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Informations du commentaire')
                    ->schema([
                        Forms\Components\TextInput::make('author_name')
                            ->label('Nom de l\'auteur')
                            ->maxLength(100),
                        
                        Forms\Components\TextInput::make('author_email')
                            ->label('Email de l\'auteur')
                            ->email()
                            ->maxLength(255),
                        
                        Forms\Components\Textarea::make('content')
                            ->label('Contenu')
                            ->required()
                            ->rows(4)
                            ->maxLength(1000),
                        
                        Forms\Components\Toggle::make('is_approved')
                            ->label('Approuvé')
                            ->default(false),
                    ])->columns(2),

                Forms\Components\Section::make('Contenu associé')
                    ->schema([
                        Forms\Components\TextInput::make('commentable_type')
                            ->label('Type de contenu')
                            ->disabled(),
                        
                        Forms\Components\TextInput::make('commentable_id')
                            ->label('ID du contenu')
                            ->disabled(),
                    ])->columns(2),

                Forms\Components\Section::make('Informations techniques')
                    ->schema([
                        Forms\Components\TextInput::make('ip_address')
                            ->label('Adresse IP')
                            ->disabled(),
                        
                        Forms\Components\Textarea::make('user_agent')
                            ->label('User Agent')
                            ->disabled()
                            ->rows(2),
                    ])->columns(1)->collapsed(),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('author_name')
                    ->label('Auteur')
                    ->searchable()
                    ->sortable(),

                Tables\Columns\TextColumn::make('content')
                    ->label('Contenu')
                    ->limit(50)
                    ->searchable(),

                Tables\Columns\TextColumn::make('commentable_type')
                    ->label('Type')
                    ->formatStateUsing(fn (string $state): string => match($state) {
                        'App\Models\Recipe' => 'Recette',
                        'App\Models\Event' => 'Événement',
                        'App\Models\DinorTv' => 'Dinor TV',
                        default => $state
                    })
                    ->badge()
                    ->color(fn (string $state): string => match($state) {
                        'App\Models\Recipe' => 'success',
                        'App\Models\Event' => 'warning',
                        'App\Models\DinorTv' => 'info',
                        default => 'gray'
                    }),

                Tables\Columns\IconColumn::make('is_approved')
                    ->label('Approuvé')
                    ->boolean()
                    ->sortable(),

                Tables\Columns\TextColumn::make('created_at')
                    ->label('Créé le')
                    ->dateTime('d/m/Y H:i')
                    ->sortable(),

                Tables\Columns\TextColumn::make('replies_count')
                    ->label('Réponses')
                    ->counts('replies')
                    ->sortable(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('is_approved')
                    ->label('Statut')
                    ->options([
                        1 => 'Approuvé',
                        0 => 'En attente',
                    ]),

                Tables\Filters\SelectFilter::make('commentable_type')
                    ->label('Type de contenu')
                    ->options([
                        'App\Models\Recipe' => 'Recettes',
                        'App\Models\Event' => 'Événements',
                        'App\Models\DinorTv' => 'Dinor TV',
                    ]),

                Tables\Filters\TrashedFilter::make(),
            ])
            ->actions([
                Tables\Actions\Action::make('approve')
                    ->label('Approuver')
                    ->icon('heroicon-o-check')
                    ->color('success')
                    ->action(fn (Comment $record) => $record->update(['is_approved' => true]))
                    ->visible(fn (Comment $record) => !$record->is_approved),

                Tables\Actions\Action::make('reject')
                    ->label('Rejeter')
                    ->icon('heroicon-o-x-mark')
                    ->color('danger')
                    ->action(fn (Comment $record) => $record->update(['is_approved' => false]))
                    ->visible(fn (Comment $record) => $record->is_approved),

                Tables\Actions\ViewAction::make(),
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\BulkAction::make('approve')
                        ->label('Approuver sélectionnés')
                        ->icon('heroicon-o-check')
                        ->color('success')
                        ->action(fn ($records) => $records->each->update(['is_approved' => true])),

                    Tables\Actions\BulkAction::make('reject')
                        ->label('Rejeter sélectionnés')
                        ->icon('heroicon-o-x-mark')
                        ->color('danger')
                        ->action(fn ($records) => $records->each->update(['is_approved' => false])),

                    Tables\Actions\DeleteBulkAction::make(),
                    Tables\Actions\ForceDeleteBulkAction::make(),
                    Tables\Actions\RestoreBulkAction::make(),
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
            'index' => Pages\ListComments::route('/'),
            'create' => Pages\CreateComment::route('/create'),
            'view' => Pages\ViewComment::route('/{record}'),
            'edit' => Pages\EditComment::route('/{record}/edit'),
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
        return static::getModel()::pending()->count();
    }

    public static function getNavigationBadgeColor(): ?string
    {
        return static::getNavigationBadge() > 0 ? 'warning' : null;
    }
} 