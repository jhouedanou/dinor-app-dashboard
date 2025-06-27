<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\EventCategory;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class EventCategoryController extends Controller
{
    /**
     * Récupérer toutes les catégories d'événements actives
     */
    public function index(Request $request)
    {
        $categories = EventCategory::active()
            ->orderBy('name')
            ->get(['id', 'name', 'slug', 'description', 'color', 'icon']);

        return response()->json([
            'success' => true,
            'data' => $categories
        ]);
    }

    /**
     * Récupérer une catégorie spécifique
     */
    public function show($id)
    {
        $category = EventCategory::active()
            ->with(['events' => function($query) {
                $query->published()->active()->orderBy('start_date', 'asc');
            }])
            ->findOrFail($id);

        return response()->json([
            'success' => true,
            'data' => $category
        ]);
    }

    /**
     * Créer une nouvelle catégorie d'événement
     */
    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'slug' => 'nullable|string|max:255|unique:event_categories,slug',
            'description' => 'nullable|string|max:500',
            'color' => 'nullable|string|max:7',
            'icon' => 'nullable|string|max:100',
        ]);

        $category = EventCategory::create([
            'name' => $request->name,
            'slug' => $request->slug ?? Str::slug($request->name),
            'description' => $request->description,
            'color' => $request->color ?? '#3b82f6',
            'icon' => $request->icon,
            'is_active' => true,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Catégorie d\'événement créée avec succès',
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
        ]);

        $exists = EventCategory::where('name', $request->name)->exists();

        return response()->json([
            'success' => true,
            'exists' => $exists
        ]);
    }
} 