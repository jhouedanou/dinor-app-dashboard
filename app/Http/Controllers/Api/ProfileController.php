<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rules\Password;

class ProfileController extends Controller
{
    /**
     * Get user profile information
     */
    public function show(): JsonResponse
    {
        $user = Auth::guard('sanctum')->user();
        
        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Vous devez être connecté'
            ], 401);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'created_at' => $user->created_at,
                'updated_at' => $user->updated_at,
            ]
        ]);
    }

    /**
     * Update user profile name
     */
    public function updateName(Request $request): JsonResponse
    {
        $user = Auth::guard('sanctum')->user();
        
        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Vous devez être connecté'
            ], 401);
        }

        $request->validate([
            'name' => 'required|string|min:2|max:255',
        ]);
        $oldName = $user->name;
        
        $user->update([
            'name' => $request->name
        ]);

        \Log::info('👤 [Profile] Nom d\'utilisateur mis à jour:', [
            'user_id' => $user->id,
            'old_name' => $oldName,
            'new_name' => $request->name
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Nom d\'utilisateur mis à jour avec succès',
            'data' => [
                'name' => $user->fresh()->name
            ]
        ]);
    }

    /**
     * Update user password
     */
    public function updatePassword(Request $request): JsonResponse
    {
        $user = Auth::guard('sanctum')->user();
        
        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Vous devez être connecté'
            ], 401);
        }

        $request->validate([
            'current_password' => 'required|string',
            'new_password' => ['required', 'string', Password::min(8)->letters()->numbers(), 'confirmed'],
            'new_password_confirmation' => 'required|string'
        ]);

        // Vérifier le mot de passe actuel
        if (!Hash::check($request->current_password, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Le mot de passe actuel est incorrect',
                'errors' => [
                    'current_password' => ['Le mot de passe actuel est incorrect']
                ]
            ], 422);
        }

        // Mettre à jour le mot de passe
        $user->update([
            'password' => Hash::make($request->new_password)
        ]);

        \Log::info('🔐 [Profile] Mot de passe mis à jour:', [
            'user_id' => $user->id,
            'user_email' => $user->email
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Mot de passe mis à jour avec succès'
        ]);
    }

    /**
     * Request data deletion (GDPR compliance)
     */
    public function requestDataDeletion(Request $request): JsonResponse
    {
        $user = Auth::guard('sanctum')->user();
        
        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Vous devez être connecté'
            ], 401);
        }

        $request->validate([
            'reason' => 'sometimes|string|max:500',
            'confirm' => 'required|boolean|accepted'
        ]);

        // Log de la demande de suppression pour traitement manuel
        \Log::warning('🗑️ [Profile] Demande de suppression de données:', [
            'user_id' => $user->id,
            'user_name' => $user->name,
            'user_email' => $user->email,
            'reason' => $request->input('reason', 'Aucune raison spécifiée'),
            'requested_at' => now(),
            'ip_address' => $request->ip(),
            'user_agent' => $request->userAgent()
        ]);

        // Dans un vrai système, ceci devrait créer une tâche de suppression
        // et notifier les administrateurs pour traitement manuel
        
        // Ici, on peut ajouter l'utilisateur à une table de demandes de suppression
        // ou envoyer un email aux administrateurs

        return response()->json([
            'success' => true,
            'message' => 'Votre demande de suppression de données a été enregistrée. Elle sera traitée dans les 30 jours conformément au RGPD. Vous recevrez une confirmation par email.'
        ]);
    }

    /**
     * Get user statistics
     */
    public function getStats(): JsonResponse
    {
        $user = Auth::guard('sanctum')->user();
        
        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Vous devez être connecté'
            ], 401);
        }

        // Compter les favoris par type
        $favoritesStats = \DB::table('user_favorites')
            ->where('user_id', $user->id)
            ->select('favoritable_type', \DB::raw('count(*) as count'))
            ->groupBy('favoritable_type')
            ->get()
            ->mapWithKeys(function ($item) {
                $type = match($item->favoritable_type) {
                    'App\\Models\\Recipe' => 'recipes',
                    'App\\Models\\Tip' => 'tips',
                    'App\\Models\\Event' => 'events',
                    'App\\Models\\DinorTv' => 'videos',
                    default => 'other'
                };
                return [$type => $item->count];
            });

        // Compter les commentaires de l'utilisateur
        $commentsCount = \DB::table('comments')
            ->where('user_id', $user->id)
            ->where('is_approved', true)
            ->count();

        // Compter les likes de l'utilisateur
        $likesCount = \DB::table('likes')
            ->where('user_id', $user->id)
            ->count();

        return response()->json([
            'success' => true,
            'data' => [
                'total_favorites' => $favoritesStats->sum(),
                'favorites_by_type' => $favoritesStats,
                'comments_count' => $commentsCount,
                'likes_count' => $likesCount,
                'member_since' => $user->created_at
            ]
        ]);
    }
}