<?php

namespace App\Exceptions;

use Illuminate\Foundation\Exceptions\Handler as ExceptionHandler;
use Throwable;

class Handler extends ExceptionHandler
{
    /**
     * The list of the inputs that are never flashed to the session on validation exceptions.
     *
     * @var array<int, string>
     */
    protected $dontFlash = [
        'current_password',
        'password',
        'password_confirmation',
    ];

    /**
     * Register the exception handling callbacks for the application.
     */
    public function register(): void
    {
        $this->reportable(function (Throwable $e) {
            //
        });
    }

    /**
     * Render an exception into an HTTP response.
     */
    public function render($request, Throwable $exception)
    {
        // Gestion spéciale pour les requêtes API
        if ($request->wantsJson() || $request->is('api/*')) {
            // Modèle non trouvé (ex: /api/v1/recipes/999)
            if ($exception instanceof \Illuminate\Database\Eloquent\ModelNotFoundException) {
                return response()->json([
                    'success' => false,
                    'message' => 'Ressource non trouvée',
                    'error' => 'MODEL_NOT_FOUND'
                ], 404);
            }
            
            // Route non trouvée (ex: /api/v1/nonexistent)
            if ($exception instanceof \Symfony\Component\HttpKernel\Exception\NotFoundHttpException) {
                return response()->json([
                    'success' => false,
                    'message' => 'Endpoint non trouvé',
                    'error' => 'ENDPOINT_NOT_FOUND'
                ], 404);
            }

            // Erreur de validation
            if ($exception instanceof \Illuminate\Validation\ValidationException) {
                return response()->json([
                    'success' => false,
                    'message' => 'Données invalides',
                    'errors' => $exception->errors()
                ], 422);
            }

            // Erreur d'autorisation
            if ($exception instanceof \Illuminate\Auth\AuthenticationException) {
                return response()->json([
                    'success' => false,
                    'message' => 'Non authentifié',
                    'error' => 'UNAUTHENTICATED'
                ], 401);
            }

            // Erreur d'accès interdit
            if ($exception instanceof \Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException) {
                return response()->json([
                    'success' => false,
                    'message' => 'Accès interdit',
                    'error' => 'ACCESS_DENIED'
                ], 403);
            }

            // Erreur de méthode non autorisée
            if ($exception instanceof \Symfony\Component\HttpKernel\Exception\MethodNotAllowedHttpException) {
                return response()->json([
                    'success' => false,
                    'message' => 'Méthode non autorisée',
                    'error' => 'METHOD_NOT_ALLOWED'
                ], 405);
            }

            // Erreur générique pour les API
            if (config('app.debug')) {
                return response()->json([
                    'success' => false,
                    'message' => 'Erreur interne du serveur',
                    'error' => $exception->getMessage(),
                    'trace' => $exception->getTrace()
                ], 500);
            } else {
                return response()->json([
                    'success' => false,
                    'message' => 'Erreur interne du serveur',
                    'error' => 'INTERNAL_SERVER_ERROR'
                ], 500);
            }
        }

        return parent::render($request, $exception);
    }
} 