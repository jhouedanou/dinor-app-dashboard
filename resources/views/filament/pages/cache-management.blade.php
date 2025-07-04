<x-filament-panels::page>
    <div class="space-y-6">
        {{-- Informations sur le cache --}}
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div class="bg-white rounded-lg shadow p-6">
                <div class="flex items-center">
                    <div class="flex-shrink-0">
                        <x-heroicon-o-server-stack class="h-8 w-8 text-blue-500" />
                    </div>
                    <div class="ml-4">
                        <h3 class="text-lg font-medium text-gray-900">Cache Driver</h3>
                        <p class="text-sm text-gray-600">{{ config('cache.default') }}</p>
                    </div>
                </div>
            </div>

            <div class="bg-white rounded-lg shadow p-6">
                <div class="flex items-center">
                    <div class="flex-shrink-0">
                        <x-heroicon-o-clock class="h-8 w-8 text-green-500" />
                    </div>
                    <div class="ml-4">
                        <h3 class="text-lg font-medium text-gray-900">Redis Connexion</h3>
                        <p class="text-sm text-gray-600">
                            @try
                                @if(config('cache.default') === 'redis')
                                    ✅ Connecté
                                @else
                                    ⚠️ Non utilisé
                                @endif
                            @catch(\Exception $e)
                                ❌ Erreur
                            @endtry
                        </p>
                    </div>
                </div>
            </div>

            <div class="bg-white rounded-lg shadow p-6">
                <div class="flex items-center">
                    <div class="flex-shrink-0">
                        <x-heroicon-o-cpu-chip class="h-8 w-8 text-purple-500" />
                    </div>
                    <div class="ml-4">
                        <h3 class="text-lg font-medium text-gray-900">OPCache</h3>
                        <p class="text-sm text-gray-600">
                            @if(function_exists('opcache_get_status'))
                                @php $opcache = opcache_get_status(); @endphp
                                @if($opcache['opcache_enabled'])
                                    ✅ Activé
                                @else
                                    ⚠️ Désactivé
                                @endif
                            @else
                                ❌ Non disponible
                            @endif
                        </p>
                    </div>
                </div>
            </div>
        </div>

        {{-- Instructions --}}
        <div class="bg-blue-50 border border-blue-200 rounded-lg p-6">
            <div class="flex">
                <div class="flex-shrink-0">
                    <x-heroicon-o-information-circle class="h-5 w-5 text-blue-400" />
                </div>
                <div class="ml-3">
                    <h3 class="text-sm font-medium text-blue-800">
                        Gestion du Cache
                    </h3>
                    <div class="mt-2 text-sm text-blue-700">
                        <p>Cette page vous permet de vider différents types de cache en toute sécurité :</p>
                        <ul class="list-disc pl-5 mt-2 space-y-1">
                            <li><strong>Cache Application :</strong> Vide le cache des données applicatives</li>
                            <li><strong>Cache Configuration :</strong> Vide le cache des fichiers de configuration</li>
                            <li><strong>Cache Vues :</strong> Vide le cache des templates Blade</li>
                            <li><strong>Tout le cache :</strong> Vide tous les caches (action complète)</li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>

        {{-- Statut détaillé --}}
        <div class="bg-white rounded-lg shadow">
            <div class="px-6 py-4 border-b border-gray-200">
                <h3 class="text-lg font-medium text-gray-900">État du système de cache</h3>
            </div>
            <div class="px-6 py-4">
                <dl class="grid grid-cols-1 gap-x-4 gap-y-6 sm:grid-cols-2">
                    <div>
                        <dt class="text-sm font-medium text-gray-500">Driver de cache par défaut</dt>
                        <dd class="mt-1 text-sm text-gray-900">{{ config('cache.default') }}</dd>
                    </div>
                    <div>
                        <dt class="text-sm font-medium text-gray-500">Support des tags</dt>
                        <dd class="mt-1 text-sm text-gray-900">
                            @if(config('cache.default') === 'redis')
                                ✅ Supporté (Redis)
                            @else
                                ❌ Non supporté
                            @endif
                        </dd>
                    </div>
                    <div>
                        <dt class="text-sm font-medium text-gray-500">Configuration Redis</dt>
                        <dd class="mt-1 text-sm text-gray-900">
                            Host: {{ config('database.redis.default.host') }}:{{ config('database.redis.default.port') }}
                        </dd>
                    </div>
                    <div>
                        <dt class="text-sm font-medium text-gray-500">Préfixe cache</dt>
                        <dd class="mt-1 text-sm text-gray-900">{{ config('cache.prefix') ?: 'Aucun' }}</dd>
                    </div>
                </dl>
            </div>
        </div>

        {{-- Actions de cache --}}
        <div class="bg-gray-50 rounded-lg p-6">
            <h3 class="text-lg font-medium text-gray-900 mb-4">Actions rapides</h3>
            <div class="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
                <button 
                    wire:click="clearApplicationCache"
                    class="flex items-center justify-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
                >
                    <x-heroicon-o-cpu-chip class="h-4 w-4 mr-2" />
                    Cache App
                </button>
                
                <button 
                    wire:click="clearConfigCache"
                    class="flex items-center justify-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500"
                >
                    <x-heroicon-o-cog-6-tooth class="h-4 w-4 mr-2" />
                    Cache Config
                </button>
                
                <button 
                    wire:click="clearViewCache"
                    class="flex items-center justify-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-yellow-600 hover:bg-yellow-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-yellow-500"
                >
                    <x-heroicon-o-eye class="h-4 w-4 mr-2" />
                    Cache Vues
                </button>
                
                <button 
                    wire:click="clearAllCache"
                    class="flex items-center justify-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-red-600 hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500"
                    wire:confirm="Êtes-vous sûr de vouloir vider tout le cache ?"
                >
                    <x-heroicon-o-trash class="h-4 w-4 mr-2" />
                    Tout vider
                </button>
            </div>
        </div>
    </div>
</x-filament-panels::page>