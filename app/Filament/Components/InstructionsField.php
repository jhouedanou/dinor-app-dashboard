<?php

namespace App\Filament\Components;

use Filament\Forms\Components\Actions\Action;
use Filament\Forms\Components\Component;
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
                    ->label('Étape')
                    ->required()
                    ->placeholder('Décrivez cette étape de la recette...')
                    ->toolbarButtons([
                        'bold',
                        'italic',
                        'underline',
                        'bulletList',
                        'orderedList',
                        'link',
                    ])
                    ->columnSpanFull(),
            ])
            ->itemLabel(function (array $state, int $index): ?string {
                $stepNumber = $index + 1;
                $content = strip_tags($state['step'] ?? '');
                $preview = strlen($content) > 50 ? substr($content, 0, 50) . '...' : $content;
                
                return "Étape {$stepNumber}: {$preview}";
            })
            ->defaultItems(1)
            ->reorderable()
            ->collapsible()
            ->cloneable()
            ->addActionLabel('Ajouter une étape')
            ->deleteAction(function (Action $action) {
                return $action
                    ->requiresConfirmation()
                    ->modalHeading('Supprimer cette étape ?')
                    ->modalDescription('Êtes-vous sûr de vouloir supprimer cette étape ? Les numéros des étapes suivantes seront automatiquement ajustés.');
            });
    }
} 