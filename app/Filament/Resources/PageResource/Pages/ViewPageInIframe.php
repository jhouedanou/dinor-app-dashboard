<?php

namespace App\Filament\Resources\PageResource\Pages;

use App\Filament\Resources\PageResource;
use App\Models\Page as PageModel;
use Filament\Pages\Actions;
use Filament\Resources\Pages\Page;
use Illuminate\Contracts\Support\Htmlable;

class ViewPageInIframe extends Page
{
    protected static string $resource = PageResource::class;

    protected static string $view = 'filament.resources.page-resource.pages.view-page-in-iframe';

    public PageModel $record;

    public function mount($record): void
    {
        $this->record = $this->resolveRecord($record);
    }

    protected function resolveRecord($key): PageModel
    {
        return PageModel::findOrFail($key);
    }

    public function getTitle(): string|Htmlable
    {
        return "Prévisualisation : {$this->record->title}";
    }

    protected function getActions(): array
    {
        return [
            Actions\Action::make('back')
                ->label('Retour à la liste')
                ->icon('heroicon-o-arrow-left')
                ->url($this->getResource()::getUrl('index'))
                ->color('gray'),

            Actions\Action::make('edit')
                ->label('Modifier')
                ->icon('heroicon-o-pencil-square')
                ->url($this->getResource()::getUrl('edit', ['record' => $this->record]))
                ->color('primary'),

            Actions\Action::make('open_external')
                ->label('Ouvrir dans un nouvel onglet')
                ->icon('heroicon-o-arrow-top-right-on-square')
                ->url($this->record->url)
                ->openUrlInNewTab()
                ->color('success'),
        ];
    }
} 