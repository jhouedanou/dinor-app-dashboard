<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Recipe;
use App\Models\Event;
use App\Models\DinorTv;
use App\Models\Tip;
use App\Models\Comment;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;
use Illuminate\Validation\Rule;

class CommentController extends Controller
{
    /**
     * Get comments for a content
     */
    public function index(Request $request): JsonResponse
    {
        $request->validate([
            'type' => 'required|in:recipe,event,dinor_tv,tip',
            'id' => 'required|integer|exists:' . $this->getTableName($request->type) . ',id',
            'per_page' => 'sometimes|integer|min:1|max:50'
        ]);

        $model = $this->getModel($request->type, $request->id);
        
        if (!$model) {
            return response()->json([
                'success' => false,
                'message' => 'Contenu non trouvé'
            ], 404);
        }

        $perPage = $request->get('per_page', 10);

        $comments = $model->approvedComments()
                         ->with(['user:id,name', 'replies.user:id,name'])
                         ->paginate($perPage);

        return response()->json([
            'success' => true,
            'data' => $comments->items(),
            'pagination' => [
                'current_page' => $comments->currentPage(),
                'last_page' => $comments->lastPage(),
                'per_page' => $comments->perPage(),
                'total' => $comments->total()
            ]
        ]);
    }

    /**
     * Store a new comment
     */
    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'type' => 'required|in:recipe,event,dinor_tv,tip',
            'id' => 'required|integer|exists:' . $this->getTableName($request->type) . ',id',
            'content' => 'required|string|min:3|max:1000',
            'author_name' => 'required_without:user_id|string|max:100',
            'author_email' => 'required_without:user_id|email|max:255',
            'parent_id' => 'sometimes|integer|exists:comments,id'
        ]);

        $model = $this->getModel($request->type, $request->id);
        
        if (!$model) {
            return response()->json([
                'success' => false,
                'message' => 'Contenu non trouvé'
            ], 404);
        }

        // Vérifier que le parent comment appartient au même contenu
        if ($request->parent_id) {
            $parentComment = Comment::find($request->parent_id);
            if (!$parentComment || 
                $parentComment->commentable_id != $request->id || 
                $parentComment->commentable_type != get_class($model)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Commentaire parent invalide'
                ], 400);
            }
        }

        $userId = Auth::id();
        $ipAddress = $request->ip();
        $userAgent = $request->userAgent();

        $comment = $model->addComment([
            'user_id' => $userId,
            'author_name' => $request->author_name,
            'author_email' => $request->author_email,
            'content' => $request->content,
            'is_approved' => true, // Auto-approve for now, can be changed to false for moderation
            'ip_address' => $ipAddress,
            'user_agent' => $userAgent,
            'parent_id' => $request->parent_id
        ]);

        $comment->load(['user:id,name']);

        return response()->json([
            'success' => true,
            'data' => $comment,
            'message' => 'Commentaire ajouté avec succès'
        ], 201);
    }

    /**
     * Update a comment
     */
    public function update(Request $request, Comment $comment): JsonResponse
    {
        $request->validate([
            'content' => 'required|string|min:3|max:1000'
        ]);

        $userId = Auth::id();
        $ipAddress = $request->ip();

        // Vérifier que l'utilisateur peut modifier ce commentaire
        if (!$comment->canModify($userId, $ipAddress)) {
            return response()->json([
                'success' => false,
                'message' => 'Vous n\'êtes pas autorisé à modifier ce commentaire'
            ], 403);
        }

        $comment->update([
            'content' => $request->content
        ]);

        $comment->load(['user:id,name']);

        return response()->json([
            'success' => true,
            'data' => $comment,
            'message' => 'Commentaire mis à jour avec succès'
        ]);
    }

    /**
     * Delete a comment
     */
    public function destroy(Request $request, Comment $comment): JsonResponse
    {
        $userId = Auth::id();
        $ipAddress = $request->ip();

        // Vérifier que l'utilisateur peut supprimer ce commentaire
        if (!$comment->canModify($userId, $ipAddress)) {
            return response()->json([
                'success' => false,
                'message' => 'Vous n\'êtes pas autorisé à supprimer ce commentaire'
            ], 403);
        }

        $comment->delete();

        return response()->json([
            'success' => true,
            'message' => 'Commentaire supprimé avec succès'
        ]);
    }

    /**
     * Get replies for a comment
     */
    public function replies(Comment $comment): JsonResponse
    {
        $replies = $comment->replies()
                          ->with(['user:id,name'])
                          ->get();

        return response()->json([
            'success' => true,
            'data' => $replies
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