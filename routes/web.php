<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Auth\LoginErrorController;
use App\Models\User;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "web" middleware group. Make something great!
|
*/

Route::get('/', function () {
    return view('welcome');
});

Route::view('/privacy-policy', 'privacy-policy')->name('privacy-policy');
Route::view('/terms-of-use', 'terms-of-use')->name('terms-of-use');

Route::get('/dashboard', function () {
    return redirect('/admin');
})->name('dashboard');

// Route pour la PWA
Route::get('/pwa', function () {
    return response()->file(public_path('pwa/index.html'), [
        'Content-Type' => 'text/html; charset=utf-8',
        'Cache-Control' => 'no-cache, no-store, must-revalidate'
    ]);
})->name('pwa');

// Route API pour récupérer les bannières
Route::get('/api/banners', function () {
    $banners = \App\Models\Banner::active()->forHome()->ordered()->get();
    return response()->json([
        'success' => true,
        'data' => $banners
    ]);
});

// Routes pour servir les fichiers statiques de la PWA avec headers correctifs
Route::get('/pwa/components/{file}', function ($file) {
    $filePath = public_path("pwa/components/{$file}");
    if (file_exists($filePath)) {
        $extension = pathinfo($filePath, PATHINFO_EXTENSION);
        $contentType = match($extension) {
            'js' => 'application/javascript; charset=utf-8',
            'css' => 'text/css; charset=utf-8',
            'json' => 'application/json; charset=utf-8',
            default => 'text/plain; charset=utf-8'
        };
        
        $headers = [
            'Content-Type' => $contentType,
            'Cache-Control' => 'public, max-age=3600',
            'X-Content-Type-Options' => 'nosniff'
        ];
        
        return response()->file($filePath, $headers);
    }
    abort(404);
})->where('file', '.*');

Route::get('/pwa/components/navigation/{file}', function ($file) {
    $filePath = public_path("pwa/components/navigation/{$file}");
    if (file_exists($filePath)) {
        $extension = pathinfo($filePath, PATHINFO_EXTENSION);
        $contentType = match($extension) {
            'js' => 'application/javascript; charset=utf-8',
            'css' => 'text/css; charset=utf-8',
            'json' => 'application/json; charset=utf-8',
            default => 'text/plain; charset=utf-8'
        };
        
        $headers = [
            'Content-Type' => $contentType,
            'Cache-Control' => 'public, max-age=3600',
            'X-Content-Type-Options' => 'nosniff'
        ];
        
        return response()->file($filePath, $headers);
    }
    abort(404);
})->where('file', '.*');

Route::get('/pwa/styles/{file}', function ($file) {
    $filePath = public_path("pwa/styles/{$file}");
    if (file_exists($filePath)) {
        $extension = pathinfo($filePath, PATHINFO_EXTENSION);
        $contentType = match($extension) {
            'css' => 'text/css',
            'js' => 'application/javascript',
            default => 'text/plain'
        };
        return response()->file($filePath, ['Content-Type' => $contentType]);
    }
    abort(404);
})->where('file', '.*');

Route::get('/pwa/scripts/{file}', function ($file) {
    $filePath = public_path("pwa/scripts/{$file}");
    if (file_exists($filePath)) {
        $extension = pathinfo($filePath, PATHINFO_EXTENSION);
        $contentType = match($extension) {
            'js' => 'application/javascript',
            'css' => 'text/css',
            default => 'text/plain'
        };
        return response()->file($filePath, ['Content-Type' => $contentType]);
    }
    abort(404);
})->where('file', '.*');

Route::get('/pwa/{file}', function ($file) {
    $filePath = public_path("pwa/{$file}");
    if (file_exists($filePath) && !is_dir($filePath)) {
        $extension = pathinfo($filePath, PATHINFO_EXTENSION);
        $contentType = match($extension) {
            'js' => 'application/javascript',
            'css' => 'text/css',
            'json' => 'application/json',
            'ico' => 'image/x-icon',
            'png' => 'image/png',
            'jpg', 'jpeg' => 'image/jpeg',
            'svg' => 'image/svg+xml',
            default => 'text/plain'
        };
        return response()->file($filePath, ['Content-Type' => $contentType]);
    }
    // Rediriger vers la version buildée par défaut
    return response()->file(public_path('pwa/index.html'), [
        'Content-Type' => 'text/html; charset=utf-8',
        'Cache-Control' => 'no-cache, no-store, must-revalidate'
    ]);
})->where('file', '[^/]+');

// Routes pour servir les assets de la PWA
Route::get('/pwa/assets/{path?}', function ($path = null) {
    $filePath = public_path("pwa/assets/{$path}");
    
    // Si c'est un fichier et qu'il existe
    if ($path && file_exists($filePath) && !is_dir($filePath)) {
        $extension = pathinfo($filePath, PATHINFO_EXTENSION);
        $contentType = match($extension) {
            'js' => 'application/javascript; charset=utf-8',
            'css' => 'text/css; charset=utf-8',
            'json' => 'application/json; charset=utf-8',
            'ico' => 'image/x-icon',
            'png' => 'image/png',
            'jpg', 'jpeg' => 'image/jpeg',
            'svg' => 'image/svg+xml',
            'webmanifest' => 'application/manifest+json',
            default => 'text/plain; charset=utf-8'
        };
        
        $headers = [
            'Content-Type' => $contentType,
            'Cache-Control' => 'public, max-age=31536000', // 1 an pour les assets hashés
            'X-Content-Type-Options' => 'nosniff'
        ];
        
        return response()->file($filePath, $headers);
    }
    
    // Sinon, servir l'index.html de la PWA
    return response()->file(public_path('pwa/index.html'), [
        'Content-Type' => 'text/html; charset=utf-8',
        'Cache-Control' => 'no-cache, no-store, must-revalidate'
    ]);
})->where('path', '.*');


// Route catch-all pour la PWA SPA (doit être en dernier)
Route::get('/pwa/{path?}', function ($path = null) {
    // Servir uniquement la version buildée de la PWA
    return response()->file(public_path('pwa/index.html'), [
        'Content-Type' => 'text/html; charset=utf-8',
        'Cache-Control' => 'no-cache, no-store, must-revalidate'
    ]);
})->where('path', '.*');

// Route pour la page d'erreur de connexion admin
Route::get('/admin/login-error', [LoginErrorController::class, 'show'])->name('admin.login.error');

// Route pour les erreurs de login depuis le dashboard
Route::get('/login-error', [LoginErrorController::class, 'show'])->name('login.error');

// Route de test d'authentification
Route::get('/test-auth', function () {
    return view('test-auth');
});

// Route de debug des tournois
Route::get('/tournaments-debug', function () {
    try {
        $tournamentsCount = \App\Models\Tournament::count();
        $participantsCount = \App\Models\TournamentParticipant::count();
        $predictionsCount = \App\Models\Prediction::count();
        
        // Vérifier si l'utilisateur 4 (Fatima) a des participations
        $userParticipations = \App\Models\TournamentParticipant::where('user_id', 4)->get();
        
        // Récupérer tous les tournois
        $allTournaments = \App\Models\Tournament::with('participants')->get();
        
        return response()->json([
            'tournaments_count' => $tournamentsCount,
            'participants_count' => $participantsCount,
            'predictions_count' => $predictionsCount,
            'user_4_participations' => $userParticipations,
            'all_tournaments' => $allTournaments,
            'message' => 'Debug des tournois'
        ]);
    } catch (\Exception $e) {
        return response()->json([
            'error' => $e->getMessage(),
            'trace' => $e->getTraceAsString()
        ]);
    }
});

// Route pour créer un token de test
Route::post('/test-create-token', function () {
    try {
        $user = User::first();
        
        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Aucun utilisateur trouvé en base de données'
            ]);
        }
        
        // Supprimer les anciens tokens
        $user->tokens()->delete();
        
        // Créer un nouveau token
        $token = $user->createToken('test-browser-' . now()->timestamp);
        
        return response()->json([
            'success' => true,
            'token' => $token->plainTextToken,
            'user' => $user,
            'message' => 'Token de test créé avec succès'
        ]);
        
    } catch (Exception $e) {
        return response()->json([
            'success' => false,
            'message' => 'Erreur: ' . $e->getMessage()
        ]);
    }
});

// Routes pour télécharger les exemples CSV
Route::get('/csv/example/{type}', function ($type) {
    $files = [
        'recipes' => 'exemple_recipes_detailed.csv',
        'tips' => 'exemple_tips_detailed.csv',
        'events' => 'exemple_events_detailed.csv',
        'dinor_tv' => 'exemple_dinor_tv_detailed.csv',
        'categories' => 'exemple_categories_detailed.csv',
        'event_categories' => 'exemple_event_categories_detailed.csv',
        'users' => 'exemple_users_detailed.csv',
    ];

    if (!isset($files[$type])) {
        abort(404);
    }

    $filePath = storage_path('app/examples/' . $files[$type]);
    
    if (!file_exists($filePath)) {
        abort(404);
    }

    return response()->download($filePath, $files[$type], [
        'Content-Type' => 'text/csv',
    ]);
})->name('csv.example');

// Route pour l'export des analytics depuis le dashboard admin
Route::middleware(['web'])->group(function () {
    Route::get('/admin/analytics/export', [App\Http\Controllers\Api\AnalyticsController::class, 'export'])->name('admin.analytics.export');
});
