<?php

namespace App\Filament\Resources;

use App\Filament\Resources\ProfessionalContentResource\Pages;
use App\Filament\Resources\ProfessionalContentResource\RelationManagers;
use App\Models\ProfessionalContent;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;
use Illuminate\Database\Eloquent\Collection;

class ProfessionalContentResource extends Resource
{
    protected static ?string $model = ProfessionalContent::class;

    protected static ?string $navigationIcon = 'heroicon-o-document-text';
    
    protected static ?string $navigationLabel = 'Contenus Professionnels';
    
    protected static ?string $modelLabel = 'Contenu Professionnel';
    
    protected static ?string $pluralModelLabel = 'Contenus Professionnels';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Select::make('user_id')
                    ->label('Utilisateur')
                    ->relationship('user', 'name')
                    ->searchable()
                    ->required(),
                
                Forms\Components\Select::make('content_type')
                    ->label('Type de contenu')
                    ->options(ProfessionalContent::CONTENT_TYPES)
                    ->required(),
                
                Forms\Components\TextInput::make('title')
                    ->label('Titre')
                    ->required()
                    ->maxLength(255),
                
                Forms\Components\Textarea::make('description')
                    ->label('Description')
                    ->required()
                    ->rows(3),
                
                Forms\Components\RichEditor::make('content')
                    ->label('Contenu')
                    ->required(),
                
                Forms\Components\FileUpload::make('images')
                    ->label('Images')
                    ->multiple()
                    ->image()
                    ->directory('professional-content'),
                
                Forms\Components\TextInput::make('video_url')
                    ->label('URL Vidéo')
                    ->url()
                    ->maxLength(255),
                
                Forms\Components\Select::make('difficulty')
                    ->label('Difficulté')
                    ->options(ProfessionalContent::DIFFICULTIES),
                
                Forms\Components\TextInput::make('category')
                    ->label('Catégorie')
                    ->maxLength(255),
                
                Forms\Components\TextInput::make('preparation_time')
                    ->label('Temps de préparation (min)')
                    ->numeric()
                    ->minValue(0),
                
                Forms\Components\TextInput::make('cooking_time')
                    ->label('Temps de cuisson (min)')
                    ->numeric()
                    ->minValue(0),
                
                Forms\Components\TextInput::make('servings')
                    ->label('Nombre de portions')
                    ->numeric()
                    ->minValue(1),
                
                Forms\Components\Repeater::make('ingredients')
                    ->label('Ingrédients')
                    ->schema([
                        Forms\Components\TextInput::make('name')
                            ->label('Nom')
                            ->required(),
                        Forms\Components\TextInput::make('quantity')
                            ->label('Quantité'),
                        Forms\Components\TextInput::make('unit')
                            ->label('Unité'),
                    ])
                    ->columns(3),
                
                Forms\Components\Repeater::make('steps')
                    ->label('Étapes')
                    ->schema([
                        Forms\Components\Textarea::make('instruction')
                            ->label('Instruction')
                            ->required(),
                    ]),
                
                Forms\Components\TagsInput::make('tags')
                    ->label('Tags'),
                
                Forms\Components\Select::make('status')
                    ->label('Statut')
                    ->options([
                        'pending' => 'En attente',
                        'approved' => 'Approuvé',
                        'rejected' => 'Rejeté',
                        'published' => 'Publié',
                    ])
                    ->default('pending')
                    ->required(),
                
                Forms\Components\Textarea::make('admin_notes')
                    ->label('Notes administrateur')
                    ->rows(2),
                
                Forms\Components\DateTimePicker::make('submitted_at')
                    ->label('Soumis le')
                    ->default(now()),
                
                Forms\Components\DateTimePicker::make('reviewed_at')
                    ->label('Révisé le'),
                
                Forms\Components\Select::make('reviewed_by')
                    ->label('Révisé par')
                    ->relationship('reviewer', 'name')
                    ->searchable(),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('user.name')
                    ->label('Utilisateur')
                    ->searchable()
                    ->sortable(),
                
                Tables\Columns\TextColumn::make('content_type')
                    ->label('Type')
                    ->badge()
                    ->formatStateUsing(fn ($state) => ProfessionalContent::CONTENT_TYPES[$state] ?? $state)
                    ->sortable(),
                
                Tables\Columns\TextColumn::make('title')
                    ->label('Titre')
                    ->searchable()
                    ->limit(50)
                    ->sortable(),
                
                Tables\Columns\TextColumn::make('status')
                    ->label('Statut')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'pending' => 'warning',
                        'approved' => 'success',
                        'rejected' => 'danger',
                        'published' => 'info',
                    })
                    ->formatStateUsing(fn ($state) => match($state) {
                        'pending' => 'En attente',
                        'approved' => 'Approuvé',
                        'rejected' => 'Rejeté',
                        'published' => 'Publié',
                        default => 'Inconnu',
                    })
                    ->sortable(),
                
                Tables\Columns\TextColumn::make('difficulty')
                    ->label('Difficulté')
                    ->badge()
                    ->formatStateUsing(fn ($state) => $state ? (ProfessionalContent::DIFFICULTIES[$state] ?? $state) : '-')
                    ->color(fn ($state): string => match ($state) {
                        'beginner' => 'success',
                        'easy' => 'info',
                        'medium' => 'warning',
                        'hard' => 'danger',
                        'expert' => 'gray',
                        default => 'gray',
                    }),
                
                Tables\Columns\TextColumn::make('submitted_at')
                    ->label('Soumis le')
                    ->dateTime()
                    ->sortable(),
                
                Tables\Columns\TextColumn::make('reviewed_at')
                    ->label('Révisé le')
                    ->dateTime()
                    ->placeholder('-')
                    ->sortable(),
                
                Tables\Columns\TextColumn::make('reviewer.name')
                    ->label('Révisé par')
                    ->placeholder('-')
                    ->sortable(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('content_type')
                    ->label('Type de contenu')
                    ->options(ProfessionalContent::CONTENT_TYPES),
                
                Tables\Filters\SelectFilter::make('status')
                    ->label('Statut')
                    ->options([
                        'pending' => 'En attente',
                        'approved' => 'Approuvé',
                        'rejected' => 'Rejeté',
                        'published' => 'Publié',
                    ]),
                
                Tables\Filters\SelectFilter::make('difficulty')
                    ->label('Difficulté')
                    ->options(ProfessionalContent::DIFFICULTIES),
                
                Tables\Filters\Filter::make('reviewed')
                    ->label('Révisé')
                    ->query(fn (Builder $query): Builder => $query->whereNotNull('reviewed_at')),
                
                Tables\Filters\Filter::make('not_reviewed')
                    ->label('Non révisé')
                    ->query(fn (Builder $query): Builder => $query->whereNull('reviewed_at')),
            ])
            ->actions([
                Tables\Actions\ViewAction::make(),
                Tables\Actions\EditAction::make(),
                Tables\Actions\Action::make('approve')
                    ->label('Approuver')
                    ->icon('heroicon-o-check')
                    ->color('success')
                    ->visible(fn (ProfessionalContent $record): bool => $record->status === 'pending')
                    ->action(function (ProfessionalContent $record) {
                        $record->update([
                            'status' => 'approved',
                            'reviewed_at' => now(),
                            'reviewed_by' => auth()->id(),
                        ]);
                    }),
                
                Tables\Actions\Action::make('reject')
                    ->label('Rejeter')
                    ->icon('heroicon-o-x-mark')
                    ->color('danger')
                    ->visible(fn (ProfessionalContent $record): bool => $record->status === 'pending')
                    ->form([
                        Forms\Components\Textarea::make('admin_notes')
                            ->label('Raison du rejet')
                            ->required(),
                    ])
                    ->action(function (ProfessionalContent $record, array $data) {
                        $record->update([
                            'status' => 'rejected',
                            'reviewed_at' => now(),
                            'reviewed_by' => auth()->id(),
                            'admin_notes' => $data['admin_notes'],
                        ]);
                    }),
                
                Tables\Actions\Action::make('publish')
                    ->label('Publier')
                    ->icon('heroicon-o-globe-alt')
                    ->color('info')
                    ->visible(fn (ProfessionalContent $record): bool => $record->status === 'approved')
                    ->action(function (ProfessionalContent $record) {
                        $record->update([
                            'status' => 'published',
                        ]);
                    }),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                    Tables\Actions\BulkAction::make('approve_selected')
                        ->label('Approuver sélectionnés')
                        ->icon('heroicon-o-check')
                        ->color('success')
                        ->action(function (Collection $records) {
                            $records->each(function (ProfessionalContent $record) {
                                if ($record->status === 'pending') {
                                    $record->update([
                                        'status' => 'approved',
                                        'reviewed_at' => now(),
                                        'reviewed_by' => auth()->id(),
                                    ]);
                                }
                            });
                        }),
                ]),
            ])
            ->defaultSort('submitted_at', 'desc');
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
            'index' => Pages\ListProfessionalContents::route('/'),
            'create' => Pages\CreateProfessionalContent::route('/create'),
            'edit' => Pages\EditProfessionalContent::route('/{record}/edit'),
        ];
    }
}
