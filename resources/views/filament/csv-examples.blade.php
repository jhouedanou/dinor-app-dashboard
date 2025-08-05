<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
    <div class="bg-white p-4 rounded-lg border">
        <h4 class="font-semibold text-gray-900 mb-2">Recettes</h4>
        <p class="text-sm text-gray-600 mb-3">Format attendu pour l'import des recettes</p>
        <a href="{{ route('csv.example', 'recipes') }}" 
           class="inline-flex items-center px-3 py-2 text-xs font-medium text-blue-600 bg-blue-50 border border-blue-200 rounded-md hover:bg-blue-100">
            <x-heroicon-m-arrow-down-tray class="w-4 h-4 mr-1" />
            Télécharger
        </a>
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