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
    protected $signature = 'test:notification {--title=Test} {--message=Message de test} {--url=}';

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
            'created_by' => 1, // Admin par défaut
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
} 