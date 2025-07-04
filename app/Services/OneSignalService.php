<?php

namespace App\Services;

use App\Models\PushNotification;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class OneSignalService
{
    private string $appId;
    private ?string $restApiKey;
    private string $apiUrl;

    public function __construct()
    {
        $this->appId = config('services.onesignal.app_id', '7703701f-3c33-408d-99e0-db5c4da8918a');
        $this->restApiKey = config('services.onesignal.rest_api_key');
        $this->apiUrl = 'https://onesignal.com/api/v1';
    }

    /**
     * Envoie une notification push via OneSignal
     */
    public function sendNotification(PushNotification $notification): array
    {
        if (!$this->restApiKey) {
            return [
                'success' => false,
                'error' => 'Clé API OneSignal non configurée'
            ];
        }

        try {
            $payload = $this->buildNotificationPayload($notification);
            
            Log::info('Envoi notification OneSignal', [
                'notification_id' => $notification->id,
                'payload' => $payload
            ]);

            $response = Http::withHeaders([
                'Authorization' => 'Basic ' . $this->restApiKey,
                'Content-Type' => 'application/json',
            ])->post($this->apiUrl . '/notifications', $payload);

            if ($response->successful()) {
                $responseData = $response->json();
                
                // Mettre à jour la notification avec l'ID OneSignal
                $notification->update([
                    'onesignal_id' => $responseData['id'] ?? null,
                    'status' => 'sent',
                    'sent_at' => now(),
                    'statistics' => $responseData
                ]);

                Log::info('Notification envoyée avec succès', [
                    'notification_id' => $notification->id,
                    'onesignal_id' => $responseData['id'] ?? null
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

                Log::error('Erreur envoi notification OneSignal', [
                    'notification_id' => $notification->id,
                    'error' => $error,
                    'status_code' => $response->status()
                ]);

                return [
                    'success' => false,
                    'error' => $error['errors'] ?? 'Erreur inconnue'
                ];
            }

        } catch (\Exception $e) {
            $notification->update(['status' => 'failed']);
            
            Log::error('Exception lors de l\'envoi OneSignal', [
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
     * Construit le payload pour l'API OneSignal
     */
    private function buildNotificationPayload(PushNotification $notification): array
    {
        $payload = [
            'app_id' => $this->appId,
            'headings' => ['en' => $notification->title],
            'contents' => ['en' => $notification->message],
        ];

        // Ciblage de l'audience
        switch ($notification->target_audience) {
            case 'all':
                $payload['included_segments'] = ['All'];
                break;
                
            case 'segments':
                if (!empty($notification->target_data)) {
                    $payload['included_segments'] = $notification->target_data;
                } else {
                    $payload['included_segments'] = ['All'];
                }
                break;
                
            case 'specific_users':
                if (!empty($notification->target_data)) {
                    $payload['include_external_user_ids'] = $notification->target_data;
                } else {
                    $payload['included_segments'] = ['All'];
                }
                break;
        }

        // URL de destination
        if ($notification->url) {
            $payload['url'] = $notification->url;
        }

        // Icône personnalisée
        if ($notification->icon) {
            $iconUrl = config('app.url') . '/storage/' . $notification->icon;
            $payload['chrome_web_icon'] = $iconUrl;
            $payload['firefox_icon'] = $iconUrl;
        }

        // Données additionnelles
        $payload['data'] = [
            'notification_id' => $notification->id,
            'created_at' => $notification->created_at->toISOString(),
        ];

        if ($notification->url) {
            $payload['data']['url'] = $notification->url;
        }

        return $payload;
    }

    /**
     * Récupère les statistiques d'une notification
     */
    public function getNotificationStats(string $onesignalId): array
    {
        try {
            $response = Http::withHeaders([
                'Authorization' => 'Basic ' . $this->restApiKey,
            ])->get($this->apiUrl . '/notifications/' . $onesignalId);

            if ($response->successful()) {
                return [
                    'success' => true,
                    'data' => $response->json()
                ];
            }

            return [
                'success' => false,
                'error' => $response->json()
            ];

        } catch (\Exception $e) {
            return [
                'success' => false,
                'error' => $e->getMessage()
            ];
        }
    }

    /**
     * Récupère la liste des segments disponibles
     */
    public function getSegments(): array
    {
        try {
            $response = Http::withHeaders([
                'Authorization' => 'Basic ' . $this->restApiKey,
            ])->get($this->apiUrl . '/apps/' . $this->appId . '/segments');

            if ($response->successful()) {
                return [
                    'success' => true,
                    'data' => $response->json()
                ];
            }

            return [
                'success' => false,
                'error' => $response->json()
            ];

        } catch (\Exception $e) {
            return [
                'success' => false,
                'error' => $e->getMessage()
            ];
        }
    }

    /**
     * Teste la connexion à l'API OneSignal
     */
    public function testConnection(): array
    {
        if (!$this->restApiKey) {
            return [
                'success' => false,
                'error' => 'Clé API OneSignal non configurée. Veuillez définir ONESIGNAL_REST_API_KEY dans votre fichier .env'
            ];
        }

        try {
            $response = Http::withHeaders([
                'Authorization' => 'Basic ' . $this->restApiKey,
            ])->get($this->apiUrl . '/apps/' . $this->appId);

            if ($response->successful()) {
                return [
                    'success' => true,
                    'message' => 'Connexion OneSignal réussie',
                    'data' => $response->json()
                ];
            }

            return [
                'success' => false,
                'error' => 'Erreur de connexion OneSignal: ' . $response->status()
            ];

        } catch (\Exception $e) {
            return [
                'success' => false,
                'error' => 'Exception: ' . $e->getMessage()
            ];
        }
    }
}