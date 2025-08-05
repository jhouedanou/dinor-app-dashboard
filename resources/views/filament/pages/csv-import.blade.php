<x-filament-panels::page>
    <div class="space-y-6">
        <form wire:submit="submit">
            {{ $this->form }}
            
            <div class="flex justify-end mt-6">
                <x-filament::button type="submit" size="lg">
                    <x-heroicon-m-arrow-up-tray class="w-5 h-5 mr-2" />
                    Importer le fichier CSV
                </x-filament::button>
            </div>
        </form>

        <div class="bg-yellow-50 border border-yellow-200 rounded-lg p-4">
            <div class="flex">
                <x-heroicon-m-exclamation-triangle class="w-5 h-5 text-yellow-400 mr-2 mt-0.5" />
                <div>
                    <h3 class="text-sm font-medium text-yellow-800">Instructions importantes</h3>
                    <div class="mt-2 text-sm text-yellow-700">
                        <ul class="list-disc list-inside space-y-1">
                            <li>Assurez-vous que votre fichier CSV est encodé en UTF-8</li>
                            <li>Les colonnes doivent être dans l'ordre spécifié dans les exemples</li>
                            <li>Les champs obligatoires ne peuvent pas être vides</li>
                            <li>Taille maximale du fichier : 10MB</li>
                            <li>En cas d'erreur, l'import s'arrêtera et vous recevrez le détail des erreurs</li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    </div>
</x-filament-panels::page>