<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Category;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

class CategoryController extends Controller
{
    /**
     * Récupérer toutes les catégories actives
     */
    public function index(Request $request)
    {
        $query = Category::active()->orderBy('name');

        // Filtrer par type si spécifié
        if ($request->has('type')) {
            $query->byType($request->type);
        }

        $categories = $query->get(['id', 'name', 'slug', 'type', 'color', 'icon']);

        return response()->json([
            'success' => true,
            'data' => $categories
        ]);
    }

    /**
     * Récupérer les catégories d'événements uniquement
     */
    public function events()
    {
        $categories = Category::active()
            ->forEvents()
            ->orderBy('name')
            ->get(['id', 'name', 'slug', 'color', 'icon']);

        return response()->json([
            'success' => true,
            'data' => $categories
        ]);
    }

    /**
     * Récupérer les catégories de recettes uniquement
     */
    public function recipes()
    {
        $categories = Category::active()
            ->forRecipes()
            ->orderBy('name')
            ->get(['id', 'name', 'slug', 'color', 'icon']);

        return response()->json([
            'success' => true,
            'data' => $categories
        ]);
    }

    /**
     * Créer une nouvelle catégorie rapidement
     */
    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'type' => 'required|in:general,recipe,event',
            'slug' => 'nullable|string|max:255|unique:categories,slug',
            'description' => 'nullable|string|max:500',
            'color' => 'nullable|string|max:7',
            'icon' => 'nullable|string|max:100',
        ]);

        $category = Category::create([
            'name' => $request->name,
            'type' => $request->type,
            'slug' => $request->slug ?? Str::slug($request->name),
            'description' => $request->description,
            'color' => $request->color,
            'icon' => $request->icon,
            'is_active' => true,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Catégorie créée avec succès',
            'data' => $category
        ], 201);
    }

    /**
     * Vérifier si une catégorie existe déjà
     */
    public function checkExists(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'type' => 'nullable|in:general,recipe,event',
        ]);

        $query = Category::where('name', $request->name);
        
        if ($request->has('type')) {
            $query->where('type', $request->type);
        }

        $exists = $query->exists();

        return response()->json([
            'success' => true,
            'exists' => $exists
        ]);
    }
} 