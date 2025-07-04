<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Team;
use Illuminate\Http\Request;

class TeamController extends Controller
{
    public function index(Request $request)
    {
        $teams = Team::active()
            ->orderBy('name')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $teams,
            'total' => $teams->count()
        ]);
    }

    public function show(Team $team)
    {
        if (!$team->is_active) {
            return response()->json([
                'success' => false,
                'message' => 'Équipe non active'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $team
        ]);
    }
}
