<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Recipe;
use App\Models\Event;
use App\Models\DinorTv;
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
        $request->validate([
            'type' => 'required|in:recipe,event,dinor_tv',
            'id' => 'required|integer|exists:' . $this->getTableName($request->type) . ',id'
        ]);

        $model = $this->getModel($request->type, $request->id);
        
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

        return response()->json([
            'success' => true,
            'action' => $result['action'],
            'likes_count' => $result['likes_count'],
            'message' => $result['action'] === 'liked' ? 'Contenu aimé' : 'Like retiré'
        ]);
    }

    /**
     * Check if content is liked by current user/IP
     */
    public function check(Request $request): JsonResponse
    {
        $request->validate([
            'type' => 'required|in:recipe,event,dinor_tv',
            'id' => 'required|integer|exists:' . $this->getTableName($request->type) . ',id'
        ]);

        $model = $this->getModel($request->type, $request->id);
        
        if (!$model) {
            return response()->json([
                'success' => false,
                'message' => 'Contenu non trouvé'
            ], 404);
        }

        $userId = Auth::id();
        $ipAddress = $request->ip();

        $isLiked = $model->isLikedBy($userId, $ipAddress);

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
        $request->validate([
            'type' => 'required|in:recipe,event,dinor_tv',
            'id' => 'required|integer|exists:' . $this->getTableName($request->type) . ',id'
        ]);

        $model = $this->getModel($request->type, $request->id);
        
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
            default => ''
        };
    }
} 