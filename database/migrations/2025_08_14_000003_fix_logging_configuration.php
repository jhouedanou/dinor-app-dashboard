<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\Artisan;

return new class extends Migration
{
    public function up(): void
    {
        // Vider le cache de configuration
        Artisan::call('config:clear');
        Artisan::call('cache:clear');
        
        // Recréer le cache de configuration
        Artisan::call('config:cache');
    }

    public function down(): void
    {
        // Vider le cache de configuration
        Artisan::call('config:clear');
        Artisan::call('cache:clear');
    }
};
