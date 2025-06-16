<x-filament-panels::page>
    <div class="filament-stats-overview-widget">
        <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6 mb-6">
            <h2 class="text-2xl font-bold text-gray-900 dark:text-white mb-4">{{ __('dinor.welcome') }} sur le Dashboard Dinor</h2>
            <p class="text-gray-600 dark:text-gray-300 mb-4">
                Gérez facilement votre contenu culinaire : recettes, événements, conseils et bien plus encore.
            </p>
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
                <div class="bg-green-50 dark:bg-green-900/20 p-4 rounded-lg">
                    <h3 class="font-semibold text-green-800 dark:text-green-400">{{ __('dinor.recipes') }}</h3>
                    <p class="text-sm text-green-600 dark:text-green-400">Créez et gérez vos recettes</p>
                </div>
                <div class="bg-blue-50 dark:bg-blue-900/20 p-4 rounded-lg">
                    <h3 class="font-semibold text-blue-800 dark:text-blue-400">{{ __('dinor.events') }}</h3>
                    <p class="text-sm text-blue-600 dark:text-blue-400">Organisez vos événements culinaires</p>
                </div>
                <div class="bg-purple-50 dark:bg-purple-900/20 p-4 rounded-lg">
                    <h3 class="font-semibold text-purple-800 dark:text-purple-400">{{ __('dinor.media') }}</h3>
                    <p class="text-sm text-purple-600 dark:text-purple-400">Gérez vos images et vidéos</p>
                </div>
                <div class="bg-orange-50 dark:bg-orange-900/20 p-4 rounded-lg">
                    <h3 class="font-semibold text-orange-800 dark:text-orange-400">{{ __('dinor.pages') }}</h3>
                    <p class="text-sm text-orange-600 dark:text-orange-400">Créez du contenu personnalisé</p>
                </div>
            </div>
        </div>
    </div>
</x-filament-panels::page> 