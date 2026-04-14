<?php

namespace App\Filament\Components;

use Filament\Forms\Components\Actions\Action;
use Filament\Forms\Components\Component;
use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\Repeater;
use Filament\Forms\Components\RichEditor;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Get;
use Filament\Forms\Set;
use Filament\Notifications\Notification;

class InstructionsField extends Component
{
    public static function make(string $name = 'instructions'): Repeater
    {
        return Repeater::make($name)
            ->label('Instructions')
            ->schema([
                RichEditor::make('step')
                    ->label('Etape')
                    ->required()
                    ->placeholder('Decrivez cette etape de la recette...')
                    ->toolbarButtons([
                        'bold',
                        'italic',
                        'underline',
                        'bulletList',
                        'orderedList',
                        'link',
                    ])
                    ->columnSpanFull(),

                FileUpload::make('audio_guide')
                    ->label('Guide audio')
                    ->disk('public')
                    ->directory('recipes/audio-guides')
                    ->visibility('public')
                    ->acceptedFileTypes(['audio/mpeg', 'audio/mp3', 'audio/wav', 'audio/wave', 'audio/x-wav', 'audio/vnd.wave', 'audio/ogg', 'audio/mp4', 'audio/x-m4a', 'audio/aac', 'audio/webm'])
                    ->maxSize(10240) // 10 MB
                    ->helperText('Audio MP3/WAV/OGG pour guider cette etape (max 10 Mo)')
                    ->columnSpanFull(),
            ])
            ->itemLabel(function ($state) {
                if (!is_array($state) || !isset($state['step'])) {
                    return 'Nouvelle etape';
                }

                $content = strip_tags($state['step'] ?? '');
                $preview = strlen($content) > 50 ? substr($content, 0, 50) . '...' : $content;
                $hasAudio = !empty($state['audio_guide']) ? ' [audio]' : '';

                return ($preview ?: 'Etape vide') . $hasAudio;
            })
            ->defaultItems(1)
            ->reorderable()
            ->collapsible()
            ->cloneable()
            ->addActionLabel('Ajouter une etape')
            ->deleteAction(function (Action $action) {
                return $action
                    ->requiresConfirmation()
                    ->modalHeading('Supprimer cette etape ?')
                    ->modalDescription('Etes-vous sur de vouloir supprimer cette etape ? Les numeros des etapes suivantes seront automatiquement ajustes.');
            });
    }
}
