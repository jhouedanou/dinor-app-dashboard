<?php

namespace App\Filament\Resources;

use App\Filament\Resources\PwaMenuItemResource\Pages;
use App\Models\PwaMenuItem;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class PwaMenuItemResource extends Resource
{
    protected static ?string $model = PwaMenuItem::class;
    protected static ?string $navigationIcon = 'heroicon-o-bars-3-bottom-left';
    protected static ?string $navigationLabel = 'Menu PWA';
    protected static ?string $modelLabel = 'Élément de menu';
    protected static ?string $pluralModelLabel = 'Éléments de menu';
    protected static ?string $navigationGroup = 'Configuration PWA';
    protected static ?int $navigationSort = 10;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Configuration de l\'élément de menu')
                    ->description('Configurez l\'apparence et le comportement de cet élément dans le menu de navigation PWA')
                    ->schema([
                        Forms\Components\TextInput::make('label')
                            ->label('Libellé')
                            ->required()
                            ->maxLength(255)
                            ->helperText('Texte affiché sous l\'icône dans le menu'),

                        Forms\Components\Select::make('icon')
                            ->label('Icône')
                            ->required()
                            ->options([
                                // Navigation & Actions
                                'home' => '🏠 home - Accueil',
                                'menu' => '☰ menu - Menu',
                                'arrow_back' => '← arrow_back - Retour',
                                'arrow_forward' => '→ arrow_forward - Suivant',
                                'search' => '🔍 search - Recherche',
                                'refresh' => '🔄 refresh - Actualiser',
                                'close' => '✕ close - Fermer',
                                'add' => '+ add - Ajouter',
                                'remove' => '- remove - Supprimer',
                                'edit' => '✏️ edit - Modifier',
                                'delete' => '🗑️ delete - Supprimer',
                                'save' => '💾 save - Sauvegarder',
                                
                                // Contenu & Médias
                                'article' => '📄 article - Article',
                                'description' => '📝 description - Description',
                                'book' => '📚 book - Livre',
                                'library_books' => '📚 library_books - Bibliothèque',
                                'image' => '🖼️ image - Image',
                                'photo' => '📷 photo - Photo',
                                'video_library' => '🎬 video_library - Vidéothèque',
                                'play_circle' => '▶️ play_circle - Lecture',
                                'play_arrow' => '▶️ play_arrow - Play',
                                'pause' => '⏸️ pause - Pause',
                                'stop' => '⏹️ stop - Stop',
                                
                                // Nourriture & Cuisine
                                'restaurant' => '🍽️ restaurant - Restaurant',
                                'restaurant_menu' => '📋 restaurant_menu - Menu restaurant',
                                'local_dining' => '🍴 local_dining - Repas',
                                'cake' => '🍰 cake - Gâteau',
                                'coffee' => '☕ coffee - Café',
                                'local_bar' => '🍹 local_bar - Bar',
                                'kitchen' => '👨‍🍳 kitchen - Cuisine',
                                'room_service' => '🛎️ room_service - Service',
                                
                                // Astuces & Conseils
                                'lightbulb' => '💡 lightbulb - Ampoule',
                                'tips_and_updates' => '💡 tips_and_updates - Conseils',
                                'help' => '❓ help - Aide',
                                'info' => 'ℹ️ info - Information',
                                'quiz' => '❓ quiz - Quiz',
                                'psychology' => '🧠 psychology - Psychologie',
                                
                                // Événements & Calendrier
                                'event' => '📅 event - Événement',
                                'calendar_today' => '📅 calendar_today - Calendrier',
                                'schedule' => '🕐 schedule - Horaire',
                                'access_time' => '⏰ access_time - Heure',
                                'today' => '📅 today - Aujourd\'hui',
                                'date_range' => '📅 date_range - Période',
                                'celebration' => '🎉 celebration - Célébration',
                                'party_mode' => '🎉 party_mode - Fête',
                                
                                // Communication & Social
                                'chat' => '💬 chat - Chat',
                                'message' => '💬 message - Message',
                                'email' => '✉️ email - Email',
                                'phone' => '📞 phone - Téléphone',
                                'contact_mail' => '📧 contact_mail - Contact',
                                'forum' => '💬 forum - Forum',
                                'comment' => '💬 comment - Commentaire',
                                
                                // Utilisateurs & Profils
                                'person' => '👤 person - Personne',
                                'people' => '👥 people - Personnes',
                                'account_circle' => '👤 account_circle - Compte',
                                'face' => '😊 face - Visage',
                                'group' => '👥 group - Groupe',
                                'family_restroom' => '👪 family_restroom - Famille',
                                
                                // Shopping & Commerce
                                'shopping_cart' => '🛒 shopping_cart - Panier',
                                'shopping_bag' => '🛍️ shopping_bag - Sac shopping',
                                'store' => '🏪 store - Magasin',
                                'local_grocery_store' => '🏪 local_grocery_store - Épicerie',
                                'payment' => '💳 payment - Paiement',
                                'local_offer' => '🏷️ local_offer - Offre',
                                
                                // Loisirs & Divertissement
                                'sports_esports' => '🎮 sports_esports - Jeux',
                                'music_note' => '🎵 music_note - Musique',
                                'radio' => '📻 radio - Radio',
                                'theater_comedy' => '🎭 theater_comedy - Théâtre',
                                'movie' => '🎬 movie - Film',
                                'camera' => '📸 camera - Caméra',
                                
                                // Localisation & Voyage
                                'location_on' => '📍 location_on - Localisation',
                                'map' => '🗺️ map - Carte',
                                'directions' => '🧭 directions - Directions',
                                'place' => '📍 place - Lieu',
                                'travel_explore' => '🧳 travel_explore - Voyage',
                                'flight' => '✈️ flight - Vol',
                                'train' => '🚆 train - Train',
                                'directions_car' => '🚗 directions_car - Voiture',
                                
                                // Favoris & Évaluations
                                'favorite' => '❤️ favorite - Favori',
                                'heart_broken' => '💔 heart_broken - Cœur brisé',
                                'star' => '⭐ star - Étoile',
                                'star_rate' => '⭐ star_rate - Notation',
                                'thumb_up' => '👍 thumb_up - Pouce levé',
                                'thumb_down' => '👎 thumb_down - Pouce baissé',
                                
                                // Paramètres & Configuration
                                'settings' => '⚙️ settings - Paramètres',
                                'tune' => '🎛️ tune - Réglages',
                                'build' => '🔧 build - Construction',
                                'engineering' => '🔧 engineering - Ingénierie',
                                'admin_panel_settings' => '🔧 admin_panel_settings - Admin',
                                
                                // Sécurité & Confidentialité
                                'lock' => '🔒 lock - Verrouillé',
                                'lock_open' => '🔓 lock_open - Déverrouillé',
                                'security' => '🔒 security - Sécurité',
                                'visibility' => '👁️ visibility - Visible',
                                'visibility_off' => '👁️‍🗨️ visibility_off - Masqué',
                                
                                // Statuts & Notifications
                                'notifications' => '🔔 notifications - Notifications',
                                'notifications_off' => '🔕 notifications_off - Notifications off',
                                'check' => '✅ check - Validé',
                                'check_circle' => '✅ check_circle - Cercle validé',
                                'cancel' => '❌ cancel - Annuler',
                                'error' => '❌ error - Erreur',
                                'warning' => '⚠️ warning - Attention',
                                
                                // Tendances & Statistiques
                                'trending_up' => '📈 trending_up - Tendance hausse',
                                'trending_down' => '📉 trending_down - Tendance baisse',
                                'analytics' => '📊 analytics - Analytiques',
                                'bar_chart' => '📊 bar_chart - Graphique',
                                'pie_chart' => '📊 pie_chart - Camembert',
                                'show_chart' => '📈 show_chart - Graphique ligne',
                                
                                // Météo & Nature
                                'wb_sunny' => '☀️ wb_sunny - Soleil',
                                'cloud' => '☁️ cloud - Nuage',
                                'beach_access' => '🏖️ beach_access - Plage',
                                'nature' => '🌿 nature - Nature',
                                'local_florist' => '🌸 local_florist - Fleuriste',
                                
                                // Outils & Utilitaires
                                'build_circle' => '🔧 build_circle - Outil',
                                'handyman' => '🔨 handyman - Bricoleur',
                                'construction' => '🚧 construction - Construction',
                                'electrical_services' => '⚡ electrical_services - Électricité',
                            ])
                            ->searchable()
                            ->helperText('Icône Material Design affichée dans le menu de navigation')
                            ->placeholder('Recherchez une icône...'),

                        Forms\Components\Select::make('route')
                            ->label('Route/Section')
                            ->required()
                            ->options([
                                'home' => 'Accueil',
                                'recipes' => 'Recettes',
                                'tips' => 'Astuces',
                                'dinor-tv' => 'Dinor TV',
                                'events' => 'Événements',
                                'pages' => 'Pages personnalisées',
                            ])
                            ->helperText('Section de l\'application à afficher'),

                        Forms\Components\ColorPicker::make('color')
                            ->label('Couleur de l\'icône')
                            ->default('#E1251B')
                            ->helperText('Couleur de l\'icône dans le menu'),

                        Forms\Components\TextInput::make('order')
                            ->label('Ordre d\'affichage')
                            ->numeric()
                            ->default(0)
                            ->helperText('Position dans le menu (1 = premier)'),

                        Forms\Components\Toggle::make('is_active')
                            ->label('Élément actif')
                            ->default(true)
                            ->helperText('L\'élément apparaît dans le menu'),
                    ])->columns(2),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('order')
                    ->label('#')
                    ->sortable()
                    ->alignCenter()
                    ->badge()
                    ->color('primary'),

                Tables\Columns\TextColumn::make('label')
                    ->label('Libellé')
                    ->searchable()
                    ->sortable()
                    ->weight('bold'),

                Tables\Columns\TextColumn::make('icon')
                    ->label('Icône')
                    ->badge()
                    ->color('gray'),

                Tables\Columns\TextColumn::make('route')
                    ->label('Section')
                    ->badge()
                    ->color('success'),

                Tables\Columns\ColorColumn::make('color')
                    ->label('Couleur')
                    ->copyable(),

                Tables\Columns\IconColumn::make('is_active')
                    ->label('Actif')
                    ->boolean()
                    ->trueIcon('heroicon-o-check-circle')
                    ->falseIcon('heroicon-o-x-circle')
                    ->trueColor('success')
                    ->falseColor('danger'),
            ])
            ->filters([
                Tables\Filters\TernaryFilter::make('is_active')
                    ->label('Statut')
                    ->boolean()
                    ->trueLabel('Actifs seulement')
                    ->falseLabel('Inactifs seulement')
                    ->native(false),
            ])
            ->actions([
                Tables\Actions\EditAction::make()
                    ->label('Modifier')
                    ->icon('heroicon-o-pencil-square'),
                    
                Tables\Actions\DeleteAction::make()
                    ->label('Supprimer')
                    ->icon('heroicon-o-trash')
                    ->successNotificationTitle('Élément supprimé avec succès'),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make()
                        ->label('Supprimer sélectionnés')
                        ->successNotificationTitle('Éléments supprimés avec succès'),

                    Tables\Actions\BulkAction::make('activate')
                        ->label('Activer')
                        ->icon('heroicon-o-check-circle')
                        ->color('success')
                        ->action(fn ($records) => $records->each->update(['is_active' => true]))
                        ->deselectRecordsAfterCompletion()
                        ->successNotificationTitle('Éléments activés'),

                    Tables\Actions\BulkAction::make('deactivate')
                        ->label('Désactiver')
                        ->icon('heroicon-o-x-circle')
                        ->color('warning')
                        ->action(fn ($records) => $records->each->update(['is_active' => false]))
                        ->deselectRecordsAfterCompletion()
                        ->successNotificationTitle('Éléments désactivés'),
                ]),
            ])
            ->defaultSort('order', 'asc')
            ->reorderable('order')
            ->emptyStateHeading('Aucun élément de menu configuré')
            ->emptyStateDescription('Configurez les éléments du menu de navigation PWA.')
            ->emptyStateIcon('heroicon-o-bars-3-bottom-left');
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
            'index' => Pages\ListPwaMenuItems::route('/'),
            'create' => Pages\CreatePwaMenuItem::route('/create'),
            'edit' => Pages\EditPwaMenuItem::route('/{record}/edit'),
        ];
    }
    
    public static function getNavigationBadge(): ?string
    {
        return static::getModel()::active()->count();
    }
} 