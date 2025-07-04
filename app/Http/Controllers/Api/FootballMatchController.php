<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\FootballMatch;
use Illuminate\Http\Request;

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

        return response()->json([
            'success' => true,
            'data' => $currentMatch
        ]);
    }
}
