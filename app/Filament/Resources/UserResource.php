<?php

namespace App\Filament\Resources;

use App\Filament\Resources\UserResource\Pages;
use App\Models\User;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Facades\Hash;

class UserResource extends Resource
{
    protected static ?string $model = User::class;

    protected static ?string $navigationIcon = 'heroicon-o-users';

    protected static ?string $navigationLabel = 'Utilisateurs';

    protected static ?string $modelLabel = 'Utilisateur';

    protected static ?string $pluralModelLabel = 'Utilisateurs';

    protected static ?string $navigationGroup = 'Administration';

    protected static ?int $navigationSort = 1;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Informations personnelles')
                    ->schema([
                        Forms\Components\TextInput::make('name')
                            ->label('Nom')
                            ->required()
                            ->maxLength(255),

                        Forms\Components\TextInput::make('email')
                            ->label('Email')
                            ->email()
                            ->required()
                            ->unique(User::class, 'email', ignoreRecord: true)
                            ->maxLength(255),

                        Forms\Components\TextInput::make('password')
                            ->label('Mot de passe')
                            ->password()
                            ->required(fn ($record) => $record === null)
                            ->dehydrated(fn ($state) => filled($state))
                            ->dehydrateStateUsing(fn ($state) => Hash::make($state))
                            ->maxLength(255),

                        Forms\Components\Select::make('role')
                            ->label('Rôle')
                            ->options([
                                'user' => 'Utilisateur',
                                'professional' => 'Professionnel',
                                'moderator' => 'Modérateur',
                                'admin' => 'Administrateur',
                            ])
                            ->default('user')
                            ->required(),

                        Forms\Components\Toggle::make('is_active')
                            ->label('Compte actif')
                            ->default(true),

                        Forms\Components\DateTimePicker::make('email_verified_at')
                            ->label('Email vérifié le')
                            ->nullable(),
                    ])->columns(2),

                Forms\Components\Section::make('Statistiques')
                    ->schema([
                        Forms\Components\Placeholder::make('likes_count')
                            ->label('Nombre de likes')
                            ->content(fn (?User $record) => $record ? $record->likes()->count() : 0),

                        Forms\Components\Placeholder::make('comments_count')
                            ->label('Nombre de commentaires')
                            ->content(fn (?User $record) => $record ? $record->comments()->count() : 0),

                        Forms\Components\Placeholder::make('created_at')
                            ->label('Membre depuis')
                            ->content(fn (?User $record) => $record ? $record->created_at->format('d/m/Y H:i') : 'N/A'),
                    ])->columns(3)->visibleOn('edit'),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('name')
                    ->label('Nom')
                    ->searchable()
                    ->sortable(),

                Tables\Columns\TextColumn::make('email')
                    ->label('Email')
                    ->searchable()
                    ->sortable(),

                Tables\Columns\TextColumn::make('role')
                    ->label('Rôle')
                    ->badge()
                    ->color(fn (string $state): string => match($state) {
                        'admin' => 'danger',
                        'moderator' => 'warning',
                        'professional' => 'info',
                        'user' => 'success',
                        default => 'gray'
                    })
                    ->formatStateUsing(fn (string $state): string => match($state) {
                        'admin' => 'Administrateur',
                        'moderator' => 'Modérateur',
                        'professional' => 'Professionnel',
                        'user' => 'Utilisateur',
                        default => $state
                    }),

                Tables\Columns\IconColumn::make('is_active')
                    ->label('Actif')
                    ->boolean(),

                Tables\Columns\IconColumn::make('email_verified_at')
                    ->label('Email vérifié')
                    ->boolean()
                    ->getStateUsing(fn ($record) => $record->email_verified_at !== null),

                Tables\Columns\TextColumn::make('likes_count')
                    ->label('Likes')
                    ->counts('likes')
                    ->sortable(),

                Tables\Columns\TextColumn::make('comments_count')
                    ->label('Commentaires')
                    ->counts('comments')
                    ->sortable(),

                Tables\Columns\TextColumn::make('created_at')
                    ->label('Créé le')
                    ->dateTime('d/m/Y H:i')
                    ->sortable()
                    ->toggleable(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('role')
                    ->label('Rôle')
                    ->options([
                        'admin' => 'Administrateur',
                        'moderator' => 'Modérateur',
                        'professional' => 'Professionnel',
                        'user' => 'Utilisateur',
                    ]),

                Tables\Filters\TernaryFilter::make('is_active')
                    ->label('Compte actif'),

                Tables\Filters\TernaryFilter::make('email_verified_at')
                    ->label('Email vérifié')
                    ->nullable(),
            ])
            ->actions([
                Tables\Actions\ViewAction::make(),
                Tables\Actions\EditAction::make(),
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
            'index' => Pages\ListUsers::route('/'),
            'create' => Pages\CreateUser::route('/create'),
            'view' => Pages\ViewUser::route('/{record}'),
            'edit' => Pages\EditUser::route('/{record}/edit'),
        ];
    }

    public static function getNavigationBadge(): ?string
    {
        return static::getModel()::count();
    }
}