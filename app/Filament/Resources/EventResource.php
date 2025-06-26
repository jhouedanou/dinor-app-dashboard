<?php

namespace App\Filament\Resources;

use App\Filament\Resources\EventResource\Pages;
use App\Models\Event;
use App\Models\Category;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;
use App\Traits\HasCacheInvalidation;

class EventResource extends Resource
{
    use HasCacheInvalidation;
    protected static ?string $model = Event::class;
    protected static ?string $navigationIcon = 'heroicon-o-calendar-days';
    protected static ?string $navigationLabel = 'Événements';
    protected static ?string $navigationGroup = 'Contenu';
    protected static ?int $navigationSort = 3;

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
                            ->unique(Event::class, 'slug', ignoreRecord: true),
                        
                        Forms\Components\Select::make('category_id')
                            ->label('Catégorie')
                            ->options(Category::active()->forEvents()->pluck('name', 'id'))
                            ->required()
                            ->searchable()
                            ->helperText('Seules les catégories de type "Événement" sont affichées'),
                            
                        Forms\Components\Textarea::make('description')
                            ->label('Description courte')
                            ->required()
                            ->rows(3),

                        Forms\Components\Textarea::make('short_description')
                            ->label('Résumé')
                            ->rows(2),
                            
                        Forms\Components\RichEditor::make('content')
                            ->label('Contenu détaillé')
                            ->columnSpanFull(),
                    ])->columns(2),

                Forms\Components\Section::make('Images et médias')
                    ->schema([
                        Forms\Components\FileUpload::make('featured_image')
                            ->label('Image principale')
                            ->image()
                            ->disk('public')
                            ->directory('events/featured')
                            ->visibility('public')
                            ->maxSize(5120)
                            ->imageEditor()
                            ->imageEditorAspectRatios([
                                '16:9',
                                '4:3',
                                '1:1',
                            ]),

                        Forms\Components\FileUpload::make('gallery')
                            ->label('Galerie d\'images')
                            ->image()
                            ->multiple()
                            ->disk('public')
                            ->directory('events/gallery')
                            ->visibility('public')
                            ->maxSize(3072)
                            ->maxFiles(20)
                            ->imageEditor()
                            ->reorderable(),

                        Forms\Components\TextInput::make('video_url')
                            ->label('URL Vidéo')
                            ->url(),

                        Forms\Components\TextInput::make('live_stream_url')
                            ->label('URL Stream Live')
                            ->url(),

                        Forms\Components\FileUpload::make('promotional_video')
                            ->label('Vidéo promotionnelle')
                            ->acceptedFileTypes(['video/mp4', 'video/webm'])
                            ->disk('public')
                            ->directory('events/videos')
                            ->visibility('public'),
                    ])->columns(2),

                Forms\Components\Section::make('Date et heure')
                    ->schema([
                        Forms\Components\DatePicker::make('start_date')
                            ->label('Date de début')
                            ->required()
                            ->native(false),
                            
                        Forms\Components\DatePicker::make('end_date')
                            ->label('Date de fin')
                            ->native(false),
                            
                        Forms\Components\TimePicker::make('start_time')
                            ->label('Heure de début')
                            ->seconds(false),
                            
                        Forms\Components\TimePicker::make('end_time')
                            ->label('Heure de fin')
                            ->seconds(false),

                        Forms\Components\Select::make('timezone')
                            ->label('Fuseau horaire')
                            ->options([
                                'UTC' => 'UTC',
                                'Africa/Abidjan' => 'Afrique/Abidjan (GMT)',
                                'Africa/Dakar' => 'Afrique/Dakar (GMT)',
                                'Europe/Paris' => 'Europe/Paris (CET)',
                            ])
                            ->default('UTC'),

                        Forms\Components\Toggle::make('is_all_day')
                            ->label('Événement toute la journée'),
                    ])->columns(3),

                Forms\Components\Section::make('Localisation')
                    ->schema([
                        Forms\Components\TextInput::make('location')
                            ->label('Lieu'),
                            
                        Forms\Components\Textarea::make('address')
                            ->label('Adresse complète')
                            ->rows(2),

                        Forms\Components\TextInput::make('city')
                            ->label('Ville'),

                        Forms\Components\TextInput::make('country')
                            ->label('Pays')
                            ->default('Côte d\'Ivoire'),

                        Forms\Components\TextInput::make('postal_code')
                            ->label('Code postal'),
                            
                        Forms\Components\TextInput::make('latitude')
                            ->label('Latitude')
                            ->numeric()
                            ->step(0.000001),
                            
                        Forms\Components\TextInput::make('longitude')
                            ->label('Longitude')
                            ->numeric()
                            ->step(0.000001),

                        Forms\Components\Toggle::make('is_online')
                            ->label('Événement en ligne')
                            ->live(),

                        Forms\Components\TextInput::make('online_meeting_url')
                            ->label('URL de réunion')
                            ->url()
                            ->visible(fn (Forms\Get $get) => $get('is_online')),

                        Forms\Components\Textarea::make('directions')
                            ->label('Indications pour s\'y rendre')
                            ->rows(2),

                        Forms\Components\TextInput::make('parking_info')
                            ->label('Informations parking'),

                        Forms\Components\TextInput::make('public_transport_info')
                            ->label('Transports en commun'),
                    ])->columns(3),

                Forms\Components\Section::make('Type et format')
                    ->schema([
                        Forms\Components\Select::make('event_type')
                            ->label('Type d\'événement')
                            ->options([
                                'conference' => 'Conférence',
                                'workshop' => 'Atelier',
                                'seminar' => 'Séminaire',
                                'cooking_class' => 'Cours de cuisine',
                                'tasting' => 'Dégustation',
                                'festival' => 'Festival',
                                'competition' => 'Concours',
                                'networking' => 'Réseautage',
                                'exhibition' => 'Exposition',
                                'party' => 'Fête',
                                'charity' => 'Charité',
                                'educational' => 'Éducatif',
                                'cultural' => 'Culturel',
                                'sports' => 'Sport',
                                'other' => 'Autre',
                            ])
                            ->default('other'),

                        Forms\Components\Select::make('event_format')
                            ->label('Format')
                            ->options([
                                'in_person' => 'En présentiel',
                                'online' => 'En ligne',
                                'hybrid' => 'Hybride',
                            ])
                            ->default('in_person'),

                        Forms\Components\Select::make('age_restriction')
                            ->label('Restriction d\'âge')
                            ->options([
                                'all_ages' => 'Tous âges',
                                '18_plus' => '18 ans et plus',
                                '21_plus' => '21 ans et plus',
                                'family_friendly' => 'Familial',
                                'adults_only' => 'Adultes seulement',
                            ])
                            ->default('all_ages'),
                    ])->columns(3),

                Forms\Components\Section::make('Inscription et participants')
                    ->schema([
                        Forms\Components\Toggle::make('requires_registration')
                            ->label('Inscription requise')
                            ->live(),

                        Forms\Components\Toggle::make('requires_approval')
                            ->label('Approbation requise')
                            ->visible(fn (Forms\Get $get) => $get('requires_registration')),

                        Forms\Components\TextInput::make('registration_url')
                            ->label('URL d\'inscription')
                            ->url()
                            ->visible(fn (Forms\Get $get) => $get('requires_registration')),

                        Forms\Components\DateTimePicker::make('registration_start')
                            ->label('Début des inscriptions')
                            ->visible(fn (Forms\Get $get) => $get('requires_registration')),

                        Forms\Components\DateTimePicker::make('registration_end')
                            ->label('Fin des inscriptions')
                            ->visible(fn (Forms\Get $get) => $get('requires_registration')),
                            
                        Forms\Components\TextInput::make('max_participants')
                            ->label('Nombre maximum de participants')
                            ->numeric(),

                        Forms\Components\TextInput::make('min_participants')
                            ->label('Nombre minimum de participants')
                            ->numeric(),
                            
                        Forms\Components\TextInput::make('current_participants')
                            ->label('Participants actuels')
                            ->numeric()
                            ->default(0),
                    ])->columns(3),

                Forms\Components\Section::make('Tarification')
                    ->schema([
                        Forms\Components\Toggle::make('is_free')
                            ->label('Événement gratuit')
                            ->default(true)
                            ->live(),

                        Forms\Components\TextInput::make('price')
                            ->label('Prix')
                            ->numeric()
                            ->prefix('XOF')
                            ->visible(fn (Forms\Get $get) => !$get('is_free')),

                        Forms\Components\TextInput::make('early_bird_price')
                            ->label('Tarif early bird')
                            ->numeric()
                            ->prefix('XOF')
                            ->visible(fn (Forms\Get $get) => !$get('is_free')),

                        Forms\Components\DateTimePicker::make('early_bird_deadline')
                            ->label('Fin du tarif early bird')
                            ->visible(fn (Forms\Get $get) => !$get('is_free')),

                        Forms\Components\TextInput::make('student_price')
                            ->label('Tarif étudiant')
                            ->numeric()
                            ->prefix('XOF')
                            ->visible(fn (Forms\Get $get) => !$get('is_free')),

                        Forms\Components\TextInput::make('group_price')
                            ->label('Tarif groupe')
                            ->numeric()
                            ->prefix('XOF')
                            ->visible(fn (Forms\Get $get) => !$get('is_free')),

                        Forms\Components\TextInput::make('group_min_size')
                            ->label('Taille minimum du groupe')
                            ->numeric()
                            ->visible(fn (Forms\Get $get) => !$get('is_free')),

                        Forms\Components\Textarea::make('pricing_notes')
                            ->label('Notes sur la tarification')
                            ->rows(2)
                            ->visible(fn (Forms\Get $get) => !$get('is_free')),
                    ])->columns(3),

                Forms\Components\Section::make('Informations pratiques')
                    ->schema([
                        Forms\Components\Select::make('dress_code')
                            ->label('Code vestimentaire')
                            ->options([
                                'casual' => 'Décontracté',
                                'business' => 'Professionnel',
                                'formal' => 'Formel',
                                'costume' => 'Costume',
                                'uniform' => 'Uniforme',
                            ]),

                        Forms\Components\Textarea::make('what_to_bring')
                            ->label('Que apporter')
                            ->rows(2),

                        Forms\Components\Textarea::make('what_is_provided')
                            ->label('Ce qui est fourni')
                            ->rows(2),

                        Forms\Components\Toggle::make('wheelchair_accessible')
                            ->label('Accessible aux fauteuils roulants'),

                        Forms\Components\Textarea::make('accessibility_info')
                            ->label('Informations d\'accessibilité')
                            ->rows(2),

                        Forms\Components\Textarea::make('food_provided')
                            ->label('Restauration fournie')
                            ->rows(2),
                    ])->columns(2),

                Forms\Components\Section::make('Contact et organisation')
                    ->schema([
                        Forms\Components\TextInput::make('organizer_name')
                            ->label('Nom de l\'organisateur'),

                        Forms\Components\TextInput::make('organizer_email')
                            ->label('Email de l\'organisateur')
                            ->email(),

                        Forms\Components\TextInput::make('organizer_phone')
                            ->label('Téléphone de l\'organisateur'),

                        Forms\Components\TextInput::make('organizer_website')
                            ->label('Site web de l\'organisateur')
                            ->url(),
                    ])->columns(2),

                Forms\Components\Section::make('Paramètres')
                    ->schema([
                        Forms\Components\Select::make('status')
                            ->label('Statut')
                            ->options([
                                'draft' => 'Brouillon',
                                'active' => 'Actif',
                                'cancelled' => 'Annulé',
                                'postponed' => 'Reporté',
                                'completed' => 'Terminé',
                            ])
                            ->default('draft'),

                        Forms\Components\TagsInput::make('tags')
                            ->label('Tags')
                            ->placeholder('Ajoutez des tags...'),
                            
                        Forms\Components\Toggle::make('is_featured')
                            ->label('Événement vedette'),
                            
                        Forms\Components\Toggle::make('is_published')
                            ->label('Publié')
                            ->default(false),

                        Forms\Components\Toggle::make('weather_dependent')
                            ->label('Dépendant de la météo'),

                        Forms\Components\Toggle::make('allow_reviews')
                            ->label('Autoriser les avis')
                            ->default(true),
                    ])->columns(3),
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
                    
                Tables\Columns\TextColumn::make('category.name')
                    ->label('Catégorie')
                    ->badge()
                    ->sortable(),

                Tables\Columns\TextColumn::make('event_type')
                    ->label('Type')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'cooking_class' => 'success',
                        'tasting' => 'warning',
                        'conference' => 'info',
                        'workshop' => 'primary',
                        default => 'gray',
                    }),
                    
                Tables\Columns\TextColumn::make('start_date')
                    ->label('Date')
                    ->date()
                    ->sortable(),

                Tables\Columns\TextColumn::make('city')
                    ->label('Ville')
                    ->searchable(),
                    
                Tables\Columns\TextColumn::make('status')
                    ->label('Statut')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'active' => 'success',
                        'draft' => 'gray',
                        'cancelled' => 'danger',
                        'postponed' => 'warning',
                        'completed' => 'info',
                    }),

                Tables\Columns\TextColumn::make('current_participants')
                    ->label('Participants')
                    ->numeric()
                    ->sortable(),
                    
                Tables\Columns\IconColumn::make('is_featured')
                    ->label('Vedette')
                    ->boolean(),
                    
                Tables\Columns\IconColumn::make('is_published')
                    ->label('Publié')
                    ->boolean(),
                    
                Tables\Columns\TextColumn::make('created_at')
                    ->label('Créé le')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('category')
                    ->relationship('category', 'name'),
                Tables\Filters\SelectFilter::make('event_type'),
                Tables\Filters\SelectFilter::make('status'),
                Tables\Filters\Filter::make('upcoming')
                    ->query(fn (Builder $query): Builder => $query->upcoming()),
                Tables\Filters\Filter::make('is_featured')
                    ->query(fn (Builder $query): Builder => $query->where('is_featured', true)),
                Tables\Filters\TrashedFilter::make(),
            ])
            ->actions([
                Tables\Actions\ViewAction::make(),
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                    Tables\Actions\ForceDeleteBulkAction::make(),
                    Tables\Actions\RestoreBulkAction::make(),
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
            ]);
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
            'index' => Pages\ListEvents::route('/'),
            'create' => Pages\CreateEvent::route('/create'),
            'view' => Pages\ViewEvent::route('/{record}'),
            'edit' => Pages\EditEvent::route('/{record}/edit'),
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