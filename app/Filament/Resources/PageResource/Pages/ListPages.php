<?php

namespace App\Filament\Resources\PageResource\Pages;

use App\Filament\Resources\PageResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListPages extends ListRecords
{
    protected static string $resource = PageResource::class;

    public function mount(): void
    {
        // Rediriger directement vers la création d'une page si aucune page n'existe
        $pagesCount = PageResource::getModel()::count();
        
        if ($pagesCount === 0) {
            redirect()->to(PageResource::getUrl('create'));
        }
    }

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make()
                ->label('Créer une nouvelle page')
                ->icon('heroicon-o-plus-circle')
                ->modalHeading('Créer une nouvelle page')
                ->modalDescription('Configurez simplement le nom du menu et l\'URL à afficher')
                ->modalWidth('4xl')
                ->successNotificationTitle('Page créée avec succès')
                ->form([
                    \Filament\Forms\Components\Section::make('Configuration de la page')
                        ->description('Configurez simplement le nom du menu et l\'URL à afficher')
                        ->schema([
                            \Filament\Forms\Components\TextInput::make('title')
                                ->label('Nom du menu')
                                ->required()
                                ->maxLength(255)
                                ->helperText('Nom qui apparaîtra dans le menu de navigation de la PWA')
                                ->placeholder('Ex: À propos, Contact, Boutique...'),
                            
                            \Filament\Forms\Components\TextInput::make('url')
                                ->label('URL à afficher')
                                ->required()
                                ->url()
                                ->helperText('Page web qui s\'ouvrira dans un iframe dans l\'application')
                                ->placeholder('https://example.com'),

                            \Filament\Forms\Components\Toggle::make('is_published')
                                ->label('Activer cette page')
                                ->default(true)
                                ->helperText('Afficher dans le menu de l\'application mobile'),

                            \Filament\Forms\Components\TextInput::make('order')
                                ->label('Position dans le menu')
                                ->numeric()
                                ->default(0)
                                ->helperText('Ordre d\'affichage (0 = en premier)'),
                        ])->columns(2),
                ]),
        ];
    }
} 