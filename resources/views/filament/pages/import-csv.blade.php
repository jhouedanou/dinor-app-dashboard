<x-filament-panels::page>
    <div class="space-y-6">
        <!-- Instructions -->
        <div class="bg-blue-50 border border-blue-200 rounded-lg p-4">
            <h3 class="text-lg font-medium text-blue-900 mb-2">Instructions d'utilisation</h3>
            <ul class="text-sm text-blue-800 space-y-1">
                <li>• Sélectionnez le type de contenu que vous souhaitez importer</li>
                <li>• Téléchargez l'exemple CSV correspondant pour voir le format attendu</li>
                <li>• Préparez votre fichier CSV en respectant exactement le format de l'exemple</li>
                <li>• Uploadez votre fichier et lancez l'import</li>
            </ul>
        </div>

        <!-- Formulaire -->
        <form wire:submit="import">
            {{ $this->form }}
        </form>

        <!-- Formats supportés -->
        <div class="bg-gray-50 border border-gray-200 rounded-lg p-4">
            <h3 class="text-lg font-medium text-gray-900 mb-2">Formats supportés</h3>
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 text-sm">
                <div>
                    <h4 class="font-medium text-gray-800">Recettes</h4>
                    <p class="text-gray-600">title, description, ingredients (JSON), instructions (JSON), difficulty, etc.</p>
                </div>
                <div>
                    <h4 class="font-medium text-gray-800">Événements</h4>
                    <p class="text-gray-600">title, description, start_date, location, price, max_participants, etc.</p>
                </div>
                <div>
                    <h4 class="font-medium text-gray-800">Astuces</h4>
                    <p class="text-gray-600">title, content, difficulty_level, estimated_time, etc.</p>
                </div>
                <div>
                    <h4 class="font-medium text-gray-800">Vidéos</h4>
                    <p class="text-gray-600">title, description, video_url, is_featured, etc.</p>
                </div>
                <div>
                    <h4 class="font-medium text-gray-800">Catégories</h4>
                    <p class="text-gray-600">name, description, color, icon, type, etc.</p>
                </div>
            </div>
        </div>

        <!-- Notes importantes -->
        <div class="bg-yellow-50 border border-yellow-200 rounded-lg p-4">
            <h3 class="text-lg font-medium text-yellow-900 mb-2">Notes importantes</h3>
            <ul class="text-sm text-yellow-800 space-y-1">
                <li>• Les champs JSON (ingredients, instructions, tags) doivent être au format JSON valide</li>
                <li>• Les dates doivent être au format YYYY-MM-DD HH:MM:SS</li>
                <li>• Les valeurs booléennes doivent être 'true' ou 'false'</li>
                <li>• Si une catégorie n'existe pas, elle sera créée automatiquement</li>
                <li>• Les slugs seront générés automatiquement à partir des titres</li>
            </ul>
        </div>
    </div>
</x-filament-panels::page>