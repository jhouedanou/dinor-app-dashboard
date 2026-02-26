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
use App\Http\Controllers\Api\AnalyticsController;
use App\Http\Controllers\Api\SplashScreenController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

// ============================================================
// Routes Analytics - publiques (tracking uniquement)
// ============================================================
Route::prefix('analytics')->group(function () {
    Route::post('/event', [AnalyticsController::class, 'trackEvent']);
});

// Analytics v1 - métriques protégées par auth
Route::prefix('v1/analytics')->name('api.v1.analytics.')->group(function () {
    // Tracking public (PWA/app envoie des events)
    Route::post('/event', [AnalyticsController::class, 'trackEvent'])->name('track-event');

    // Métriques internes - protégées
    Route::middleware('auth:sanctum')->group(function () {
        Route::get('/', [AnalyticsController::class, 'index'])->name('index');
        Route::get('/app-statistics', [AnalyticsController::class, 'appStatistics'])->name('app-statistics');
        Route::get('/content-statistics', [AnalyticsController::class, 'contentStatistics'])->name('content-statistics');
        Route::get('/engagement', [AnalyticsController::class, 'engagementMetrics'])->name('engagement');
        Route::get('/realtime', [AnalyticsController::class, 'realTimeMetrics'])->name('realtime');
        Route::get('/platforms', [AnalyticsController::class, 'platformStatistics'])->name('platforms');
        Route::get('/geographic', [AnalyticsController::class, 'geographicStatistics'])->name('geographic');
        Route::get('/popular-content', [AnalyticsController::class, 'popularContent'])->name('popular-content');
        Route::get('/favorites-statistics', [AnalyticsController::class, 'favoritesStatistics'])->name('favorites-statistics');
        Route::get('/metrics', [AnalyticsController::class, 'getDashboardMetrics'])->name('metrics');
        Route::post('/clear-cache', [AnalyticsController::class, 'clearCache'])->name('clear-cache');
        Route::get('/export', [AnalyticsController::class, 'export'])->name('export');
        Route::get('/info', [AnalyticsController::class, 'info'])->name('info');
    });
});

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});

// ============================================================
// Routes pour les partages (publiques - tracking)
// ============================================================
Route::prefix('v1/shares')->group(function () {
    Route::get('/url', [ShareController::class, 'getShareUrl']);
    Route::get('/metadata', [ShareController::class, 'getShareMetadata']);
    Route::post('/track', [ShareController::class, 'trackShare']);
});

// ============================================================
// Routes d'authentification
// ============================================================
Route::prefix('v1/auth')->group(function () {
    Route::post('/register', [AuthController::class, 'register']);
    Route::post('/login', [AuthController::class, 'login']);

    Route::middleware('auth:sanctum')->group(function () {
        Route::post('/logout', [AuthController::class, 'logout']);
        Route::get('/profile', [AuthController::class, 'profile']);
        Route::put('/profile', [AuthController::class, 'updateProfile']);
    });
});

// ============================================================
// Routes publiques pour l'app mobile (lecture seule)
// ============================================================
Route::prefix('v1')->group(function () {

    // Route spécifique tournois (DOIT être avant toute route {tournament})
    Route::middleware('auth:sanctum')->get('/tournaments/my-tournaments', [App\Http\Controllers\Api\TournamentController::class, 'myTournaments']);

    // Recettes
    Route::get('/recipes', [RecipeController::class, 'index']);
    Route::get('/recipes/{id}', [RecipeController::class, 'show']);
    Route::get('/recipes/featured/list', [RecipeController::class, 'featured']);
    Route::get('/recipes/categories/list', [RecipeController::class, 'categories']);

    // Bannières (lecture publique)
    Route::get('/banners', [BannerController::class, 'index']);
    Route::get('/banners/{id}', [BannerController::class, 'show']);
    Route::get('/banners/type/{type}', [BannerController::class, 'getByType']);

    // Cache PWA - lecture seule publique
    Route::get('/cache/stats', [CacheController::class, 'stats']);
    Route::get('/cache/status', [CacheController::class, 'status']);

    // Pages
    Route::get('/pages', [PageController::class, 'index']);
    Route::get('/pages/homepage', [PageController::class, 'homepage']);
    Route::get('/pages/menu', [PageController::class, 'menu']);
    Route::get('/pages/latest', [PageController::class, 'latest']);
    Route::get('/pages/{slug}', [PageController::class, 'show']);

    // Catégories (lecture publique)
    Route::get('/categories', [CategoryController::class, 'index']);
    Route::get('/categories/events', [CategoryController::class, 'events']);
    Route::get('/categories/recipes', [CategoryController::class, 'recipes']);
    Route::get('/categories/check', [CategoryController::class, 'checkExists']);

    // Event Categories (lecture publique)
    Route::get('/event-categories', [App\Http\Controllers\Api\EventCategoryController::class, 'index']);
    Route::get('/event-categories/{id}', [App\Http\Controllers\Api\EventCategoryController::class, 'show']);

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

    // Likes - Routes publiques (lecture seulement)
    Route::get('/likes/check', [LikeController::class, 'check']);
    Route::get('/likes', [LikeController::class, 'index']);

    // Comments - Routes publiques (lecture et création anonyme throttlée)
    Route::get('/comments', [CommentController::class, 'index']);
    Route::post('/comments', [CommentController::class, 'store'])->middleware('throttle:comments');
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

    // Statistiques publiques (lecture seule, pas de données sensibles)
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

// ============================================================
// Routes SplashScreen
// ============================================================
Route::prefix('v1/splash-screen')->group(function () {
    Route::get('/active', [SplashScreenController::class, 'getActive']);
});

Route::middleware('auth:sanctum')->prefix('v1/splash-screen')->group(function () {
    Route::post('/clear-cache', [SplashScreenController::class, 'clearCache']);
});

// ============================================================
// Routes protégées par authentification
// ============================================================
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

    // Profile - Routes protégées
    Route::get('/profile', [App\Http\Controllers\Api\ProfileController::class, 'show']);
    Route::get('/profile/stats', [App\Http\Controllers\Api\ProfileController::class, 'getStats']);
    Route::put('/profile/name', [App\Http\Controllers\Api\ProfileController::class, 'updateName']);
    Route::put('/profile/password', [App\Http\Controllers\Api\ProfileController::class, 'updatePassword']);
    Route::post('/profile/request-deletion', [App\Http\Controllers\Api\ProfileController::class, 'requestDataDeletion']);

    // Professional Content - Lecture seule (la création/modification se fait uniquement via Filament admin)
    Route::get('/professional-content', [ProfessionalContentController::class, 'index']);
    Route::get('/professional-content/types', [ProfessionalContentController::class, 'getContentTypes']);
    Route::get('/professional-content/{professionalContent}', [ProfessionalContentController::class, 'show']);

    // Routes de suppression pour l'administration
    Route::delete('/recipes/{recipe}', [RecipeController::class, 'destroy']);
    Route::delete('/tips/{tip}', [TipController::class, 'destroy']);

    // ---- Routes admin (cache, création catégories) ----
    Route::post('/banners/clear-cache', [BannerController::class, 'clearCache']);
    Route::post('/cache/invalidate-content', [CacheController::class, 'invalidateContent']);
    Route::post('/cache/clear-all', [CacheController::class, 'clearAll']);
    Route::post('/cache/invalidate', [CacheController::class, 'invalidate']);
    Route::post('/cache/clear', [CacheController::class, 'clear']);
    Route::post('/categories', [CategoryController::class, 'store']);
    Route::post('/event-categories', [App\Http\Controllers\Api\EventCategoryController::class, 'store']);
    Route::post('/event-categories/check-exists', [App\Http\Controllers\Api\EventCategoryController::class, 'checkExists']);
});

// ============================================================
// Routes cache PWA - lecture publique, écriture protégée
// ============================================================
Route::prefix('pwa/cache')->group(function () {
    // Lecture publique (la PWA a besoin de lire le cache)
    Route::post('get', [CacheController::class, 'get']);
    Route::get('stats', [CacheController::class, 'stats']);
    Route::get('status', [CacheController::class, 'getStatus']);

    // Écriture/suppression protégée
    Route::middleware('auth:sanctum')->group(function () {
        Route::post('set', [CacheController::class, 'set']);
        Route::post('invalidate', [CacheController::class, 'invalidate']);
        Route::post('clear', [CacheController::class, 'clear']);
        Route::post('warmup', [CacheController::class, 'warmup']);
        Route::post('invalidate-content', [CacheController::class, 'invalidateContent']);
    });
});
