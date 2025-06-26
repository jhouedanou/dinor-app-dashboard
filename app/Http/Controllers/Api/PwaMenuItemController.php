<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\PwaMenuItem;
use Illuminate\Http\JsonResponse;

class PwaMenuItemController extends Controller
{
    /**
     * Récupère tous les éléments de menu PWA actifs
     */
    public function index(): JsonResponse
    {
        try {
            $menuItems = PwaMenuItem::active()
                ->ordered()
                ->get()
                ->map(function ($item) {
                    return [
                        'id' => $item->id,
                        'name' => $item->name,
                        'label' => $item->label,
                        'icon' => $item->icon,
                        'path' => $item->path,
                        'action_type' => $item->action_type,
                        'web_url' => $item->web_url,
                        'order' => $item->order,
                    ];
                });

            return response()->json([
                'success' => true,
                'data' => $menuItems
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la récupération des éléments de menu',
                'error' => $e->getMessage()
            ], 500);
        }
    }
} 