@php
    $data = $this->getViewData();
@endphp

<x-filament-widgets::widget>
    <x-filament::section>
        <div class="space-y-6">
            <!-- Stats Overview -->
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-4">
                <div class="bg-primary-50 rounded-lg p-4">
                    <div class="flex items-center">
                        <div class="p-2 bg-primary-500 rounded-lg">
                            <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"></path>
                            </svg>
                        </div>
                        <div class="ml-4">
                            <p class="text-sm font-medium text-gray-600">Aujourd'hui</p>
                            <p class="text-2xl font-bold text-gray-900">{{ number_format($data['predictionStats']['total_today']) }}</p>
                        </div>
                    </div>
                </div>

                <div class="bg-green-50 rounded-lg p-4">
                    <div class="flex items-center">
                        <div class="p-2 bg-green-500 rounded-lg">
                            <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"></path>
                            </svg>
                        </div>
                        <div class="ml-4">
                            <p class="text-sm font-medium text-gray-600">Utilisateurs actifs</p>
                            <p class="text-2xl font-bold text-gray-900">{{ number_format($data['predictionStats']['active_users_today']) }}</p>
                        </div>
                    </div>
                </div>

                <div class="bg-blue-50 rounded-lg p-4">
                    <div class="flex items-center">
                        <div class="p-2 bg-blue-500 rounded-lg">
                            <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"></path>
                            </svg>
                        </div>
                        <div class="ml-4">
                            <p class="text-sm font-medium text-gray-600">Cette semaine</p>
                            <p class="text-2xl font-bold text-gray-900">{{ number_format($data['predictionStats']['total_week']) }}</p>
                        </div>
                    </div>
                </div>

                <div class="bg-yellow-50 rounded-lg p-4">
                    <div class="flex items-center">
                        <div class="p-2 bg-yellow-500 rounded-lg">
                            <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                            </svg>
                        </div>
                        <div class="ml-4">
                            <p class="text-sm font-medium text-gray-600">En attente calcul</p>
                            <p class="text-2xl font-bold text-gray-900">{{ number_format($data['predictionStats']['pending_calculations']) }}</p>
                        </div>
                    </div>
                </div>

                <div class="bg-purple-50 rounded-lg p-4">
                    <div class="flex items-center">
                        <div class="p-2 bg-purple-500 rounded-lg">
                            <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"></path>
                            </svg>
                        </div>
                        <div class="ml-4">
                            <p class="text-sm font-medium text-gray-600">Matchs actifs</p>
                            <p class="text-2xl font-bold text-gray-900">{{ number_format($data['predictionStats']['matches_with_predictions']) }}</p>
                        </div>
                    </div>
                </div>
            </div>

            <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
                <!-- Live Matches -->
                <div class="bg-white rounded-lg border border-gray-200">
                    <div class="px-6 py-4 border-b border-gray-200">
                        <div class="flex items-center">
                            <div class="w-3 h-3 bg-red-500 rounded-full mr-3 animate-pulse"></div>
                            <h3 class="text-lg font-semibold text-gray-900">Matchs en cours</h3>
                        </div>
                    </div>
                    <div class="p-6">
                        @if(count($data['activeMatches']) > 0)
                            <div class="space-y-4">
                                @foreach($data['activeMatches'] as $matchData)
                                    @php $match = $matchData['match']; @endphp
                                    <div class="border border-gray-200 rounded-lg p-4">
                                        <div class="flex justify-between items-start mb-3">
                                            <div>
                                                <h4 class="font-semibold text-gray-900">
                                                    {{ $match->homeTeam->short_name ?? $match->homeTeam->name }} vs 
                                                    {{ $match->awayTeam->short_name ?? $match->awayTeam->name }}
                                                </h4>
                                                <p class="text-sm text-gray-600">{{ $match->tournament->name ?? 'Match amical' }}</p>
                                            </div>
                                            <span class="px-2 py-1 bg-red-100 text-red-800 rounded-full text-xs font-medium">LIVE</span>
                                        </div>
                                        
                                        <div class="grid grid-cols-3 gap-4 text-center">
                                            <div class="bg-blue-50 rounded p-2">
                                                <div class="text-lg font-bold text-blue-600">{{ $matchData['predictions_breakdown']['home'] }}</div>
                                                <div class="text-xs text-gray-600">Domicile</div>
                                            </div>
                                            <div class="bg-gray-50 rounded p-2">
                                                <div class="text-lg font-bold text-gray-600">{{ $matchData['predictions_breakdown']['draw'] }}</div>
                                                <div class="text-xs text-gray-600">Nul</div>
                                            </div>
                                            <div class="bg-green-50 rounded p-2">
                                                <div class="text-lg font-bold text-green-600">{{ $matchData['predictions_breakdown']['away'] }}</div>
                                                <div class="text-xs text-gray-600">Extérieur</div>
                                            </div>
                                        </div>
                                        
                                        @if($matchData['popular_prediction'])
                                            <div class="mt-3 text-center">
                                                <span class="text-sm text-gray-600">Score populaire: </span>
                                                <span class="font-semibold">{{ $matchData['popular_prediction']['score'] }}</span>
                                                <span class="text-xs text-gray-500">({{ $matchData['popular_prediction']['percentage'] }}%)</span>
                                            </div>
                                        @endif
                                    </div>
                                @endforeach
                            </div>
                        @else
                            <div class="text-center py-8">
                                <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.172 16.172a4 4 0 015.656 0M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                                </svg>
                                <h3 class="mt-2 text-sm font-medium text-gray-900">Aucun match en cours</h3>
                                <p class="mt-1 text-sm text-gray-500">Les matchs en direct apparaîtront ici.</p>
                            </div>
                        @endif
                    </div>
                </div>

                <!-- Upcoming Matches -->
                <div class="bg-white rounded-lg border border-gray-200">
                    <div class="px-6 py-4 border-b border-gray-200">
                        <h3 class="text-lg font-semibold text-gray-900">Prochains matchs (24h)</h3>
                    </div>
                    <div class="p-6 max-h-96 overflow-y-auto">
                        @if(count($data['upcomingMatches']) > 0)
                            <div class="space-y-4">
                                @foreach($data['upcomingMatches'] as $matchData)
                                    @php $match = $matchData['match']; @endphp
                                    <div class="border border-gray-200 rounded-lg p-4">
                                        <div class="flex justify-between items-start mb-2">
                                            <div>
                                                <h4 class="font-semibold text-gray-900">
                                                    {{ $match->homeTeam->short_name ?? $match->homeTeam->name }} vs 
                                                    {{ $match->awayTeam->short_name ?? $match->awayTeam->name }}
                                                </h4>
                                                <p class="text-sm text-gray-600">{{ $match->match_date->format('d/m H:i') }}</p>
                                            </div>
                                            <div class="text-right">
                                                <div class="text-sm font-medium text-gray-900">{{ $matchData['predictions_count'] }} pronostics</div>
                                                <div class="text-xs text-gray-500">Ferme dans {{ $matchData['time_until_closure'] }}</div>
                                            </div>
                                        </div>
                                        
                                        @if($matchData['popular_prediction'])
                                            <div class="text-center mt-2">
                                                <span class="text-xs text-gray-600">Tendance: </span>
                                                <span class="text-sm font-semibold">{{ $matchData['popular_prediction']['score'] }}</span>
                                                <span class="text-xs text-gray-500">({{ $matchData['popular_prediction']['count'] }} votes)</span>
                                            </div>
                                        @endif
                                    </div>
                                @endforeach
                            </div>
                        @else
                            <div class="text-center py-8">
                                <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                                </svg>
                                <h3 class="mt-2 text-sm font-medium text-gray-900">Aucun match à venir</h3>
                                <p class="mt-1 text-sm text-gray-500">Les prochains matchs apparaîtront ici.</p>
                            </div>
                        @endif
                    </div>
                </div>
            </div>

            <!-- Recent Matches & Tournaments -->
            <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
                <!-- Recent Matches -->
                <div class="bg-white rounded-lg border border-gray-200">
                    <div class="px-6 py-4 border-b border-gray-200">
                        <h3 class="text-lg font-semibold text-gray-900">Matchs récents</h3>
                    </div>
                    <div class="p-6">
                        @if(count($data['recentMatches']) > 0)
                            <div class="space-y-4">
                                @foreach($data['recentMatches'] as $matchData)
                                    @php $match = $matchData['match']; @endphp
                                    <div class="border border-gray-200 rounded-lg p-4">
                                        <div class="flex justify-between items-start mb-2">
                                            <div>
                                                <h4 class="font-semibold text-gray-900">
                                                    {{ $match->homeTeam->short_name ?? $match->homeTeam->name }} 
                                                    {{ $match->home_score }}-{{ $match->away_score }}
                                                    {{ $match->awayTeam->short_name ?? $match->awayTeam->name }}
                                                </h4>
                                                <p class="text-sm text-gray-600">{{ $match->match_date->format('d/m H:i') }}</p>
                                            </div>
                                            <span class="px-2 py-1 bg-green-100 text-green-800 rounded-full text-xs font-medium">TERMINÉ</span>
                                        </div>
                                        
                                        <div class="grid grid-cols-3 gap-4 text-center text-sm">
                                            <div>
                                                <div class="font-medium text-gray-900">{{ $matchData['predictions_count'] }}</div>
                                                <div class="text-gray-600">Pronostics</div>
                                            </div>
                                            <div>
                                                <div class="font-medium text-green-600">{{ $matchData['correct_predictions']['exact'] }}</div>
                                                <div class="text-gray-600">Scores exacts</div>
                                            </div>
                                            <div>
                                                <div class="font-medium text-blue-600">{{ $matchData['accuracy_rate'] }}%</div>
                                                <div class="text-gray-600">Précision</div>
                                            </div>
                                        </div>
                                    </div>
                                @endforeach
                            </div>
                        @else
                            <div class="text-center py-8">
                                <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                                </svg>
                                <h3 class="mt-2 text-sm font-medium text-gray-900">Aucun match récent</h3>
                            </div>
                        @endif
                    </div>
                </div>

                <!-- Active Tournaments -->
                <div class="bg-white rounded-lg border border-gray-200">
                    <div class="px-6 py-4 border-b border-gray-200">
                        <h3 class="text-lg font-semibold text-gray-900">Tournois actifs</h3>
                    </div>
                    <div class="p-6">
                        @if(count($data['tournaments']) > 0)
                            <div class="space-y-4">
                                @foreach($data['tournaments'] as $tournamentData)
                                    @php $tournament = $tournamentData['tournament']; @endphp
                                    <div class="border border-gray-200 rounded-lg p-4">
                                        <div class="flex justify-between items-start mb-3">
                                            <div>
                                                <h4 class="font-semibold text-gray-900">{{ $tournament->name }}</h4>
                                                <span class="px-2 py-1 bg-blue-100 text-blue-800 rounded-full text-xs font-medium">
                                                    {{ $tournament->status_label }}
                                                </span>
                                            </div>
                                            <div class="text-right text-sm">
                                                <div class="font-medium text-gray-900">{{ $tournamentData['completion_rate'] }}%</div>
                                                <div class="text-gray-600">Complété</div>
                                            </div>
                                        </div>
                                        
                                        <div class="grid grid-cols-3 gap-4 text-center text-sm">
                                            <div>
                                                <div class="font-medium text-gray-900">{{ number_format($tournament->participants_count) }}</div>
                                                <div class="text-gray-600">Participants</div>
                                            </div>
                                            <div>
                                                <div class="font-medium text-blue-600">{{ $tournamentData['matches_count'] }}</div>
                                                <div class="text-gray-600">Matchs</div>
                                            </div>
                                            <div>
                                                <div class="font-medium text-green-600">{{ $tournamentData['average_predictions_per_match'] }}</div>
                                                <div class="text-gray-600">Moy. prono.</div>
                                            </div>
                                        </div>
                                    </div>
                                @endforeach
                            </div>
                        @else
                            <div class="text-center py-8">
                                <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"></path>
                                </svg>
                                <h3 class="mt-2 text-sm font-medium text-gray-900">Aucun tournoi actif</h3>
                            </div>
                        @endif
                    </div>
                </div>
            </div>
        </div>
    </x-filament::section>
</x-filament-widgets::widget> 