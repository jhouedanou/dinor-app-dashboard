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
        // Support both old format (type/id) and new format (commentable_type/commentable_id)
        $type = $request->input('type') ?: $this->extractTypeFromCommentableType($request->input('commentable_type'));
        $id = $request->input('id') ?: $request->input('commentable_id');

        $request->validate([
            'per_page' => 'sometimes|integer|min:1|max:50'
        ]);

        // Manual validation for type and id
        if (!$type || !in_array($type, ['recipe', 'event', 'dinor_tv', 'tip'])) {
            return response()->json([
                'success' => false,
                'message' => 'Type de contenu invalide'
            ], 400);
        }

        if (!$id || !is_numeric($id)) {
            return response()->json([
                'success' => false,
                'message' => 'ID du contenu invalide'
            ], 400);
        }

        $model = $this->getModel($type, $id);
        
        if (!$model) {
            return response()->json([
                'success' => false,
                'message' => 'Contenu non trouvé'
            ], 404);
        }

        // Temporairement sans pagination pour debug
        $comments = $model->approvedComments()
                         ->with(['user:id,name', 'replies.user:id,name'])
                         ->get();

        \Log::info('📋 [Comments] Commentaires trouvés:', ['count' => $comments->count(), 'comments' => $comments->toArray()]);

        return response()->json([
            'success' => true,
            'data' => $comments->toArray(),
            'total' => $comments->count()
        ]);
    }

    /**
     * Store a new comment
     */
    public function store(Request $request): JsonResponse
    {
        // Support both old format (type/id) and new format (commentable_type/commentable_id)
        $type = $request->input('type') ?: $this->extractTypeFromCommentableType($request->input('commentable_type'));
        $id = $request->input('id') ?: $request->input('commentable_id');

        // Log des données reçues pour debug
        \Log::info('📝 [Comments] Données reçues:', ['data' => $request->all()]);
        \Log::info('📝 [Comments] Type extrait:', ['type' => $type]);
        \Log::info('📝 [Comments] ID extrait:', ['id' => $id]);
        \Log::info('📝 [Comments] User connecté:', ['user' => Auth::check() ? Auth::user()->toArray() : 'Non connecté']);

        // Validation différente selon si l'utilisateur est connecté ou non
        $validationRules = [
            'content' => 'required|string|min:3|max:1000',
            'parent_id' => 'sometimes|integer|exists:comments,id',
            'captcha_answer' => 'sometimes|integer'
        ];

        // Pour les utilisateurs anonymes, exiger nom et email
        if (!Auth::check()) {
            $validationRules['author_name'] = 'required|string|min:2|max:100';
            $validationRules['author_email'] = 'required|email|max:255';
        }

        try {
            $request->validate($validationRules);
        } catch (\Illuminate\Validation\ValidationException $e) {
            \Log::error('❌ [Comments] Erreur de validation:', ['errors' => $e->errors()]);
            return response()->json([
                'success' => false,
                'message' => 'Erreur de validation',
                'errors' => $e->errors()
            ], 422);
        }

        // Manual validation for type and id
        if (!$type || !in_array($type, ['recipe', 'event', 'dinor_tv', 'tip'])) {
            return response()->json([
                'success' => false,
                'message' => 'Type de contenu invalide'
            ], 400);
        }

        if (!$id || !is_numeric($id)) {
            return response()->json([
                'success' => false,
                'message' => 'ID du contenu invalide'
            ], 400);
        }

        // Vérification du captcha (désactivé temporairement pour debug)
        // if ($request->has('captcha_answer')) {
        //     $captchaSession = session('captcha_' . $request->ip());
        //     if (!$captchaSession || $captchaSession['answer'] != $request->captcha_answer || 
        //         (time() - $captchaSession['created_at']) > 300) { // 5 minutes
        //         return response()->json([
        //             'success' => false,
        //             'message' => 'Captcha invalide ou expiré',
        //             'requires_captcha' => true
        //         ], 400);
        //     }
        // }

        $model = $this->getModel($type, $id);
        
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
                $parentComment->commentable_id != $id || 
                $parentComment->commentable_type != get_class($model)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Commentaire parent invalide'
                ], 400);
            }
        }

        $ipAddress = $request->ip();
        $userAgent = $request->userAgent();

        // Différencier utilisateur connecté vs anonyme
        if (Auth::check()) {
            // Utilisateur connecté
            $user = Auth::user();
            $commentData = [
                'user_id' => $user->id,
                'author_name' => $user->name,
                'author_email' => $user->email,
                'content' => $request->content,
                'is_approved' => true,
                'ip_address' => $ipAddress,
                'user_agent' => $userAgent,
                'parent_id' => $request->parent_id
            ];
        } else {
            // Utilisateur anonyme
            $commentData = [
                'user_id' => null,
                'author_name' => $request->author_name,
                'author_email' => $request->author_email,
                'content' => $request->content,
                'is_approved' => true, // Auto-approve for now, can be changed to false for moderation
                'ip_address' => $ipAddress,
                'user_agent' => $userAgent,
                'parent_id' => $request->parent_id
            ];
        }

        $comment = $model->addComment($commentData);

        // Effacer le captcha après utilisation (temporairement désactivé)
        // session()->forget('captcha_' . $request->ip());

        $comment->load(['user:id,name']);
        
        \Log::info('✅ [Comments] Commentaire créé avec succès:', ['comment' => $comment->toArray()]);

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
    public function destroy(Request $request, $id): JsonResponse
    {
        // Log pour debug
        \Log::info('🗑️ [Comments] Tentative de suppression:', [
            'comment_id' => $id,
            'user_id' => Auth::id(),
            'user_authenticated' => Auth::check(),
            'request_data' => $request->all()
        ]);

        // Vérifier que l'utilisateur est connecté
        if (!Auth::check()) {
            return response()->json([
                'success' => false,
                'message' => 'Vous devez être connecté pour supprimer un commentaire'
            ], 401);
        }

        // Trouver le commentaire manuellement
        $comment = Comment::find($id);
        
        if (!$comment) {
            \Log::warning('❌ [Comments] Commentaire non trouvé:', ['comment_id' => $id]);
            return response()->json([
                'success' => false,
                'message' => 'Commentaire non trouvé'
            ], 404);
        }

        $userId = Auth::id();
        $ipAddress = $request->ip();

        \Log::info('🔍 [Comments] Vérification des permissions:', [
            'comment_user_id' => $comment->user_id,
            'current_user_id' => $userId,
            'can_modify' => $comment->canModify($userId, $ipAddress)
        ]);

        // Vérifier que l'utilisateur peut supprimer ce commentaire
        if (!$comment->canModify($userId, $ipAddress)) {
            \Log::warning('❌ [Comments] Permission refusée pour la suppression:', [
                'comment_id' => $id,
                'user_id' => $userId
            ]);
            return response()->json([
                'success' => false,
                'message' => 'Vous n\'êtes pas autorisé à supprimer ce commentaire'
            ], 403);
        }

        $comment->delete();

        \Log::info('✅ [Comments] Commentaire supprimé avec succès:', ['comment_id' => $id]);

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

    /**
     * Extract type from commentable_type (e.g., "App\Models\Recipe" -> "recipe")
     */
    private function extractTypeFromCommentableType(?string $commentableType): ?string
    {
        if (!$commentableType) {
            return null;
        }

        return match($commentableType) {
            'App\\Models\\Recipe', 'App\Models\Recipe' => 'recipe',
            'App\\Models\\Event', 'App\Models\Event' => 'event',
            'App\\Models\\DinorTv', 'App\Models\DinorTv' => 'dinor_tv',
            'App\\Models\\Tip', 'App\Models\Tip' => 'tip',
            default => null
        };
    }

    /**
     * Generate a simple math captcha
     */
    public function generateCaptcha(Request $request): JsonResponse
    {
        $num1 = rand(1, 10);
        $num2 = rand(1, 10);
        $operations = ['+', '-', '*'];
        $operation = $operations[array_rand($operations)];
        
        $answer = match($operation) {
            '+' => $num1 + $num2,
            '-' => $num1 - $num2,
            '*' => $num1 * $num2,
        };

        // Stocker en session avec l'IP de l'utilisateur
        session(['captcha_' . $request->ip() => [
            'answer' => $answer,
            'created_at' => time()
        ]]);

        return response()->json([
            'success' => true,
            'data' => [
                'question' => "{$num1} {$operation} {$num2} = ?",
                'expires_in' => 300 // 5 minutes
            ]
        ]);
    }
} 