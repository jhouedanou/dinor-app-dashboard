<?php

namespace App\Filament\Components;

use Filament\Forms\Components\Component;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\Tabs;
use Filament\Forms\Components\Tabs\Tab;
use Filament\Forms\Components\Repeater;
use Filament\Forms\Components\Grid;

class InstructionsField extends Component
{
    public static function make($name = 'instructions')
    {
        return Tabs::make('instructions_tabs')
            ->tabs([
                Tab::make('Mode simple')
                    ->schema([
                        Textarea::make('instructions_text')
                            ->label('Instructions (une par ligne)')
                            ->placeholder('Préchauffez le four à 180°C
Mélangez la farine et le sucre
Ajoutez les œufs un par un
...')
                            ->rows(8)
                            ->afterStateUpdated(function ($state, $set) {
                                if ($state) {
                                    $lines = array_filter(explode("\n", $state));
                                    $instructions = [];
                                    foreach ($lines as $index => $line) {
                                        $instructions[] = [
                                            'step_number' => $index + 1,
                                            'step' => trim($line)
                                        ];
                                    }
                                    $set('instructions', $instructions);
                                }
                            })
                            ->live()
                            ->hint('Saisissez chaque étape sur une ligne séparée'),
                    ]),
                    
                Tab::make('Mode avancé')
                    ->schema([
                        Repeater::make('instructions')
                            ->label('Instructions détaillées')
                            ->schema([
                                Grid::make(2)
                                    ->schema([
                                        Textarea::make('step')
                                            ->label('Étape')
                                            ->required()
                                            ->rows(2)
                                            ->columnSpan(2),
                                    ])
                            ])
                            ->collapsible()
                            ->itemLabel(function ($state, $index) {
                                $stepNumber = $index + 1;
                                $stepText = $state['step'] ?? '';
                                $preview = strlen($stepText) > 50 ? substr($stepText, 0, 50) . '...' : $stepText;
                                return "Étape {$stepNumber}: {$preview}";
                            })
                            ->defaultItems(1)
                            ->addActionLabel('Ajouter une étape')
                            ->reorderable()
                            ->cloneable(),
                    ]),
            ]);
    }
} 