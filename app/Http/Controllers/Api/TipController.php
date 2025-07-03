<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Tip;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class TipController extends Controller
{
    public function index(Request $request)
    {
        $query = Tip::with('category')
            ->published()
            ->orderBy('created_at', 'desc');

        // Filtres
        if ($request->has('category_id')) {
            $query->where('category_id', $request->category_id);
        }

        if ($request->has('difficulty_level')) {
            $query->where('difficulty_level', $request->difficulty_level);
        }

        if ($request->has('featured')) {
            $query->featured();
        }

        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('title', 'like', "%{$search}%")
                  ->orWhere('content', 'like', "%{$search}%");
            });
        }

        $tips = $query->paginate($request->get('per_page', 15));
        
        // Enrichir avec les informations de like/favori pour l'utilisateur connecté
        $userId = Auth::id();
        $ipAddress = $request->ip();
        
        $enrichedTips = collect($tips->items())->map(function ($tip) use ($userId, $ipAddress) {
            // Ajouter is_liked pour l'utilisateur connecté
            if ($userId) {
                $tip->is_liked = $tip->isLikedBy($userId);
                $tip->is_favorited = $tip->isFavoritedByUser($userId);
            } else {
                $tip->is_liked = $tip->isLikedBy($ipAddress);
                $tip->is_favorited = false;
            }
            
            return $tip;
        });

        return response()->json([
            'success' => true,
            'data' => $enrichedTips,
            'pagination' => [
                'current_page' => $tips->currentPage(),
                'last_page' => $tips->lastPage(),
                'per_page' => $tips->perPage(),
                'total' => $tips->total(),
            ]
        ])->header('Cache-Control', 'no-cache, no-store, must-revalidate')
          ->header('Pragma', 'no-cache')
          ->header('Expires', '0');
    }

    public function show(Request $request, $id)
    {
        $tip = Tip::with(['category', 'approvedComments.user:id,name', 'approvedComments.replies.user:id,name'])
            ->published()
            ->findOrFail($id);
            
        // Ajouter les informations de like/favori pour l'utilisateur connecté
        $userId = Auth::id();
        $ipAddress = $request->ip();
        
        if ($userId) {
            $tip->is_liked = $tip->isLikedBy($userId);
            $tip->is_favorited = $tip->isFavoritedByUser($userId);
        } else {
            $tip->is_liked = $tip->isLikedBy($ipAddress);
            $tip->is_favorited = false;
        }

        return response()->json([
            'success' => true,
            'data' => $tip
        ]);
    }

    public function featured(Request $request)
    {
        $tips = Tip::with('category')
            ->published()
            ->featured()
            ->limit(10)
            ->get();
            
        // Enrichir avec les informations de like/favori pour l'utilisateur connecté
        $userId = Auth::id();
        $ipAddress = $request->ip();
        
        $enrichedTips = $tips->map(function ($tip) use ($userId, $ipAddress) {
            // Ajouter is_liked pour l'utilisateur connecté
            if ($userId) {
                $tip->is_liked = $tip->isLikedBy($userId);
                $tip->is_favorited = $tip->isFavoritedByUser($userId);
            } else {
                $tip->is_liked = $tip->isLikedBy($ipAddress);
                $tip->is_favorited = false;
            }
            
            return $tip;
        });

        return response()->json([
            'success' => true,
            'data' => $enrichedTips
        ]);
    }
    
    /**
     * Supprimer une astuce
     */
    public function destroy(Request $request, Tip $tip)
    {
        try {
            // Vérifier les permissions si nécessaire
            // if (!$request->user()->can('delete', $tip)) {
            //     return response()->json(['success' => false, 'message' => 'Non autorisé'], 403);
            // }
            
            $tip->delete();
            
            return response()->json([
                'success' => true,
                'message' => 'Astuce supprimée avec succès'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la suppression: ' . $e->getMessage()
            ], 500);
        }
    }
} 