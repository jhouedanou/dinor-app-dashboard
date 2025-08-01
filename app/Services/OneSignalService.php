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

                // Convert errors array to string if needed
                $errorMessage = $error['errors'] ?? 'Erreur inconnue';
                if (is_array($errorMessage)) {
                    $errorMessage = implode('. ', $errorMessage);
                }
                
                return [
                    'success' => false,
                    'error' => $errorMessage
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

        // Initialiser les données personnalisées
        $payload['data'] = [
            'notification_id' => $notification->id,
            'created_at' => $notification->created_at->toISOString(),
        ];

        // URL de destination (deep link ou URL personnalisée)
        $deepLinkUrl = $notification->getDeepLinkUrl();
        $isInternalContent = $deepLinkUrl && str_starts_with($deepLinkUrl, 'dinor://');
        
        if ($isInternalContent) {
            // Pour le contenu interne, utiliser seulement les données personnalisées
            // Ne pas définir d'URLs pour éviter les conflits OneSignal
            $payload['data']['content_type'] = $notification->content_type;
            $payload['data']['content_id'] = $notification->content_id;
            $payload['data']['deep_link'] = $deepLinkUrl;
            $payload['data']['action'] = 'navigate_to_content';
            
            // Configuration pour ouvrir l'app automatiquement
            $payload['android_background_data'] = true;
            $payload['content_available'] = true; // Pour iOS
            
        } else {
            // Pour les URLs externes, utiliser la logique normale
            if ($notification->url) {
                $payload['url'] = $notification->url;
                $payload['data']['url'] = $notification->url;
                $payload['data']['action'] = 'open_url';
                
                // Configuration pour ouvrir l'URL externe
                $payload['web_url'] = $notification->url;
            }
        }

        // Icône personnalisée
        if ($notification->icon) {
            $iconUrl = config('app.url') . '/storage/' . $notification->icon;
            $payload['chrome_web_icon'] = $iconUrl;
            $payload['firefox_icon'] = $iconUrl;
            $payload['ios_attachments'] = ['id' => $iconUrl];
            $payload['big_picture'] = $iconUrl;
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