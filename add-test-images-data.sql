-- Script pour ajouter des données de test avec images et galleries
-- À exécuter après avoir configuré la base de données

-- Mettre à jour quelques recettes existantes avec des images et galleries
UPDATE recipes SET 
    featured_image = 'recipes/featured/recipe-1.jpg',
    gallery = '["recipes/gallery/recipe-1-1.jpg", "recipes/gallery/recipe-1-2.jpg", "recipes/gallery/recipe-1-3.jpg"]',
    ingredients = '["Tomates fraîches (3 pièces)", "Oignons moyens (2 pièces)", "Gousses d\'ail (3 pièces)", "Épices locales (au goût)", "Huile de palme (2 cuillères à soupe)", "Poisson fumé (200g)", "Légumes verts (250g)"]',
    instructions = '["Préparer et laver tous les ingrédients", "Faire revenir les oignons et l\'ail dans l\'huile chaude", "Ajouter les tomates coupées et les épices", "Laisser mijoter pendant 15 minutes à feu moyen", "Ajouter le poisson fumé et les légumes verts", "Cuire encore 10 minutes en remuant délicatement", "Servir chaud avec du riz blanc ou de l\'attiéké"]'
WHERE id = 1;

UPDATE recipes SET 
    featured_image = 'recipes/featured/default-recipe.jpg',
    gallery = '["recipes/gallery/recipe-1-1.jpg", "recipes/gallery/recipe-1-2.jpg"]',
    ingredients = '["Bananes plantain bien mûres (4 pièces)", "Huile de friture (500ml)", "Sel (une pincée)", "Oignons (facultatif)", "Piment rouge (au goût)"]',
    instructions = '["Éplucher les bananes plantain", "Les couper en rondelles ou en lanières", "Chauffer l\'huile dans une poêle", "Frire les bananes jusqu\'à ce qu\'elles soient dorées", "Égoutter sur du papier absorbant", "Saler légèrement avant de servir"]'
WHERE id = 2;

-- Mettre à jour quelques événements avec des images et galleries
UPDATE events SET 
    featured_image = 'events/featured/event-1.jpg',
    gallery = '["events/gallery/event-1-1.jpg", "events/gallery/event-1-2.jpg"]',
    program = 'Dégustation des spécialités ivoiriennes\\nAtelier de préparation de l\'attiéké\\nConcours de cuisine entre participants\\nRemise des prix et clôture'
WHERE id = 1;

UPDATE events SET 
    featured_image = 'events/featured/default-event.jpg',
    gallery = '["events/gallery/event-1-1.jpg"]',
    program = 'Accueil et présentation des chefs\\nDémonstration de techniques culinaires\\nAtelier pratique guidé\\nDégustation collective'
WHERE id = 2;

-- Insérer une nouvelle recette avec toutes les données
INSERT INTO recipes (
    title, 
    description, 
    short_description,
    featured_image,
    gallery,
    ingredients,
    instructions,
    preparation_time,
    cooking_time,
    servings,
    difficulty,
    category_id,
    is_published,
    is_featured,
    created_at,
    updated_at
) VALUES (
    'Poulet Kedjenou aux légumes',
    'Plat traditionnel ivoirien mijoté dans sa propre eau avec des légumes frais et des épices locales. Une recette authentique transmise de génération en génération.',
    'Délicieux poulet mijoté aux épices ivoiriennes',
    'recipes/featured/recipe-1.jpg',
    '["recipes/gallery/recipe-1-1.jpg", "recipes/gallery/recipe-1-2.jpg", "recipes/gallery/recipe-1-3.jpg"]',
    '["Poulet fermier (1 kg)", "Oignons (2 moyens)", "Tomates (3 grosses)", "Gingembre frais (2 cm)", "Ail (4 gousses)", "Piment vert (2 pièces)", "Aubergines africaines (200g)", "Gombo (150g)", "Huile de palme (3 cuillères)", "Sel et poivre", "Bouillon de volaille", "Feuilles de laurier (2)"]',
    '["Découper le poulet en morceaux et assaisonner", "Faire mariner avec ail, gingembre et épices 30 min", "Faire chauffer l\'huile de palme dans une cocotte", "Faire dorer les morceaux de poulet de tous côtés", "Ajouter les oignons émincés et faire revenir", "Incorporer les tomates coupées en dés", "Ajouter les légumes et les épices", "Couvrir et laisser mijoter 45 minutes", "Vérifier l\'assaisonnement", "Servir chaud avec du riz ou de l\'attiéké"]',
    30,
    45,
    6,
    'medium',
    1,
    1,
    1,
    NOW(),
    NOW()
);

-- Insérer un nouvel événement avec toutes les données
INSERT INTO events (
    title,
    description,
    short_description,
    featured_image,
    gallery,
    program,
    start_date,
    end_date,
    location,
    city,
    is_free,
    price,
    currency,
    category_id,
    event_type,
    is_published,
    is_featured,
    created_at,
    updated_at
) VALUES (
    'Festival Culinaire de Côte d\'Ivoire',
    'Grand festival célébrant la richesse de la gastronomie ivoirienne avec des chefs renommés, des dégustations et des ateliers pratiques pour tous les âges.',
    'Célébration de la gastronomie ivoirienne',
    'events/featured/event-1.jpg',
    '["events/gallery/event-1-1.jpg", "events/gallery/event-1-2.jpg"]',
    '09h00 - Ouverture officielle du festival\\n10h00 - Démonstrations culinaires par les chefs\\n12h00 - Dégustation de spécialités régionales\\n14h00 - Ateliers participatifs pour enfants\\n16h00 - Concours de cuisine amateur\\n18h00 - Remise des prix et spectacle\\n20h00 - Clôture du festival',
    DATE_ADD(CURDATE(), INTERVAL 15 DAY),
    DATE_ADD(CURDATE(), INTERVAL 15 DAY),
    'Place de la République',
    'Abidjan',
    0,
    5000,
    'XOF',
    1,
    'festival',
    1,
    1,
    NOW(),
    NOW()
); 