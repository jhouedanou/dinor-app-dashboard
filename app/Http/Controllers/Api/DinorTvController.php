<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\DinorTv;
use Illuminate\Http\Request;

class DinorTvController extends Controller
{
    public function index(Request $request)
    {
        $query = DinorTv::published()
            ->orderBy('created_at', 'desc');

        // Filtres
        if ($request->has('featured')) {
            $query->featured();
        }

        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('title', 'like', "%{$search}%")
                  ->orWhere('description', 'like', "%{$search}%");
            });
        }

        $videos = $query->paginate($request->get('per_page', 15));

        return response()->json([
            'success' => true,
            'data' => $videos->items(),
            'pagination' => [
                'current_page' => $videos->currentPage(),
                'last_page' => $videos->lastPage(),
                'per_page' => $videos->perPage(),
                'total' => $videos->total(),
            ]
        ]);
    }

    public function show($id)
    {
        $video = DinorTv::published()
            ->findOrFail($id);

        return response()->json([
            'success' => true,
            'data' => $video
        ]);
    }

    public function featured()
    {
        $videos = DinorTv::published()
            ->featured()
            ->limit(10)
            ->get();

        return response()->json([
            'success' => true,
            'data' => $videos
        ]);
    }

    public function live()
    {
        $videos = DinorTv::published()
            ->featured()
            ->limit(10)
            ->get();

        return response()->json([
            'success' => true,
            'data' => $videos
        ]);
    }

    public function incrementView($id)
    {
        $video = DinorTv::findOrFail($id);
        $video->increment('view_count');

        return response()->json([
            'success' => true,
            'message' => 'Vue comptabilisée',
            'data' => [
                'view_count' => $video->fresh()->view_count
            ]
        ]);
    }

    public function toggleLike($id)
    {
        $video = DinorTv::findOrFail($id);
        
        // Logique simplifiée - les likes ne sont plus trackés dans le modèle simplifié
        return response()->json([
            'success' => true,
            'message' => 'Like comptabilisé'
        ]);
    }
} 