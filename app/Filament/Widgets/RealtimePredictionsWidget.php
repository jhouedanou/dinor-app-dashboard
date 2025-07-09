<?php

namespace App\Filament\Widgets;

use App\Models\FootballMatch;
use App\Models\Prediction;
use App\Models\Tournament;
use Filament\Widgets\Widget;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class RealtimePredictionsWidget extends Widget
{
    protected static string $view = 'filament.widgets.realtime-predictions';
    
    protected static ?int $sort = 1;
    
    protected static ?string $heading = 'Pronostics en temps réel';
    
    protected int | string | array $columnSpan = 'full';
    
    // Refresh every 30 seconds
    protected static ?string $pollingInterval = '30s';

    public function getViewData(): array
    {
        return [
            'activeMatches' => $this->getActiveMatches(),
            'upcomingMatches' => $this->getUpcomingMatches(),
            'recentMatches' => $this->getRecentMatches(),
            'predictionStats' => $this->getPredictionStats(),
            'tournaments' => $this->getActiveTournaments()
        ];
    }

    private function getActiveMatches(): array
    {
        return FootballMatch::with(['homeTeam', 'awayTeam', 'tournament'])
            ->where('status', 'live')
            ->where('is_active', true)
            ->orderBy('match_date')
            ->get()
            ->map(function ($match) {
                return [
                    'match' => $match,
                    'predictions_count' => $this->getMatchPredictionsCount($match->id),
                    'predictions_breakdown' => $this->getMatchPredictionsBreakdown($match->id),
                    'popular_prediction' => $this->getMostPopularPrediction($match->id)
                ];
            })
            ->toArray();
    }

    private function getUpcomingMatches(): array
    {
        return FootballMatch::with(['homeTeam', 'awayTeam', 'tournament'])
            ->where('status', 'scheduled')
            ->where('match_date', '>', now())
            ->where('match_date', '<=', now()->addHours(24))
            ->where('is_active', true)
            ->orderBy('match_date')
            ->get()
            ->map(function ($match) {
                return [
                    'match' => $match,
                    'predictions_count' => $this->getMatchPredictionsCount($match->id),
                    'predictions_breakdown' => $this->getMatchPredictionsBreakdown($match->id),
                    'popular_prediction' => $this->getMostPopularPrediction($match->id),
                    'time_until_closure' => $this->getTimeUntilClosure($match)
                ];
            })
            ->toArray();
    }

    private function getRecentMatches(): array
    {
        return FootballMatch::with(['homeTeam', 'awayTeam', 'tournament'])
            ->where('status', 'finished')
            ->where('match_date', '>=', now()->subHours(24))
            ->where('is_active', true)
            ->orderByDesc('match_date')
            ->limit(5)
            ->get()
            ->map(function ($match) {
                return [
                    'match' => $match,
                    'predictions_count' => $this->getMatchPredictionsCount($match->id),
                    'correct_predictions' => $this->getCorrectPredictions($match->id),
                    'accuracy_rate' => $this->getMatchAccuracy($match->id)
                ];
            })
            ->toArray();
    }

    private function getPredictionStats(): array
    {
        $today = Carbon::today();
        
        return [
            'total_today' => Prediction::whereDate('created_at', $today)->count(),
            'total_week' => Prediction::where('created_at', '>=', $today->copy()->subDays(7))->count(),
            'active_users_today' => Prediction::whereDate('created_at', $today)
                ->distinct('user_id')
                ->count('user_id'),
            'pending_calculations' => Prediction::where('is_calculated', false)
                ->whereHas('footballMatch', function ($query) {
                    $query->where('status', 'finished');
                })
                ->count(),
            'matches_with_predictions' => FootballMatch::whereHas('predictions')
                ->where('match_date', '>=', $today)
                ->count()
        ];
    }

    private function getActiveTournaments(): array
    {
        return Tournament::with(['matches' => function ($query) {
                $query->where('is_active', true)
                    ->where('match_date', '>=', now()->subDays(1));
            }])
            ->whereIn('status', ['registration_open', 'registration_closed', 'active'])
            ->withCount(['participants', 'predictions'])
            ->get()
            ->map(function ($tournament) {
                $matchesCount = $tournament->matches->count();
                $predictionsCount = $tournament->predictions_count;
                
                return [
                    'tournament' => $tournament,
                    'matches_count' => $matchesCount,
                    'predictions_count' => $predictionsCount,
                    'average_predictions_per_match' => $matchesCount > 0 ? round($predictionsCount / $matchesCount, 1) : 0,
                    'completion_rate' => $this->getTournamentCompletionRate($tournament->id)
                ];
            })
            ->toArray();
    }

    private function getMatchPredictionsCount(int $matchId): int
    {
        return Prediction::where('football_match_id', $matchId)->count();
    }

    private function getMatchPredictionsBreakdown(int $matchId): array
    {
        $predictions = Prediction::where('football_match_id', $matchId)
            ->select('predicted_winner', DB::raw('count(*) as count'))
            ->groupBy('predicted_winner')
            ->get()
            ->keyBy('predicted_winner');

        return [
            'home' => $predictions->get('home')->count ?? 0,
            'draw' => $predictions->get('draw')->count ?? 0,
            'away' => $predictions->get('away')->count ?? 0
        ];
    }

    private function getMostPopularPrediction(int $matchId): ?array
    {
        $popularScore = Prediction::where('football_match_id', $matchId)
            ->select('predicted_home_score', 'predicted_away_score', DB::raw('count(*) as count'))
            ->groupBy('predicted_home_score', 'predicted_away_score')
            ->orderByDesc('count')
            ->first();

        if (!$popularScore) {
            return null;
        }

        return [
            'score' => "{$popularScore->predicted_home_score}-{$popularScore->predicted_away_score}",
            'count' => $popularScore->count,
            'percentage' => round(($popularScore->count / $this->getMatchPredictionsCount($matchId)) * 100, 1)
        ];
    }

    private function getTimeUntilClosure(FootballMatch $match): ?string
    {
        if (!$match->can_predict) {
            return 'Fermé';
        }

        $closureTime = $match->predictions_close_at ?? $match->match_date->copy()->subMinutes(15);
        $now = now();

        if ($closureTime <= $now) {
            return 'Fermé';
        }

        $diffInMinutes = $now->diffInMinutes($closureTime);
        
        if ($diffInMinutes < 60) {
            return "{$diffInMinutes} min";
        } elseif ($diffInMinutes < 1440) {
            $hours = intval($diffInMinutes / 60);
            $minutes = $diffInMinutes % 60;
            return "{$hours}h {$minutes}min";
        } else {
            $days = intval($diffInMinutes / 1440);
            return "{$days}j";
        }
    }

    private function getCorrectPredictions(int $matchId): array
    {
        $match = FootballMatch::find($matchId);
        
        if (!$match || !$match->is_finished) {
            return ['exact' => 0, 'winner' => 0];
        }

        $exactPredictions = Prediction::where('football_match_id', $matchId)
            ->where('predicted_home_score', $match->home_score)
            ->where('predicted_away_score', $match->away_score)
            ->count();

        $winnerPredictions = Prediction::where('football_match_id', $matchId)
            ->where('predicted_winner', $match->winner)
            ->count();

        return [
            'exact' => $exactPredictions,
            'winner' => $winnerPredictions
        ];
    }

    private function getMatchAccuracy(int $matchId): float
    {
        $totalPredictions = $this->getMatchPredictionsCount($matchId);
        
        if ($totalPredictions === 0) {
            return 0;
        }

        $correctPredictions = $this->getCorrectPredictions($matchId);
        
        return round(($correctPredictions['winner'] / $totalPredictions) * 100, 1);
    }

    private function getTournamentCompletionRate(int $tournamentId): float
    {
        $totalMatches = FootballMatch::where('tournament_id', $tournamentId)
            ->where('is_active', true)
            ->count();

        if ($totalMatches === 0) {
            return 0;
        }

        $finishedMatches = FootballMatch::where('tournament_id', $tournamentId)
            ->where('status', 'finished')
            ->where('is_active', true)
            ->count();

        return round(($finishedMatches / $totalMatches) * 100, 1);
    }
} 