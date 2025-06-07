<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Recipe;
use App\Models\Event;
use App\Models\DinorTv;
use App\Models\User;
use App\Models\Like;
use App\Models\Comment;

class LikesAndCommentsSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Créer quelques utilisateurs de test
        $users = User::factory(10)->create();

        // Récupérer quelques contenus existants
        $recipes = Recipe::limit(5)->get();
        $events = Event::limit(3)->get();
        $dinorTvs = DinorTv::limit(3)->get();

        // Créer des likes pour les recettes
        foreach ($recipes as $recipe) {
            // Likes d'utilisateurs connectés
            foreach ($users->random(rand(3, 7)) as $user) {
                Like::create([
                    'user_id' => $user->id,
                    'likeable_id' => $recipe->id,
                    'likeable_type' => Recipe::class,
                    'ip_address' => fake()->ipv4(),
                    'user_agent' => fake()->userAgent(),
                ]);
            }

            // Quelques likes anonymes
            for ($i = 0; $i < rand(2, 5); $i++) {
                Like::create([
                    'user_id' => null,
                    'likeable_id' => $recipe->id,
                    'likeable_type' => Recipe::class,
                    'ip_address' => fake()->ipv4(),
                    'user_agent' => fake()->userAgent(),
                ]);
            }

            // Commentaires pour les recettes
            foreach ($users->random(rand(2, 5)) as $user) {
                $comment = Comment::create([
                    'user_id' => $user->id,
                    'commentable_id' => $recipe->id,
                    'commentable_type' => Recipe::class,
                    'content' => fake()->paragraph(rand(1, 3)),
                    'is_approved' => true,
                    'ip_address' => fake()->ipv4(),
                    'user_agent' => fake()->userAgent(),
                ]);

                // Quelques réponses
                if (rand(0, 1)) {
                    Comment::create([
                        'user_id' => $users->random()->id,
                        'commentable_id' => $recipe->id,
                        'commentable_type' => Recipe::class,
                        'content' => fake()->sentence(rand(5, 15)),
                        'is_approved' => true,
                        'parent_id' => $comment->id,
                        'ip_address' => fake()->ipv4(),
                        'user_agent' => fake()->userAgent(),
                    ]);
                }
            }

            // Quelques commentaires anonymes
            for ($i = 0; $i < rand(1, 3); $i++) {
                Comment::create([
                    'user_id' => null,
                    'commentable_id' => $recipe->id,
                    'commentable_type' => Recipe::class,
                    'author_name' => fake()->name(),
                    'author_email' => fake()->email(),
                    'content' => fake()->paragraph(rand(1, 2)),
                    'is_approved' => rand(0, 1) ? true : false,
                    'ip_address' => fake()->ipv4(),
                    'user_agent' => fake()->userAgent(),
                ]);
            }
        }

        // Créer des likes et commentaires pour les événements
        foreach ($events as $event) {
            foreach ($users->random(rand(2, 6)) as $user) {
                Like::create([
                    'user_id' => $user->id,
                    'likeable_id' => $event->id,
                    'likeable_type' => Event::class,
                    'ip_address' => fake()->ipv4(),
                    'user_agent' => fake()->userAgent(),
                ]);

                if (rand(0, 1)) {
                    Comment::create([
                        'user_id' => $user->id,
                        'commentable_id' => $event->id,
                        'commentable_type' => Event::class,
                        'content' => fake()->paragraph(rand(1, 2)),
                        'is_approved' => true,
                        'ip_address' => fake()->ipv4(),
                        'user_agent' => fake()->userAgent(),
                    ]);
                }
            }
        }

        // Créer des likes et commentaires pour Dinor TV
        foreach ($dinorTvs as $dinorTv) {
            foreach ($users->random(rand(3, 8)) as $user) {
                Like::create([
                    'user_id' => $user->id,
                    'likeable_id' => $dinorTv->id,
                    'likeable_type' => DinorTv::class,
                    'ip_address' => fake()->ipv4(),
                    'user_agent' => fake()->userAgent(),
                ]);

                if (rand(0, 1)) {
                    Comment::create([
                        'user_id' => $user->id,
                        'commentable_id' => $dinorTv->id,
                        'commentable_type' => DinorTv::class,
                        'content' => fake()->sentence(rand(10, 30)),
                        'is_approved' => true,
                        'ip_address' => fake()->ipv4(),
                        'user_agent' => fake()->userAgent(),
                    ]);
                }
            }
        }

        $this->command->info('Likes et commentaires créés avec succès !');
    }
} 