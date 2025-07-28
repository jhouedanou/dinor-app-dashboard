<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Event;
use App\Models\Recipe;
use App\Models\Tip;
use App\Models\DinorTv;

class ShareController extends Controller
{
    /**
     * Récupérer l'URL de partage
     */
    public function getShareUrl(Request $request)
    {
        $request->validate([
            'type' => 'required|in:event,recipe,tip,video',
            'id' => 'required|integer',
            'platform' => 'nullable|string'
        ]);

        $type = $request->input('type');
        $id = $request->input('id');
        $platform = $request->input('platform');

        // Trouver le modèle selon le type
        $model = $this->getModelByType($type, $id);

        if (!$model) {
            return response()->json([
                'success' => false,
                'message' => 'Élément non trouvé'
            ], 404);
        }

        // Générer l'URL de partage
        $shareUrl = $this->generateShareUrl($type, $id, $model, $platform);

        return response()->json([
            'success' => true,
            'data' => [
                'url' => $shareUrl,
                'type' => $type,
                'id' => $id,
                'platform' => $platform
            ]
        ]);
    }

    /**
     * Récupérer les métadonnées de partage
     */
    public function getShareMetadata(Request $request)
    {
        $request->validate([
            'type' => 'required|in:event,recipe,tip,video',
            'id' => 'required|integer'
        ]);

        $type = $request->input('type');
        $id = $request->input('id');

        // Trouver le modèle selon le type
        $model = $this->getModelByType($type, $id);

        if (!$model) {
            return response()->json([
                'success' => false,
                'message' => 'Élément non trouvé'
            ], 404);
        }

        // Générer les métadonnées
        $metadata = $this->generateMetadata($type, $model);

        return response()->json([
            'success' => true,
            'data' => $metadata
        ]);
    }

    /**
     * Enregistrer un partage
     */
    public function trackShare(Request $request)
    {
        $request->validate([
            'type' => 'required|in:event,recipe,tip,video',
            'id' => 'required|integer',
            'platform' => 'required|string'
        ]);

        $type = $request->input('type');
        $id = $request->input('id');
        $platform = $request->input('platform');

        // Trouver le modèle selon le type
        $model = $this->getModelByType($type, $id);

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

    /**
     * Trouver le modèle selon le type
     */
    private function getModelByType(string $type, int $id)
    {
        switch ($type) {
            case 'event':
                return Event::find($id);
            case 'recipe':
                return Recipe::find($id);
            case 'tip':
                return Tip::find($id);
            case 'video':
                return DinorTv::find($id);
            default:
                return null;
        }
    }

    /**
     * Générer l'URL de partage
     */
    private function generateShareUrl(string $type, int $id, $model, ?string $platform = null): string
    {
        $baseUrl = config('app.url');
        
        // URL de base selon le type
        $url = match($type) {
            'event' => "{$baseUrl}/events/{$id}",
            'recipe' => "{$baseUrl}/recipes/{$id}",
            'tip' => "{$baseUrl}/tips/{$id}",
            'video' => "{$baseUrl}/videos/{$id}",
            default => "{$baseUrl}"
        };

        // Ajouter des paramètres spécifiques selon la plateforme
        if ($platform) {
            $url .= "?utm_source=mobile&utm_medium={$platform}&utm_campaign=share";
        } else {
            $url .= "?utm_source=mobile&utm_medium=app&utm_campaign=share";
        }

        return $url;
    }

    /**
     * Générer les métadonnées de partage
     */
    private function generateMetadata(string $type, $model): array
    {
        $metadata = [
            'title' => $model->title ?? $model->name ?? 'Dinor',
            'description' => $model->description ?? $model->short_description ?? 'Découvrez ceci sur Dinor',
            'image' => $model->featured_image_url ?? $model->image_url ?? null,
            'type' => $type,
        ];

        // Ajouter des métadonnées spécifiques selon le type
        switch ($type) {
            case 'recipe':
                $metadata['cooking_time'] = $model->cooking_time ?? null;
                $metadata['servings'] = $model->servings ?? null;
                $metadata['difficulty'] = $model->difficulty ?? null;
                break;
                
            case 'event':
                $metadata['date'] = $model->event_date ?? null;
                $metadata['location'] = $model->location ?? null;
                $metadata['start_time'] = $model->start_time ?? null;
                $metadata['end_time'] = $model->end_time ?? null;
                break;
                
            case 'tip':
                $metadata['category'] = $model->category ?? null;
                $metadata['difficulty'] = $model->difficulty ?? null;
                break;
                
            case 'video':
                $metadata['duration'] = $model->duration ?? null;
                $metadata['category'] = $model->category ?? null;
                break;
        }

        return $metadata;
    }
} 