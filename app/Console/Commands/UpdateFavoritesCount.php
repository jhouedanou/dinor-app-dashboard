<?php

namespace App\Console\Commands;

use App\Models\Recipe;
use App\Models\Event;
use App\Models\Tip;
use Illuminate\Console\Command;

class UpdateFavoritesCount extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'favorites:update-counts';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Update favorites_count and likes_count fields for all content types';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $this->info('Updating favorites and likes count for all content...');

        // Update recipes
        $this->info('Updating recipes...');
        Recipe::chunk(100, function ($recipes) {
            foreach ($recipes as $recipe) {
                $favoritesCount = $recipe->favorites()->count();
                $likesCount = $recipe->likes()->count();
                $recipe->update([
                    'favorites_count' => $favoritesCount,
                    'likes_count' => $likesCount
                ]);
            }
        });

        // Update events
        $this->info('Updating events...');
        Event::chunk(100, function ($events) {
            foreach ($events as $event) {
                $favoritesCount = $event->favorites()->count();
                $likesCount = $event->likes()->count();
                $event->update([
                    'favorites_count' => $favoritesCount,
                    'likes_count' => $likesCount
                ]);
            }
        });

        // Update tips
        $this->info('Updating tips...');
        Tip::chunk(100, function ($tips) {
            foreach ($tips as $tip) {
                $favoritesCount = $tip->favorites()->count();
                $likesCount = $tip->likes()->count();
                $tip->update([
                    'favorites_count' => $favoritesCount,
                    'likes_count' => $likesCount
                ]);
            }
        });

        $this->info('Favorites and likes count updated successfully!');
    }
}