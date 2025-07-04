<?php

namespace App\Services;

use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Redis;

class CacheService
{
    protected $defaultTtl = 300; // 5 minutes
    protected $tagSupport = false;

    public function __construct()
    {
        // Vérifier si le driver de cache supporte les tags
        $this->tagSupport = $this->cacheSupportsTagging();
    }

    /**
     * Vérifier si le cache supporte les tags
     */
    protected function cacheSupportsTagging(): bool
    {
        try {
            Cache::tags(['test'])->put('test', 'value', 1);
            Cache::tags(['test'])->forget('test');
            return true;
        } catch (\Exception $e) {
            Log::info('Cache driver does not support tagging, using alternative strategy');
            return false;
        }
    }

    /**
     * Mettre en cache avec tags si supporté, sinon avec clé préfixée
     */
    public function put(string $key, $value, int $ttl = null, array $tags = []): bool
    {
        $ttl = $ttl ?? $this->defaultTtl;

        try {
            if ($this->tagSupport && !empty($tags)) {
                return Cache::tags($tags)->put($key, $value, $ttl);
            } else {
                // Si pas de support des tags, préfixer la clé avec les tags
                $prefixedKey = $this->getPrefixedKey($key, $tags);
                return Cache::put($prefixedKey, $value, $ttl);
            }
        } catch (\Exception $e) {
            Log::error('Cache put error: ' . $e->getMessage(), [
                'key' => $key,
                'tags' => $tags
            ]);
            return false;
        }
    }

    /**
     * Récupérer du cache
     */
    public function get(string $key, $default = null, array $tags = [])
    {
        try {
            if ($this->tagSupport && !empty($tags)) {
                return Cache::tags($tags)->get($key, $default);
            } else {
                $prefixedKey = $this->getPrefixedKey($key, $tags);
                return Cache::get($prefixedKey, $default);
            }
        } catch (\Exception $e) {
            Log::error('Cache get error: ' . $e->getMessage(), [
                'key' => $key,
                'tags' => $tags
            ]);
            return $default;
        }
    }

    /**
     * Supprimer du cache
     */
    public function forget(string $key, array $tags = []): bool
    {
        try {
            if ($this->tagSupport && !empty($tags)) {
                return Cache::tags($tags)->forget($key);
            } else {
                $prefixedKey = $this->getPrefixedKey($key, $tags);
                return Cache::forget($prefixedKey);
            }
        } catch (\Exception $e) {
            Log::error('Cache forget error: ' . $e->getMessage(), [
                'key' => $key,
                'tags' => $tags
            ]);
            return false;
        }
    }

    /**
     * Vider le cache par tags
     */
    public function flushTags(array $tags): bool
    {
        try {
            if ($this->tagSupport) {
                Cache::tags($tags)->flush();
                Log::info('Cache flushed for tags: ' . implode(', ', $tags));
                return true;
            } else {
                // Alternative: chercher et supprimer toutes les clés avec ces préfixes
                $this->flushByPrefix($tags);
                return true;
            }
        } catch (\Exception $e) {
            Log::error('Cache flush tags error: ' . $e->getMessage(), [
                'tags' => $tags
            ]);
            return false;
        }
    }

    /**
     * Vider tout le cache
     */
    public function flush(): bool
    {
        try {
            Cache::flush();
            Log::info('All cache flushed');
            return true;
        } catch (\Exception $e) {
            Log::error('Cache flush error: ' . $e->getMessage());
            return false;
        }
    }

    /**
     * Obtenir une clé préfixée avec les tags
     */
    protected function getPrefixedKey(string $key, array $tags): string
    {
        if (empty($tags)) {
            return $key;
        }
        
        $prefix = implode(':', $tags);
        return $prefix . ':' . $key;
    }

    /**
     * Alternative au flush par tags pour les drivers sans support
     */
    protected function flushByPrefix(array $tags): void
    {
        // Cette méthode nécessiterait d'itérer sur toutes les clés
        // Pour simplifier, on fait un flush complet
        Log::warning('Fallback: flushing all cache instead of specific tags', [
            'tags' => $tags,
            'reason' => 'Cache driver does not support tagging'
        ]);
        
        Cache::flush();
    }

    /**
     * Méthode spéciale pour Filament
     */
    public function flushFilamentCache(): array
    {
        $result = [
            'success' => false,
            'message' => '',
            'operations' => []
        ];

        try {
            // Essayer de vider les caches Filament spécifiques
            $operations = [];

            // 1. Cache général
            if ($this->flush()) {
                $operations[] = 'Cache général vidé';
            }

            // 2. Cache de configuration
            if (function_exists('opcache_reset')) {
                opcache_reset();
                $operations[] = 'OPCache réinitialisé';
            }

            // 3. Cache des vues
            try {
                \Artisan::call('view:clear');
                $operations[] = 'Cache des vues vidé';
            } catch (\Exception $e) {
                Log::warning('Could not clear view cache: ' . $e->getMessage());
            }

            // 4. Cache des configurations
            try {
                \Artisan::call('config:clear');
                $operations[] = 'Cache de configuration vidé';
            } catch (\Exception $e) {
                Log::warning('Could not clear config cache: ' . $e->getMessage());
            }

            $result = [
                'success' => true,
                'message' => 'Cache vidé avec succès. ' . count($operations) . ' opérations effectuées.',
                'operations' => $operations
            ];

            Log::info('Filament cache cleared successfully', $result);

        } catch (\Exception $e) {
            $result = [
                'success' => false,
                'message' => 'Erreur lors du vidage du cache: ' . $e->getMessage(),
                'operations' => []
            ];

            Log::error('Filament cache clear error', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);
        }

        return $result;
    }
}