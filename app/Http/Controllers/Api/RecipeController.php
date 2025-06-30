<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Recipe;
use Illuminate\Http\Request;

class RecipeController extends Controller
{
    public function index(Request $request)
    {
        // Par défaut, ne retourner que les recettes publiées et non supprimées
        $query = Recipe::with('category')
            ->where('is_published', true)
            ->orderBy('created_at', 'desc');

        // Permettre d'inclure les non publiées pour l'admin
        if ($request->has('include_unpublished') && $request->boolean('include_unpublished')) {
            $query = Recipe::with('category')->orderBy('created_at', 'desc');
        }



        // Filtres optionnels
        if ($request->has('category_id')) {
            $query->where('category_id', $request->category_id);
        }

        if ($request->has('difficulty')) {
            $query->where('difficulty', $request->difficulty);
        }

        if ($request->has('featured')) {
            $query->where('is_featured', true);
        }

        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('title', 'like', "%{$search}%")
                  ->orWhere('description', 'like', "%{$search}%");
            });
        }

        $recipes = $query->paginate($request->get('per_page', 15));

        return response()->json([
            'success' => true,
            'data' => $recipes->items(),
            'pagination' => [
                'current_page' => $recipes->currentPage(),
                'last_page' => $recipes->lastPage(),
                'per_page' => $recipes->perPage(),
                'total' => $recipes->total(),
            ],
            'debug_info' => [
                'total_recipes_in_db' => Recipe::count(),
                'published_recipes' => Recipe::where('is_published', true)->count(),
                'featured_recipes' => Recipe::where('is_featured', true)->count(),
            ]
        ])->header('Cache-Control', 'no-cache, no-store, must-revalidate')
          ->header('Pragma', 'no-cache')
          ->header('Expires', '0');
    }

    public function show($id)
    {
        $recipe = Recipe::with(['category', 'approvedComments.user:id,name', 'approvedComments.replies.user:id,name'])
            ->published()
            ->findOrFail($id);

        // Enrichir les ingrédients avec les noms depuis la base de données
        if ($recipe->ingredients) {
            $ingredients = collect($recipe->ingredients)->map(function ($ingredient) {
                if (isset($ingredient['ingredient_id'])) {
                    $ingredientModel = \App\Models\Ingredient::find($ingredient['ingredient_id']);
                    if ($ingredientModel) {
                        $ingredient['name'] = $ingredientModel->name;
                        $ingredient['category'] = $ingredientModel->category;
                    }
                }
                return $ingredient;
            });
            $recipe->ingredients = $ingredients->toArray();
        }

        return response()->json([
            'success' => true,
            'data' => $recipe
        ]);
    }

    public function featured()
    {
        $recipes = Recipe::with('category')
            ->published()
            ->featured()
            ->limit(10)
            ->get();

        return response()->json([
            'success' => true,
            'data' => $recipes
        ]);
    }

    public function categories()
    {
        $categories = \App\Models\Category::active()
            ->withCount(['recipes' => function($query) {
                $query->published();
            }])
            ->get();

        return response()->json([
            'success' => true,
            'data' => $categories
        ]);
    }
    
    /**
     * Supprimer une recette
     */
    public function destroy(Request $request, Recipe $recipe)
    {
        try {
            // Vérifier les permissions si nécessaire
            // if (!$request->user()->can('delete', $recipe)) {
            //     return response()->json(['success' => false, 'message' => 'Non autorisé'], 403);
            // }
            
            $recipe->delete();
            
            return response()->json([
                'success' => true,
                'message' => 'Recette supprimée avec succès'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la suppression: ' . $e->getMessage()
            ], 500);
        }
    }
} 