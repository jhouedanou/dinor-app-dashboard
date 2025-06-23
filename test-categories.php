<?php

require_once 'vendor/autoload.php';

use App\Models\Category;
use App\Models\Recipe;

// Charger l'application Laravel
$app = require_once 'bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

echo "=== Test du système de catégories ===\n\n";

// 1. Vérifier les catégories existantes
echo "1. Catégories existantes :\n";
$categories = Category::all();
foreach ($categories as $category) {
    echo "- {$category->name} (ID: {$category->id}, Actif: " . ($category->is_active ? 'Oui' : 'Non') . ")\n";
}

echo "\n";

// 2. Vérifier les catégories actives
echo "2. Catégories actives :\n";
$activeCategories = Category::active()->get();
foreach ($activeCategories as $category) {
    echo "- {$category->name}\n";
}

echo "\n";

// 3. Vérifier les recettes par catégorie
echo "3. Recettes par catégorie :\n";
$categoriesWithRecipes = Category::withCount('recipes')->get();
foreach ($categoriesWithRecipes as $category) {
    echo "- {$category->name}: {$category->recipes_count} recettes\n";
}

echo "\n";

// 4. Test de création d'une nouvelle catégorie
echo "4. Test de création d'une nouvelle catégorie :\n";
try {
    $newCategory = Category::create([
        'name' => 'Test Catégorie',
        'slug' => 'test-categorie',
        'description' => 'Catégorie de test',
        'color' => '#FF0000',
        'icon' => 'heroicon-o-test',
        'is_active' => true,
    ]);
    echo "✓ Catégorie créée avec succès: {$newCategory->name}\n";
    
    // Supprimer la catégorie de test
    $newCategory->delete();
    echo "✓ Catégorie de test supprimée\n";
} catch (Exception $e) {
    echo "✗ Erreur lors de la création: " . $e->getMessage() . "\n";
}

echo "\n=== Test terminé ===\n"; 