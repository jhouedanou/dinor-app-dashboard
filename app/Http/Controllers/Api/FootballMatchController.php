<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\FootballMatch;
use App\Models\Prediction;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Cache;

class FootballMatchController extends Controller
{
    public function index(Request $request)
    {
        $query = FootballMatch::with(['homeTeam', 'awayTeam'])
            ->active()
            ->orderBy('match_date', 'desc');

        // Filtres
        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        if ($request->has('upcoming')) {
            $query->upcoming();
        }

        if ($request->has('finished')) {
            $query->finished();
        }

        if ($request->has('predictions_open')) {
            $query->predictionsOpen();
        }

        $matches = $query->paginate($request->get('per_page', 15));

        return response()->json([
            'success' => true,
            'data' => $matches->items(),
            'pagination' => [
                'current_page' => $matches->currentPage(),
                'last_page' => $matches->lastPage(),
                'per_page' => $matches->perPage(),
                'total' => $matches->total(),
            ]
        ]);
    }

    /**
     * Get priority matches (next 3 upcoming matches) with enhanced data
     */
    public function priority(Request $request)
    {
        $userId = Auth::id();
        
        // Cache key includes user ID for personalized data
        $cacheKey = "priority_matches_" . ($userId ?? 'guest');
        
        $matches = Cache::remember($cacheKey, 300, function () use ($userId) {
            $query = FootballMatch::with([
                'homeTeam:id,name,short_name,logo',
                'awayTeam:id,name,short_name,logo',
                'tournament:id,name,status'
            ])
            ->active()
            ->upcoming()
            ->where('predictions_enabled', true)
            ->orderBy('match_date')
            ->limit(3);

            $matches = $query->get();

            // If user is authenticated, load their predictions
            if ($userId) {
                $matchIds = $matches->pluck('id')->toArray();
                
                if (!empty($matchIds)) {
                    $userPredictions = Prediction::where('user_id', $userId)
                        ->whereIn('football_match_id', $matchIds)
                        ->get()
                        ->keyBy('football_match_id');

                    // Attach user predictions to matches
                    $matches->transform(function ($match) use ($userPredictions) {
                        $match->user_prediction = $userPredictions->get($match->id);
                        return $match;
                    });
                }
            }

            return $matches;
        });

        // Add real-time predictions count for each match
        $enhancedMatches = $matches->map(function ($match) {
            // Get real-time predictions count (not cached for accuracy)
            $predictionsCount = Prediction::where('football_match_id', $match->id)->count();
            $match->predictions_count = $predictionsCount;
            
            // Calculate time until closure
            $match->time_until_closure = $this->calculateTimeUntilClosure($match);
            
            // Add popularity indicators
            $match->prediction_trends = $this->getMatchPredictionTrends($match->id);
            
            return $match;
        });

        return response()->json([
            'success' => true,
            'data' => $enhancedMatches,
            'cache_info' => [
                'cached_at' => Cache::get($cacheKey . '_timestamp', now()),
                'next_refresh' => now()->addMinutes(5)
            ]
        ]);
    }

    /**
     * Get lazy-loaded matches (matches beyond the first 3)
     */
    public function lazy(Request $request)
    {
        $offset = max(0, (int) $request->get('offset', 3));
        $limit = min(50, (int) $request->get('limit', 10));
        $userId = Auth::id();

        $cacheKey = "lazy_matches_{$offset}_{$limit}_" . ($userId ?? 'guest');

        $matches = Cache::remember($cacheKey, 600, function () use ($offset, $limit, $userId) {
            $query = FootballMatch::with([
                'homeTeam:id,name,short_name,logo',
                'awayTeam:id,name,short_name,logo',
                'tournament:id,name'
            ])
            ->active()
            ->upcoming()
            ->orderBy('match_date')
            ->skip($offset)
            ->take($limit);

            $matches = $query->get();

            // Load user predictions if authenticated
            if ($userId) {
                $matchIds = $matches->pluck('id')->toArray();
                
                if (!empty($matchIds)) {
                    $userPredictions = Prediction::where('user_id', $userId)
                        ->whereIn('football_match_id', $matchIds)
                        ->get()
                        ->keyBy('football_match_id');

                    $matches->transform(function ($match) use ($userPredictions) {
                        $match->user_prediction = $userPredictions->get($match->id);
                        return $match;
                    });
                }
            }

            return $matches;
        });

        return response()->json([
            'success' => true,
            'data' => $matches,
            'pagination' => [
                'offset' => $offset,
                'limit' => $limit,
                'has_more' => $matches->count() === $limit
            ]
        ]);
    }

    public function show(FootballMatch $footballMatch)
    {
        $footballMatch->load(['homeTeam', 'awayTeam', 'predictions.user']);

        return response()->json([
            'success' => true,
            'data' => $footballMatch
        ]);
    }

    public function upcoming(Request $request)
    {
        $matches = FootballMatch::with(['homeTeam', 'awayTeam'])
            ->active()
            ->upcoming()
            ->orderBy('match_date')
            ->limit($request->get('limit', 10))
            ->get();

        return response()->json([
            'success' => true,
            'data' => $matches
        ]);
    }

    public function current(Request $request)
    {
        // Use cache for current match with shorter TTL
        $cacheKey = 'current_match';
        
        $currentMatch = Cache::remember($cacheKey, 180, function () {
            // Match en cours ou le prochain match le plus proche
            $currentMatch = FootballMatch::with(['homeTeam', 'awayTeam'])
                ->active()
                ->where(function($query) {
                    $query->where('status', 'live')
                          ->orWhere(function($q) {
                              $q->where('status', 'scheduled')
                                ->where('match_date', '>=', now())
                                ->where('match_date', '<=', now()->addHours(2));
                          });
                })
                ->orderBy('match_date')
                ->first();

            if (!$currentMatch) {
                // Si aucun match en cours, prendre le prochain
                $currentMatch = FootballMatch::with(['homeTeam', 'awayTeam'])
                    ->active()
                    ->upcoming()
                    ->orderBy('match_date')
                    ->first();
            }

            return $currentMatch;
        });

        // Add user prediction if authenticated
        if ($currentMatch && Auth::check()) {
            $userPrediction = Prediction::where('user_id', Auth::id())
                ->where('football_match_id', $currentMatch->id)
                ->first();
            
            $currentMatch->user_prediction = $userPrediction;
        }

        return response()->json([
            'success' => true,
            'data' => $currentMatch
        ]);
    }

    /**
     * Calculate time until predictions closure
     */
    private function calculateTimeUntilClosure(FootballMatch $match): array
    {
        if (!$match->can_predict) {
            return [
                'status' => 'closed',
                'message' => 'Pronostics fermés',
                'minutes_left' => 0
            ];
        }

        $closureTime = $match->predictions_close_at ?? $match->match_date->copy()->subMinutes(15);
        $now = now();

        if ($closureTime <= $now) {
            return [
                'status' => 'closed',
                'message' => 'Pronostics fermés',
                'minutes_left' => 0
            ];
        }

        $minutesLeft = $now->diffInMinutes($closureTime);
        
        if ($minutesLeft <= 15) {
            $status = 'urgent';
            $message = "Ferme dans {$minutesLeft} min";
        } elseif ($minutesLeft <= 60) {
            $status = 'soon';
            $message = "Ferme dans {$minutesLeft} min";
        } else {
            $hours = intval($minutesLeft / 60);
            $status = 'open';
            $message = $hours > 24 ? "Ferme dans " . intval($hours / 24) . "j" : "Ferme dans {$hours}h";
        }

        return [
            'status' => $status,
            'message' => $message,
            'minutes_left' => $minutesLeft,
            'closure_time' => $closureTime
        ];
    }

    /**
     * Get prediction trends for a match
     */
    private function getMatchPredictionTrends(int $matchId): array
    {
        $cacheKey = "match_trends_{$matchId}";
        
        return Cache::remember($cacheKey, 300, function () use ($matchId) {
            $trends = Prediction::where('football_match_id', $matchId)
                ->selectRaw('predicted_winner, COUNT(*) as count')
                ->groupBy('predicted_winner')
                ->get()
                ->pluck('count', 'predicted_winner')
                ->toArray();

            $total = array_sum($trends);
            
            if ($total === 0) {
                return [
                    'home_percentage' => 0,
                    'draw_percentage' => 0,
                    'away_percentage' => 0,
                    'total_predictions' => 0,
                    'most_popular' => null
                ];
            }

            $homePercentage = round((($trends['home'] ?? 0) / $total) * 100, 1);
            $drawPercentage = round((($trends['draw'] ?? 0) / $total) * 100, 1);
            $awayPercentage = round((($trends['away'] ?? 0) / $total) * 100, 1);

            // Find most popular prediction
            $mostPopular = collect($trends)->sortDesc()->keys()->first();

            return [
                'home_percentage' => $homePercentage,
                'draw_percentage' => $drawPercentage,
                'away_percentage' => $awayPercentage,
                'total_predictions' => $total,
                'most_popular' => $mostPopular
            ];
        });
    }

    /**
     * Invalidate matches cache
     */
    public function invalidateCache()
    {
        $patterns = [
            'priority_matches_*',
            'lazy_matches_*',
            'current_match',
            'match_trends_*'
        ];

        foreach ($patterns as $pattern) {
            // For simplicity, we clear all cache. In production, use pattern-based clearing
            Cache::flush();
        }

        return response()->json([
            'success' => true,
            'message' => 'Cache des matchs invalidé'
        ]);
    }
}
