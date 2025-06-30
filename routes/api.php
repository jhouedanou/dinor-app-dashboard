<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\RecipeController;
use App\Http\Controllers\Api\EventController;
use App\Http\Controllers\Api\PageController;
use App\Http\Controllers\Api\TipController;
use App\Http\Controllers\Api\DinorTvController;
use App\Http\Controllers\Api\LikeController;
use App\Http\Controllers\Api\CommentController;
use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\BannerController;
use App\Http\Controllers\Api\CacheController;
use App\Http\Controllers\Api\ShareController;
use App\Http\Controllers\PWA\CacheController as PWACacheController;
use App\Http\Controllers\PWA\PwaMenuItemController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});

// Routes d'authentification
Route::prefix('v1/auth')->group(function () {
    Route::post('/register', [AuthController::class, 'register']);
    Route::post('/login', [AuthController::class, 'login']);
    
    Route::middleware('auth:sanctum')->group(function () {
        Route::post('/logout', [AuthController::class, 'logout']);
        Route::get('/profile', [AuthController::class, 'profile']);
        Route::put('/profile', [AuthController::class, 'updateProfile']);
    });
});

// Routes publiques pour l'app mobile
Route::prefix('v1')->group(function () {
    
    // Recettes
    Route::get('/recipes', [RecipeController::class, 'index']);
    Route::get('/recipes/{id}', [RecipeController::class, 'show']);
    Route::get('/recipes/featured/list', [RecipeController::class, 'featured']);
    Route::get('/recipes/categories/list', [RecipeController::class, 'categories']);
    
    // Bannières
    Route::get('/banners', [BannerController::class, 'index']);
    Route::get('/banners/{id}', [BannerController::class, 'show']);
    Route::get('/banners/type/{type}', [BannerController::class, 'getByType']);
    
    // PWA Menu Items
    Route::get('/pwa-menu-items', [PwaMenuItemController::class, 'index']);
    
    // Pages
    Route::get('/pages', [PageController::class, 'index']);
    
    // Catégories
    Route::get('/categories', [CategoryController::class, 'index']);
    Route::get('/categories/events', [CategoryController::class, 'events']);

// Event Categories (nouvelles catégories spécifiques aux événements)
Route::get('/event-categories', [App\Http\Controllers\Api\EventCategoryController::class, 'index']);
Route::get('/event-categories/{id}', [App\Http\Controllers\Api\EventCategoryController::class, 'show']);
Route::post('/event-categories', [App\Http\Controllers\Api\EventCategoryController::class, 'store']);
Route::post('/event-categories/check-exists', [App\Http\Controllers\Api\EventCategoryController::class, 'checkExists']);
    Route::get('/categories/recipes', [CategoryController::class, 'recipes']);
    Route::post('/categories', [CategoryController::class, 'store']);
    Route::get('/categories/check', [CategoryController::class, 'checkExists']);
    
    // Astuces
    Route::get('/tips', [TipController::class, 'index']);
    Route::get('/tips/{id}', [TipController::class, 'show']);
    Route::get('/tips/featured/list', [TipController::class, 'featured']);
    
    // Événements
    Route::get('/events', [EventController::class, 'index']);
    Route::get('/events/{id}', [EventController::class, 'show']);
    Route::get('/events/upcoming/list', [EventController::class, 'upcoming']);
    Route::get('/events/featured/list', [EventController::class, 'featured']);
    Route::post('/events/{id}/register', [EventController::class, 'register']);
    
    // Dinor TV
    Route::get('/dinor-tv', [DinorTvController::class, 'index']);
    Route::get('/dinor-tv/{id}', [DinorTvController::class, 'show']);
    Route::get('/dinor-tv/featured/list', [DinorTvController::class, 'featured']);
    Route::get('/dinor-tv/live/list', [DinorTvController::class, 'live']);
    Route::post('/dinor-tv/{id}/view', [DinorTvController::class, 'incrementView']);
    Route::post('/dinor-tv/{id}/like', [DinorTvController::class, 'toggleLike']);
    
    // Pages
    Route::get('/pages', [PageController::class, 'index']);
    Route::get('/pages/homepage', [PageController::class, 'homepage']);
    Route::get('/pages/menu', [PageController::class, 'menu']);
    Route::get('/pages/latest', [PageController::class, 'latest']);
    Route::get('/pages/{slug}', [PageController::class, 'show']);
    
    // Likes - Routes publiques (lecture seulement)
    Route::get('/likes/check', [LikeController::class, 'check']);
    Route::get('/likes', [LikeController::class, 'index']);
    
    // Comments - Routes publiques (lecture seulement)
    Route::get('/comments', [CommentController::class, 'index']);
    Route::get('/comments/{comment}/replies', [CommentController::class, 'replies']);
    
    // Shares - Tracking des partages
    Route::post('/shares/track', [ShareController::class, 'track']);
    
    // Dashboard global pour l'app
    Route::get('/dashboard', function() {
        return response()->json([
            'success' => true,
            'data' => [
                'featured_recipes' => \App\Models\Recipe::published()->featured()->limit(5)->get(),
                'upcoming_events' => \App\Models\Event::published()->upcoming()->limit(5)->get(),
                'latest_tips' => \App\Models\Tip::published()->orderBy('created_at', 'desc')->limit(5)->get(),
                'featured_videos' => \App\Models\DinorTv::published()->featured()->limit(5)->get(),
            ]
        ]);
    });

    // Cache management
    Route::post('/cache/invalidate', [CacheController::class, 'invalidate']);
    Route::post('/cache/clear', [CacheController::class, 'clear']);

    // Statistiques détaillées des likes par catégorie
    Route::get('/likes/stats', function() {
        $recipeLikes = \App\Models\Like::where('likeable_type', 'App\Models\Recipe')->count();
        $eventLikes = \App\Models\Like::where('likeable_type', 'App\Models\Event')->count();
        $tipLikes = \App\Models\Like::where('likeable_type', 'App\Models\Tip')->count();
        $videoLikes = \App\Models\Like::where('likeable_type', 'App\Models\DinorTv')->count();
        
        return response()->json([
            'success' => true,
            'data' => [
                'total_likes' => $recipeLikes + $eventLikes + $tipLikes + $videoLikes,
                'likes_by_category' => [
                    'recipes' => $recipeLikes,
                    'events' => $eventLikes,
                    'tips' => $tipLikes,
                    'videos' => $videoLikes
                ]
            ]
        ]);
    });

    // Statistiques détaillées des commentaires par catégorie
    Route::get('/comments/stats', function() {
        $recipeComments = \App\Models\Comment::where('commentable_type', 'App\Models\Recipe')->count();
        $eventComments = \App\Models\Comment::where('commentable_type', 'App\Models\Event')->count();
        $tipComments = \App\Models\Comment::where('commentable_type', 'App\Models\Tip')->count();
        $videoComments = \App\Models\Comment::where('commentable_type', 'App\Models\DinorTv')->count();
        
        return response()->json([
            'success' => true,
            'data' => [
                'total_comments' => $recipeComments + $eventComments + $tipComments + $videoComments,
                'comments_by_category' => [
                    'recipes' => $recipeComments,
                    'events' => $eventComments,
                    'tips' => $tipComments,
                    'videos' => $videoComments
                ]
            ]
        ]);
    });
});

// Routes avec middleware d'authentification
Route::middleware('auth:sanctum')->prefix('v1')->group(function () {
    // Likes - Routes protégées
    Route::post('/likes/toggle', [LikeController::class, 'toggle']);
    
    // Comments - Routes protégées
    Route::post('/comments', [CommentController::class, 'store']);
    Route::put('/comments/{comment}', [CommentController::class, 'update']);
    Route::delete('/comments/{comment}', [CommentController::class, 'destroy']);
    
    // Routes de suppression pour l'administration
    Route::delete('/recipes/{recipe}', [RecipeController::class, 'destroy']);
    Route::delete('/tips/{tip}', [TipController::class, 'destroy']);
});

// Routes de test pour diagnostiquer le problème des données vides
Route::prefix('test')->group(function () {
    // Test sans filtres
    Route::get('/recipes-all', function() {
        $recipes = \App\Models\Recipe::all();
        return response()->json([
            'total_recipes' => $recipes->count(),
            'published_recipes' => \App\Models\Recipe::where('is_published', true)->count(),
            'featured_recipes' => \App\Models\Recipe::where('is_featured', true)->count(),
            'sample_recipe' => $recipes->first(),
        ]);
    });
    
    Route::get('/events-all', function() {
        $events = \App\Models\Event::all();
        return response()->json([
            'total_events' => $events->count(),
            'published_events' => \App\Models\Event::where('is_published', true)->count(),
            'active_events' => \App\Models\Event::where('status', 'active')->count(),
            'sample_event' => $events->first(),
        ]);
    });
    
    Route::get('/categories-all', function() {
        $categories = \App\Models\Category::all();
        return response()->json([
            'total_categories' => $categories->count(),
            'sample_category' => $categories->first(),
        ]);
    });
    
    Route::get('/database-check', function() {
        return response()->json([
            'database_connected' => true,
            'recipes_count' => \App\Models\Recipe::count(),
            'events_count' => \App\Models\Event::count(),
            'categories_count' => \App\Models\Category::count(),
            'tips_count' => \App\Models\Tip::count(),
            'users_count' => \App\Models\User::count(),
        ]);
    });
});

// Routes pour le cache PWA uniquement (pas pour Filament)
Route::prefix('pwa/cache')->group(function () {
    Route::post('set', [CacheController::class, 'set']);
    Route::post('get', [CacheController::class, 'get']);
    Route::post('invalidate', [CacheController::class, 'invalidate']);
    Route::post('clear', [CacheController::class, 'clear']);
    Route::get('stats', [CacheController::class, 'stats']);
    Route::post('warmup', [CacheController::class, 'warmup']);
}); 