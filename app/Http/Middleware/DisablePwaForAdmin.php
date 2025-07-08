<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class DisablePwaForAdmin
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        $response = $next($request);
        
        // Si on est sur les routes admin, ajouter des headers pour désactiver PWA
        if ($request->is('admin*')) {
            $response->headers->set('X-Frame-Options', 'DENY');
            $response->headers->set('X-Robots-Tag', 'noindex, nofollow');
            
            // Désactiver le cache pour éviter les conflits
            $response->headers->set('Cache-Control', 'no-cache, no-store, must-revalidate');
            $response->headers->set('Pragma', 'no-cache');
            $response->headers->set('Expires', '0');
            
            // Bloquer les requêtes vers Vite depuis admin
            if ($request->header('referer') && str_contains($request->header('referer'), '/admin')) {
                if (str_contains($request->getUri(), '@vite') || str_contains($request->getUri(), ':5173')) {
                    return response('Blocked for admin', 403);
                }
            }
        }
        
        return $response;
    }
} 