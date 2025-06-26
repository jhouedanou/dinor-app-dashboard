<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Tip;
use Illuminate\Http\Request;

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

        return response()->json([
            'success' => true,
            'data' => $tips->items(),
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

    public function show($id)
    {
        $tip = Tip::with('category')
            ->published()
            ->findOrFail($id);

        return response()->json([
            'success' => true,
            'data' => $tip
        ]);
    }

    public function featured()
    {
        $tips = Tip::with('category')
            ->published()
            ->featured()
            ->limit(10)
            ->get();

        return response()->json([
            'success' => true,
            'data' => $tips
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