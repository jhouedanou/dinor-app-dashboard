<?php

namespace App\Services;

use App\Models\PushNotification;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage;

class FirebaseNotificationService
{
    private ?string $projectId;
    private ?string $serviceAccountJson;
    private string $apiUrl;

    public function __construct()
    {
        $this->projectId = config('services.firebase.project_id');
        $this->serviceAccountJson = config('services.firebase.service_account_json');
        $this->apiUrl = "https://fcm.googleapis.com/v1/projects/{$this->projectId}/messages:send";
    }

    /**
     * Envoie une notification push via Firebase FCM
     */
    public function sendNotification(PushNotification $notification): array
    {
        if (!$this->projectId || !$this->serviceAccountJson) {
            return [
                'success' => false,
                'error' => 'Configuration Firebase FCM incomplete'
            ];
        }

        try {
            $accessToken = $this->getAccessToken();
            if (!$accessToken) {
                return [
                    'success' => false,
                    'error' => 'Impossible d\'obtenir le token d\'accès Firebase'
                ];
            }

            $payload = $this->buildNotificationPayload($notification);
            
            Log::info('Envoi notification Firebase FCM', [
                'notification_id' => $notification->id,
                'payload' => $payload
            ]);

            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $accessToken,
                'Content-Type' => 'application/json',
            ])->post($this->apiUrl, $payload);

            if ($response->successful()) {
                $responseData = $response->json();
                
                $notification->update([
                    'onesignal_id' => $responseData['name'] ?? null,
                    'status' => 'sent',
                    'sent_at' => now(),
                    'statistics' => $responseData
                ]);

                return [
                    'success' => true,
                    'data' => $responseData
                ];
            } else {
                $error = $response->json();
                
                $notification->update([
                    'status' => 'failed',
                    'statistics' => $error
                ]);

                return [
                    'success' => false,
                    'error' => $error['error']['message'] ?? 'Erreur inconnue'
                ];
            }

        } catch (\Exception $e) {
            $notification->update(['status' => 'failed']);
            
            Log::error('Exception lors de l\'envoi Firebase FCM', [
                'notification_id' => $notification->id,
                'error' => $e->getMessage()
            ]);

            return [
                'success' => false,
                'error' => $e->getMessage()
            ];
        }
    }

    /**
     * Obtient un token d'accès Firebase
     */
    private function getAccessToken(): ?string
    {
        try {
            $serviceAccount = json_decode($this->serviceAccountJson, true);
            
            if (!$serviceAccount) {
                throw new \Exception('Service account JSON invalide');
            }

            // Ici vous devriez implémenter l'authentification OAuth2 avec JWT
            // Pour l'instant, retournons null pour éviter l'erreur
            return null;
            
        } catch (\Exception $e) {
            Log::error('Erreur obtention token Firebase', ['error' => $e->getMessage()]);
            return null;
        }
    }

    /**
     * Construit le payload pour l'API Firebase FCM
     */
    private function buildNotificationPayload(PushNotification $notification): array
    {
        $message = [
            'topic' => 'all-users', // Ou utilisez 'token' pour un device spécifique
            'notification' => [
                'title' => $notification->title,
                'body' => $notification->message,
            ],
            'data' => [
                'notification_id' => (string) $notification->id,
                'created_at' => $notification->created_at->toISOString(),
            ]
        ];

        if ($notification->url) {
            $message['data']['url'] = $notification->url;
        }

        return ['message' => $message];
    }

    /**
     * Teste la connexion à Firebase FCM
     */
    public function testConnection(): array
    {
        if (!$this->projectId) {
            return [
                'success' => false,
                'error' => 'Project ID Firebase non configuré'
            ];
        }

        if (!$this->serviceAccountJson) {
            return [
                'success' => false,
                'error' => 'Service Account JSON non configuré'
            ];
        }

        try {
            $serviceAccount = json_decode($this->serviceAccountJson, true);
            
            if (!$serviceAccount) {
                return [
                    'success' => false,
                    'error' => 'Service Account JSON invalide - vérifiez le format JSON'
                ];
            }

            if (!isset($serviceAccount['project_id']) || 
                !isset($serviceAccount['private_key']) || 
                !isset($serviceAccount['client_email'])) {
                return [
                    'success' => false,
                    'error' => 'Service Account JSON manque des champs requis (project_id, private_key, client_email)'
                ];
            }

            return [
                'success' => true,
                'message' => 'Configuration Firebase FCM valide',
                'project_id' => $serviceAccount['project_id']
            ];

        } catch (\Exception $e) {
            return [
                'success' => false,
                'error' => 'Erreur de validation JSON: ' . $e->getMessage()
            ];
        }
    }
} 