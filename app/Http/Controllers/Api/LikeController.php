<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Recipe;
use App\Models\Event;
use App\Models\DinorTv;
use App\Models\Tip;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;

class LikeController extends Controller
{
    /**
     * Toggle like for a content
     */
    public function toggle(Request $request): JsonResponse
    {
        // Vérifier que l'utilisateur est connecté
        if (!Auth::check()) {
            return response()->json([
                'success' => false,
                'message' => 'Vous devez vous connecter ou vous inscrire pour aimer ce contenu',
                'requires_auth' => true,
                'login_url' => '/login',
                'register_url' => '/register'
            ], 401);
        }

        // Récupérer les données du JSON body ou des paramètres
        $jsonData = $request->json()->all() ?: [];
        $type = $jsonData['type'] ?? $request->input('type');
        $id = $jsonData['id'] ?? $request->input('id');

        // Vérification préalable des données avant validation
        if (!$type || !$id) {
            return response()->json([
                'success' => false,
                'message' => 'Paramètres manquants: type et id sont requis'
            ], 422);
        }

        // Valider les données
        $validator = validator([
            'type' => $type,
            'id' => $id
        ], [
            'type' => 'required|in:recipe,event,dinor_tv,tip',
            'id' => 'required|integer|exists:' . $this->getTableName($type) . ',id'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Données invalides',
                'errors' => $validator->errors()
            ], 422);
        }

        $model = $this->getModel($type, $id);
        
        if (!$model) {
            return response()->json([
                'success' => false,
                'message' => 'Contenu non trouvé'
            ], 404);
        }

        $userId = Auth::id();
        $ipAddress = $request->ip();
        $userAgent = $request->userAgent();

        $result = $model->toggleLike($userId, $ipAddress, $userAgent);

        // Toggle également le favori pour l'utilisateur connecté
        $favoriteResult = null;
        if ($userId) {
            $favoriteResult = $model->toggleFavorite($userId);
        }

        // Recalculer et mettre à jour les compteurs réels
        $actualCount = $model->likes()->count();
        $actualFavoritesCount = $model->favorites()->count();
        $model->update([
            'likes_count' => $actualCount,
            'favorites_count' => $actualFavoritesCount
        ]);

        return response()->json([
            'success' => true,
            'action' => $result['action'],
            'likes_count' => $actualCount,
            'favorites_count' => $actualFavoritesCount,
            'favorite_action' => $favoriteResult ? $favoriteResult['action'] : null,
            'message' => $result['action'] === 'liked' ? 'Contenu aimé et ajouté aux favoris' : 'Like et favori retirés'
        ]);
    }

    /**
     * Check if content is liked by current user/IP
     */
    public function check(Request $request): JsonResponse
    {
        // Récupérer les données du JSON body ou des paramètres
        $jsonData = $request->json()->all() ?: [];
        $type = $jsonData['type'] ?? $request->input('type');
        $id = $jsonData['id'] ?? $request->input('id');

        // Vérification préalable des données avant validation
        if (!$type || !$id) {
            return response()->json([
                'success' => false,
                'message' => 'Paramètres manquants: type et id sont requis'
            ], 422);
        }

        // Valider les données
        $validator = validator([
            'type' => $type,
            'id' => $id
        ], [
            'type' => 'required|in:recipe,event,dinor_tv,tip',
            'id' => 'required|integer|exists:' . $this->getTableName($type) . ',id'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Données invalides',
                'errors' => $validator->errors()
            ], 422);
        }

        $model = $this->getModel($type, $id);
        
        if (!$model) {
            return response()->json([
                'success' => false,
                'message' => 'Contenu non trouvé'
            ], 404);
        }

        $userId = Auth::id();
        $ipAddress = $request->ip();

        // Utiliser l'ID utilisateur si connecté, sinon l'IP
        $userIdentifier = $userId ?: $ipAddress;
        $isLiked = $model->isLikedBy($userIdentifier);

        return response()->json([
            'success' => true,
            'is_liked' => $isLiked,
            'likes_count' => $model->likes_count
        ]);
    }

    /**
     * Get likes for a content
     */
    public function index(Request $request): JsonResponse
    {
        // Récupérer les données du JSON body ou des paramètres
        $jsonData = $request->json()->all() ?: [];
        $type = $jsonData['type'] ?? $request->input('type');
        $id = $jsonData['id'] ?? $request->input('id');

        // Vérification préalable des données avant validation
        if (!$type || !$id) {
            return response()->json([
                'success' => false,
                'message' => 'Paramètres manquants: type et id sont requis'
            ], 422);
        }

        // Valider les données
        $validator = validator([
            'type' => $type,
            'id' => $id
        ], [
            'type' => 'required|in:recipe,event,dinor_tv,tip',
            'id' => 'required|integer|exists:' . $this->getTableName($type) . ',id'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Données invalides',
                'errors' => $validator->errors()
            ], 422);
        }

        $model = $this->getModel($type, $id);
        
        if (!$model) {
            return response()->json([
                'success' => false,
                'message' => 'Contenu non trouvé'
            ], 404);
        }

        $likes = $model->likes()
                      ->with('user:id,name')
                      ->orderBy('created_at', 'desc')
                      ->paginate(20);

        return response()->json([
            'success' => true,
            'data' => $likes->items(),
            'pagination' => [
                'current_page' => $likes->currentPage(),
                'last_page' => $likes->lastPage(),
                'per_page' => $likes->perPage(),
                'total' => $likes->total()
            ]
        ]);
    }

    /**
     * Get model instance by type and ID
     */
    private function getModel(string $type, int $id)
    {
        return match($type) {
            'recipe' => Recipe::find($id),
            'event' => Event::find($id),
            'dinor_tv' => DinorTv::find($id),
            'tip' => Tip::find($id),
            default => null
        };
    }

    /**
     * Get table name by type
     */
    private function getTableName(string $type): string
    {
        return match($type) {
            'recipe' => 'recipes',
            'event' => 'events',
            'dinor_tv' => 'dinor_tv',
            'tip' => 'tips',
            default => ''
        };
    }
} 