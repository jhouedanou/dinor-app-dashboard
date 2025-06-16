#!/bin/bash

echo "📊 Ajout de données d'exemple Dinor Dashboard"
echo "============================================="

# Fonction pour exécuter une commande dans le conteneur
exec_in_container() {
    local container=$1
    local command=$2
    echo "🔧 Exécution dans $container: $command"
    docker exec -it "$container" bash -c "$command"
}

echo ""
echo "1️⃣ Création d'utilisateurs de test..."
exec_in_container "dinor-app" "php artisan tinker --execute=\"
\$users = [];
for (\$i = 1; \$i <= 15; \$i++) {
    \$users[] = [
        'name' => 'Utilisateur Test ' . \$i,
        'email' => 'user' . \$i . '@dinor.app',
        'password' => bcrypt('password'),
        'email_verified_at' => now(),
        'created_at' => now(),
        'updated_at' => now(),
    ];
}
App\Models\User::insert(\$users);
echo 'Utilisateurs créés: ' . count(\$users);
\""

echo ""
echo "2️⃣ Création de recettes supplémentaires..."
exec_in_container "dinor-app" "php artisan tinker --execute=\"
\$categories = App\Models\Category::all();
\$recipes = [
    [
        'title' => 'Kedjenou de Poulet',
        'slug' => 'kedjenou-poulet',
        'description' => 'Poulet traditionnel cuit à l\'étouffée avec des légumes',
        'short_description' => 'Spécialité ivoirienne authentique',
        'category_id' => \$categories->first()->id,
        'preparation_time' => 25,
        'cooking_time' => 60,
        'servings' => 6,
        'difficulty' => 'medium',
        'meal_type' => 'lunch',
        'is_published' => true,
        'is_featured' => true,
        'chef_name' => 'Chef Konaté',
        'ingredients' => json_encode([
            ['name' => 'Poulet fermier', 'quantity' => '1.5', 'unit' => 'kg'],
            ['name' => 'Gingembre', 'quantity' => '30', 'unit' => 'g'],
            ['name' => 'Oignons', 'quantity' => '3', 'unit' => 'pièces'],
            ['name' => 'Tomates', 'quantity' => '4', 'unit' => 'pièces']
        ]),
        'instructions' => json_encode([
            ['step' => 'Découper le poulet en morceaux'],
            ['step' => 'Assaisonner avec gingembre et épices'],
            ['step' => 'Disposer dans une canari avec légumes'],
            ['step' => 'Cuire à l\'étouffée pendant 1h']
        ]),
        'tags' => json_encode(['kedjenou', 'poulet', 'traditionnel']),
        'origin_country' => 'Côte d\'Ivoire',
        'created_at' => now(),
        'updated_at' => now()
    ],
    [
        'title' => 'Sauce Graine',
        'slug' => 'sauce-graine',
        'description' => 'Sauce traditionnelle à base de graines de palme',
        'short_description' => 'Délicieuse sauce ivoirienne',
        'category_id' => \$categories->first()->id,
        'preparation_time' => 30,
        'cooking_time' => 90,
        'servings' => 8,
        'difficulty' => 'hard',
        'meal_type' => 'lunch',
        'is_published' => true,
        'chef_name' => 'Chef Aminata',
        'ingredients' => json_encode([
            ['name' => 'Graines de palme', 'quantity' => '500', 'unit' => 'g'],
            ['name' => 'Viande de bœuf', 'quantity' => '800', 'unit' => 'g'],
            ['name' => 'Poisson fumé', 'quantity' => '200', 'unit' => 'g'],
            ['name' => 'Gombo', 'quantity' => '300', 'unit' => 'g']
        ]),
        'instructions' => json_encode([
            ['step' => 'Écraser les graines de palme'],
            ['step' => 'Extraire l\'huile rouge'],
            ['step' => 'Cuire la viande avec les épices'],
            ['step' => 'Ajouter les légumes et mijoter']
        ]),
        'tags' => json_encode(['sauce', 'graine', 'traditionnel']),
        'origin_country' => 'Côte d\'Ivoire',
        'created_at' => now(),
        'updated_at' => now()
    ]
];
App\Models\Recipe::insert(\$recipes);
echo 'Recettes créées: ' . count(\$recipes);
\""

echo ""
echo "3️⃣ Ajout d'événements variés..."
exec_in_container "dinor-app" "php artisan tinker --execute=\"
\$categories = App\Models\Category::all();
\$events = [
    [
        'title' => 'Concours de Cuisine Ivoirienne',
        'slug' => 'concours-cuisine-ivoirienne',
        'description' => 'Participez au grand concours de cuisine traditionnelle',
        'short_description' => 'Concours culinaire avec prix',
        'start_date' => now()->addDays(20),
        'end_date' => now()->addDays(21),
        'start_time' => '10:00:00',
        'end_time' => '16:00:00',
        'location' => 'Centre Culturel de Cocody',
        'address' => 'Boulevard Lagunaire, Cocody',
        'city' => 'Abidjan',
        'country' => 'Côte d\'Ivoire',
        'category_id' => \$categories->first()->id,
        'event_type' => 'competition',
        'event_format' => 'in_person',
        'max_participants' => 50,
        'price' => 2000,
        'currency' => 'XOF',
        'is_free' => false,
        'requires_registration' => true,
        'status' => 'active',
        'is_published' => true,
        'tags' => json_encode(['concours', 'cuisine', 'prix']),
        'created_at' => now(),
        'updated_at' => now()
    ],
    [
        'title' => 'Marché des Saveurs',
        'slug' => 'marche-saveurs',
        'description' => 'Découvrez les produits locaux et épices',
        'short_description' => 'Marché spécialisé produits locaux',
        'start_date' => now()->addDays(10),
        'start_time' => '07:00:00',
        'end_time' => '14:00:00',
        'location' => 'Marché de Treichville',
        'address' => 'Avenue Chardy, Treichville',
        'city' => 'Abidjan',
        'country' => 'Côte d\'Ivoire',
        'category_id' => \$categories->first()->id,
        'event_type' => 'exhibition',
        'event_format' => 'in_person',
        'is_free' => true,
        'status' => 'active',
        'is_published' => true,
        'tags' => json_encode(['marché', 'produits', 'local']),
        'created_at' => now(),
        'updated_at' => now()
    ]
];
App\Models\Event::insert(\$events);
echo 'Événements créés: ' . count(\$events);
\""

echo ""
echo "4️⃣ Création de contenus Dinor TV..."
exec_in_container "dinor-app" "php artisan tinker --execute=\"
\$categories = App\Models\Category::all();
\$videos = [
    [
        'title' => 'Secrets du Garba',
        'slug' => 'secrets-garba',
        'description' => 'Apprenez à préparer le garba comme un pro',
        'video_url' => 'https://www.youtube.com/watch?v=demo1',
        'duration' => 720,
        'category_id' => \$categories->first()->id,
        'is_published' => true,
        'is_featured' => true,
        'tags' => json_encode(['garba', 'technique', 'expert']),
        'created_at' => now(),
        'updated_at' => now()
    ],
    [
        'title' => 'Live Cooking Show',
        'slug' => 'live-cooking-show',
        'description' => 'Émission culinaire en direct tous les vendredis',
        'video_url' => 'https://www.youtube.com/watch?v=demo2',
        'duration' => 3600,
        'category_id' => \$categories->first()->id,
        'is_live' => true,
        'scheduled_at' => now()->addDays(5),
        'is_published' => true,
        'tags' => json_encode(['live', 'show', 'vendredi']),
        'created_at' => now(),
        'updated_at' => now()
    ]
];
App\Models\DinorTv::insert(\$videos);
echo 'Vidéos créées: ' . count(\$videos);
\""

echo ""
echo "5️⃣ Ajout d'astuces culinaires..."
exec_in_container "dinor-app" "php artisan tinker --execute=\"
\$categories = App\Models\Category::all();
\$tips = [
    [
        'title' => 'Comment bien nettoyer le poisson',
        'slug' => 'nettoyer-poisson',
        'content' => 'Pour bien nettoyer un poisson, commencez par écailler sous l\'eau froide, retirez les nageoires puis videz délicatement...',
        'category_id' => \$categories->first()->id,
        'difficulty_level' => 'beginner',
        'estimated_time' => 10,
        'is_published' => true,
        'is_featured' => true,
        'tags' => json_encode(['poisson', 'nettoyage', 'base']),
        'created_at' => now(),
        'updated_at' => now()
    ],
    [
        'title' => 'Conservation de l\'huile de palme',
        'slug' => 'conservation-huile-palme',
        'content' => 'L\'huile de palme rouge se conserve mieux dans un endroit frais et sec, à l\'abri de la lumière...',
        'category_id' => \$categories->first()->id,
        'difficulty_level' => 'beginner',
        'estimated_time' => 5,
        'is_published' => true,
        'tags' => json_encode(['huile', 'palme', 'conservation']),
        'created_at' => now(),
        'updated_at' => now()
    ]
];
App\Models\Tip::insert(\$tips);
echo 'Astuces créées: ' . count(\$tips);
\""

echo ""
echo "6️⃣ Génération d'interactions (likes/commentaires)..."
exec_in_container "dinor-app" "php artisan db:seed --class=LikesAndCommentsSeeder"

echo ""
echo "✅ Données d'exemple ajoutées avec succès !"
echo ""
echo "📊 Contenu disponible :"
echo "   - Utilisateurs de test : ~15"
echo "   - Recettes : 4+ avec ingrédients et instructions"
echo "   - Événements : 4+ variés"
echo "   - Vidéos Dinor TV : 4+"
echo "   - Astuces culinaires : 4+"
echo "   - Likes et commentaires sur tous les contenus"
echo ""
echo "🌐 Accédez à votre dashboard : http://localhost:8000/admin"
echo "🔐 Connexion : admin@dinor.app / Dinor2024!Admin" 