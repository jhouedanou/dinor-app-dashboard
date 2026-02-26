@php
    $data = $this->getData();
    $popularContent = $data['popular_content'];
    $stats = $data['favorites_stats'];
    $periodLabel = $data['period_label'];
    $totalFavorites = $data['total_favorites'];
@endphp

<x-filament-widgets::widget>
    <x-filament::section>
        <div class="space-y-6">
            {{-- En-tête avec statistiques --}}
            <div class="flex items-center justify-between">
                <div>
                    <h2 class="text-xl font-semibold text-gray-900 dark:text-white">
                        📊 Contenus Populaires
                    </h2>
                    <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">
                        {{ $periodLabel }} • {{ number_format($totalFavorites) }} favoris au total
                    </p>
                </div>
                <div class="flex space-x-4 text-sm">
                    <div class="text-center">
                        <div class="font-semibold text-gray-900 dark:text-white">{{ number_format($stats['total_favorites']) }}</div>
                        <div class="text-gray-500 dark:text-gray-400">Favoris</div>
                    </div>
                    <div class="text-center">
                        <div class="font-semibold text-gray-900 dark:text-white">{{ number_format($stats['unique_users']) }}</div>
                        <div class="text-gray-500 dark:text-gray-400">Utilisateurs</div>
                    </div>
                    <div class="text-center">
                        <div class="font-semibold text-gray-900 dark:text-white">{{ $stats['avg_per_user'] }}</div>
                        <div class="text-gray-500 dark:text-gray-400">Moy/User</div>
                    </div>
                </div>
            </div>

            {{-- Sélecteur de période --}}
            <div class="flex space-x-2">
                <select 
                    onchange="window.location.href = '{{ request()->url() }}?period=' + this.value"
                    class="text-sm border-gray-300 dark:border-gray-600 rounded-lg focus:border-primary-500 focus:ring-primary-500 dark:bg-gray-800 dark:text-white"
                >
                    <option value="7d" {{ request('period', '30d') === '7d' ? 'selected' : '' }}>7 derniers jours</option>
                    <option value="30d" {{ request('period', '30d') === '30d' ? 'selected' : '' }}>30 derniers jours</option>
                    <option value="90d" {{ request('period', '30d') === '90d' ? 'selected' : '' }}>90 derniers jours</option>
                    <option value="all" {{ request('period', '30d') === 'all' ? 'selected' : '' }}>Depuis le début</option>
                </select>
                
                <button 
                    onclick="window.location.reload()"
                    class="px-3 py-1 text-sm bg-primary-100 hover:bg-primary-200 text-primary-700 rounded-lg transition-colors"
                >
                    🔄 Actualiser
                </button>
            </div>

            {{-- Répartition par type de contenu --}}
            @if($stats['by_type']->count() > 0)
            <div class="bg-gray-50 dark:bg-gray-900 rounded-lg p-4">
                <h3 class="font-medium text-gray-900 dark:text-white mb-3">Répartition par type</h3>
                <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
                    @php $total = $stats['by_type']->sum('count'); @endphp
                    @foreach($stats['by_type'] as $typeStats)
                    <div class="text-center">
                        <div class="text-lg font-semibold text-gray-900 dark:text-white">
                            {{ number_format($typeStats['count']) }}
                        </div>
                        <div class="text-sm text-gray-600 dark:text-gray-400">
                            {{ $typeStats['type'] }}
                        </div>
                        <div class="text-xs text-gray-500">
                            {{ $total > 0 ? round(($typeStats['count'] / $total) * 100, 1) : 0 }}%
                        </div>
                    </div>
                    @endforeach
                </div>
            </div>
            @endif

            {{-- Liste des contenus populaires --}}
            @if($popularContent->count() > 0)
            <div class="space-y-3">
                <h3 class="font-medium text-gray-900 dark:text-white">Top contenus favoris</h3>
                <div class="space-y-2">
                    @foreach($popularContent as $index => $content)
                    <div class="flex items-center justify-between p-3 bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-lg hover:bg-gray-50 dark:hover:bg-gray-750 transition-colors">
                        <div class="flex items-center space-x-3">
                            {{-- Position --}}
                            <div class="flex-shrink-0 w-8 h-8 bg-primary-100 dark:bg-primary-900 text-primary-700 dark:text-primary-300 rounded-full flex items-center justify-center text-sm font-semibold">
                                {{ $index + 1 }}
                            </div>

                            {{-- Image si disponible --}}
                            @if($content['image'])
                            <div class="flex-shrink-0">
                                <img 
                                    src="{{ asset('storage/' . $content['image']) }}" 
                                    alt="{{ $content['title'] }}"
                                    class="w-12 h-12 rounded-lg object-cover"
                                    onerror="this.style.display='none'"
                                >
                            </div>
                            @endif

                            {{-- Informations du contenu --}}
                            <div class="flex-grow min-w-0">
                                <div class="flex items-center space-x-2">
                                    <h4 class="text-sm font-medium text-gray-900 dark:text-white truncate">
                                        {{ $content['title'] }}
                                    </h4>
                                    <span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium 
                                        {{ match($content['type_slug']) {
                                            'recipe' => 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200',
                                            'tip' => 'bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200',
                                            'event' => 'bg-purple-100 text-purple-800 dark:bg-purple-900 dark:text-purple-200',
                                            'dinor_tv' => 'bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200',
                                            default => 'bg-gray-100 text-gray-800 dark:bg-gray-900 dark:text-gray-200'
                                        } }}">
                                        {{ $content['type'] }}
                                    </span>
                                </div>
                                <div class="flex items-center space-x-2 mt-1 text-xs text-gray-500 dark:text-gray-400">
                                    @if($content['category'])
                                    <span>📂 {{ $content['category'] }}</span>
                                    @endif
                                    @if($content['created_at'])
                                    <span>📅 {{ \Carbon\Carbon::parse($content['created_at'])->format('d/m/Y') }}</span>
                                    @endif
                                </div>
                            </div>
                        </div>

                        {{-- Statistiques et actions --}}
                        <div class="flex items-center space-x-3">
                            <div class="text-right">
                                <div class="text-lg font-semibold text-gray-900 dark:text-white">
                                    {{ number_format($content['favorites_count']) }}
                                </div>
                                <div class="text-xs text-gray-500 dark:text-gray-400">
                                    {{ $content['favorites_count'] > 1 ? 'favoris' : 'favori' }}
                                </div>
                            </div>

                            {{-- Bouton de consultation --}}
                            @if($content['url'])
                            <a 
                                href="{{ $content['url'] }}" 
                                class="inline-flex items-center px-3 py-1.5 text-xs font-medium text-primary-700 bg-primary-100 rounded-lg hover:bg-primary-200 dark:bg-primary-900 dark:text-primary-300 dark:hover:bg-primary-800 transition-colors"
                                target="_blank"
                            >
                                👁️ Voir
                            </a>
                            @endif
                        </div>
                    </div>
                    @endforeach
                </div>
            </div>
            @else
            <div class="text-center py-8 text-gray-500 dark:text-gray-400">
                <div class="text-4xl mb-2">📭</div>
                <p>Aucun contenu populaire trouvé</p>
                <p class="text-sm mt-1">Les contenus ajoutés aux favoris ou les plus likés apparaîtront ici</p>
            </div>
            @endif

            {{-- Footer --}}
            <div class="border-t border-gray-200 dark:border-gray-700 pt-4">
                <div class="text-sm text-gray-500 dark:text-gray-400">
                    Basé sur les favoris utilisateurs • {{ $periodLabel }}
                </div>
            </div>
        </div>
    </x-filament::section>
</x-filament-widgets::widget>