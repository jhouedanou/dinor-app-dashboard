<?php

// Script de test pour les bannières Dinor
// Utilisation : php test-banners.php

header('Content-Type: application/json');

// Données de test pour les bannières
$banners = [
    [
        'id' => 1,
        'type_contenu' => 'home',
        'titre' => 'Bienvenue sur Dinor',
        'sous_titre' => 'Découvrez la richesse de la cuisine ivoirienne',
        'section' => 'hero',
        'title' => 'Bienvenue sur Dinor',
        'description' => 'Une application dédiée aux saveurs authentiques de la Côte d\'Ivoire. Recettes traditionnelles, astuces culinaires et événements gastronomiques.',
        'image_url' => null,
        'background_color' => '#E1251B',
        'text_color' => '#FFFFFF',
        'button_text' => 'Découvrir nos recettes',
        'button_url' => '/recipes',
        'button_color' => '#FFFFFF',
        'position' => 'home',
        'order' => 1,
        'is_active' => true,
        'created_at' => '2025-06-27T16:00:00.000000Z',
        'updated_at' => '2025-06-27T16:00:00.000000Z'
    ],
    [
        'id' => 2,
        'type_contenu' => 'recipes',
        'titre' => 'Nos Délicieuses Recettes',
        'sous_titre' => 'Du traditionnel au moderne',
        'section' => 'hero',
        'title' => 'Nos Délicieuses Recettes',
        'description' => 'Explorez notre collection de recettes ivoiriennes, des plats traditionnels aux créations modernes.',
        'image_url' => null,
        'background_color' => '#2D8B57',
        'text_color' => '#FFFFFF',
        'button_text' => 'Voir toutes les recettes',
        'button_url' => '/recipes',
        'button_color' => '#FFFFFF',
        'position' => 'home',
        'order' => 2,
        'is_active' => true,
        'created_at' => '2025-06-27T16:00:00.000000Z',
        'updated_at' => '2025-06-27T16:00:00.000000Z'
    ],
    [
        'id' => 3,
        'type_contenu' => 'tips',
        'titre' => 'Astuces Culinaires',
        'sous_titre' => 'Les secrets des grands chefs',
        'section' => 'hero',
        'title' => 'Astuces Culinaires',
        'description' => 'Découvrez les techniques et astuces qui feront de vous un expert de la cuisine ivoirienne.',
        'image_url' => null,
        'background_color' => '#FF8C00',
        'text_color' => '#FFFFFF',
        'button_text' => 'Découvrir les astuces',
        'button_url' => '/tips',
        'button_color' => '#FFFFFF',
        'position' => 'home',
        'order' => 3,
        'is_active' => true,
        'created_at' => '2025-06-27T16:00:00.000000Z',
        'updated_at' => '2025-06-27T16:00:00.000000Z'
    ],
    [
        'id' => 6,
        'type_contenu' => 'home',
        'titre' => 'Nouvelle Collection',
        'sous_titre' => 'Plats de fête ivoiriens',
        'section' => 'featured',
        'title' => 'Nouvelle Collection',
        'description' => 'Découvrez notre nouvelle collection de recettes pour les grandes occasions.',
        'image_url' => null,
        'background_color' => '#FFD700',
        'text_color' => '#000000',
        'button_text' => 'Découvrir',
        'button_url' => '/recipes?featured=1',
        'button_color' => '#E1251B',
        'position' => 'home',
        'order' => 10,
        'is_active' => true,
        'created_at' => '2025-06-27T16:00:00.000000Z',
        'updated_at' => '2025-06-27T16:00:00.000000Z'
    ]
];

// Paramètres de la requête
$type_contenu = $_GET['type_contenu'] ?? null;
$section = $_GET['section'] ?? null;
$position = $_GET['position'] ?? 'home';

// Filtrer les bannières
$filtered_banners = array_filter($banners, function ($banner) use ($type_contenu, $section, $position) {
    $matches = true;
    
    if ($type_contenu && $banner['type_contenu'] !== $type_contenu) {
        $matches = false;
    }
    
    if ($section && $banner['section'] !== $section) {
        $matches = false;
    }
    
    if ($position && $banner['position'] !== $position && $banner['position'] !== 'all_pages') {
        $matches = false;
    }
    
    return $matches && $banner['is_active'];
});

// Trier par ordre
usort($filtered_banners, function ($a, $b) {
    return $a['order'] <=> $b['order'];
});

// Réponse JSON
$response = [
    'success' => true,
    'data' => array_values($filtered_banners),
    'count' => count($filtered_banners),
    'message' => 'Bannières de test récupérées avec succès'
];

echo json_encode($response, JSON_PRETTY_PRINT);

// Affichage pour le debug en CLI
if (php_sapi_name() === 'cli') {
    echo "\n\n=== Test des bannières Dinor ===\n";
    echo "Nombre de bannières trouvées: " . count($filtered_banners) . "\n";
    
    foreach ($filtered_banners as $banner) {
        echo "\n- {$banner['titre']} ({$banner['type_contenu']}/{$banner['section']})\n";
        echo "  Couleur: {$banner['background_color']}\n";
        echo "  Bouton: {$banner['button_text']} -> {$banner['button_url']}\n";
    }
    
    echo "\n=== Bannières pour homepage (type=home, section=hero) ===\n";
    
    $home_banners = array_filter($banners, function ($banner) {
        return $banner['type_contenu'] === 'home' && $banner['section'] === 'hero' && $banner['is_active'];
    });
    
    foreach ($home_banners as $banner) {
        echo "✅ {$banner['titre']}\n";
    }
    
    echo "\n=== Comment tester dans la PWA ===\n";
    echo "1. Vérifiez que l'API /banners fonctionne\n";
    echo "2. Testez avec: curl 'http://localhost:8000/api/banners?type_contenu=home&section=hero'\n";
    echo "3. Dans la PWA, vérifiez le composant BannerSection sur la homepage\n";
    echo "4. Les bannières devraient s'afficher avec les couleurs définies\n";
} 