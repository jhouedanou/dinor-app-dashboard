<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Recipe;
use Illuminate\Http\Request;

class RecipeController extends Controller
{
    public function index(Request $request)
    {
        $query = Recipe::with('category')
            ->published()
            ->orderBy('created_at', 'desc');

        // Filtres
        if ($request->has('category_id')) {
            $query->where('category_id', $request->category_id);
        }

        if ($request->has('difficulty')) {
            $query->where('difficulty', $request->difficulty);
        }

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

        $recipes = $query->paginate($request->get('per_page', 15));

        return response()->json([
            'success' => true,
            'data' => $recipes->items(),
            'pagination' => [
                'current_page' => $recipes->currentPage(),
                'last_page' => $recipes->lastPage(),
                'per_page' => $recipes->perPage(),
                'total' => $recipes->total(),
            ]
        ]);
    }

    public function show($id)
    {
        $recipe = Recipe::with('category')
            ->published()
            ->findOrFail($id);

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
} 