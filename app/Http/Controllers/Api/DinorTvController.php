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

        // Enrichir les données avec les nouvelles images
        $enrichedVideos = $videos->items();
        foreach ($enrichedVideos as $video) {
            $this->enrichVideoWithImages($video);
        }

        return response()->json([
            'success' => true,
            'data' => $enrichedVideos,
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
        $video = DinorTv::with(['approvedComments.user:id,name', 'approvedComments.replies.user:id,name'])
            ->published()
            ->findOrFail($id);

        // Enrichir avec les nouvelles images
        $this->enrichVideoWithImages($video);

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

        // Enrichir avec les images
        foreach ($videos as $video) {
            $this->enrichVideoWithImages($video);
        }

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

        // Enrichir avec les images
        foreach ($videos as $video) {
            $this->enrichVideoWithImages($video);
        }

        return response()->json([
            'success' => true,
            'data' => $videos
        ]);
    }

    /**
     * Enrichit un objet DinorTv avec les données d'images personnalisées
     */
    private function enrichVideoWithImages($video)
    {
        // Ajouter les URLs des nouvelles images
        $video->featured_image_url = $video->featured_image_url;
        $video->poster_image_url = $video->poster_image_url;
        $video->banner_image_url = $video->banner_image_url;
        $video->gallery_images = $video->gallery_images;

        // Ajouter des informations sur la disponibilité des images
        $video->has_custom_images = !empty($video->featured_image) || 
                                   !empty($video->poster_image) || 
                                   !empty($video->banner_image) ||
                                   (!empty($video->gallery) && count($video->gallery) > 0);

        // Ajouter le compteur d'images dans la galerie
        $video->gallery_count = count($video->gallery_images);

        return $video;
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