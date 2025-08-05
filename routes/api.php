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
use App\Http\Controllers\Api\SearchController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\PWA\CacheController as PWACacheController;
use App\Http\Controllers\Api\ProfessionalContentController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});

// Routes pour les partages
Route::prefix('v1/shares')->group(function () {
    // Récupérer l'URL de partage
    Route::get('/url', [ShareController::class, 'getShareUrl']);
    
    // Récupérer les métadonnées de partage
    Route::get('/metadata', [ShareController::class, 'getShareMetadata']);
    
    // Tracker un partage
    Route::post('/track', [ShareController::class, 'trackShare']);
});

// Route de test avec vrais favoris (sans authentification)
Route::get('/test-favorites', function() {
    try {
        $favorites = \App\Models\UserFavorite::with('favoritable')
            ->orderBy('favorited_at', 'desc')
            ->get();
        
        $favoritesData = $favorites->map(function ($favorite) {
            $favoritable = $favorite->favoritable;
            if (!$favoritable) return null;

            // Déterminer le type
            $type = match(get_class($favoritable)) {
                \App\Models\Recipe::class => 'recipe',
                \App\Models\Event::class => 'event',
                \App\Models\Tip::class => 'tip',
                \App\Models\DinorTv::class => 'dinor_tv',
                default => 'unknown'
            };

            return [
                'id' => $favorite->id,
                'favorited_at' => $favorite->favorited_at,
                'type' => $type,
                'content' => [
                    'id' => $favoritable->id,
                    'title' => $favoritable->title,
                    'description' => $favoritable->description ?? $favoritable->content ?? null,
                    'image' => $favoritable->image ?? null,
                    'created_at' => $favoritable->created_at,
                    'likes_count' => $favoritable->likes_count ?? 0,
                    'comments_count' => $favoritable->comments_count ?? 0,
                    'favorites_count' => $favoritable->favorites_count ?? 0,
                ]
            ];
        })->filter()->values();

        return response()->json([
            'success' => true,
            'data' => $favoritesData,
            'pagination' => [
                'current_page' => 1,
                'last_page' => 1,
                'per_page' => 20,
                'total' => $favoritesData->count()
            ]
        ]);
    } catch (\Exception $e) {
        return response()->json([
            'success' => false,
            'message' => 'Erreur lors du chargement des favoris: ' . $e->getMessage(),
            'data' => []
        ]);
    }
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
    
    // Route spécifique tournois (DOIT être avant toute route {tournament})
    Route::middleware('auth:sanctum')->get('/tournaments/my-tournaments', [App\Http\Controllers\Api\TournamentController::class, 'myTournaments']);
    
    // Recettes
    Route::get('/recipes', [RecipeController::class, 'index']);
    Route::get('/recipes/{id}', [RecipeController::class, 'show']);
    Route::get('/recipes/featured/list', [RecipeController::class, 'featured']);
    Route::get('/recipes/categories/list', [RecipeController::class, 'categories']);
    
    // Bannières
    Route::get('/banners', [BannerController::class, 'index']);
    Route::get('/banners/{id}', [BannerController::class, 'show']);
    Route::get('/banners/type/{type}', [BannerController::class, 'getByType']);
    Route::post('/banners/clear-cache', [BannerController::class, 'clearCache']);
    
    // Cache PWA
    Route::post('/cache/invalidate-content', [CacheController::class, 'invalidateContent']);
    Route::post('/cache/clear-all', [CacheController::class, 'clearAll']);
    Route::get('/cache/stats', [CacheController::class, 'stats']);
    Route::get('/cache/status', [CacheController::class, 'status']);
    
    
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
    
    // Comments - Routes publiques (lecture et création pour support anonyme)
    Route::get('/comments', [CommentController::class, 'index']);
    Route::post('/comments', [CommentController::class, 'store']);
    Route::get('/comments/{comment}/replies', [CommentController::class, 'replies']);
    Route::get('/comments/captcha/generate', [CommentController::class, 'generateCaptcha']);
    
    // Favorites - Routes publiques (lecture seulement)
    Route::get('/favorites/check', [App\Http\Controllers\Api\FavoriteController::class, 'check']);
    
    // Pronostics - Routes publiques
    Route::get('/teams', [App\Http\Controllers\Api\TeamController::class, 'index']);
    Route::get('/teams/{team}', [App\Http\Controllers\Api\TeamController::class, 'show']);
    
    Route::get('/matches', [App\Http\Controllers\Api\FootballMatchController::class, 'index'])->middleware('cache.matches:600');
    Route::get('/matches/{footballMatch}', [App\Http\Controllers\Api\FootballMatchController::class, 'show'])->middleware('cache.matches:300');
    Route::get('/matches/upcoming/list', [App\Http\Controllers\Api\FootballMatchController::class, 'upcoming'])->middleware('cache.matches:300');
    Route::get('/matches/current/match', [App\Http\Controllers\Api\FootballMatchController::class, 'current'])->middleware('cache.matches:180');
    
    // Tournois - Routes publiques
    Route::get('/tournaments', [App\Http\Controllers\Api\TournamentController::class, 'index'])->middleware('cache.matches:600');
    Route::get('/tournaments/featured', [App\Http\Controllers\Api\TournamentController::class, 'featured'])->middleware('cache.matches:300');
    Route::get('/tournaments/{tournament}', [App\Http\Controllers\Api\TournamentController::class, 'show'])->middleware('cache.matches:600');
    Route::get('/tournaments/{tournament}/matches', [App\Http\Controllers\Api\TournamentController::class, 'matches'])->middleware('cache.matches:300');
    Route::get('/tournaments/{tournament}/leaderboard', [App\Http\Controllers\Api\TournamentController::class, 'leaderboard'])->middleware('cache.matches:180');
    
    // Leaderboard - Routes publiques
    Route::get('/leaderboard', [App\Http\Controllers\Api\LeaderboardController::class, 'index']);
    Route::get('/leaderboard/top', [App\Http\Controllers\Api\LeaderboardController::class, 'top']);
    
    // Route de test avec vrais favoris de la base de données
    Route::get('/favorites-real', function() {
        try {
            $favorites = \App\Models\UserFavorite::with('favoritable')
                ->orderBy('favorited_at', 'desc')
                ->get();
            
            $favoritesData = $favorites->map(function ($favorite) {
                $favoritable = $favorite->favoritable;
                if (!$favoritable) return null;

                // Déterminer le type
                $type = match(get_class($favoritable)) {
                    \App\Models\Recipe::class => 'recipe',
                    \App\Models\Event::class => 'event',
                    \App\Models\Tip::class => 'tip',
                    \App\Models\DinorTv::class => 'dinor_tv',
                    default => 'unknown'
                };

                return [
                    'id' => $favorite->id,
                    'favorited_at' => $favorite->favorited_at,
                    'type' => $type,
                    'content' => [
                        'id' => $favoritable->id,
                        'title' => $favoritable->title,
                        'description' => $favoritable->description ?? $favoritable->content ?? null,
                        'image' => $favoritable->image ?? null,
                        'created_at' => $favoritable->created_at,
                        'likes_count' => $favoritable->likes_count ?? 0,
                        'comments_count' => $favoritable->comments_count ?? 0,
                        'favorites_count' => $favoritable->favorites_count ?? 0,
                    ]
                ];
            })->filter()->values();

            return response()->json([
                'success' => true,
                'data' => $favoritesData,
                'pagination' => [
                    'current_page' => 1,
                    'last_page' => 1,
                    'per_page' => 20,
                    'total' => $favoritesData->count()
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors du chargement des favoris: ' . $e->getMessage(),
                'data' => []
            ]);
        }
    });
    
    // Test route pour debug des commentaires
    Route::get('/test/comments/{id}', function($id) {
        $recipe = \App\Models\Recipe::with(['approvedComments.user:id,name', 'approvedComments.replies.user:id,name'])->find($id);
        if (!$recipe) {
            return response()->json(['error' => 'Recipe not found'], 404);
        }
        return response()->json([
            'recipe_id' => $id,
            'recipe_title' => $recipe->title,
            'comments_from_relation' => $recipe->approvedComments,
            'comments_from_db' => \App\Models\Comment::where('commentable_type', 'App\\Models\\Recipe')->where('commentable_id', $id)->where('is_approved', true)->get(),
            'all_comments_for_recipe' => \App\Models\Comment::where('commentable_type', 'App\\Models\\Recipe')->where('commentable_id', $id)->get()
        ]);
    });
    
    // Shares - Tracking des partages
    Route::post('/shares/track', [ShareController::class, 'track']);
    
    // Recherche - Routes publiques
    Route::get('/search', [SearchController::class, 'index']);
    Route::get('/search/suggestions', [SearchController::class, 'suggestions']);
    
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
    
    // Comments - Routes protégées (modification et suppression seulement)
    Route::put('/comments/{comment}', [CommentController::class, 'update']);
    Route::delete('/comments/{id}', [CommentController::class, 'destroy']);
    
    // Favorites - Routes protégées
    Route::get('/favorites', [App\Http\Controllers\Api\FavoriteController::class, 'index']);
    Route::get('/favorites/check', [App\Http\Controllers\Api\FavoriteController::class, 'check']);
    Route::post('/favorites/toggle', [App\Http\Controllers\Api\FavoriteController::class, 'toggle']);
    Route::delete('/favorites/{favorite}', [App\Http\Controllers\Api\FavoriteController::class, 'remove']);
    
    // Prédictions - Routes protégées
    Route::get('/predictions', [App\Http\Controllers\Api\PredictionController::class, 'index']);
    Route::post('/predictions', [App\Http\Controllers\Api\PredictionController::class, 'store']);
    Route::patch('/predictions/upsert', [App\Http\Controllers\Api\PredictionController::class, 'upsert']);
    Route::post('/predictions/batch', [App\Http\Controllers\Api\PredictionController::class, 'batchGetPredictions']);
    Route::get('/predictions/my-recent', [App\Http\Controllers\Api\PredictionController::class, 'userRecentPredictions']);
    Route::get('/user/predictions/stats', [App\Http\Controllers\Api\PredictionController::class, 'userStats']);
    Route::get('/predictions/match/{matchId}', [App\Http\Controllers\Api\PredictionController::class, 'getUserPredictionForMatch']);
    Route::get('/predictions/{prediction}', [App\Http\Controllers\Api\PredictionController::class, 'show'])->where('prediction', '[0-9]+');
    Route::put('/predictions/{prediction}', [App\Http\Controllers\Api\PredictionController::class, 'update'])->where('prediction', '[0-9]+');
    
    // Paris de Tournois - Routes protégées
    Route::get('/tournaments/betting-available', [App\Http\Controllers\Api\BettingController::class, 'getAvailableTournaments']);
    Route::get('/tournaments/{tournament}/matches/betting', [App\Http\Controllers\Api\BettingController::class, 'getTournamentBettingMatches']);
    
    // Notifications - Routes protégées
    Route::get('/notifications', [NotificationController::class, 'index']);
    Route::patch('/notifications/{id}/read', [NotificationController::class, 'markAsRead']);
    Route::get('/tournaments/{tournament}/my-bets', [App\Http\Controllers\Api\BettingController::class, 'getUserTournamentBets']);
    Route::post('/matches/{match}/bet', [App\Http\Controllers\Api\BettingController::class, 'placeBet']);
    Route::get('/betting/my-stats', [App\Http\Controllers\Api\BettingController::class, 'getUserBettingStats']);
    Route::get('/betting/trending', [App\Http\Controllers\Api\BettingController::class, 'getTrendingStats']);
    
    // Leaderboard - Routes protégées utilisateur
    Route::get('/leaderboard/my-stats', [App\Http\Controllers\Api\LeaderboardController::class, 'userStats']);
    Route::get('/leaderboard/my-rank', [App\Http\Controllers\Api\LeaderboardController::class, 'userRank']);
    Route::post('/leaderboard/refresh', [App\Http\Controllers\Api\LeaderboardController::class, 'refresh']);
    
    // Tournois - Routes protégées
    Route::post('/tournaments/{tournament}/register', [App\Http\Controllers\Api\TournamentController::class, 'register']);
    Route::delete('/tournaments/{tournament}/register', [App\Http\Controllers\Api\TournamentController::class, 'unregister']);
    
    // Route de test avec vrais favoris de la base de données
    Route::get('/favorites-real', function() {
        try {
            $favorites = \App\Models\UserFavorite::with('favoritable')
                ->orderBy('favorited_at', 'desc')
                ->get();
            
            $favoritesData = $favorites->map(function ($favorite) {
                $favoritable = $favorite->favoritable;
                if (!$favoritable) return null;

                // Déterminer le type
                $type = match(get_class($favoritable)) {
                    \App\Models\Recipe::class => 'recipe',
                    \App\Models\Event::class => 'event',
                    \App\Models\Tip::class => 'tip',
                    \App\Models\DinorTv::class => 'dinor_tv',
                    default => 'unknown'
                };

                return [
                    'id' => $favorite->id,
                    'favorited_at' => $favorite->favorited_at,
                    'type' => $type,
                    'content' => [
                        'id' => $favoritable->id,
                        'title' => $favoritable->title,
                        'description' => $favoritable->description ?? $favoritable->content ?? null,
                        'image' => $favoritable->image ?? null,
                        'created_at' => $favoritable->created_at,
                        'likes_count' => $favoritable->likes_count ?? 0,
                        'comments_count' => $favoritable->comments_count ?? 0,
                        'favorites_count' => $favoritable->favorites_count ?? 0,
                    ]
                ];
            })->filter()->values();

            return response()->json([
                'success' => true,
                'data' => $favoritesData,
                'pagination' => [
                    'current_page' => 1,
                    'last_page' => 1,
                    'per_page' => 20,
                    'total' => $favoritesData->count()
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors du chargement des favoris: ' . $e->getMessage(),
                'data' => []
            ]);
        }
    });
    
    // Profile - Routes protégées
    Route::get('/profile', [App\Http\Controllers\Api\ProfileController::class, 'show']);
    Route::get('/profile/stats', [App\Http\Controllers\Api\ProfileController::class, 'getStats']);
    Route::put('/profile/name', [App\Http\Controllers\Api\ProfileController::class, 'updateName']);
    Route::put('/profile/password', [App\Http\Controllers\Api\ProfileController::class, 'updatePassword']);
    Route::post('/profile/request-deletion', [App\Http\Controllers\Api\ProfileController::class, 'requestDataDeletion']);
    
    // Professional Content - Routes protégées
    Route::apiResource('professional-content', ProfessionalContentController::class);
    Route::get('/professional-content/types', [ProfessionalContentController::class, 'getContentTypes']);
    
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
            'tournaments_count' => \App\Models\Tournament::count(),
            'tournament_participants_count' => \App\Models\TournamentParticipant::count(),
            'predictions_count' => \App\Models\Prediction::count(),
            'football_matches_count' => \App\Models\FootballMatch::count(),
        ]);
    });
});

// Routes pour la gestion du cache PWA
Route::prefix('pwa/cache')->group(function () {
    Route::post('set', [CacheController::class, 'set']);
    Route::post('get', [CacheController::class, 'get']);
    Route::post('invalidate', [CacheController::class, 'invalidate']);
    Route::post('clear', [CacheController::class, 'clear']);
    Route::get('stats', [CacheController::class, 'stats']);
    Route::post('warmup', [CacheController::class, 'warmup']);
    
    // Nouvel endpoint pour vérifier l'état du cache et les invalidations
    Route::get('status', [CacheController::class, 'getStatus']);
    Route::post('invalidate-content', [CacheController::class, 'invalidateContent']);
});

// Route de test spécifique pour les tournois
Route::get('/test/tournaments-debug', function() {
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