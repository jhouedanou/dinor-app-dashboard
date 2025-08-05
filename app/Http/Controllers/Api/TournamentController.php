<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Tournament;
use App\Models\TournamentParticipant;
use App\Models\FootballMatch;
use App\Models\Prediction;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Cache;

class TournamentController extends Controller
{
    public function index(Request $request)
    {
        try {
            $query = Tournament::with(['creator:id,name'])
                ->public()
                ->notExpired();

            // Filtres
            if ($request->has('status')) {
                $statuses = explode(',', $request->status);
                $query->whereIn('status', $statuses);
            }

            if ($request->has('featured')) {
                $query->featured();
            }

            // Tri
            $sortBy = $request->get('sort_by', 'start_date');
            $sortDirection = $request->get('sort_direction', 'asc');
            
            switch ($sortBy) {
                case 'participants':
                    $query->withCount('participants')
                          ->orderBy('participants_count', $sortDirection);
                    break;
                case 'prize_pool':
                    $query->orderBy('prize_pool', $sortDirection);
                    break;
                case 'created_at':
                    $query->orderBy('created_at', $sortDirection);
                    break;
                default:
                    $query->orderBy('start_date', $sortDirection);
            }

            // Pagination
            $perPage = min($request->get('per_page', 12), 50);
            $tournaments = $query->paginate($perPage);

            // Mettre à jour automatiquement le statut des tournois et ajouter les données utilisateur
            $user = Auth::user();
            $tournamentData = [];
            
            foreach ($tournaments as $tournament) {
                $tournament->updateStatus();
                
                $data = $tournament->toArray();
                
                // Ajouter des données spécifiques à l'utilisateur connecté
                if ($user) {
                    try {
                        $data['user_is_participant'] = $tournament->participants()
                            ->where('user_id', $user->id)->exists();
                        $data['user_can_register'] = $tournament->canUserRegister($user);
                    } catch (\Exception $e) {
                        $data['user_is_participant'] = false;
                        $data['user_can_register'] = false;
                    }
                } else {
                    $data['user_is_participant'] = false;
                    $data['user_can_register'] = false;
                }
                
                $tournamentData[] = $data;
            }

            return response()->json([
                'success' => true,
                'data' => $tournamentData,
                'meta' => [
                    'current_page' => $tournaments->currentPage(),
                    'last_page' => $tournaments->lastPage(),
                    'per_page' => $tournaments->perPage(),
                    'total' => $tournaments->total(),
                ],
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors du chargement des tournois',
                'error' => config('app.debug') ? $e->getMessage() : 'TOURNAMENT_LOAD_ERROR'
            ], 500);
        }
    }

    public function show($id)
    {
        try {
            $tournament = Tournament::with([
                'creator:id,name',
                'participants.user:id,name',
                'matches.homeTeam:id,name,short_name',
                'matches.awayTeam:id,name,short_name'
            ])->findOrFail($id);

            $tournament->updateStatus();

            $data = $tournament->toArray();
            
            // Ajouter des données supplémentaires pour l'utilisateur connecté
            if (Auth::check()) {
                $user = Auth::user();
                try {
                    $data['user_is_participant'] = $tournament->participants()
                        ->where('user_id', $user->id)->exists();
                    $data['user_can_register'] = $tournament->canUserRegister($user);
                } catch (\Exception $e) {
                    $data['user_is_participant'] = false;
                    $data['user_can_register'] = false;
                }
            } else {
                $data['user_is_participant'] = false;
                $data['user_can_register'] = false;
            }

            return response()->json([
                'success' => true,
                'data' => $data
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Tournoi non trouvé',
                'error' => 'TOURNAMENT_NOT_FOUND'
            ], 404);
        }
    }

    public function register(Request $request, $id)
    {
        try {
            if (!Auth::check()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Vous devez être connecté pour vous inscrire',
                    'error' => 'AUTHENTICATION_REQUIRED'
                ], 401);
            }

            $tournament = Tournament::findOrFail($id);
            $user = Auth::user();

            if (!$tournament->canUserRegister($user)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Inscription impossible pour ce tournoi',
                    'error' => 'REGISTRATION_NOT_ALLOWED'
                ], 422);
            }

            DB::transaction(function () use ($tournament, $user) {
                $participant = $tournament->registerUser($user);
                
                if (!$participant) {
                    throw new \Exception('Erreur lors de l\'inscription');
                }
            });

            return response()->json([
                'success' => true,
                'message' => 'Inscription réussie au tournoi',
                'data' => [
                    'tournament_id' => $tournament->id,
                    'tournament_name' => $tournament->name,
                    'registered_at' => now()->toISOString()
                ]
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de l\'inscription',
                'error' => config('app.debug') ? $e->getMessage() : 'REGISTRATION_ERROR'
            ], 500);
        }
    }

    public function unregister(Request $request, $id)
    {
        try {
            if (!Auth::check()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Vous devez être connecté',
                    'error' => 'AUTHENTICATION_REQUIRED'
                ], 401);
            }

            $tournament = Tournament::findOrFail($id);
            $user = Auth::user();

            $participant = TournamentParticipant::where('tournament_id', $tournament->id)
                ->where('user_id', $user->id)
                ->first();

            if (!$participant) {
                return response()->json([
                    'success' => false,
                    'message' => 'Vous n\'êtes pas inscrit à ce tournoi',
                    'error' => 'NOT_REGISTERED'
                ], 422);
            }

            // Vérifier si la désinscription est encore possible
            if ($tournament->status === 'active') {
                return response()->json([
                    'success' => false,
                    'message' => 'Impossible de se désinscrire d\'un tournoi en cours',
                    'error' => 'TOURNAMENT_ACTIVE'
                ], 422);
            }

            DB::transaction(function () use ($participant, $tournament, $user) {
                $participant->update(['status' => 'withdrawn']);
                
                // Nettoyer le leaderboard
                $tournament->leaderboard()
                    ->where('user_id', $user->id)
                    ->delete();
                
                // Recalculer les rangs
                $tournament->calculateRanks();
            });

            return response()->json([
                'success' => true,
                'message' => 'Désinscription réussie du tournoi'
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la désinscription',
                'error' => config('app.debug') ? $e->getMessage() : 'UNREGISTRATION_ERROR'
            ], 500);
        }
    }

    public function leaderboard($id, Request $request)
    {
        try {
            $tournament = Tournament::findOrFail($id);
            
            $limit = min($request->get('limit', 50), 100);
            
            $leaderboard = $tournament->leaderboard()
                ->with('user:id,name')
                ->byRank()
                ->limit($limit)
                ->get();

            return response()->json([
                'success' => true,
                'data' => $leaderboard,
                'tournament' => [
                    'id' => $tournament->id,
                    'name' => $tournament->name,
                    'status' => $tournament->status,
                    'participants_count' => $tournament->participants_count
                ]
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors du chargement du classement',
                'error' => 'LEADERBOARD_ERROR'
            ], 500);
        }
    }

    public function myTournaments(Request $request)
    {
        try {
            // Utiliser Auth::guard('sanctum') pour supporter les tokens Bearer
            $user = Auth::guard('sanctum')->user();
            
            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'Vous devez être connecté',
                    'error' => 'AUTHENTICATION_REQUIRED'
                ], 401);
            }
            
            $tournaments = Tournament::whereHas('participants', function ($query) use ($user) {
                $query->where('user_id', $user->id)
                      ->where('status', 'active');
            })
            ->with([
                'leaderboard' => function ($query) use ($user) {
                    $query->where('user_id', $user->id);
                }
            ])
            ->orderByDesc('start_date')
            ->get();

            $data = $tournaments->map(function ($tournament) {
                $leaderboard = $tournament->leaderboard->first();
                return [
                    'tournament' => $tournament,
                    'user_rank' => $leaderboard?->rank ?? 0,
                    'user_points' => $leaderboard?->total_points ?? 0,
                    'user_predictions' => $leaderboard?->total_predictions ?? 0,
                    'user_accuracy' => $leaderboard?->accuracy ?? 0,
                ];
            });

            return response()->json([
                'success' => true,
                'data' => $data,
                'count' => $data->count(),
                'message' => $data->count() > 0 ? 'Tournois trouvés' : 'Vous n\'êtes inscrit à aucun tournoi actif'
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors du chargement de vos tournois',
                'error' => 'MY_TOURNAMENTS_ERROR',
                'debug' => config('app.debug') ? $e->getMessage() : null
            ], 500);
        }
    }

    /**
     * Get matches for a specific tournament with user predictions
     */
    public function matches(Request $request, Tournament $tournament)
    {
        try {
            // Cache key for tournament matches
            $cacheKey = "tournament_matches_{$tournament->id}";
            $userId = Auth::id();
            
            // Get matches with eager loading
            $matches = Cache::remember($cacheKey, 300, function () use ($tournament) {
                return FootballMatch::with(['homeTeam:id,name,short_name,logo', 'awayTeam:id,name,short_name,logo'])
                    ->where('tournament_id', $tournament->id)
                    ->where('is_active', true)
                    ->orderBy('match_date')
                    ->get();
            });

            // If user is authenticated, load their predictions
            if ($userId) {
                $matchIds = $matches->pluck('id')->toArray();
                
                // Get user predictions for these matches
                $userPredictions = Prediction::where('user_id', $userId)
                    ->whereIn('football_match_id', $matchIds)
                    ->get()
                    ->keyBy('football_match_id');

                // Attach user predictions to matches
                $matches = $matches->map(function ($match) use ($userPredictions) {
                    $match->user_prediction = $userPredictions->get($match->id);
                    return $match;
                });
            }

            return response()->json([
                'success' => true,
                'data' => $matches,
                'tournament' => [
                    'id' => $tournament->id,
                    'name' => $tournament->name,
                    'status' => $tournament->status,
                    'can_predict' => $tournament->can_predict
                ]
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors du chargement des matchs du tournoi',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get featured tournaments with optimized loading
     */
    public function featured(Request $request)
    {
        try {
            $limit = min($request->get('limit', 10), 20);
            
            $tournaments = Tournament::with(['creator:id,name'])
                ->public()
                ->featured()
                ->notExpired()
                ->withCount('participants')
                ->orderBy('start_date')
                ->limit($limit)
                ->get();

            // Update status for each tournament
            $tournaments->each(function ($tournament) {
                $tournament->updateStatus();
            });

            return response()->json([
                'success' => true,
                'data' => $tournaments
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors du chargement des tournois en vedette',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}