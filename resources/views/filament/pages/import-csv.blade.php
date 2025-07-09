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
            <h3 class="text-lg font-medium text-gray-900 mb-4">Formats supportés</h3>
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 text-sm">
                <!-- Contenu principal -->
                <div class="space-y-2">
                    <h4 class="font-semibold text-gray-800 text-base border-b pb-1">Contenu Principal</h4>
                    <div>
                        <h5 class="font-medium text-gray-800">Recettes</h5>
                        <p class="text-gray-600">title, description, ingredients (JSON), instructions (JSON), difficulty, etc.</p>
                    </div>
                    <div>
                        <h5 class="font-medium text-gray-800">Événements</h5>
                        <p class="text-gray-600">title, description, start_date, location, price, max_participants, etc.</p>
                    </div>
                    <div>
                        <h5 class="font-medium text-gray-800">Astuces</h5>
                        <p class="text-gray-600">title, content, difficulty_level, estimated_time, etc.</p>
                    </div>
                    <div>
                        <h5 class="font-medium text-gray-800">Vidéos (Dinor TV)</h5>
                        <p class="text-gray-600">title, description, video_url, is_featured, etc.</p>
                    </div>
                </div>

                <!-- Configuration -->
                <div class="space-y-2">
                    <h4 class="font-semibold text-gray-800 text-base border-b pb-1">Configuration</h4>
                    <div>
                        <h5 class="font-medium text-gray-800">Catégories</h5>
                        <p class="text-gray-600">name, description, color, icon, type, etc.</p>
                    </div>
                    <div>
                        <h5 class="font-medium text-gray-800">Catégories d'Événements</h5>
                        <p class="text-gray-600">name, description, color, icon, is_active, etc.</p>
                    </div>
                    <div>
                        <h5 class="font-medium text-gray-800">Bannières</h5>
                        <p class="text-gray-600">title, type_contenu, image_url, button_text, position, etc.</p>
                    </div>
                    <div>
                        <h5 class="font-medium text-gray-800">Ingrédients</h5>
                        <p class="text-gray-600">name, category, unit, average_price, description, etc.</p>
                    </div>
                </div>

                <!-- Sports & Prédictions -->
                <div class="space-y-2">
                    <h4 class="font-semibold text-gray-800 text-base border-b pb-1">Sports & Prédictions</h4>
                    <div>
                        <h5 class="font-medium text-gray-800">Équipes</h5>
                        <p class="text-gray-600">name, short_name, country, logo, colors, founded_year, etc.</p>
                    </div>
                    <div>
                        <h5 class="font-medium text-gray-800">Matchs de Football</h5>
                        <p class="text-gray-600">home_team, away_team, match_date, competition, venue, etc.</p>
                    </div>
                    <div>
                        <h5 class="font-medium text-gray-800">Tournois</h5>
                        <p class="text-gray-600">name, start_date, max_participants, prize_pool, rules, etc.</p>
                    </div>
                    <div>
                        <h5 class="font-medium text-gray-800">Prédictions</h5>
                        <p class="text-gray-600">user_email, match_id, predicted_scores, points_earned, etc.</p>
                    </div>
                </div>

                <!-- Système -->
                <div class="space-y-2">
                    <h4 class="font-semibold text-gray-800 text-base border-b pb-1">Système</h4>
                    <div>
                        <h5 class="font-medium text-gray-800">Utilisateurs</h5>
                        <p class="text-gray-600">name, email, password, role, is_active, etc.</p>
                    </div>
                    <div>
                        <h5 class="font-medium text-gray-800">Notifications Push</h5>
                        <p class="text-gray-600">title, message, target_audience, scheduled_at, etc.</p>
                    </div>
                    <div>
                        <h5 class="font-medium text-gray-800">Pages</h5>
                        <p class="text-gray-600">title, content, meta_title, template, is_published, etc.</p>
                    </div>
                </div>

                <!-- Média -->
                <div class="space-y-2">
                    <h4 class="font-semibold text-gray-800 text-base border-b pb-1">Média</h4>
                    <div>
                        <h5 class="font-medium text-gray-800">Fichiers Média</h5>
                        <p class="text-gray-600">name, filename, path, mime_type, size, collection_name, etc.</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Notes importantes -->
        <div class="bg-yellow-50 border border-yellow-200 rounded-lg p-4">
            <h3 class="text-lg font-medium text-yellow-900 mb-2">Notes importantes</h3>
            <ul class="text-sm text-yellow-800 space-y-1">
                <li>• <strong>Format JSON:</strong> Les champs JSON (ingredients, instructions, tags, rules, etc.) doivent être au format JSON valide</li>
                <li>• <strong>Dates:</strong> Les dates doivent être au format YYYY-MM-DD HH:MM:SS</li>
                <li>• <strong>Booléens:</strong> Les valeurs booléennes doivent être 'true' ou 'false'</li>
                <li>• <strong>Relations:</strong> Les équipes dans les matchs doivent correspondre exactement aux noms existants</li>
                <li>• <strong>Catégories:</strong> Si une catégorie n'existe pas, elle sera créée automatiquement</li>
                <li>• <strong>Utilisateurs:</strong> Les emails doivent être uniques et valides</li>
                <li>• <strong>Mots de passe:</strong> Seront automatiquement hachés lors de l'import</li>
                <li>• <strong>Slugs:</strong> Seront générés automatiquement à partir des titres/noms</li>
                <li>• <strong>Médias:</strong> Les chemins de fichiers doivent pointer vers des fichiers existants</li>
            </ul>
        </div>

        <!-- Exemples de données spéciales -->
        <div class="bg-green-50 border border-green-200 rounded-lg p-4">
            <h3 class="text-lg font-medium text-green-900 mb-2">Exemples de formats spéciaux</h3>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm">
                <div>
                    <h4 class="font-medium text-green-800">Format JSON pour ingrédients:</h4>
                    <code class="block text-xs bg-green-100 p-2 rounded mt-1">
                        [{"quantity":"2","unit":"tasses","ingredient_id":null}]
                    </code>
                </div>
                <div>
                    <h4 class="font-medium text-green-800">Format JSON pour tags:</h4>
                    <code class="block text-xs bg-green-100 p-2 rounded mt-1">
                        ["riz","traditionnel","plat-principal"]
                    </code>
                </div>
                <div>
                    <h4 class="font-medium text-green-800">Format pour les couleurs:</h4>
                    <code class="block text-xs bg-green-100 p-2 rounded mt-1">
                        #FF6B6B (format hexadécimal)
                    </code>
                </div>
                <div>
                    <h4 class="font-medium text-green-800">Icônes Heroicons:</h4>
                    <code class="block text-xs bg-green-100 p-2 rounded mt-1">
                        heroicon-o-tag, heroicon-o-calendar, etc.
                    </code>
                </div>
            </div>
        </div>
    </div>
</x-filament-panels::page>