<?php

namespace App\Http\Controllers\PWA;

use App\Http\Controllers\Controller;
use App\Models\PwaMenuItem;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class PwaMenuItemController extends Controller
{
    /**
     * Afficher la liste des éléments de menu PWA actifs
     */
    public function index(Request $request): JsonResponse
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
                        'is_active' => $item->is_active,
                    ];
                });

            return response()->json([
                'success' => true,
                'data' => $menuItems,
                'count' => $menuItems->count()
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