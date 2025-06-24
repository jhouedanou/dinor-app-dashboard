<x-filament-panels::page>
    <div class="space-y-6">
        <div class="bg-blue-50 border border-blue-200 rounded-lg p-4">
            <div class="flex">
                <div class="flex-shrink-0">
                    <x-heroicon-o-information-circle class="h-5 w-5 text-blue-400" />
                </div>
                <div class="ml-3">
                    <h3 class="text-sm font-medium text-blue-800">
                        Sécurité du compte
                    </h3>
                    <div class="mt-2 text-sm text-blue-700">
                        <p>
                            Il est recommandé de changer votre mot de passe régulièrement et d'utiliser 
                            un mot de passe fort contenant au minimum 8 caractères avec une combinaison 
                            de lettres, chiffres et symboles.
                        </p>
                    </div>
                </div>
            </div>
        </div>

        <x-filament-panels::form wire:submit="updatePassword">
            {{ $this->form }}
            
            <x-filament-panels::form.actions
                :actions="$this->getFormActions()"
                alignment="start"
            />
        </x-filament-panels::form>
        
        <div class="bg-yellow-50 border border-yellow-200 rounded-lg p-4">
            <div class="flex">
                <div class="flex-shrink-0">
                    <x-heroicon-o-exclamation-triangle class="h-5 w-5 text-yellow-400" />
                </div>
                <div class="ml-3">
                    <h3 class="text-sm font-medium text-yellow-800">
                        Conseils de sécurité
                    </h3>
                    <div class="mt-2 text-sm text-yellow-700">
                        <ul class="list-disc list-inside space-y-1">
                            <li>Utilisez un mot de passe unique pour ce compte</li>
                            <li>Activez l'authentification à deux facteurs si disponible</li>
                            <li>Ne partagez jamais vos identifiants</li>
                            <li>Déconnectez-vous toujours après utilisation</li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    </div>
</x-filament-panels::page>