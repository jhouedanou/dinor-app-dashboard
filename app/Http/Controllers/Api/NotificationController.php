<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\PushNotification;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    /**
     * Récupérer les notifications pour l'utilisateur connecté
     * 
     * @param Request $request
     * @return JsonResponse
     */
    public function index(Request $request): JsonResponse
    {
        try {
            // Récupérer les notifications envoyées (statut 'sent')
            // que l'utilisateur peut voir
            $notifications = PushNotification::where('status', 'sent')
                ->where(function ($query) {
                    // Notifications pour tous les utilisateurs ou audience spécifique
                    $query->where('target_audience', 'all')
                          ->orWhere('target_audience', 'users')
                          ->orWhereNull('target_audience');
                })
                ->orderBy('sent_at', 'desc')
                ->orderBy('created_at', 'desc')
                ->paginate(20);

            // Transformer les données pour l'app mobile
            $formattedNotifications = $notifications->getCollection()->map(function ($notification) {
                return [
                    'id' => $notification->id,
                    'title' => $notification->title,
                    'message' => $notification->message,
                    'icon' => $notification->icon,
                    'content_type' => $notification->content_type,
                    'content_id' => $notification->content_id,
                    'content_name' => $notification->getContentName(),
                    'deep_link' => $notification->getDeepLinkUrl(),
                    'url' => $notification->url,
                    'sent_at' => $notification->sent_at?->toISOString(),
                    'created_at' => $notification->created_at->toISOString(),
                ];
            });

            return response()->json([
                'success' => true,
                'data' => $formattedNotifications,
                'pagination' => [
                    'current_page' => $notifications->currentPage(),
                    'last_page' => $notifications->lastPage(),
                    'per_page' => $notifications->perPage(),
                    'total' => $notifications->total(),
                    'has_more_pages' => $notifications->hasMorePages(),
                ]
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la récupération des notifications: ' . $e->getMessage(),
                'data' => []
            ], 500);
        }
    }

    /**
     * Marquer une notification comme lue (optionnel pour le futur)
     * 
     * @param Request $request
     * @param int $id
     * @return JsonResponse
     */
    public function markAsRead(Request $request, int $id): JsonResponse
    {
        try {
            // Pour le moment, on retourne juste un succès
            // On pourrait implémenter un système de lecture plus tard
            
            return response()->json([
                'success' => true,
                'message' => 'Notification marquée comme lue'
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors du marquage de la notification: ' . $e->getMessage()
            ], 500);
        }
    }
} 