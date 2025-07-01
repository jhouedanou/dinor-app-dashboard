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
    protected $description = 'Update favorites_count field for all content types';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $this->info('Updating favorites count for all content...');

        // Update recipes
        $this->info('Updating recipes...');
        Recipe::chunk(100, function ($recipes) {
            foreach ($recipes as $recipe) {
                $actualCount = $recipe->favorites()->count();
                $recipe->update(['favorites_count' => $actualCount]);
            }
        });

        // Update events
        $this->info('Updating events...');
        Event::chunk(100, function ($events) {
            foreach ($events as $event) {
                $actualCount = $event->favorites()->count();
                $event->update(['favorites_count' => $actualCount]);
            }
        });

        // Update tips
        $this->info('Updating tips...');
        Tip::chunk(100, function ($tips) {
            foreach ($tips as $tip) {
                $actualCount = $tip->favorites()->count();
                $tip->update(['favorites_count' => $actualCount]);
            }
        });

        $this->info('Favorites count updated successfully!');
    }
}