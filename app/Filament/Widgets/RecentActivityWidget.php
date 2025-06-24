<?php

namespace App\Filament\Widgets;

use App\Models\Like;
use App\Models\Comment;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Widgets\TableWidget as BaseWidget;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Collection;

class RecentActivityWidget extends BaseWidget
{
    protected static ?string $heading = 'Activité Récente (Likes & Commentaires)';

    protected static ?int $sort = 5;

    protected int | string | array $columnSpan = 'full';

    public function table(Table $table): Table
    {
        return $table
            ->query($this->getTableQuery())
            ->columns([
                Tables\Columns\TextColumn::make('type')
                    ->label('Type')
                    ->badge()
                    ->color(fn (string $state): string => match($state) {
                        'Like' => 'success',
                        'Commentaire' => 'primary',
                        default => 'gray'
                    }),

                Tables\Columns\TextColumn::make('content_type')
                    ->label('Contenu')
                    ->formatStateUsing(fn (string $state): string => match($state) {
                        'App\Models\Recipe' => 'Recette',
                        'App\Models\Event' => 'Événement',
                        'App\Models\Tip' => 'Astuce',
                        'App\Models\DinorTv' => 'Vidéo',
                        default => $state
                    })
                    ->badge()
                    ->color(fn (string $state): string => match($state) {
                        'App\Models\Recipe' => 'success',
                        'App\Models\Event' => 'warning',
                        'App\Models\Tip' => 'primary',
                        'App\Models\DinorTv' => 'info',
                        default => 'gray'
                    }),

                Tables\Columns\TextColumn::make('user')
                    ->label('Utilisateur')
                    ->formatStateUsing(function ($record) {
                        if ($record->type === 'Like') {
                            return $record->user_id ? 'Utilisateur connecté' : 'Anonyme (' . substr($record->ip_address, 0, 10) . ')';
                        } else {
                            return $record->author_name ?: ($record->user_id ? 'Utilisateur connecté' : 'Anonyme');
                        }
                    }),

                Tables\Columns\TextColumn::make('content')
                    ->label('Détails')
                    ->limit(50)
                    ->formatStateUsing(function ($record) {
                        if ($record->type === 'Like') {
                            return '❤️ A aimé ce contenu';
                        } else {
                            return $record->content;
                        }
                    }),

                Tables\Columns\TextColumn::make('created_at')
                    ->label('Date')
                    ->dateTime('d/m/Y H:i')
                    ->sortable(),
            ])
            ->defaultSort('created_at', 'desc')
            ->paginated([10, 25, 50]);
    }

    protected function getTableQuery(): Builder
    {
        // Créer une collection combinée des likes et commentaires
        $likes = Like::with('user')
            ->select([
                'id',
                'user_id',
                'likeable_type as content_type',
                'likeable_id as content_id',
                'ip_address',
                'created_at',
                \DB::raw("'Like' as type"),
                \DB::raw("null as content"),
                \DB::raw("null as author_name"),
                \DB::raw("null as is_approved")
            ])
            ->orderBy('created_at', 'desc')
            ->limit(25);

        $comments = Comment::with('user')
            ->select([
                'id',
                'user_id',
                'commentable_type as content_type',
                'commentable_id as content_id',
                'ip_address',
                'created_at',
                \DB::raw("'Commentaire' as type"),
                'content',
                'author_name',
                'is_approved'
            ])
            ->orderBy('created_at', 'desc')
            ->limit(25);

        // Utiliser une union pour combiner les deux requêtes
        return $likes->union($comments);
    }

    protected static ?string $pollingInterval = '30s';
}