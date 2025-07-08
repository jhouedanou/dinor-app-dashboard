<x-filament-panels::page>
    <div class="space-y-6">
        {{-- Informations de la page --}}
        <div class="bg-white shadow rounded-lg p-6">
            <h3 class="text-lg font-medium text-gray-900 mb-4">Informations de la page</h3>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                    <dt class="text-sm font-medium text-gray-500">Titre</dt>
                    <dd class="mt-1 text-sm text-gray-900">{{ $record->title }}</dd>
                </div>
                <div>
                    <dt class="text-sm font-medium text-gray-500">URL</dt>
                    <dd class="mt-1 text-sm text-gray-900 break-all">
                        <a href="{{ $record->url }}" target="_blank" class="text-primary-600 hover:text-primary-900">
                            {{ $record->url }}
                        </a>
                    </dd>
                </div>
                <div>
                    <dt class="text-sm font-medium text-gray-500">Statut</dt>
                    <dd class="mt-1">
                        @if($record->is_published)
                            <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                                Publiée
                            </span>
                        @else
                            <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800">
                                Brouillon
                            </span>
                        @endif
                    </dd>
                </div>
                <div>
                    <dt class="text-sm font-medium text-gray-500">Position dans le menu</dt>
                    <dd class="mt-1 text-sm text-gray-900">{{ $record->order ?? 'Non définie' }}</dd>
                </div>
            </div>
        </div>

        {{-- Contrôles de l'iframe --}}
        <div class="bg-white shadow rounded-lg p-6">
            <div class="flex items-center justify-between mb-4">
                <h3 class="text-lg font-medium text-gray-900">Prévisualisation</h3>
                <div class="flex space-x-2">
                    {{-- Boutons de taille d'écran --}}
                    <button onclick="setIframeSize('100%', '600px')" 
                            class="px-3 py-1 text-xs bg-gray-100 hover:bg-gray-200 rounded">
                        Desktop
                    </button>
                    <button onclick="setIframeSize('768px', '600px')" 
                            class="px-3 py-1 text-xs bg-gray-100 hover:bg-gray-200 rounded">
                        Tablet
                    </button>
                    <button onclick="setIframeSize('375px', '667px')" 
                            class="px-3 py-1 text-xs bg-gray-100 hover:bg-gray-200 rounded">
                        Mobile
                    </button>
                    <button onclick="refreshIframe()" 
                            class="px-3 py-1 text-xs bg-primary-100 hover:bg-primary-200 text-primary-700 rounded">
                        ↻ Actualiser
                    </button>
                </div>
            </div>
            
            {{-- Container de l'iframe --}}
            <div class="border rounded-lg overflow-hidden" style="resize: both;">
                <div id="iframe-container" class="mx-auto transition-all duration-300" style="width: 100%; height: 600px;">
                    @if($record->url)
                        <iframe id="page-iframe"
                                src="{{ $record->url }}"
                                class="w-full h-full border-0"
                                sandbox="allow-same-origin allow-scripts allow-popups allow-forms"
                                loading="lazy">
                        </iframe>
                    @else
                        <div class="flex items-center justify-center h-full bg-gray-50">
                            <div class="text-center">
                                <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
                                </svg>
                                <h3 class="mt-2 text-sm font-medium text-gray-900">Aucune URL définie</h3>
                                <p class="mt-1 text-sm text-gray-500">Ajoutez une URL pour prévisualiser la page.</p>
                            </div>
                        </div>
                    @endif
                </div>
            </div>

            {{-- Informations de chargement --}}
            <div class="mt-4 text-xs text-gray-500">
                <p><strong>Note :</strong> Certaines pages peuvent bloquer l'affichage en iframe pour des raisons de sécurité. 
                Si la page ne s'affiche pas, utilisez le bouton "Ouvrir dans un nouvel onglet".</p>
            </div>
        </div>
    </div>

    <script>
        function setIframeSize(width, height) {
            const container = document.getElementById('iframe-container');
            container.style.width = width;
            container.style.height = height;
        }

        function refreshIframe() {
            const iframe = document.getElementById('page-iframe');
            if (iframe) {
                iframe.src = iframe.src;
            }
        }

        // Gérer les erreurs de chargement
        document.addEventListener('DOMContentLoaded', function() {
            const iframe = document.getElementById('page-iframe');
            if (iframe) {
                iframe.addEventListener('error', function() {
                    console.log('Erreur de chargement de l\'iframe');
                });
                
                iframe.addEventListener('load', function() {
                    console.log('Iframe chargée avec succès');
                });
            }
        });
    </script>
</x-filament-panels::page> 