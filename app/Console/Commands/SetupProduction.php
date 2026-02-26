<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\Artisan;

class SetupProduction extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'dinor:setup-production {--force : Force la recréation des données}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Configure l\'application Dinor pour la production avec données de démonstration';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $this->info('🚀 Configuration de Dinor pour la production...');
        
        // Vérifier l'environnement
        if (app()->environment('production') && !$this->option('force')) {
            if (!$this->confirm('Vous êtes en production. Voulez-vous continuer ?')) {
                $this->info('Opération annulée.');
                return 0;
            }
        }

        // Étape 1: Migrations
        $this->info('📊 Exécution des migrations...');
        Artisan::call('migrate', ['--force' => true]);
        $this->line(Artisan::output());

        // Étape 2: Cache des configurations
        $this->info('⚙️  Mise en cache des configurations...');
        Artisan::call('config:cache');
        Artisan::call('route:cache');
        Artisan::call('view:cache');

        // Étape 3: Stockage symbolique
        $this->info('🔗 Création du lien symbolique pour le stockage...');
        try {
            Artisan::call('storage:link');
            $this->line(Artisan::output());
        } catch (\Exception $e) {
            $this->warn('Le lien symbolique existe peut-être déjà.');
        }

        // Étape 4: Seeders
        $this->info('🌱 Ajout des données de démonstration...');
        Artisan::call('db:seed', [
            '--class' => 'ProductionSetupSeeder',
            '--force' => true
        ]);
        $this->line(Artisan::output());

        // Étape 5: Optimisations
        $this->info('🚀 Optimisations finales...');
        Artisan::call('optimize');
        
        $this->info('');
        $this->info('✅ Configuration terminée avec succès!');
        $this->info('');
        $this->info('🔑 Comptes créés:');
        $this->info('   Admin: admin@dinor.app / [mot de passe configuré dans .env ADMIN_DEFAULT_PASSWORD]');
        $this->info('');
        $this->info('🌐 L\'application est maintenant prête pour la production!');
        $this->info('   Dashboard admin: /admin');

        return 0;
    }
}