<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Banner;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class BannerController extends Controller
{
    /**
     * Afficher la liste des bannières actives
     */
    public function index(Request $request): JsonResponse
    {
        try {
            $query = Banner::active()->ordered();
            
            // Filtrer par position si spécifiée
            if ($request->has('position')) {
                $query->where('position', $request->position);
            }
            
            // Par défaut, afficher les bannières pour la page d'accueil
            if (!$request->has('position')) {
                $query->forHome();
            }
            
            $banners = $query->get();
            
            // Transformer les données pour l'API
            $transformedBanners = $banners->map(function ($banner) {
                return [
                    'id' => $banner->id,
                    'title' => $banner->title,
                    'description' => $banner->description,
                    'image_url' => $banner->image_url ? url('storage/' . $banner->image_url) : null,
                    'background_color' => $banner->background_color,
                    'text_color' => $banner->text_color,
                    'button_text' => $banner->button_text,
                    'button_url' => $banner->button_url,
                    'button_color' => $banner->button_color,
                    'position' => $banner->position,
                    'order' => $banner->order,
                    'created_at' => $banner->created_at,
                    'updated_at' => $banner->updated_at,
                ];
            });
            
            return response()->json([
                'success' => true,
                'data' => $transformedBanners,
                'count' => $transformedBanners->count()
            ]);
            
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la récupération des bannières',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Afficher une bannière spécifique
     */
    public function show(string $id): JsonResponse
    {
        try {
            $banner = Banner::findOrFail($id);
            
            $transformedBanner = [
                'id' => $banner->id,
                'title' => $banner->title,
                'description' => $banner->description,
                'image_url' => $banner->image_url ? url('storage/' . $banner->image_url) : null,
                'background_color' => $banner->background_color,
                'text_color' => $banner->text_color,
                'button_text' => $banner->button_text,
                'button_url' => $banner->button_url,
                'button_color' => $banner->button_color,
                'position' => $banner->position,
                'order' => $banner->order,
                'is_active' => $banner->is_active,
                'created_at' => $banner->created_at,
                'updated_at' => $banner->updated_at,
            ];
            
            return response()->json([
                'success' => true,
                'data' => $transformedBanner
            ]);
            
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Bannière non trouvée',
                'error' => $e->getMessage()
            ], 404);
        }
    }

    /**
     * Créer une nouvelle bannière (pour les futurs besoins admin)
     */
    public function store(Request $request): JsonResponse
    {
        try {
            $validatedData = $request->validate([
                'title' => 'required|string|max:255',
                'description' => 'nullable|string|max:500',
                'image_url' => 'nullable|string',
                'background_color' => 'required|string|max:7',
                'text_color' => 'required|string|max:7',
                'button_text' => 'nullable|string|max:50',
                'button_url' => 'nullable|string',
                'button_color' => 'nullable|string|max:7',
                'position' => 'required|in:home,all_pages,specific',
                'order' => 'nullable|integer',
                'is_active' => 'boolean'
            ]);

            $banner = Banner::create($validatedData);

            return response()->json([
                'success' => true,
                'message' => 'Bannière créée avec succès',
                'data' => $banner
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la création de la bannière',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Mettre à jour une bannière
     */
    public function update(Request $request, string $id): JsonResponse
    {
        try {
            $banner = Banner::findOrFail($id);
            
            $validatedData = $request->validate([
                'title' => 'sometimes|required|string|max:255',
                'description' => 'nullable|string|max:500',
                'image_url' => 'nullable|string',
                'background_color' => 'sometimes|required|string|max:7',
                'text_color' => 'sometimes|required|string|max:7',
                'button_text' => 'nullable|string|max:50',
                'button_url' => 'nullable|string',
                'button_color' => 'nullable|string|max:7',
                'position' => 'sometimes|required|in:home,all_pages,specific',
                'order' => 'nullable|integer',
                'is_active' => 'boolean'
            ]);

            $banner->update($validatedData);

            return response()->json([
                'success' => true,
                'message' => 'Bannière mise à jour avec succès',
                'data' => $banner
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la mise à jour de la bannière',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Supprimer une bannière
     */
    public function destroy(string $id): JsonResponse
    {
        try {
            $banner = Banner::findOrFail($id);
            $banner->delete();

            return response()->json([
                'success' => true,
                'message' => 'Bannière supprimée avec succès'
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la suppression de la bannière',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}
