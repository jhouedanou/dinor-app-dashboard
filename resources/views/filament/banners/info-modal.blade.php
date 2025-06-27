<div class="space-y-4">
    <div class="p-4 bg-blue-50 rounded-lg border border-blue-200">
        <h3 class="font-semibold text-blue-800 mb-2">🎯 Système de Bannières Dinor</h3>
        <p class="text-blue-700 text-sm">
            Les bannières permettent d'afficher des messages promotionnels sur votre application PWA avec des couleurs personnalisées, images de fond et boutons d'action.
        </p>
    </div>

    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div class="p-3 bg-green-50 rounded border border-green-200">
            <h4 class="font-medium text-green-800 mb-1">✅ Types Supportés</h4>
            <ul class="text-sm text-green-700 space-y-1">
                <li>• <strong>Home</strong> - Page d'accueil</li>
                <li>• <strong>Recettes</strong> - Section recettes</li>
                <li>• <strong>Astuces</strong> - Section astuces</li>
                <li>• <strong>Événements</strong> - Section événements</li>
                <li>• <strong>Dinor TV</strong> - Section vidéos</li>
            </ul>
        </div>

        <div class="p-3 bg-purple-50 rounded border border-purple-200">
            <h4 class="font-medium text-purple-800 mb-1">🎨 Sections d'Affichage</h4>
            <ul class="text-sm text-purple-700 space-y-1">
                <li>• <strong>Hero</strong> - Bannière principale</li>
                <li>• <strong>Header</strong> - En-tête de page</li>
                <li>• <strong>Featured</strong> - Contenu mis en avant</li>
                <li>• <strong>Footer</strong> - Pied de page</li>
            </ul>
        </div>
    </div>

    <div class="p-4 bg-yellow-50 rounded-lg border border-yellow-200">
        <h4 class="font-semibold text-yellow-800 mb-2">⚠️ Configuration Requise</h4>
        <div class="text-sm text-yellow-700 space-y-1">
            <p><strong>1. Base de données :</strong> La table <code class="bg-yellow-100 px-1 rounded">banners</code> doit être migrée</p>
            <p><strong>2. Commandes :</strong> <code class="bg-yellow-100 px-1 rounded">php artisan migrate</code> puis <code class="bg-yellow-100 px-1 rounded">php artisan db:seed --class=BannerSeeder</code></p>
            <p><strong>3. API :</strong> Les routes <code class="bg-yellow-100 px-1 rounded">/api/banners</code> sont déjà configurées</p>
        </div>
    </div>

    <div class="p-4 bg-gray-50 rounded-lg border border-gray-200">
        <h4 class="font-semibold text-gray-800 mb-2">🔧 Fonctionnalités</h4>
        <div class="grid grid-cols-1 sm:grid-cols-2 gap-2 text-sm text-gray-700">
            <div>✅ Titres et sous-titres</div>
            <div>✅ Images de fond</div>
            <div>✅ Couleurs personnalisées</div>
            <div>✅ Boutons d'action</div>
            <div>✅ Système d'ordre</div>
            <div>✅ Activation/désactivation</div>
        </div>
    </div>

    <div class="p-3 bg-red-50 rounded border border-red-200">
        <h4 class="font-medium text-red-800 mb-1">🚨 État Actuel</h4>
        <p class="text-sm text-red-700">
            La base de données PostgreSQL n'est pas accessible. Configurez votre connexion DB pour utiliser pleinement ce système.
        </p>
    </div>
</div> 