@php
    $appStats = $appStats ?? [];
    $contentStats = $contentStats ?? [];
    $engagementMetrics = $engagementMetrics ?? [];
    $realTimeMetrics = $realTimeMetrics ?? [];
    $platformStats = $platformStats ?? [];
    $geographicStats = $geographicStats ?? [];
    $trends = $trends ?? [];
    $topContent = $topContent ?? [];
@endphp

<x-filament-widgets::widget>
    <x-filament::section>
        {{-- Header avec métriques temps réel --}}
        <div class="mb-6">
            <div class="flex items-center justify-between mb-4">
                <div>
                    <h2 class="text-2xl font-bold text-gray-900 dark:text-white">
                        📊 Analytics Firebase
                    </h2>
                    <p class="text-sm text-gray-600 dark:text-gray-400">
                        Données en temps réel • Dernière mise à jour: {{ now()->format('H:i') }}
                    </p>
                </div>
                <div class="flex items-center space-x-3">
                    <div class="flex items-center px-3 py-1 bg-green-100 dark:bg-green-900 rounded-full">
                        <div class="w-2 h-2 bg-green-500 rounded-full animate-pulse mr-2"></div>
                        <span class="text-sm font-medium text-green-800 dark:text-green-200">
                            {{ $realTimeMetrics['current_users'] ?? 0 }} en ligne
                        </span>
                    </div>
                </div>
            </div>

            {{-- Métriques temps réel --}}
            <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
                <div class="bg-blue-50 dark:bg-blue-900/20 p-4 rounded-lg">
                    <div class="flex items-center">
                        <div class="p-2 bg-blue-500 rounded-lg">
                            <svg class="w-5 h-5 text-white" fill="currentColor" viewBox="0 0 20 20">
                                <path d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/>
                            </svg>
                        </div>
                        <div class="ml-3">
                            <p class="text-sm text-gray-600 dark:text-gray-400">Sessions aujourd'hui</p>
                            <p class="text-xl font-bold text-gray-900 dark:text-white">
                                {{ number_format($realTimeMetrics['sessions_today'] ?? 0) }}
                            </p>
                        </div>
                    </div>
                </div>

                <div class="bg-green-50 dark:bg-green-900/20 p-4 rounded-lg">
                    <div class="flex items-center">
                        <div class="p-2 bg-green-500 rounded-lg">
                            <svg class="w-5 h-5 text-white" fill="currentColor" viewBox="0 0 20 20">
                                <path d="M13 6a3 3 0 11-6 0 3 3 0 016 0zM18 8a2 2 0 11-4 0 2 2 0 014 0zM14 15a4 4 0 00-8 0v3h8v-3z"/>
                            </svg>
                        </div>
                        <div class="ml-3">
                            <p class="text-sm text-gray-600 dark:text-gray-400">Nouveaux utilisateurs</p>
                            <p class="text-xl font-bold text-gray-900 dark:text-white">
                                {{ $realTimeMetrics['new_users_today'] ?? 0 }}
                            </p>
                        </div>
                    </div>
                </div>

                <div class="bg-purple-50 dark:bg-purple-900/20 p-4 rounded-lg">
                    <div class="flex items-center">
                        <div class="p-2 bg-purple-500 rounded-lg">
                            <svg class="w-5 h-5 text-white" fill="currentColor" viewBox="0 0 20 20">
                                <path d="M3 4a1 1 0 011-1h12a1 1 0 011 1v2a1 1 0 01-1 1H4a1 1 0 01-1-1V4zM3 10a1 1 0 011-1h6a1 1 0 011 1v6a1 1 0 01-1 1H4a1 1 0 01-1-1v-6zM14 9a1 1 0 00-1 1v6a1 1 0 001 1h2a1 1 0 001-1v-6a1 1 0 00-1-1h-2z"/>
                            </svg>
                        </div>
                        <div class="ml-3">
                            <p class="text-sm text-gray-600 dark:text-gray-400">Pages vues</p>
                            <p class="text-xl font-bold text-gray-900 dark:text-white">
                                {{ number_format($realTimeMetrics['page_views_today'] ?? 0) }}
                            </p>
                        </div>
                    </div>
                </div>

                <div class="bg-orange-50 dark:bg-orange-900/20 p-4 rounded-lg">
                    <div class="flex items-center">
                        <div class="p-2 bg-orange-500 rounded-lg">
                            <svg class="w-5 h-5 text-white" fill="currentColor" viewBox="0 0 20 20">
                                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-12a1 1 0 10-2 0v4a1 1 0 00.293.707l2.828 2.829a1 1 0 101.415-1.415L11 9.586V6z" clip-rule="evenodd"/>
                            </svg>
                        </div>
                        <div class="ml-3">
                            <p class="text-sm text-gray-600 dark:text-gray-400">Durée moy.</p>
                            <p class="text-xl font-bold text-gray-900 dark:text-white">
                                {{ round($realTimeMetrics['avg_session_duration_today'] ?? 0, 1) }}min
                            </p>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        {{-- Grille principale --}}
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
            
            {{-- Colonne gauche: Métriques utilisateurs --}}
            <div class="lg:col-span-1">
                <div class="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700 p-6">
                    <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-4">
                        👥 Utilisateurs
                    </h3>
                    
                    @if(!empty($appStats['overview']))
                    <div class="space-y-4">
                        <div class="flex justify-between items-center">
                            <span class="text-sm text-gray-600 dark:text-gray-400">Total</span>
                            <span class="text-lg font-bold text-gray-900 dark:text-white">
                                {{ number_format($appStats['overview']['total_users']) }}
                            </span>
                        </div>
                        <div class="flex justify-between items-center">
                            <span class="text-sm text-gray-600 dark:text-gray-400">Actifs (30j)</span>
                            <span class="text-lg font-semibold text-blue-600 dark:text-blue-400">
                                {{ number_format($appStats['overview']['active_users_30d']) }}
                            </span>
                        </div>
                        <div class="flex justify-between items-center">
                            <span class="text-sm text-gray-600 dark:text-gray-400">Actifs (7j)</span>
                            <span class="text-lg font-semibold text-green-600 dark:text-green-400">
                                {{ number_format($appStats['overview']['active_users_7d']) }}
                            </span>
                        </div>
                        <div class="flex justify-between items-center">
                            <span class="text-sm text-gray-600 dark:text-gray-400">Actifs (24h)</span>
                            <span class="text-lg font-semibold text-purple-600 dark:text-purple-400">
                                {{ number_format($appStats['overview']['active_users_1d']) }}
                            </span>
                        </div>
                        
                        @if(isset($appStats['overview']['growth_rate']) && $appStats['overview']['growth_rate'] > 0)
                        <div class="mt-4 p-3 bg-green-50 dark:bg-green-900/20 rounded-lg">
                            <div class="flex items-center">
                                <svg class="w-4 h-4 text-green-500 mr-2" fill="currentColor" viewBox="0 0 20 20">
                                    <path fill-rule="evenodd" d="M3.293 9.707a1 1 0 010-1.414l6-6a1 1 0 011.414 0l6 6a1 1 0 01-1.414 1.414L11 5.414V17a1 1 0 11-2 0V5.414L4.707 9.707a1 1 0 01-1.414 0z" clip-rule="evenodd"/>
                                </svg>
                                <span class="text-sm font-medium text-green-800 dark:text-green-200">
                                    +{{ round($appStats['overview']['growth_rate'] * 100, 1) }}% ce mois
                                </span>
                            </div>
                        </div>
                        @endif
                    </div>
                    @endif
                </div>

                {{-- Plateformes --}}
                @if(!empty($platformStats))
                <div class="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700 p-6 mt-6">
                    <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-4">
                        📱 Plateformes
                    </h3>
                    <div class="space-y-3">
                        @foreach($platformStats as $platform => $stats)
                        <div class="flex items-center justify-between">
                            <div class="flex items-center">
                                <div class="w-8 h-2 bg-gradient-to-r from-blue-400 to-blue-600 rounded mr-3" 
                                     style="width: {{ $stats['percentage'] }}%"></div>
                                <span class="text-sm font-medium text-gray-700 dark:text-gray-300 capitalize">
                                    {{ $platform }}
                                </span>
                            </div>
                            <div class="text-right">
                                <div class="text-sm font-bold text-gray-900 dark:text-white">
                                    {{ $stats['percentage'] }}%
                                </div>
                                <div class="text-xs text-gray-500 dark:text-gray-400">
                                    {{ number_format($stats['users']) }} utilisateurs
                                </div>
                            </div>
                        </div>
                        @endforeach
                    </div>
                </div>
                @endif
            </div>

            {{-- Colonne centrale: Contenu populaire --}}
            <div class="lg:col-span-1">
                @if(!empty($contentStats['top_content']))
                <div class="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700 p-6">
                    <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-4">
                        🔥 Contenu Populaire
                    </h3>
                    <div class="space-y-4">
                        @foreach(array_slice($contentStats['top_content'], 0, 5) as $content)
                        <div class="flex items-center justify-between p-3 bg-gray-50 dark:bg-gray-700 rounded-lg">
                            <div class="flex-1 min-w-0">
                                <p class="text-sm font-medium text-gray-900 dark:text-white truncate">
                                    {{ $content['title'] }}
                                </p>
                                <div class="flex items-center mt-1">
                                    @switch($content['type'])
                                        @case('recipe')
                                            <span class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200">
                                                🍽️ Recette
                                            </span>
                                            @break
                                        @case('tip')
                                            <span class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200">
                                                💡 Astuce
                                            </span>
                                            @break
                                        @case('event')
                                            <span class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-purple-100 text-purple-800 dark:bg-purple-900 dark:text-purple-200">
                                                📅 Événement
                                            </span>
                                            @break
                                        @case('video')
                                            <span class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200">
                                                🎥 Vidéo
                                            </span>
                                            @break
                                    @endswitch
                                </div>
                            </div>
                            <div class="text-right ml-4">
                                <p class="text-lg font-bold text-gray-900 dark:text-white">
                                    {{ number_format($content['views']) }}
                                </p>
                                <p class="text-xs text-gray-500 dark:text-gray-400">vues</p>
                            </div>
                        </div>
                        @endforeach
                    </div>
                </div>
                @endif

                {{-- Pages les plus visitées --}}
                @if(!empty($contentStats['top_pages']))
                <div class="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700 p-6 mt-6">
                    <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-4">
                        📊 Pages Populaires
                    </h3>
                    <div class="space-y-3">
                        @foreach(array_slice($contentStats['top_pages'], 0, 5) as $page)
                        <div class="flex justify-between items-center">
                            <span class="text-sm font-medium text-gray-700 dark:text-gray-300">
                                {{ $page['page'] }}
                            </span>
                            <div class="text-right">
                                <div class="text-sm font-bold text-gray-900 dark:text-white">
                                    {{ number_format($page['views']) }}
                                </div>
                                <div class="text-xs text-gray-500 dark:text-gray-400">
                                    {{ number_format($page['unique_views']) }} uniques
                                </div>
                            </div>
                        </div>
                        @endforeach
                    </div>
                </div>
                @endif
            </div>

            {{-- Colonne droite: Engagement et géographie --}}
            <div class="lg:col-span-1">
                @if(!empty($contentStats['engagement']))
                <div class="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700 p-6">
                    <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-4">
                        ❤️ Engagement
                    </h3>
                    <div class="space-y-4">
                        <div class="flex justify-between items-center">
                            <span class="text-sm text-gray-600 dark:text-gray-400">Total likes</span>
                            <span class="text-lg font-bold text-red-600 dark:text-red-400">
                                {{ number_format($contentStats['engagement']['total_likes']) }}
                            </span>
                        </div>
                        <div class="flex justify-between items-center">
                            <span class="text-sm text-gray-600 dark:text-gray-400">Total partages</span>
                            <span class="text-lg font-bold text-blue-600 dark:text-blue-400">
                                {{ number_format($contentStats['engagement']['total_shares']) }}
                            </span>
                        </div>
                        <div class="flex justify-between items-center">
                            <span class="text-sm text-gray-600 dark:text-gray-400">Commentaires</span>
                            <span class="text-lg font-bold text-green-600 dark:text-green-400">
                                {{ number_format($contentStats['engagement']['total_comments']) }}
                            </span>
                        </div>
                        <div class="flex justify-between items-center">
                            <span class="text-sm text-gray-600 dark:text-gray-400">Favoris</span>
                            <span class="text-lg font-bold text-purple-600 dark:text-purple-400">
                                {{ number_format($contentStats['engagement']['total_favorites']) }}
                            </span>
                        </div>
                        <div class="pt-2 border-t border-gray-200 dark:border-gray-600">
                            <div class="flex justify-between items-center">
                                <span class="text-sm text-gray-600 dark:text-gray-400">Temps moyen</span>
                                <span class="text-lg font-bold text-orange-600 dark:text-orange-400">
                                    {{ round($contentStats['engagement']['avg_time_on_content'], 1) }}min
                                </span>
                            </div>
                        </div>
                    </div>
                </div>
                @endif

                {{-- Géographie --}}
                @if(!empty($geographicStats['countries']))
                <div class="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700 p-6 mt-6">
                    <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-4">
                        🌍 Géographie
                    </h3>
                    <div class="space-y-3">
                        @foreach(array_slice($geographicStats['countries'], 0, 5) as $country)
                        <div class="flex justify-between items-center">
                            <span class="text-sm font-medium text-gray-700 dark:text-gray-300">
                                {{ $country['country'] }}
                            </span>
                            <div class="text-right">
                                <div class="text-sm font-bold text-gray-900 dark:text-white">
                                    {{ number_format($country['users']) }}
                                </div>
                                <div class="text-xs text-gray-500 dark:text-gray-400">
                                    {{ number_format($country['sessions']) }} sessions
                                </div>
                            </div>
                        </div>
                        @endforeach
                    </div>
                </div>
                @endif
            </div>
        </div>

        {{-- Section événements temps réel --}}
        @if(!empty($realTimeMetrics['top_events_today']))
        <div class="mt-6 bg-gradient-to-r from-blue-50 to-purple-50 dark:from-blue-900/20 dark:to-purple-900/20 rounded-lg border border-blue-200 dark:border-blue-700 p-6">
            <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-4">
                ⚡ Événements Temps Réel (Aujourd'hui)
            </h3>
            <div class="grid grid-cols-2 md:grid-cols-5 gap-4">
                @foreach($realTimeMetrics['top_events_today'] as $event)
                <div class="text-center">
                    <div class="text-2xl font-bold text-blue-600 dark:text-blue-400">
                        {{ number_format($event['count']) }}
                    </div>
                    <div class="text-sm text-gray-600 dark:text-gray-400 capitalize">
                        {{ str_replace('_', ' ', $event['event']) }}
                    </div>
                </div>
                @endforeach
            </div>
        </div>
        @endif

        {{-- Footer avec informations sur les données --}}
        <div class="mt-6 pt-4 border-t border-gray-200 dark:border-gray-700">
            <div class="flex items-center justify-between text-xs text-gray-500 dark:text-gray-400">
                <div>
                    <span>📊 Données Firebase Analytics</span>
                    <span class="mx-2">•</span>
                    <span>Mise à jour automatique toutes les 5 minutes</span>
                </div>
                <div>
                    <span>Dernière actualisation: {{ now()->format('d/m/Y à H:i:s') }}</span>
                </div>
            </div>
        </div>
    </x-filament::section>
</x-filament-widgets::widget>