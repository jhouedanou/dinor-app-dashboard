<?php

namespace App\Filament\Resources;

use App\Filament\Resources\PushNotificationResource\Pages;
use App\Models\PushNotification;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Facades\Auth;
use App\Services\OneSignalService;
use Filament\Notifications\Notification;

class PushNotificationResource extends Resource
{
    protected static ?string $model = PushNotification::class;
    protected static ?string $navigationIcon = 'heroicon-o-bell';
    protected static ?string $navigationLabel = 'Notifications Push';
    protected static ?string $navigationGroup = 'Communication';
    protected static ?int $navigationSort = 1;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Contenu de la notification')
                    ->schema([
                        Forms\Components\TextInput::make('title')
                            ->label('Titre')
                            ->required()
                            ->maxLength(255),

                        Forms\Components\Textarea::make('message')
                            ->label('Message')
                            ->required()
                            ->rows(3)
                            ->maxLength(1000),

                        Forms\Components\Select::make('content_type')
                            ->label('Type de contenu')
                            ->options([
                                '' => 'Aucun lien',
                                'recipe' => '🍽️ Recette',
                                'tip' => '💡 Astuce',
                                'event' => '📅 Événement',
                                'dinor_tv' => '📺 Dinor TV',
                                'page' => '📄 Page',
                                'custom' => '🔗 Lien personnalisé',
                            ])
                            ->live()
                            ->helperText('Choisissez le type de contenu vers lequel rediriger'),

                        Forms\Components\Select::make('content_id')
                            ->label('Contenu spécifique')
                            ->options(function (Forms\Get $get) {
                                $contentType = $get('content_type');
                                
                                return match($contentType) {
                                    'recipe' => \App\Models\Recipe::pluck('title', 'id')->toArray(),
                                    'tip' => \App\Models\Tip::pluck('title', 'id')->toArray(),
                                    'event' => \App\Models\Event::pluck('title', 'id')->toArray(),
                                    'dinor_tv' => \App\Models\DinorTv::pluck('title', 'id')->toArray(),
                                    'page' => \App\Models\Page::pluck('title', 'id')->toArray(),
                                    default => [],
                                };
                            })
                            ->visible(fn (Forms\Get $get) => in_array($get('content_type'), ['recipe', 'tip', 'event', 'dinor_tv', 'page']))
                            ->searchable()
                            ->required(fn (Forms\Get $get) => in_array($get('content_type'), ['recipe', 'tip', 'event', 'dinor_tv', 'page']))
                            ->helperText('Sélectionnez le contenu spécifique à afficher'),

                        Forms\Components\TextInput::make('url')
                            ->label('URL personnalisée')
                            ->url()
                            ->visible(fn (Forms\Get $get) => $get('content_type') === 'custom')
                            ->required(fn (Forms\Get $get) => $get('content_type') === 'custom')
                            ->placeholder('https://example.com/page')
                            ->helperText('URL web personnalisée'),

                        Forms\Components\FileUpload::make('icon')
                            ->label('Icône personnalisée')
                            ->image()
                            ->disk('public')
                            ->directory('notifications')
                            ->maxSize(2048)
                            ->acceptedFileTypes(['image/jpeg', 'image/png', 'image/gif', 'image/webp'])
                            ->rules([new \App\Rules\SafeFile()])
                            ->helperText('Optionnel - Une icône par défaut sera utilisée si non spécifiée (max 2MB)'),
                    ])->columns(2),

                Forms\Components\Section::make('Ciblage')
                    ->schema([
                        Forms\Components\Select::make('target_audience')
                            ->label('Audience cible')
                            ->options([
                                'all' => 'Tous les utilisateurs',
                                'segments' => 'Segments spécifiques',
                                'specific_users' => 'Utilisateurs spécifiques',
                            ])
                            ->default('all')
                            ->required()
                            ->live(),

                        Forms\Components\TagsInput::make('target_data')
                            ->label('IDs utilisateurs/segments')
                            ->visible(fn (Forms\Get $get) => in_array($get('target_audience'), ['segments', 'specific_users']))
                            ->helperText('Entrez les IDs des utilisateurs ou segments à cibler'),
                    ]),

                Forms\Components\Section::make('Planification')
                    ->schema([
                        Forms\Components\Select::make('status')
                            ->label('Statut')
                            ->options(function ($livewire) {
                                $isCreating = $livewire instanceof \App\Filament\Resources\PushNotificationResource\Pages\CreatePushNotification;
                                
                                $options = [
                                    'draft' => 'Brouillon',
                                    'scheduled' => 'Planifiée',
                                ];
                                
                                if ($isCreating) {
                                    $options['send_now'] = '🚀 Envoyer maintenant';
                                }
                                
                                $options['sent'] = 'Envoyée';
                                $options['failed'] = 'Échec';
                                
                                return $options;
                            })
                            ->default('draft')
                            ->required()
                            ->live()
                            ->helperText('Choisissez "Envoyer maintenant" pour envoyer la notification dès la création'),

                        Forms\Components\DateTimePicker::make('scheduled_at')
                            ->label('Date d\'envoi planifiée')
                            ->visible(fn (Forms\Get $get) => $get('status') === 'scheduled')
                            ->required(fn (Forms\Get $get) => $get('status') === 'scheduled'),
                    ])->columns(2),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('title')
                    ->label('Titre')
                    ->searchable()
                    ->sortable(),

                Tables\Columns\TextColumn::make('message')
                    ->label('Message')
                    ->limit(50)
                    ->tooltip(function (Tables\Columns\TextColumn $column): ?string {
                        $state = $column->getState();
                        return strlen($state) > 50 ? $state : null;
                    }),

                Tables\Columns\TextColumn::make('content_link')
                    ->label('Lien de contenu')
                    ->getStateUsing(function ($record) {
                        if ($record->content_type && $record->content_id) {
                            $contentName = $record->getContentName();
                            $typeEmoji = match($record->content_type) {
                                'recipe' => '🍽️',
                                'tip' => '💡',
                                'event' => '📅',
                                'dinor_tv' => '📺',
                                'page' => '📄',
                                default => '🔗',
                            };
                            return $typeEmoji . ' ' . ($contentName ?? "ID: {$record->content_id}");
                        }
                        
                        if ($record->url) {
                            return '🌐 ' . \Illuminate\Support\Str::limit($record->url, 30);
                        }
                        
                        return 'Aucun lien';
                    })
                    ->tooltip(function ($record) {
                        if ($record->content_type && $record->content_id) {
                            return "Type: {$record->content_type}, ID: {$record->content_id}";
                        }
                        return $record->url;
                    }),

                Tables\Columns\BadgeColumn::make('status')
                    ->label('Statut')
                    ->colors([
                        'secondary' => 'draft',
                        'warning' => 'scheduled',
                        'success' => 'sent',
                        'danger' => 'failed',
                    ])
                    ->icons([
                        'heroicon-m-pencil' => 'draft',
                        'heroicon-m-clock' => 'scheduled',
                        'heroicon-m-check-circle' => 'sent',
                        'heroicon-m-x-circle' => 'failed',
                    ]),

                Tables\Columns\TextColumn::make('target_audience')
                    ->label('Audience')
                    ->formatStateUsing(fn (string $state) => match($state) {
                        'all' => 'Tous',
                        'segments' => 'Segments',
                        'specific_users' => 'Utilisateurs spécifiques',
                        default => $state,
                    }),

                Tables\Columns\TextColumn::make('scheduled_at')
                    ->label('Planifié pour')
                    ->dateTime()
                    ->sortable(),

                Tables\Columns\TextColumn::make('sent_at')
                    ->label('Envoyé le')
                    ->dateTime()
                    ->sortable(),

                Tables\Columns\TextColumn::make('creator.name')
                    ->label('Créé par'),

                Tables\Columns\TextColumn::make('created_at')
                    ->label('Créé le')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->label('Statut')
                    ->options([
                        'draft' => 'Brouillon',
                        'scheduled' => 'Planifiée',
                        'sent' => 'Envoyée',
                        'failed' => 'Échec',
                    ]),

                Tables\Filters\SelectFilter::make('target_audience')
                    ->label('Audience')
                    ->options([
                        'all' => 'Tous les utilisateurs',
                        'segments' => 'Segments',
                        'specific_users' => 'Utilisateurs spécifiques',
                    ]),
            ])
            ->actions([
                Tables\Actions\Action::make('send')
                    ->label('Envoyer')
                    ->icon('heroicon-o-paper-airplane')
                    ->color('success')
                    ->visible(fn (PushNotification $record) => $record->status === 'draft')
                    ->requiresConfirmation()
                    ->modalHeading('Envoyer la notification')
                    ->modalDescription('Êtes-vous sûr de vouloir envoyer cette notification ? Cette action est irréversible.')
                    ->action(function (PushNotification $record) {
                        $oneSignalService = new OneSignalService();
                        $result = $oneSignalService->sendNotification($record);
                        
                        if ($result['success']) {
                            // Mettre à jour le statut de la notification
                            $record->update([
                                'status' => 'sent',
                                'sent_at' => now(),
                                'onesignal_id' => $result['onesignal_id'] ?? null,
                                'recipients_count' => $result['recipients'] ?? 0,
                            ]);
                            
                            Notification::make()
                                ->title('Notification envoyée avec succès !')
                                ->body('OneSignal ID: ' . ($result['onesignal_id'] ?? 'N/A'))
                                ->success()
                                ->send();
                        } else {
                            // Mettre à jour le statut d'erreur
                            $record->update([
                                'status' => 'failed',
                                'error_message' => $result['error'],
                            ]);
                            
                            Notification::make()
                                ->title('Erreur lors de l\'envoi')
                                ->body($result['error'])
                                ->danger()
                                ->send();
                        }
                    }),

                Tables\Actions\Action::make('test_connection')
                    ->label('Tester OneSignal')
                    ->icon('heroicon-o-signal')
                    ->color('info')
                    ->action(function () {
                        $oneSignalService = new OneSignalService();
                        $result = $oneSignalService->testConnection();
                        
                        if ($result['success']) {
                            Notification::make()
                                ->title('Connexion OneSignal réussie !')
                                ->success()
                                ->send();
                        } else {
                            Notification::make()
                                ->title('Erreur de connexion OneSignal')
                                ->body($result['error'])
                                ->danger()
                                ->send();
                        }
                    })->visible(fn () => Auth::guard('admin')->check() && Auth::guard('admin')->user()->email === 'admin@dinor.app'),

                Tables\Actions\Action::make('send_test_now')
                    ->label('Envoi Test Rapide')
                    ->icon('heroicon-o-paper-airplane')
                    ->color('warning')
                    ->action(function () {
                        // Créer une notification de test
                        $notification = PushNotification::create([
                            'title' => 'Test Rapide Admin',
                            'message' => 'Notification de test depuis l\'admin - ' . now()->format('H:i:s'),
                            'status' => 'draft',
                            'created_by' => Auth::guard('admin')->id(),
                        ]);
                        
                        // L'envoyer immédiatement
                        $oneSignalService = new OneSignalService();
                        $result = $oneSignalService->sendNotification($notification);
                        
                        if ($result['success']) {
                            $notification->update([
                                'status' => 'sent',
                                'sent_at' => now(),
                                'onesignal_id' => $result['onesignal_id'] ?? null,
                                'recipients_count' => $result['recipients'] ?? 0,
                            ]);
                            
                            Notification::make()
                                ->title('Test envoyé avec succès !')
                                ->body('OneSignal ID: ' . ($result['onesignal_id'] ?? 'N/A'))
                                ->success()
                                ->send();
                        } else {
                            $notification->update([
                                'status' => 'failed',
                                'error_message' => $result['error'],
                            ]);
                            
                            Notification::make()
                                ->title('Erreur lors du test')
                                ->body($result['error'])
                                ->danger()
                                ->send();
                        }
                    })->visible(fn () => Auth::guard('admin')->check() && Auth::guard('admin')->user()->email === 'admin@dinor.app'),

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

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListPushNotifications::route('/'),
            'create' => Pages\CreatePushNotification::route('/create'),
            'edit' => Pages\EditPushNotification::route('/{record}/edit'),
        ];
    }

    public static function getNavigationBadge(): ?string
    {
        return static::getModel()::where('status', 'draft')->count();
    }
}
