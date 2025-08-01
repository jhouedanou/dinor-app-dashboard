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

                        Forms\Components\TextInput::make('url')
                            ->label('URL de destination')
                            ->url()
                            ->placeholder('https://example.com/page')
                            ->helperText('URL vers laquelle rediriger quand l\'utilisateur clique sur la notification'),

                        Forms\Components\FileUpload::make('icon')
                            ->label('Icône personnalisée')
                            ->image()
                            ->disk('public')
                            ->directory('notifications')
                            ->helperText('Optionnel - Une icône par défaut sera utilisée si non spécifiée'),
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
                            ->options([
                                'draft' => 'Brouillon',
                                'scheduled' => 'Planifiée',
                                'sent' => 'Envoyée',
                                'failed' => 'Échec',
                            ])
                            ->default('draft')
                            ->required()
                            ->live(),

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
                            Notification::make()
                                ->title('Notification envoyée avec succès !')
                                ->success()
                                ->send();
                        } else {
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
