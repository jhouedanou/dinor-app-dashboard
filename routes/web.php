<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Auth\LoginErrorController;

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
    return redirect('/admin');
});

Route::get('/dashboard', function () {
    return redirect('/admin');
})->name('dashboard');

// Route pour la PWA
Route::get('/pwa', function () {
    return redirect('/pwa/');
})->name('pwa');

// Route API pour récupérer les éléments du menu PWA
Route::get('/api/pwa-menu-items', function () {
    $items = \App\Models\PwaMenuItem::active()->ordered()->get();
    return response()->json([
        'success' => true,
        'data' => $items
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
    return response()->file(public_path('pwa/index.html'));
})->where('file', '[^/]+');

// Route catch-all pour la PWA SPA (doit être en dernier)
Route::get('/pwa/{path?}', function () {
    return response()->file(public_path('pwa/index.html'));
})->where('path', '.*');

// Route pour la page d'erreur de connexion admin
Route::get('/admin/login-error', [LoginErrorController::class, 'show'])->name('admin.login.error');