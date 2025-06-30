<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Event;
use App\Models\Recipe;
use App\Models\Tip;

class ShareController extends Controller
{
    /**
     * Enregistrer un partage
     */
    public function track(Request $request)
    {
        $request->validate([
            'type' => 'required|in:event,recipe,tip',
            'id' => 'required|integer',
            'platform' => 'required|string'
        ]);

        $type = $request->input('type');
        $id = $request->input('id');
        $platform = $request->input('platform');

        // Trouver le modèle selon le type
        $model = null;
        switch ($type) {
            case 'event':
                $model = Event::find($id);
                break;
            case 'recipe':
                $model = Recipe::find($id);
                break;
            case 'tip':
                $model = Tip::find($id);
                break;
        }

        if (!$model) {
            return response()->json([
                'success' => false,
                'message' => 'Élément non trouvé'
            ], 404);
        }

        // Incrémenter le compteur de partages si la méthode existe
        if (method_exists($model, 'incrementShares')) {
            $model->incrementShares();
        }

        return response()->json([
            'success' => true,
            'message' => 'Partage enregistré',
            'data' => [
                'shares_count' => $model->shares_count ?? 0,
                'platform' => $platform
            ]
        ]);
    }
} 