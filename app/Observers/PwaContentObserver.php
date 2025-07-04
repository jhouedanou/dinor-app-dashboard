<?php

namespace App\Observers;

use App\Traits\HasPwaRebuild;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Cache;

class PwaContentObserver
{
    use HasPwaRebuild;

    /**
     * Handle the model "created" event.
     */
    public function created($model): void
    {
        $this->handleContentChange('created', $model);
    }

    /**
     * Handle the model "updated" event.
     */
    public function updated($model): void
    {
        $this->handleContentChange('updated', $model);
    }

    /**
     * Handle the model "deleted" event.
     */
    public function deleted($model): void
    {
        $this->handleContentChange('deleted', $model);
    }

    /**
     * Handle the model "restored" event.
     */
    public function restored($model): void
    {
        $this->handleContentChange('restored', $model);
    }

    /**
     * Gère les changements de contenu et déclenche le rebuild PWA si nécessaire
     */
    private function handleContentChange(string $action, $model): void
    {
        try {
            $modelClass = get_class($model);
            $modelName = class_basename($modelClass);
            $contentType = $this->getContentType($modelClass);
            
            // Log de l'action pour debugging
            Log::info("PWA Content Change: {$action} {$modelName}", [
                'model' => $modelName,
                'action' => $action,
                'content_type' => $contentType,
                'id' => $model->id ?? null
            ]);
            
            // Vérifier si le modèle affecte la PWA
            if ($this->shouldTriggerPwaRebuild($model, $action)) {
                Log::info("Triggering PWA cache invalidation for {$modelName} {$action}");
                
                // Invalider le cache spécifique au type de contenu
                if ($contentType) {
                    static::invalidateContentCache($contentType);
                }
                
                // Déclencher le rebuild complet si nécessaire
                if ($this->shouldTriggerFullRebuild($action, $model)) {
                    static::triggerPwaRebuild();
                }
            }
            
        } catch (\Exception $e) {
            Log::error("Error in PwaContentObserver: " . $e->getMessage(), [
                'model' => get_class($model),
                'action' => $action,
                'error' => $e->getMessage()
            ]);
        }
    }

    /**
     * Détermine si un changement de modèle doit déclencher un rebuild PWA
     */
    private function shouldTriggerPwaRebuild($model, string $action): bool
    {
        $modelClass = get_class($model);
        
        // Modèles qui affectent la PWA
        $pwaModels = [
            \App\Models\Recipe::class,
            \App\Models\Event::class,
            \App\Models\Tip::class,
            \App\Models\DinorTv::class,
            \App\Models\Page::class,
            \App\Models\PwaMenuItem::class,
            \App\Models\Banner::class,
            \App\Models\Category::class,
        ];
        
        if (!in_array($modelClass, $pwaModels)) {
            return false;
        }
        
        // Pour les modèles publiés, vérifier si is_published a changé
        if (method_exists($model, 'getOriginal') && isset($model->is_published)) {
            $wasPublished = $model->getOriginal('is_published');
            $isPublished = $model->is_published;
            
            // Déclencher rebuild si le statut de publication change
            if ($wasPublished !== $isPublished) {
                return true;
            }
            
            // Déclencher rebuild seulement si le contenu est publié
            if (!$isPublished && $action !== 'deleted') {
                return false;
            }
        }
        
        // Toujours déclencher pour les suppressions et créations
        if (in_array($action, ['created', 'deleted', 'restored'])) {
            return true;
        }
        
        // Pour les mises à jour, vérifier si des champs importants ont changé
        if ($action === 'updated' && method_exists($model, 'wasChanged')) {
            $importantFields = ['title', 'name', 'label', 'description', 'url', 'content', 'is_published', 'is_featured', 'order'];
            
            foreach ($importantFields as $field) {
                if ($model->wasChanged($field)) {
                    return true;
                }
            }
        }
        
        return false;
    }
    
    /**
     * Détermine si un rebuild complet est nécessaire
     */
    private function shouldTriggerFullRebuild(string $action, $model): bool
    {
        // Rebuild complet pour les suppressions et créations
        if (in_array($action, ['created', 'deleted'])) {
            return true;
        }
        
        // Rebuild complet si des champs critiques changent
        if ($action === 'updated' && method_exists($model, 'wasChanged')) {
            $criticalFields = ['is_published', 'is_featured', 'title', 'name'];
            
            foreach ($criticalFields as $field) {
                if ($model->wasChanged($field)) {
                    return true;
                }
            }
        }
        
        return false;
    }
    
    /**
     * Obtient le type de contenu à partir de la classe du modèle
     */
    private function getContentType(string $modelClass): ?string
    {
        return match($modelClass) {
            \App\Models\Recipe::class => 'recipes',
            \App\Models\Event::class => 'events',
            \App\Models\Tip::class => 'tips',
            \App\Models\DinorTv::class => 'videos',
            \App\Models\Page::class => 'pages',
            \App\Models\PwaMenuItem::class => 'pwa-menu',
            \App\Models\Banner::class => 'banners',
            \App\Models\Category::class => 'categories',
            default => null
        };
    }

    /**
     * Invalide le cache pour un type de contenu spécifique
     */
    public static function invalidateContentCache(string $contentType): void
    {
        try {
            // Appeler l'endpoint d'invalidation du cache
            $response = \Illuminate\Support\Facades\Http::post(config('app.url') . '/api/v1/cache/invalidate-content', [
                'content_types' => [$contentType]
            ]);

            if ($response->successful()) {
                Log::info("Cache invalidé pour le type de contenu: {$contentType}");
            } else {
                Log::warning("Échec de l'invalidation du cache pour: {$contentType}", [
                    'status' => $response->status(),
                    'response' => $response->body()
                ]);
            }
        } catch (\Exception $e) {
            Log::error("Erreur lors de l'invalidation du cache pour {$contentType}: " . $e->getMessage());
        }
    }
}