<?php

namespace App\Console\Commands;

use App\Models\PushNotification;
use App\Services\OneSignalService;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Auth;

class TestNotification extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'test:notification {--title=Test} {--message=Message de test} {--url=} {--simulate} {--minimal}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Envoie une notification de test via OneSignal';

    protected OneSignalService $oneSignalService;

    public function __construct(OneSignalService $oneSignalService)
    {
        parent::__construct();
        $this->oneSignalService = $oneSignalService;
    }

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $this->info('🧪 Test de notification OneSignal');
        $this->newLine();

        // Mode simulation si demandé ou si pas de clés configurées
        $simulate = $this->option('simulate') || $this->option('minimal') || !config('services.onesignal.rest_api_key');
        
        if ($simulate) {
            $mode = $this->option('minimal') ? 'minimal' : 'simulation';
            $this->warn('⚠️  Mode ' . $mode . ' activé (pas de clés OneSignal configurées)');
            $this->newLine();
            
            // 1. Test de la configuration
            $this->line('1️⃣ Vérification de la configuration...');
            $this->checkConfiguration();
            
            // 2. Créer une notification de test (simulation)
            $this->line('2️⃣ Création d\'une notification de test (simulation)...');
            
            $notification = PushNotification::create([
                'title' => $this->option('title') . ' - ' . now()->format('H:i:s'),
                'message' => $this->option('message') . ' (envoyé à ' . now()->format('d/m/Y H:i:s') . ')',
                'url' => $this->option('url'),
                'target_audience' => 'all',
                'status' => 'draft',
                'created_by' => 1,
            ]);

            $this->info('✅ Notification créée avec l\'ID: ' . $notification->id);
            $this->newLine();
            
            // 3. Simuler l'envoi
            $this->line('3️⃣ Simulation de l\'envoi...');
            $this->info('✅ Notification simulée avec succès !');
            $this->line('   🆔 OneSignal ID: SIMULATED-' . $notification->id);
            $this->line('   👥 Destinataires: Tous les utilisateurs (simulation)');
            
            $notification->update([
                'onesignal_id' => 'SIMULATED-' . $notification->id,
                'status' => 'sent',
                'sent_at' => now(),
                'statistics' => ['simulated' => true]
            ]);
            
            $this->newLine();
            if ($this->option('minimal')) {
                $this->warn('📝 Configuration OneSignal minimale :');
                $this->line('   1. Allez sur https://onesignal.com');
                $this->line('   2. Créez une nouvelle application');
                $this->line('   3. Choisissez "Flutter" comme plateforme');
                $this->line('   4. Suivez les étapes de configuration');
                $this->line('   5. Récupérez le nouvel App ID et REST API Key');
                $this->line('   6. Mettez à jour votre configuration');
            } else {
                $this->warn('📝 Pour envoyer de vraies notifications :');
                $this->line('   1. Obtenez vos clés OneSignal depuis le dashboard');
                $this->line('   2. Configurez ONESIGNAL_REST_API_KEY dans .env');
                $this->line('   3. Relancez cette commande sans --simulate');
            }
            
            return Command::SUCCESS;
        }

        // Mode normal avec OneSignal
        // 1. Tester la connexion OneSignal
        $this->line('1️⃣ Test de la connexion OneSignal...');
        $connectionResult = $this->oneSignalService->testConnection();
        
        if (!$connectionResult['success']) {
            $this->error('❌ Connexion OneSignal échouée: ' . $connectionResult['error']);
            $this->newLine();
            $this->line('🔧 Vérifiez vos variables d\'environnement:');
            $this->line('   - ONESIGNAL_APP_ID');
            $this->line('   - ONESIGNAL_REST_API_KEY');
            return Command::FAILURE;
        }
        
        $this->info('✅ Connexion OneSignal réussie');
        $this->newLine();

        // 2. Créer et envoyer une notification de test
        $this->line('2️⃣ Création d\'une notification de test...');
        
        $notification = PushNotification::create([
            'title' => $this->option('title') . ' - ' . now()->format('H:i:s'),
            'message' => $this->option('message') . ' (envoyé à ' . now()->format('d/m/Y H:i:s') . ')',
            'url' => $this->option('url'),
            'target_audience' => 'all',
            'status' => 'draft',
            'created_by' => 1,
        ]);

        $this->info('✅ Notification créée avec l\'ID: ' . $notification->id);
        $this->newLine();

        // 3. Envoyer la notification
        $this->line('3️⃣ Envoi de la notification...');
        
        $result = $this->oneSignalService->sendNotification($notification);
        
        if ($result['success']) {
            $this->info('✅ Notification envoyée avec succès !');
            $this->line('   🆔 OneSignal ID: ' . ($result['data']['id'] ?? 'N/A'));
            $this->line('   👥 Destinataires: ' . ($result['data']['recipients'] ?? 'N/A'));
            
            if (isset($result['data']['external_id'])) {
                $this->line('   🔗 External ID: ' . $result['data']['external_id']);
            }
        } else {
            $this->error('❌ Échec de l\'envoi: ' . $result['error']);
            return Command::FAILURE;
        }

        $this->newLine();
        $this->info('🎉 Test terminé avec succès !');
        $this->line('📱 Vérifiez votre application Flutter pour voir la notification');
        
        return Command::SUCCESS;
    }

    private function checkConfiguration()
    {
        $appId = config('services.onesignal.app_id');
        $restApiKey = config('services.onesignal.rest_api_key');
        
        $this->line('📋 Configuration actuelle:');
        $this->line('   - ONESIGNAL_APP_ID: ' . ($appId ? '✅ ' . $appId : '❌ Manquant'));
        $this->line('   - ONESIGNAL_REST_API_KEY: ' . ($restApiKey ? '✅ Configuré' : '❌ Manquant'));
        
        if (!$restApiKey) {
            $this->newLine();
            $this->line('🔑 Pour obtenir vos clés OneSignal:');
            $this->line('   1. Allez sur https://onesignal.com');
            $this->line('   2. Connectez-vous à votre compte');
            $this->line('   3. Sélectionnez votre application');
            $this->line('   4. Settings → Keys & IDs');
            $this->line('   5. Copiez REST API Key et User Auth Key');
            $this->line('   6. Ajoutez-les dans votre fichier .env');
        }
    }
} 