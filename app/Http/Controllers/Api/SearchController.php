<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Recipe;
use App\Models\Event;
use App\Models\Tip;
use App\Models\DinorTv;
use Illuminate\Http\Request;

class SearchController extends Controller
{
    /**
     * Recherche globale dans tous les contenus
     */
    public function index(Request $request)
    {
        $query = $request->input('q', '');
        $type = $request->input('type', '');
        $limit = min($request->input('limit', 10), 50);

        if (empty($query)) {
            return response()->json([
                'success' => false,
                'message' => 'Le paramètre de recherche "q" est requis'
            ], 400);
        }

        $results = [];
        $totalResults = 0;

        // Si aucun type spécifié, chercher dans tous
        if (empty($type) || $type === 'recipe') {
            $recipes = Recipe::where('title', 'like', "%{$query}%")
                ->orWhere('description', 'like', "%{$query}%")
                ->published()
                ->with(['media', 'likes'])
                ->limit($limit)
                ->get()
                ->map(function ($recipe) {
                    return [
                        'id' => $recipe->id,
                        'title' => $recipe->title,
                        'description' => $recipe->description,
                        'image' => $recipe->image_url,
                        'type' => 'recipe',
                        'created_at' => $recipe->created_at,
                        'likes_count' => $recipe->likes_count,
                        'url' => "/recipe/{$recipe->id}"
                    ];
                });

            $results['recipes'] = $recipes;
            $totalResults += count($recipes);
        }

        if (empty($type) || $type === 'event') {
            $events = Event::where('title', 'like', "%{$query}%")
                ->orWhere('description', 'like', "%{$query}%")
                ->published()
                ->with(['media', 'likes'])
                ->limit($limit)
                ->get()
                ->map(function ($event) {
                    return [
                        'id' => $event->id,
                        'title' => $event->title,
                        'description' => $event->description,
                        'image' => $event->image_url,
                        'type' => 'event',
                        'created_at' => $event->created_at,
                        'event_date' => $event->event_date,
                        'likes_count' => $event->likes_count,
                        'url' => "/event/{$event->id}"
                    ];
                });

            $results['events'] = $events;
            $totalResults += count($events);
        }

        if (empty($type) || $type === 'tip') {
            $tips = Tip::where('title', 'like', "%{$query}%")
                ->orWhere('description', 'like', "%{$query}%")
                ->published()
                ->with(['media', 'likes'])
                ->limit($limit)
                ->get()
                ->map(function ($tip) {
                    return [
                        'id' => $tip->id,
                        'title' => $tip->title,
                        'description' => $tip->description,
                        'image' => $tip->image_url,
                        'type' => 'tip',
                        'created_at' => $tip->created_at,
                        'likes_count' => $tip->likes_count,
                        'url' => "/tip/{$tip->id}"
                    ];
                });

            $results['tips'] = $tips;
            $totalResults += count($tips);
        }

        if (empty($type) || $type === 'dinor_tv') {
            $videos = DinorTv::where('title', 'like', "%{$query}%")
                ->orWhere('description', 'like', "%{$query}%")
                ->published()
                ->with(['media', 'likes'])
                ->limit($limit)
                ->get()
                ->map(function ($video) {
                    return [
                        'id' => $video->id,
                        'title' => $video->title,
                        'description' => $video->description,
                        'image' => $video->image_url,
                        'thumbnail_url' => $video->thumbnail_url,
                        'video_url' => $video->video_url,
                        'type' => 'dinor_tv',
                        'created_at' => $video->created_at,
                        'views_count' => $video->views_count ?? 0,
                        'likes_count' => $video->likes_count,
                        'url' => "/dinor-tv"
                    ];
                });

            $results['videos'] = $videos;
            $totalResults += count($videos);
        }

        // Aplatir les résultats si un type spécifique est demandé
        if (!empty($type)) {
            $typeMap = [
                'recipe' => 'recipes',
                'event' => 'events',
                'tip' => 'tips',
                'dinor_tv' => 'videos'
            ];
            
            if (isset($typeMap[$type]) && isset($results[$typeMap[$type]])) {
                $results = $results[$typeMap[$type]];
            } else {
                $results = [];
            }
        }

        return response()->json([
            'success' => true,
            'data' => $results,
            'meta' => [
                'query' => $query,
                'type' => $type,
                'total_results' => $totalResults,
                'limit' => $limit
            ]
        ]);
    }

    /**
     * Suggestions de recherche basées sur les titres populaires
     */
    public function suggestions(Request $request)
    {
        $query = $request->input('q', '');
        $limit = min($request->input('limit', 5), 20);

        if (strlen($query) < 2) {
            return response()->json([
                'success' => true,
                'data' => []
            ]);
        }

        $suggestions = [];

        // Récupérer des suggestions depuis les titres
        $recipes = Recipe::where('title', 'like', "%{$query}%")
            ->published()
            ->select('title')
            ->limit($limit)
            ->pluck('title');

        $events = Event::where('title', 'like', "%{$query}%")
            ->published()
            ->select('title')
            ->limit($limit)
            ->pluck('title');

        $tips = Tip::where('title', 'like', "%{$query}%")
            ->published()
            ->select('title')
            ->limit($limit)
            ->pluck('title');

        $videos = DinorTv::where('title', 'like', "%{$query}%")
            ->published()
            ->select('title')
            ->limit($limit)
            ->pluck('title');

        $allSuggestions = collect([])
            ->merge($recipes)
            ->merge($events)
            ->merge($tips)
            ->merge($videos)
            ->unique()
            ->take($limit)
            ->values();

        return response()->json([
            'success' => true,
            'data' => $allSuggestions
        ]);
    }
}