<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\UserFavorite;
use App\Models\Recipe;
use App\Models\Event;
use App\Models\Tip;
use App\Models\DinorTv;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;
use Illuminate\Validation\Rule;

class FavoriteController extends Controller
{
    /**
     * Get user's favorites
     */
    public function index(Request $request): JsonResponse
    {
        if (!Auth::check()) {
            return response()->json([
                'success' => false,
                'message' => 'Vous devez être connecté pour voir vos favoris'
            ], 401);
        }

        $request->validate([
            'type' => 'sometimes|string|in:recipe,event,tip,dinor_tv',
            'per_page' => 'sometimes|integer|min:1|max:50'
        ]);

        $userId = Auth::id();
        $type = $request->input('type');
        $perPage = $request->input('per_page', 20);

        $query = UserFavorite::forUser($userId)
                            ->with('favoritable')
                            ->orderBy('favorited_at', 'desc');

        if ($type) {
            $modelClass = $this->getModelClass($type);
            if ($modelClass) {
                $query->forType($modelClass);
            }
        }

        $favorites = $query->paginate($perPage);

        // Transformer les données pour le frontend
        $favoritesData = $favorites->getCollection()->map(function ($favorite) {
            $favoritable = $favorite->favoritable;
            if (!$favoritable) return null;

            return [
                'id' => $favorite->id,
                'favorited_at' => $favorite->favorited_at,
                'type' => $this->getTypeFromModel($favoritable),
                'content' => [
                    'id' => $favoritable->id,
                    'title' => $favoritable->title,
                    'description' => $favoritable->description ?? $favoritable->short_description ?? null,
                    'image' => $favoritable->image ?? null,
                    'created_at' => $favoritable->created_at,
                    // Statistiques
                    'likes_count' => $favoritable->likes_count ?? 0,
                    'comments_count' => $favoritable->comments_count ?? 0,
                    'favorites_count' => $favoritable->favorites_count ?? 0,
                ]
            ];
        })->filter(); // Retirer les null

        return response()->json([
            'success' => true,
            'data' => $favoritesData->values(),
            'pagination' => [
                'current_page' => $favorites->currentPage(),
                'last_page' => $favorites->lastPage(),
                'per_page' => $favorites->perPage(),
                'total' => $favorites->total(),
            ]
        ]);
    }

    /**
     * Check if an item is favorited by the user
     */
    public function check(Request $request): JsonResponse
    {
        if (!Auth::check()) {
            return response()->json([
                'success' => true,
                'is_favorited' => false
            ]);
        }

        $request->validate([
            'type' => 'required|string|in:recipe,event,tip,dinor_tv',
            'id' => 'required|integer|min:1'
        ]);

        $userId = Auth::id();
        $type = $request->input('type');
        $id = $request->input('id');

        $modelClass = $this->getModelClass($type);
        if (!$modelClass) {
            return response()->json([
                'success' => false,
                'message' => 'Type de contenu invalide'
            ], 400);
        }

        $isFavorited = UserFavorite::isFavorited($userId, $id, $modelClass);

        return response()->json([
            'success' => true,
            'is_favorited' => $isFavorited
        ]);
    }

    /**
     * Toggle favorite status
     */
    public function toggle(Request $request): JsonResponse
    {
        if (!Auth::check()) {
            return response()->json([
                'success' => false,
                'message' => 'Vous devez être connecté pour ajouter aux favoris'
            ], 401);
        }

        $request->validate([
            'type' => 'required|string|in:recipe,event,tip,dinor_tv',
            'id' => 'required|integer|min:1'
        ]);

        $userId = Auth::id();
        $type = $request->input('type');
        $id = $request->input('id');

        $modelClass = $this->getModelClass($type);
        if (!$modelClass) {
            return response()->json([
                'success' => false,
                'message' => 'Type de contenu invalide'
            ], 400);
        }

        // Vérifier que l'item existe
        $model = $modelClass::find($id);
        if (!$model) {
            return response()->json([
                'success' => false,
                'message' => 'Contenu non trouvé'
            ], 404);
        }

        $isFavorited = UserFavorite::toggleFavorite($userId, $id, $modelClass);

        // Compter les favoris pour cet item
        $favoritesCount = UserFavorite::where('favoritable_id', $id)
                                     ->where('favoritable_type', $modelClass)
                                     ->count();

        return response()->json([
            'success' => true,
            'is_favorited' => $isFavorited,
            'message' => $isFavorited ? 'Ajouté aux favoris' : 'Retiré des favoris',
            'data' => [
                'total_favorites' => $favoritesCount
            ]
        ]);
    }

    /**
     * Remove from favorites
     */
    public function remove(Request $request, UserFavorite $favorite): JsonResponse
    {
        if (!Auth::check()) {
            return response()->json([
                'success' => false,
                'message' => 'Vous devez être connecté'
            ], 401);
        }

        $userId = Auth::id();

        // Vérifier que ce favori appartient à l'utilisateur connecté
        if ($favorite->user_id !== $userId) {
            return response()->json([
                'success' => false,
                'message' => 'Vous ne pouvez pas supprimer ce favori'
            ], 403);
        }

        $favorite->delete();

        return response()->json([
            'success' => true,
            'message' => 'Favori supprimé avec succès'
        ]);
    }

    /**
     * Get model class from type
     */
    private function getModelClass(string $type): ?string
    {
        return match($type) {
            'recipe' => Recipe::class,
            'event' => Event::class,
            'tip' => Tip::class,
            'dinor_tv' => DinorTv::class,
            default => null
        };
    }

    /**
     * Get type from model instance
     */
    private function getTypeFromModel($model): string
    {
        return match(get_class($model)) {
            Recipe::class => 'recipe',
            Event::class => 'event',
            Tip::class => 'tip',
            DinorTv::class => 'dinor_tv',
            default => 'unknown'
        };
    }
}