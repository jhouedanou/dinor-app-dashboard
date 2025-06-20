<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Symfony\Component\HttpFoundation\Response;

class FilamentAdminAuth
{
    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next): Response
    {
        // Vérifier l'authentification avec le guard 'admin'
        if (!Auth::guard('admin')->check()) {
            return redirect()->route('filament.admin.auth.login');
        }

        return $next($request);
    }
} 