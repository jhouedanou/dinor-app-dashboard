@php
    $data = $this->getViewData();
@endphp

<x-filament-widgets::widget>
    <x-filament::section>
        <div class="space-y-6">
            <!-- Header Section -->
            <div class="text-center mb-6">
                <h2 class="text-2xl font-bold text-gray-900 dark:text-white mb-2">⚽ Pronostics en Temps Réel</h2>
                <p class="text-sm text-gray-600 dark:text-gray-400">Suivez l'activité des pronostics et les matchs en cours</p>
            </div>

            <!-- Stats Overview -->
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-4">
                <div class="bg-gradient-to-br from-blue-50 to-blue-100 dark:from-blue-900/20 dark:to-blue-800/20 rounded-xl p-4 border border-blue-200 dark:border-blue-700">
                    <div class="flex items-center">
                        <div class="p-3 bg-blue-500 rounded-xl shadow-lg">
                            <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"></path>
                            </svg>
                        </div>
                        <div class="ml-4">
                            <p class="text-sm font-medium text-blue-700 dark:text-blue-300">Aujourd'hui</p>
                            <p class="text-2xl font-bold text-blue-900 dark:text-blue-100">{{ number_format($data['predictionStats']['total_today']) }}</p>
                        </div>
                    </div>
                </div>

                <div class="bg-gradient-to-br from-green-50 to-green-100 dark:from-green-900/20 dark:to-green-800/20 rounded-xl p-4 border border-green-200 dark:border-green-700">
                    <div class="flex items-center">
                        <div class="p-3 bg-green-500 rounded-xl shadow-lg">
                            <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"></path>
                            </svg>
                        </div>
                        <div class="ml-4">
                            <p class="text-sm font-medium text-green-700 dark:text-green-300">Utilisateurs actifs</p>
                            <p class="text-2xl font-bold text-green-900 dark:text-green-100">{{ number_format($data['predictionStats']['active_users_today']) }}</p>
                        </div>
                    </div>
                </div>

                <div class="bg-gradient-to-br from-purple-50 to-purple-100 dark:from-purple-900/20 dark:to-purple-800/20 rounded-xl p-4 border border-purple-200 dark:border-purple-700">
                    <div class="flex items-center">
                        <div class="p-3 bg-purple-500 rounded-xl shadow-lg">
                            <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"></path>
                            </svg>
                        </div>
                        <div class="ml-4">
                            <p class="text-sm font-medium text-purple-700 dark:text-purple-300">Cette semaine</p>
                            <p class="text-2xl font-bold text-purple-900 dark:text-purple-100">{{ number_format($data['predictionStats']['total_week']) }}</p>
                        </div>
                    </div>
                </div>

                <div class="bg-gradient-to-br from-orange-50 to-orange-100 dark:from-orange-900/20 dark:to-orange-800/20 rounded-xl p-4 border border-orange-200 dark:border-orange-700">
                    <div class="flex items-center">
                        <div class="p-3 bg-orange-500 rounded-xl shadow-lg">
                            <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                            </svg>
                        </div>
                        <div class="ml-4">
                            <p class="text-sm font-medium text-orange-700 dark:text-orange-300">En attente</p>
                            <p class="text-2xl font-bold text-orange-900 dark:text-orange-100">{{ number_format($data['predictionStats']['pending_calculations']) }}</p>
                        </div>
                    </div>
                </div>

                <div class="bg-gradient-to-br from-indigo-50 to-indigo-100 dark:from-indigo-900/20 dark:to-indigo-800/20 rounded-xl p-4 border border-indigo-200 dark:border-indigo-700">
                    <div class="flex items-center">
                        <div class="p-3 bg-indigo-500 rounded-xl shadow-lg">
                            <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"></path>
                            </svg>
                        </div>
                        <div class="ml-4">
                            <p class="text-sm font-medium text-indigo-700 dark:text-indigo-300">Matchs actifs</p>
                            <p class="text-2xl font-bold text-indigo-900 dark:text-indigo-100">{{ number_format($data['predictionStats']['matches_with_predictions']) }}</p>
                        </div>
                    </div>
                </div>
            </div>

            <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
                <!-- Live Matches -->
                <div class="bg-white dark:bg-gray-800 rounded-xl border border-gray-200 dark:border-gray-700 shadow-sm">
                    <div class="px-6 py-4 border-b border-gray-200 dark:border-gray-700 bg-gradient-to-r from-red-50 to-pink-50 dark:from-red-900/20 dark:to-pink-900/20 rounded-t-xl">
                        <div class="flex items-center">
                            <div class="w-3 h-3 bg-red-500 rounded-full mr-3 animate-pulse shadow-lg"></div>
                            <h3 class="text-lg font-semibold text-gray-900 dark:text-white">🔴 Matchs en Direct</h3>
                            <span class="ml-auto text-xs bg-red-100 text-red-700 px-2 py-1 rounded-full">LIVE</span>
                        </div>
                    </div>
                    <div class="p-6">
                        @if(count($data['activeMatches']) > 0)
                            <div class="space-y-4">
                                @foreach($data['activeMatches'] as $matchData)
                                    @php $match = $matchData['match']; @endphp
                                    <div class="border border-gray-200 dark:border-gray-600 rounded-lg p-4 bg-gradient-to-r from-gray-50 to-white dark:from-gray-700 dark:to-gray-800">
                                        <div class="flex justify-between items-start mb-3">
                                            <div>
                                                <h4 class="font-semibold text-gray-900 dark:text-white">
                                                    {{ $match->homeTeam->short_name ?? $match->homeTeam->name }} vs 
                                                    {{ $match->awayTeam->short_name ?? $match->awayTeam->name }}
                                                </h4>
                                                <p class="text-sm text-gray-600 dark:text-gray-400">🏆 {{ $match->tournament->name ?? 'Match amical' }}</p>
                                            </div>
                                            <span class="px-3 py-1 bg-red-100 text-red-800 rounded-full text-xs font-medium animate-pulse">🔴 LIVE</span>
                                        </div>
                                        
                                        <div class="grid grid-cols-3 gap-4 text-center">
                                            <div class="bg-blue-50 dark:bg-blue-900/30 rounded-lg p-3 border border-blue-200 dark:border-blue-700">
                                                <div class="text-xl font-bold text-blue-600 dark:text-blue-400">{{ $matchData['predictions_breakdown']['home'] }}</div>
                                                <div class="text-xs text-gray-600 dark:text-gray-400">🏠 Domicile</div>
                                            </div>
                                            <div class="bg-gray-50 dark:bg-gray-700 rounded-lg p-3 border border-gray-200 dark:border-gray-600">
                                                <div class="text-xl font-bold text-gray-600 dark:text-gray-300">{{ $matchData['predictions_breakdown']['draw'] }}</div>
                                                <div class="text-xs text-gray-600 dark:text-gray-400">🤝 Nul</div>
                                            </div>
                                            <div class="bg-green-50 dark:bg-green-900/30 rounded-lg p-3 border border-green-200 dark:border-green-700">
                                                <div class="text-xl font-bold text-green-600 dark:text-green-400">{{ $matchData['predictions_breakdown']['away'] }}</div>
                                                <div class="text-xs text-gray-600 dark:text-gray-400">✈️ Extérieur</div>
                                            </div>
                                        </div>
                                        
                                        @if($matchData['popular_prediction'])
                                            <div class="mt-3 text-center bg-yellow-50 dark:bg-yellow-900/20 rounded-lg p-2">
                                                <span class="text-sm text-gray-600 dark:text-gray-400">⭐ Score populaire: </span>
                                                <span class="font-semibold text-yellow-700 dark:text-yellow-300">{{ $matchData['popular_prediction']['score'] }}</span>
                                                <span class="text-xs text-gray-500 dark:text-gray-400">({{ $matchData['popular_prediction']['percentage'] }}%)</span>
                                            </div>
                                        @endif
                                    </div>
                                @endforeach
                            </div>
                        @else
                            <div class="text-center py-12">
                                <div class="bg-gray-100 dark:bg-gray-700 rounded-full w-20 h-20 flex items-center justify-center mx-auto mb-4">
                                    <svg class="w-10 h-10 text-gray-400 dark:text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z"></path>
                                    </svg>
                                </div>
                                <h3 class="text-lg font-medium text-gray-900 dark:text-white mb-2">🎯 Aucun match en direct</h3>
                                <p class="text-sm text-gray-500 dark:text-gray-400 max-w-sm mx-auto">
                                    Les matchs en cours avec des pronostics actifs apparaîtront ici en temps réel. 
                                    <span class="block mt-1 text-xs">⚡ Mise à jour automatique toutes les 30 secondes</span>
                                </p>
                            </div>
                        @endif
                    </div>
                </div>

                <!-- Upcoming Matches -->
                <div class="bg-white dark:bg-gray-800 rounded-xl border border-gray-200 dark:border-gray-700 shadow-sm">
                    <div class="px-6 py-4 border-b border-gray-200 dark:border-gray-700 bg-gradient-to-r from-blue-50 to-indigo-50 dark:from-blue-900/20 dark:to-indigo-900/20 rounded-t-xl">
                        <div class="flex items-center">
                            <div class="w-3 h-3 bg-blue-500 rounded-full mr-3 animate-bounce"></div>
                            <h3 class="text-lg font-semibold text-gray-900 dark:text-white">⏰ Prochains Matchs (24h)</h3>
                        </div>
                    </div>
                    <div class="p-6 max-h-96 overflow-y-auto">
                        @if(count($data['upcomingMatches']) > 0)
                            <div class="space-y-4">
                                @foreach($data['upcomingMatches'] as $matchData)
                                    @php $match = $matchData['match']; @endphp
                                    <div class="border border-gray-200 dark:border-gray-600 rounded-lg p-4 bg-gradient-to-r from-blue-50 to-indigo-50 dark:from-blue-900/20 dark:to-indigo-900/20 hover:shadow-md transition-shadow">
                                        <div class="flex justify-between items-start mb-2">
                                            <div>
                                                <h4 class="font-semibold text-gray-900 dark:text-white">
                                                    ⚽ {{ $match->homeTeam->short_name ?? $match->homeTeam->name }} vs 
                                                    {{ $match->awayTeam->short_name ?? $match->awayTeam->name }}
                                                </h4>
                                                <p class="text-sm text-gray-600 dark:text-gray-400">📅 {{ $match->match_date->format('d/m H:i') }}</p>
                                            </div>
                                            <div class="text-right">
                                                <div class="text-sm font-medium text-blue-600 dark:text-blue-400">📊 {{ $matchData['predictions_count'] }} pronostics</div>
                                                <div class="text-xs text-orange-600 dark:text-orange-400 bg-orange-100 dark:bg-orange-900/30 px-2 py-1 rounded">
                                                    ⏳ Ferme dans {{ $matchData['time_until_closure'] }}
                                                </div>
                                            </div>
                                        </div>
                                        
                                        @if($matchData['popular_prediction'])
                                            <div class="text-center mt-3 bg-white dark:bg-gray-700 rounded-lg p-2 border border-gray-200 dark:border-gray-600">
                                                <span class="text-xs text-gray-600 dark:text-gray-400">🔥 Tendance: </span>
                                                <span class="text-sm font-semibold text-green-600 dark:text-green-400">{{ $matchData['popular_prediction']['score'] }}</span>
                                                <span class="text-xs text-gray-500 dark:text-gray-400">({{ $matchData['popular_prediction']['count'] }} votes)</span>
                                            </div>
                                        @endif
                                    </div>
                                @endforeach
                            </div>
                        @else
                            <div class="text-center py-12">
                                <div class="bg-blue-100 dark:bg-blue-900/30 rounded-full w-20 h-20 flex items-center justify-center mx-auto mb-4">
                                    <svg class="w-10 h-10 text-blue-500 dark:text-blue-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                                    </svg>
                                </div>
                                <h3 class="text-lg font-medium text-gray-900 dark:text-white mb-2">📋 Aucun match programmé</h3>
                                <p class="text-sm text-gray-500 dark:text-gray-400 max-w-sm mx-auto">
                                    Les matchs prévus dans les prochaines 24 heures s'afficheront ici. 
                                    <span class="block mt-1 text-xs">🎯 Vous pourrez suivre les tendances des pronostics</span>
                                </p>
                            </div>
                        @endif
                    </div>
                </div>
            </div>

            <!-- Recent Matches & Tournaments -->
            <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
                <!-- Recent Matches -->
                <div class="bg-white dark:bg-gray-800 rounded-xl border border-gray-200 dark:border-gray-700 shadow-sm">
                    <div class="px-6 py-4 border-b border-gray-200 dark:border-gray-700 bg-gradient-to-r from-green-50 to-emerald-50 dark:from-green-900/20 dark:to-emerald-900/20 rounded-t-xl">
                        <h3 class="text-lg font-semibold text-gray-900 dark:text-white">✅ Matchs Récents</h3>
                    </div>
                    <div class="p-6">
                        @if(count($data['recentMatches']) > 0)
                            <div class="space-y-4">
                                @foreach($data['recentMatches'] as $matchData)
                                    @php $match = $matchData['match']; @endphp
                                    <div class="border border-gray-200 dark:border-gray-600 rounded-lg p-4 bg-gradient-to-r from-green-50 to-emerald-50 dark:from-green-900/20 dark:to-emerald-900/20">
                                        <div class="flex justify-between items-start mb-2">
                                            <div>
                                                <h4 class="font-semibold text-gray-900 dark:text-white">
                                                    🏁 {{ $match->homeTeam->short_name ?? $match->homeTeam->name }} 
                                                    @if($match->home_score !== null && $match->away_score !== null)
                                                        <span class="text-green-600 dark:text-green-400 font-bold">{{ $match->home_score }}-{{ $match->away_score }}</span>
                                                    @endif
                                                    {{ $match->awayTeam->short_name ?? $match->awayTeam->name }}
                                                </h4>
                                                <p class="text-sm text-gray-600 dark:text-gray-400">📅 {{ $match->match_date->format('d/m H:i') }}</p>
                                            </div>
                                            <div class="text-right">
                                                <div class="text-sm font-medium text-green-600 dark:text-green-400">
                                                    📊 {{ $matchData['predictions_count'] }} pronostics
                                                </div>
                                                @if(isset($matchData['accuracy_rate']) && $matchData['accuracy_rate'] > 0)
                                                    <div class="text-xs text-purple-600 dark:text-purple-400">
                                                        🎯 {{ number_format($matchData['accuracy_rate'], 1) }}% de réussite
                                                    </div>
                                                @endif
                                            </div>
                                        </div>
                                    </div>
                                @endforeach
                            </div>
                        @else
                            <div class="text-center py-12">
                                <div class="bg-green-100 dark:bg-green-900/30 rounded-full w-20 h-20 flex items-center justify-center mx-auto mb-4">
                                    <svg class="w-10 h-10 text-green-500 dark:text-green-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                                    </svg>
                                </div>
                                <h3 class="text-lg font-medium text-gray-900 dark:text-white mb-2">📈 Aucun match récent</h3>
                                <p class="text-sm text-gray-500 dark:text-gray-400 max-w-sm mx-auto">
                                    Les matchs terminés dans les dernières 24 heures apparaîtront ici.
                                    <span class="block mt-1 text-xs">🏆 Avec les statistiques de réussite des pronostics</span>
                                </p>
                            </div>
                        @endif
                    </div>
                </div>

                <!-- Active Tournaments -->
                <div class="bg-white dark:bg-gray-800 rounded-xl border border-gray-200 dark:border-gray-700 shadow-sm">
                    <div class="px-6 py-4 border-b border-gray-200 dark:border-gray-700 bg-gradient-to-r from-purple-50 to-pink-50 dark:from-purple-900/20 dark:to-pink-900/20 rounded-t-xl">
                        <h3 class="text-lg font-semibold text-gray-900 dark:text-white">🏆 Tournois Actifs</h3>
                    </div>
                    <div class="p-6">
                        @if(count($data['tournaments']) > 0)
                            <div class="space-y-4">
                                @foreach($data['tournaments'] as $tournamentData)
                                    @php $tournament = $tournamentData['tournament']; @endphp
                                    <div class="border border-gray-200 dark:border-gray-600 rounded-lg p-4 bg-gradient-to-r from-purple-50 to-pink-50 dark:from-purple-900/20 dark:to-pink-900/20">
                                        <div class="flex justify-between items-start">
                                            <div>
                                                <h4 class="font-semibold text-gray-900 dark:text-white">
                                                    🏆 {{ $tournament->name }}
                                                </h4>
                                                <p class="text-sm text-gray-600 dark:text-gray-400">
                                                    📊 {{ $tournamentData['matches_count'] }} matchs • 
                                                    👥 {{ $tournamentData['predictions_count'] }} pronostics
                                                </p>
                                            </div>
                                            <div class="text-right">
                                                <div class="text-sm font-medium text-purple-600 dark:text-purple-400">
                                                    📈 {{ $tournamentData['completion_rate'] }}% complété
                                                </div>
                                                @if($tournamentData['average_predictions_per_match'] > 0)
                                                    <div class="text-xs text-gray-500 dark:text-gray-400">
                                                        ⚡ {{ $tournamentData['average_predictions_per_match'] }} pronostics/match
                                                    </div>
                                                @endif
                                            </div>
                                        </div>
                                    </div>
                                @endforeach
                            </div>
                        @else
                            <div class="text-center py-12">
                                <div class="bg-purple-100 dark:bg-purple-900/30 rounded-full w-20 h-20 flex items-center justify-center mx-auto mb-4">
                                    <svg class="w-10 h-10 text-purple-500 dark:text-purple-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1"></path>
                                    </svg>
                                </div>
                                <h3 class="text-lg font-medium text-gray-900 dark:text-white mb-2">🎯 Aucun tournoi actif</h3>
                                <p class="text-sm text-gray-500 dark:text-gray-400 max-w-sm mx-auto">
                                    Les compétitions et tournois en cours s'afficheront ici.
                                    <span class="block mt-1 text-xs">⚡ Avec le suivi de progression en temps réel</span>
                                </p>
                            </div>
                        @endif
                    </div>
                </div>
            </div>
        </div>
    </x-filament::section>
</x-filament-widgets::widget> 