<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
    <div class="bg-white p-4 rounded-lg border">
        <h4 class="font-semibold text-gray-900 mb-2">Recettes</h4>
        <p class="text-sm text-gray-600 mb-3">Format attendu pour l'import des recettes</p>
        <div class="space-y-2">
            <a href="{{ route('csv.example', 'recipes') }}" 
               class="inline-flex items-center px-3 py-2 text-xs font-medium text-blue-600 bg-blue-50 border border-blue-200 rounded-md hover:bg-blue-100">
                <x-heroicon-m-arrow-down-tray class="w-4 h-4 mr-1" />
                Format détaillé
            </a>
            <a href="{{ asset('storage/examples/exemple_recipes_simple.csv') }}" 
               class="inline-flex items-center px-3 py-2 text-xs font-medium text-green-600 bg-green-50 border border-green-200 rounded-md hover:bg-green-100 ml-2">
                <x-heroicon-m-arrow-down-tray class="w-4 h-4 mr-1" />
                Format simplifié ✨
            </a>
        </div>
        <p class="text-xs text-gray-500 mt-2">Le format simplifié est recommandé pour un import plus facile</p>
    </div>

    <div class="bg-white p-4 rounded-lg border">
        <h4 class="font-semibold text-gray-900 mb-2">Astuces</h4>
        <p class="text-sm text-gray-600 mb-3">Format attendu pour l'import des astuces</p>
        <a href="{{ route('csv.example', 'tips') }}" 
           class="inline-flex items-center px-3 py-2 text-xs font-medium text-blue-600 bg-blue-50 border border-blue-200 rounded-md hover:bg-blue-100">
            <x-heroicon-m-arrow-down-tray class="w-4 h-4 mr-1" />
            Télécharger
        </a>
    </div>

    <div class="bg-white p-4 rounded-lg border">
        <h4 class="font-semibold text-gray-900 mb-2">Événements</h4>
        <p class="text-sm text-gray-600 mb-3">Format attendu pour l'import des événements</p>
        <a href="{{ route('csv.example', 'events') }}" 
           class="inline-flex items-center px-3 py-2 text-xs font-medium text-blue-600 bg-blue-50 border border-blue-200 rounded-md hover:bg-blue-100">
            <x-heroicon-m-arrow-down-tray class="w-4 h-4 mr-1" />
            Télécharger
        </a>
    </div>

    <div class="bg-white p-4 rounded-lg border">
        <h4 class="font-semibold text-gray-900 mb-2">Vidéos Dinor TV</h4>
        <p class="text-sm text-gray-600 mb-3">Format attendu pour l'import des vidéos</p>
        <a href="{{ route('csv.example', 'dinor_tv') }}" 
           class="inline-flex items-center px-3 py-2 text-xs font-medium text-blue-600 bg-blue-50 border border-blue-200 rounded-md hover:bg-blue-100">
            <x-heroicon-m-arrow-down-tray class="w-4 h-4 mr-1" />
            Télécharger
        </a>
    </div>

    <div class="bg-white p-4 rounded-lg border">
        <h4 class="font-semibold text-gray-900 mb-2">Catégories</h4>
        <p class="text-sm text-gray-600 mb-3">Format attendu pour l'import des catégories</p>
        <a href="{{ route('csv.example', 'categories') }}" 
           class="inline-flex items-center px-3 py-2 text-xs font-medium text-blue-600 bg-blue-50 border border-blue-200 rounded-md hover:bg-blue-100">
            <x-heroicon-m-arrow-down-tray class="w-4 h-4 mr-1" />
            Télécharger
        </a>
    </div>

    <div class="bg-white p-4 rounded-lg border">
        <h4 class="font-semibold text-gray-900 mb-2">Utilisateurs</h4>
        <p class="text-sm text-gray-600 mb-3">Format attendu pour l'import des utilisateurs</p>
        <a href="{{ route('csv.example', 'users') }}" 
           class="inline-flex items-center px-3 py-2 text-xs font-medium text-blue-600 bg-blue-50 border border-blue-200 rounded-md hover:bg-blue-100">
            <x-heroicon-m-arrow-down-tray class="w-4 h-4 mr-1" />
            Télécharger
        </a>
    </div>
</div>