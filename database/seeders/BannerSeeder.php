<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Banner;

class BannerSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Bannière principale d'accueil (Hero)
        Banner::updateOrCreate(
            ['type_contenu' => 'home', 'section' => 'hero'],
            [
                'titre' => 'Bienvenue sur Dinor',
                'sous_titre' => 'Découvrez la richesse de la cuisine ivoirienne',
                'description' => 'Une application dédiée aux saveurs authentiques de la Côte d\'Ivoire. Recettes traditionnelles, astuces culinaires et événements gastronomiques.',
                'background_color' => '#E1251B',
                'text_color' => '#FFFFFF',
                'button_text' => 'Découvrir nos recettes',
                'button_url' => '/recipes',
                'button_color' => '#FFFFFF',
                'position' => 'home',
                'order' => 1,
                'is_active' => true
            ]
        );

        // Bannière recettes
        Banner::updateOrCreate(
            ['type_contenu' => 'recipes', 'section' => 'hero'],
            [
                'titre' => 'Nos Délicieuses Recettes',
                'sous_titre' => 'Du traditionnel au moderne',
                'description' => 'Explorez notre collection de recettes ivoiriennes, des plats traditionnels aux créations modernes.',
                'background_color' => '#2D8B57',
                'text_color' => '#FFFFFF',
                'button_text' => 'Voir toutes les recettes',
                'button_url' => '/recipes',
                'button_color' => '#FFFFFF',
                'position' => 'home',
                'order' => 2,
                'is_active' => true
            ]
        );

        // Bannière astuces
        Banner::updateOrCreate(
            ['type_contenu' => 'tips', 'section' => 'hero'],
            [
                'titre' => 'Astuces Culinaires',
                'sous_titre' => 'Les secrets des grands chefs',
                'description' => 'Découvrez les techniques et astuces qui feront de vous un expert de la cuisine ivoirienne.',
                'background_color' => '#FF8C00',
                'text_color' => '#FFFFFF',
                'button_text' => 'Découvrir les astuces',
                'button_url' => '/tips',
                'button_color' => '#FFFFFF',
                'position' => 'home',
                'order' => 3,
                'is_active' => true
            ]
        );

        // Bannière événements
        Banner::updateOrCreate(
            ['type_contenu' => 'events', 'section' => 'hero'],
            [
                'titre' => 'Événements Culinaires',
                'sous_titre' => 'Rencontres et découvertes',
                'description' => 'Participez à nos événements gastronomiques et découvrez la culture culinaire ivoirienne.',
                'background_color' => '#8B008B',
                'text_color' => '#FFFFFF',
                'button_text' => 'Voir les événements',
                'button_url' => '/events',
                'button_color' => '#FFFFFF',
                'position' => 'home',
                'order' => 4,
                'is_active' => true
            ]
        );

        // Bannière Dinor TV
        Banner::updateOrCreate(
            ['type_contenu' => 'dinor_tv', 'section' => 'hero'],
            [
                'titre' => 'Dinor TV',
                'sous_titre' => 'Cuisine en direct',
                'description' => 'Regardez nos chefs préparer les meilleurs plats ivoiriens en direct et en replay.',
                'background_color' => '#DC143C',
                'text_color' => '#FFFFFF',
                'button_text' => 'Regarder maintenant',
                'button_url' => '/dinor-tv',
                'button_color' => '#FFFFFF',
                'position' => 'home',
                'order' => 5,
                'is_active' => true
            ]
        );

        // Bannière promotionnelle (featured)
        Banner::updateOrCreate(
            ['type_contenu' => 'home', 'section' => 'featured'],
            [
                'titre' => 'Nouvelle Collection',
                'sous_titre' => 'Plats de fête ivoiriens',
                'description' => 'Découvrez notre nouvelle collection de recettes pour les grandes occasions.',
                'background_color' => '#FFD700',
                'text_color' => '#000000',
                'button_text' => 'Découvrir',
                'button_url' => '/recipes?featured=1',
                'button_color' => '#E1251B',
                'position' => 'home',
                'order' => 10,
                'is_active' => true
            ]
        );

        $this->command->info('Bannières d\'exemple créées avec succès !');
    }
} 