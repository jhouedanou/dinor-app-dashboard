<?php

namespace App\Console\Commands;

use App\Services\FirebaseNotificationService;
use Illuminate\Console\Command;

class TestFirebaseNotification extends Command
{
    protected $signature = 'test:firebase';
    protected $description = 'Teste la configuration Firebase FCM et diagnostique les erreurs JSON';

    public function handle()
    {
        $this->info('🔥 Test de configuration Firebase FCM');
        $this->newLine();

        $firebaseService = new FirebaseNotificationService();
        
        // 1. Test de connexion
        $this->line('1️⃣ Test de la configuration Firebase...');
        $result = $firebaseService->testConnection();
        
        if ($result['success']) {
            $this->info('✅ Configuration Firebase valide');
            $this->line('   📁 Project ID: ' . $result['project_id']);
        } else {
            $this->error('❌ Erreur de configuration: ' . $result['error']);
            $this->newLine();
            
            // 2. Diagnostic détaillé
            $this->line('🔍 Diagnostic détaillé:');
            $this->diagnoseFirebaseConfig();
            
            return Command::FAILURE;
        }

        $this->newLine();
        $this->info('🎉 Configuration Firebase FCM valide !');
        
        return Command::SUCCESS;
    }

    private function diagnoseFirebaseConfig()
    {
        // Vérifier les variables d'environnement
        $projectId = config('services.firebase.project_id');
        $serviceAccountJson = config('services.firebase.service_account_json');
        
        $this->line('📋 Variables d\'environnement:');
        $this->line('   - FIREBASE_PROJECT_ID: ' . ($projectId ? '✅ Défini' : '❌ Manquant'));
        $this->line('   - FIREBASE_SERVICE_ACCOUNT_JSON: ' . ($serviceAccountJson ? '✅ Défini' : '❌ Manquant'));
        
        if ($serviceAccountJson) {
            $this->newLine();
            $this->line('🔍 Validation du JSON:');
            
            // Vérifier si c'est un JSON valide
            $decoded = json_decode($serviceAccountJson, true);
            if (json_last_error() !== JSON_ERROR_NONE) {
                $this->error('   ❌ JSON invalide: ' . json_last_error_msg());
                $this->line('   💡 Conseil: Vérifiez que votre JSON n\'est pas mal formaté');
                return;
            }
            
            $this->info('   ✅ JSON valide');
            
            // Vérifier les champs requis
            $requiredFields = ['project_id', 'private_key', 'client_email', 'type'];
            foreach ($requiredFields as $field) {
                if (isset($decoded[$field])) {
                    $this->line("   ✅ Champ '$field': présent");
                } else {
                    $this->error("   ❌ Champ '$field': manquant");
                }
            }
            
            // Vérifier le type
            if (isset($decoded['type']) && $decoded['type'] !== 'service_account') {
                $this->error('   ❌ Type incorrect: ' . $decoded['type'] . ' (attendu: service_account)');
            }
        }
        
        $this->newLine();
        $this->line('📝 Pour corriger l\'erreur "service account JSON invalid":');
        $this->line('   1. Allez sur https://console.firebase.google.com');
        $this->line('   2. Sélectionnez votre projet');
        $this->line('   3. Settings → Service accounts');
        $this->line('   4. Cliquez "Generate new private key"');
        $this->line('   5. Téléchargez le fichier JSON');
        $this->line('   6. Copiez tout le contenu JSON dans FIREBASE_SERVICE_ACCOUNT_JSON');
        $this->line('   7. Assurez-vous que le JSON est sur UNE seule ligne dans le .env');
    }
} 