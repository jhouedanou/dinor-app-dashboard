<?php

// Script rapide pour ajouter des données de test
// Usage: php add-quick-test-data.php

echo "=== Ajout de données de test pour l'API ===\n";

// Configuration de base de données
$host = 'localhost';
$dbname = 'dinor_app'; // Adaptez selon votre configuration
$username = 'root';    // Adaptez selon votre configuration
$password = '';        // Adaptez selon votre configuration

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    echo "✓ Connexion à la base de données réussie\n";
} catch (PDOException $e) {
    echo "✗ Erreur de connexion : " . $e->getMessage() . "\n";
    exit(1);
}

// Vérifier si des catégories existent
$stmt = $pdo->query("SELECT COUNT(*) FROM categories");
$categoryCount = $stmt->fetchColumn();

if ($categoryCount == 0) {
    echo "Ajout d'une catégorie par défaut...\n";
    $pdo->exec("INSERT INTO categories (name, slug, description, is_active, created_at, updated_at) 
                VALUES ('Cuisine Ivoirienne', 'cuisine-ivoirienne', 'Plats traditionnels de Côte d''Ivoire', 1, NOW(), NOW())");
}

$stmt = $pdo->query("SELECT id FROM categories LIMIT 1");
$categoryId = $stmt->fetchColumn();

// Ajouter des recettes de test
echo "Ajout de recettes de test...\n";
$recipes = [
    [
        'title' => 'Kedjenou de Poulet Test',
        'slug' => 'kedjenou-poulet-test-' . time(),
        'description' => 'Poulet traditionnel cuit à l\'étouffée - Version de test',
        'short_description' => 'Spécialité ivoirienne authentique',
        'ingredients' => json_encode([
            ['name' => 'Poulet', 'quantity' => '1', 'unit' => 'kg'],
            ['name' => 'Gingembre', 'quantity' => '20', 'unit' => 'g']
        ]),
        'instructions' => json_encode([
            ['step' => 'Découper le poulet'],
            ['step' => 'Assaisonner et cuire']
        ]),
        'preparation_time' => 25,
        'cooking_time' => 60,
        'servings' => 6,
        'difficulty' => 'medium',
        'meal_type' => 'lunch',
        'is_published' => 1,
        'is_featured' => 1,
        'category_id' => $categoryId
    ],
    [
        'title' => 'Alloco Simple Test',
        'slug' => 'alloco-simple-test-' . time(),
        'description' => 'Bananes plantains frites - Version de test',
        'short_description' => 'Collation traditionnelle',
        'ingredients' => json_encode([
            ['name' => 'Bananes plantains', 'quantity' => '4', 'unit' => 'pièces'],
            ['name' => 'Huile', 'quantity' => '100', 'unit' => 'ml']
        ]),
        'instructions' => json_encode([
            ['step' => 'Couper les bananes'],
            ['step' => 'Faire frire']
        ]),
        'preparation_time' => 10,
        'cooking_time' => 15,
        'servings' => 4,
        'difficulty' => 'easy',
        'meal_type' => 'snack',
        'is_published' => 1,
        'is_featured' => 0,
        'category_id' => $categoryId
    ]
];

foreach ($recipes as $recipe) {
    $sql = "INSERT INTO recipes (title, slug, description, short_description, ingredients, instructions, 
            preparation_time, cooking_time, servings, difficulty, meal_type, is_published, is_featured, 
            category_id, created_at, updated_at) 
            VALUES (:title, :slug, :description, :short_description, :ingredients, :instructions, 
            :preparation_time, :cooking_time, :servings, :difficulty, :meal_type, :is_published, 
            :is_featured, :category_id, NOW(), NOW())";
    
    $stmt = $pdo->prepare($sql);
    $stmt->execute($recipe);
    echo "✓ Recette ajoutée: " . $recipe['title'] . "\n";
}

// Ajouter des événements de test
echo "Ajout d'événements de test...\n";
$events = [
    [
        'title' => 'Concours Cuisine Test',
        'slug' => 'concours-cuisine-test-' . time(),
        'description' => 'Concours de cuisine - Version de test',
        'short_description' => 'Concours culinaire',
        'start_date' => date('Y-m-d', strtotime('+10 days')),
        'end_date' => date('Y-m-d', strtotime('+11 days')),
        'start_time' => '10:00:00',
        'end_time' => '16:00:00',
        'location' => 'Centre Test',
        'city' => 'Abidjan',
        'country' => 'Côte d\'Ivoire',
        'event_type' => 'competition',
        'event_format' => 'in_person',
        'status' => 'active',
        'is_published' => 1,
        'is_featured' => 1,
        'category_id' => $categoryId
    ]
];

foreach ($events as $event) {
    $sql = "INSERT INTO events (title, slug, description, short_description, start_date, end_date, start_time, 
            end_time, location, city, country, event_type, event_format, status, is_published, is_featured, 
            category_id, created_at, updated_at) 
            VALUES (:title, :slug, :description, :short_description, :start_date, :end_date, :start_time, 
            :end_time, :location, :city, :country, :event_type, :event_format, :status, :is_published, 
            :is_featured, :category_id, NOW(), NOW())";
    
    $stmt = $pdo->prepare($sql);
    $stmt->execute($event);
    echo "✓ Événement ajouté: " . $event['title'] . "\n";
}

// Vérification finale
$stmt = $pdo->query("SELECT COUNT(*) FROM recipes");
$recipeCount = $stmt->fetchColumn();

$stmt = $pdo->query("SELECT COUNT(*) FROM events");
$eventCount = $stmt->fetchColumn();

echo "\n=== Résumé ===\n";
echo "Nombre total de recettes: $recipeCount\n";
echo "Nombre total d'événements: $eventCount\n";
echo "Nombre total de catégories: $categoryCount\n";

echo "\n=== URLs de test ===\n";
echo "API Recettes: https://new.dinorapp.com/api/v1/recipes\n";
echo "API Événements: https://new.dinorapp.com/api/v1/events\n";
echo "Test Database: https://new.dinorapp.com/api/test/database-check\n";
echo "Test Recettes: https://new.dinorapp.com/api/test/recipes-all\n";

echo "\n✓ Données de test ajoutées avec succès !\n"; 