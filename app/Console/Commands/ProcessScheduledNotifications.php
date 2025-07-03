<?php

namespace App\Console\Commands;

use App\Models\PushNotification;
use App\Services\OneSignalService;
use Illuminate\Console\Command;

class ProcessScheduledNotifications extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'notifications:send-scheduled';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Traite et envoie les notifications push planifiées';

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
        $this->info('🔔 Traitement des notifications planifiées...');

        // Récupérer les notifications à envoyer
        $notifications = PushNotification::pending()->get();

        if ($notifications->isEmpty()) {
            $this->info('✅ Aucune notification à envoyer.');
            return Command::SUCCESS;
        }

        $this->info("📱 {$notifications->count()} notification(s) à traiter.");

        $sent = 0;
        $failed = 0;

        foreach ($notifications as $notification) {
            $this->line("📤 Envoi de: {$notification->title}");

            $result = $this->oneSignalService->sendNotification($notification);

            if ($result['success']) {
                $sent++;
                $this->info("✅ Envoyée avec succès (ID OneSignal: {$result['data']['id']})");
            } else {
                $failed++;
                $this->error("❌ Échec: {$result['error']}");
            }
        }

        $this->newLine();
        $this->info("📊 Résumé:");
        $this->line("✅ Envoyées: {$sent}");
        if ($failed > 0) {
            $this->line("❌ Échecs: {$failed}");
        }

        return Command::SUCCESS;
    }
}
