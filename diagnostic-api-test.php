<?php
/**
 * Script de diagnostic pour les API PWA
 * À exécuter pour vérifier que les endpoints fonctionnent
 */

require_once 'vendor/autoload.php';

// Charger Laravel
$app = require_once 'bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\Recipe;
use App\Models\Category;
use App\Models\Event;
use App\Models\Tip;

echo "🔍 === DIAGNOSTIC API PWA ===\n\n";

try {
    // Test 1: Vérifier les recettes
    echo "1️⃣ Test des Recettes\n";
    echo "-------------------\n";
    $totalRecipes = Recipe::count();
    $publishedRecipes = Recipe::published()->count();
    $featuredRecipes = Recipe::featured()->count();
    
    echo "Total recettes: {$totalRecipes}\n";
    echo "Recettes publiées: {$publishedRecipes}\n";
    echo "Recettes vedettes: {$featuredRecipes}\n";
    
    if ($publishedRecipes > 0) {
        $sampleRecipe = Recipe::published()->first();
        echo "Exemple recette ID: {$sampleRecipe->id} - {$sampleRecipe->title}\n";
        echo "URL image: " . ($sampleRecipe->featured_image_url ?? 'Aucune') . "\n";
    }
    echo "\n";
    
    // Test 2: Test d'une URL API specific
    echo "2️⃣ Test API Endpoint\n";
    echo "--------------------\n";
    
    if ($publishedRecipes > 0) {
        $testRecipe = Recipe::published()->first();
        echo "Test /api/v1/recipes/{$testRecipe->id}\n";
        
        // Simuler la requête
        $controller = new \App\Http\Controllers\Api\RecipeController();
        try {
            $response = $controller->show($testRecipe->id);
            $data = json_decode($response->getContent(), true);
            echo "✅ API Response Success: " . ($data['success'] ? 'OUI' : 'NON') . "\n";
            echo "Titre retourné: " . ($data['data']['title'] ?? 'Aucun') . "\n";
        } catch (Exception $e) {
            echo "❌ Erreur API: " . $e->getMessage() . "\n";
        }
    }
    echo "\n";
    
    // Test 3: Vérifier les catégories
    echo "3️⃣ Test des Catégories\n";
    echo "----------------------\n";
    $categories = Category::count();
    echo "Total catégories: {$categories}\n";
    
    if ($categories > 0) {
        $sampleCategory = Category::first();
        echo "Exemple catégorie: {$sampleCategory->name}\n";
    }
    echo "\n";
    
    // Test 4: Vérifier la configuration de base
    echo "4️⃣ Configuration\n";
    echo "----------------\n";
    echo "APP_URL: " . config('app.url') . "\n";
    echo "Environment: " . config('app.env') . "\n";
    echo "Debug: " . (config('app.debug') ? 'ON' : 'OFF') . "\n";
    echo "\n";
    
    // Test 5: URLs de test direct
    echo "5️⃣ URLs à tester dans le navigateur\n";
    echo "-----------------------------------\n";
    $baseUrl = config('app.url');
    echo "Toutes les recettes: {$baseUrl}/api/v1/recipes\n";
    echo "Recettes featured: {$baseUrl}/api/v1/recipes/featured/list\n";
    echo "Dashboard: {$baseUrl}/api/v1/dashboard\n";
    
    if ($publishedRecipes > 0) {
        $testRecipe = Recipe::published()->first();
        echo "Recette spécifique: {$baseUrl}/api/v1/recipes/{$testRecipe->id}\n";
    }
    echo "\n";
    
    // Test 6: Test de connectivité base de données
    echo "6️⃣ Test Database\n";
    echo "----------------\n";
    try {
        \Illuminate\Support\Facades\DB::connection()->getPdo();
        echo "✅ Database connectée\n";
        
        // Test simple query
        $result = \Illuminate\Support\Facades\DB::select('SELECT COUNT(*) as count FROM recipes');
        echo "✅ Query test réussie: {$result[0]->count} recettes trouvées\n";
    } catch (Exception $e) {
        echo "❌ Erreur database: " . $e->getMessage() . "\n";
    }
    echo "\n";
    
    echo "🎉 Diagnostic terminé !\n";
    echo "\n";
    echo "💡 Si les APIs fonctionnent ici mais pas dans la PWA :\n";
    echo "   1. Vérifiez la configuration nginx/proxy\n";
    echo "   2. Vérifiez les CORS\n";
    echo "   3. Vérifiez les permissions de fichiers\n";
    echo "   4. Regardez les logs nginx et Laravel\n";

} catch (Exception $e) {
    echo "❌ Erreur fatale: " . $e->getMessage() . "\n";
    echo "Stack trace: " . $e->getTraceAsString() . "\n";
} 