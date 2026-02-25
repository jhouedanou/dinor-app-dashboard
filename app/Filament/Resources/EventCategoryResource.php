<?php

namespace App\Filament\Resources;

use App\Filament\Resources\EventCategoryResource\Pages;
use App\Models\EventCategory;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Str;

class EventCategoryResource extends Resource
{
    protected static ?string $model = EventCategory::class;
    protected static ?string $navigationIcon = 'heroicon-o-tag';
    protected static ?string $navigationLabel = 'Catégories d\'événements';
    protected static ?string $navigationGroup = 'Configuration';
    protected static ?int $navigationSort = 1;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Informations générales')
                    ->schema([
                        Forms\Components\TextInput::make('name')
                            ->label('Nom')
                            ->required()
                            ->maxLength(255)
                            ->live(onBlur: true)
                            ->afterStateUpdated(fn (string $context, $state, callable $set) => 
                                $context === 'create' ? $set('slug', Str::slug($state)) : null
                            ),

                        Forms\Components\TextInput::make('slug')
                            ->label('Slug URL')
                            ->required()
                            ->maxLength(255)
                            ->unique(EventCategory::class, 'slug', ignoreRecord: true),

                        Forms\Components\Textarea::make('description')
                            ->label('Description')
                            ->rows(3),
                    ])->columns(2),

                Forms\Components\Section::make('Apparence')
                    ->schema([
                        Forms\Components\ColorPicker::make('color')
                            ->label('Couleur')
                            ->default('#3b82f6'),

                        Forms\Components\Select::make('icon')
                            ->label('Icône')
                            ->options([
                                'heroicon-o-academic-cap' => 'Séminaire',
                                'heroicon-o-microphone' => 'Conférence',
                                'heroicon-o-wrench-screwdriver' => 'Atelier',
                                'heroicon-o-book-open' => 'Cours',
                                'heroicon-o-heart' => 'Dégustation',
                                'heroicon-o-sparkles' => 'Festival',
                                'heroicon-o-trophy' => 'Concours',
                                'heroicon-o-users' => 'Networking',
                                'heroicon-o-building-storefront' => 'Exposition',
                                'heroicon-o-gift' => 'Fête',
                                'heroicon-o-calendar-days' => 'Événement',
                                'heroicon-o-star' => 'Spécial',
                            ])
                            ->searchable(),

                        Forms\Components\FileUpload::make('image')
                            ->label('Image de catégorie')
                            ->image()
                            ->disk('public')
                            ->directory('event-categories')
                            ->visibility('public')
                            ->maxSize(2048)
                            ->acceptedFileTypes(['image/jpeg', 'image/png', 'image/gif', 'image/webp']),
                    ])->columns(2),

                Forms\Components\Section::make('Paramètres')
                    ->schema([
                        Forms\Components\Toggle::make('is_active')
                            ->label('Actif')
                            ->default(true),
                    ]),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\ColorColumn::make('color')
                    ->label('Couleur'),

                Tables\Columns\TextColumn::make('name')
                    ->label('Nom')
                    ->searchable()
                    ->sortable(),

                Tables\Columns\TextColumn::make('slug')
                    ->label('Slug')
                    ->searchable()
                    ->copyable(),

                Tables\Columns\TextColumn::make('description')
                    ->label('Description')
                    ->limit(50),

                Tables\Columns\TextColumn::make('events_count')
                    ->label('Événements')
                    ->counts('events')
                    ->sortable(),

                Tables\Columns\IconColumn::make('is_active')
                    ->label('Actif')
                    ->boolean(),

                Tables\Columns\TextColumn::make('created_at')
                    ->label('Créé le')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                Tables\Filters\TernaryFilter::make('is_active')
                    ->label('Statut')
                    ->trueLabel('Actif')
                    ->falseLabel('Inactif')
                    ->native(false),
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
            ->defaultSort('name');
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
            'index' => Pages\ListEventCategories::route('/'),
            'create' => Pages\CreateEventCategory::route('/create'),
            'view' => Pages\ViewEventCategory::route('/{record}'),
            'edit' => Pages\EditEventCategory::route('/{record}/edit'),
        ];
    }
} 