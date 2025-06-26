<?php

namespace App\Observers;

use App\Traits\HasPwaRebuild;
use Illuminate\Support\Facades\Log;

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
            
            // Log de l'action pour debugging
            Log::info("PWA Content Change: {$action} {$modelName}", [
                'model' => $modelName,
                'action' => $action,
                'id' => $model->id ?? null
            ]);
            
            // Vérifier si le modèle affecte la PWA
            if ($this->shouldTriggerPwaRebuild($model, $action)) {
                Log::info("Triggering PWA rebuild for {$modelName} {$action}");
                static::triggerPwaRebuild();
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
}