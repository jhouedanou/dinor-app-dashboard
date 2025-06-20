<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\AdminUser;
use Illuminate\Support\Facades\Hash;

class SetupProduction extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'dinor:setup-production 
                           {--force : Forcer la configuration même si déjà faite}
                           {--skip-admin : Ignorer la création de l\'admin}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Configure automatiquement l\'application pour la production';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $this->info('🚀 Configuration de Dinor Dashboard pour la production...');
        $this->newLine();

        $force = $this->option('force');
        $skipAdmin = $this->option('skip-admin');

        // 1. Vérifier l'environnement
        $this->info('1. Vérification de l\'environnement...');
        if (app()->environment('production') || $force) {
            $this->info('   ✅ Environnement de production détecté');
        } else {
            $this->warn('   ⚠️  Pas en environnement de production');
            if (!$this->confirm('Continuer quand même ?')) {
                return Command::FAILURE;
            }
        }

        // 2. Nettoyer les caches
        $this->info('2. Nettoyage des caches...');
        $this->call('config:clear');
        $this->call('cache:clear');
        $this->call('route:clear');
        $this->call('view:clear');
        $this->info('   ✅ Caches nettoyés');

        // 3. Exécuter les migrations
        $this->info('3. Exécution des migrations...');
        $this->call('migrate', ['--force' => true]);
        $this->info('   ✅ Migrations exécutées');

        // 4. Créer/mettre à jour l'utilisateur admin
        if (!$skipAdmin) {
            $this->info('4. Configuration de l\'utilisateur admin...');
            $this->setupAdminUser();
        } else {
            $this->info('4. Configuration admin ignorée (--skip-admin)');
        }

        // 5. Créer le lien symbolique du storage
        $this->info('5. Configuration du storage...');
        try {
            $this->call('storage:link');
            $this->info('   ✅ Lien symbolique créé');
        } catch (\Exception $e) {
            $this->warn('   ⚠️  Lien symbolique déjà existant ou erreur: ' . $e->getMessage());
        }

        // 6. Optimisation pour la production
        $this->info('6. Optimisation pour la production...');
        $this->call('config:cache');
        $this->call('route:cache');
        $this->call('view:cache');
        $this->info('   ✅ Optimisations appliquées');

        // 7. Vérifications finales
        $this->info('7. Vérifications finales...');
        $this->performFinalChecks();

        $this->newLine();
        $this->info('🎉 Configuration terminée avec succès !');
        $this->displayConnectionInfo();

        return Command::SUCCESS;
    }

    /**
     * Configure l'utilisateur admin
     */
    private function setupAdminUser()
    {
        $email = env('ADMIN_DEFAULT_EMAIL', 'admin@dinor.app');
        $password = env('ADMIN_DEFAULT_PASSWORD', 'Dinor2024!Admin');
        $name = env('ADMIN_DEFAULT_NAME', 'AdministrateurDinor');

        $admin = AdminUser::where('email', $email)->first();

        if ($admin) {
            // Mettre à jour l'admin existant
            $admin->update([
                'name' => $name,
                'password' => Hash::make($password),
                'is_active' => true,
            ]);
            $this->info("   ✅ Utilisateur admin mis à jour: {$email}");
        } else {
            // Créer un nouvel admin
            AdminUser::create([
                'name' => $name,
                'email' => $email,
                'password' => Hash::make($password),
                'email_verified_at' => now(),
                'is_active' => true,
            ]);
            $this->info("   ✅ Nouvel utilisateur admin créé: {$email}");
        }
    }

    /**
     * Effectuer les vérifications finales
     */
    private function performFinalChecks()
    {
        $checks = [
            'Base de données' => $this->checkDatabase(),
            'Admin user' => $this->checkAdminUser(),
            'Storage link' => $this->checkStorageLink(),
            'Cache optimisé' => $this->checkCache(),
        ];

        foreach ($checks as $check => $result) {
            $status = $result ? '✅' : '❌';
            $this->info("   {$status} {$check}");
        }
    }

    /**
     * Vérifier la connexion à la base de données
     */
    private function checkDatabase(): bool
    {
        try {
            \DB::connection()->getPdo();
            return true;
        } catch (\Exception $e) {
            return false;
        }
    }

    /**
     * Vérifier l'existence de l'utilisateur admin
     */
    private function checkAdminUser(): bool
    {
        $email = env('ADMIN_DEFAULT_EMAIL', 'admin@dinor.app');
        return AdminUser::where('email', $email)->where('is_active', true)->exists();
    }

    /**
     * Vérifier le lien symbolique du storage
     */
    private function checkStorageLink(): bool
    {
        return is_link(public_path('storage'));
    }

    /**
     * Vérifier si le cache est optimisé
     */
    private function checkCache(): bool
    {
        return file_exists(bootstrap_path('cache/config.php')) && 
               file_exists(bootstrap_path('cache/routes-v7.php'));
    }

    /**
     * Afficher les informations de connexion
     */
    private function displayConnectionInfo()
    {
        $email = env('ADMIN_DEFAULT_EMAIL', 'admin@dinor.app');
        $url = config('app.url');

        $this->newLine();
        $this->info('📋 Informations de connexion:');
        $this->info("🌐 URL Dashboard: {$url}/admin/login");
        $this->info("📧 Email: {$email}");
        $this->info("🔑 Mot de passe: " . env('ADMIN_DEFAULT_PASSWORD', 'Dinor2024!Admin'));
        $this->newLine();
        $this->info('📋 URLs API importantes:');
        $this->info("🔗 API Recettes: {$url}/api/v1/recipes");
        $this->info("🔗 API Événements: {$url}/api/v1/events");
        $this->info("🔗 Test Database: {$url}/api/test/database-check");
    }
} 