<?php

namespace App\Filament\Resources\PushNotificationResource\Pages;

use App\Filament\Resources\PushNotificationResource;
use App\Services\OneSignalService;
use Filament\Actions;
use Filament\Resources\Pages\CreateRecord;
use Filament\Notifications\Notification;
use Illuminate\Support\Facades\Auth;
use Illuminate\Database\Eloquent\Model;

class CreatePushNotification extends CreateRecord
{
    protected static string $resource = PushNotificationResource::class;

    protected function mutateFormDataBeforeCreate(array $data): array
    {
        $data['created_by'] = Auth::guard('admin')->id();
        
        // Stocker si on doit envoyer immédiatement
        if ($data['status'] === 'send_now') {
            $this->shouldSendImmediately = true;
            $data['status'] = 'draft'; // Créer d'abord en draft
        }
        
        return $data;
    }

    private bool $shouldSendImmediately = false;

    protected function afterCreate(): void
    {
        $record = $this->record;
        
        // Vérifier si on doit envoyer immédiatement
        if ($this->shouldSendImmediately) {
            $this->sendNotificationNow($record);
        }
    }

    private function sendNotificationNow(Model $record): void
    {
        try {
            $oneSignalService = new OneSignalService();
            $result = $oneSignalService->sendNotification($record);
            
            if ($result['success']) {
                // Mettre à jour le statut de la notification
                $record->update([
                    'status' => 'sent',
                    'sent_at' => now(),
                    'onesignal_id' => $result['onesignal_id'] ?? null,
                    'recipients_count' => $result['recipients'] ?? 0,
                ]);
                
                Notification::make()
                    ->title('🚀 Notification créée et envoyée avec succès !')
                    ->body('OneSignal ID: ' . ($result['onesignal_id'] ?? 'N/A'))
                    ->success()
                    ->send();
            } else {
                // Mettre à jour le statut d'erreur
                $record->update([
                    'status' => 'failed',
                    'error_message' => $result['error'],
                ]);
                
                // Ensure error message is a string
                $errorMessage = $result['error'];
                if (is_array($errorMessage)) {
                    $errorMessage = implode('. ', $errorMessage);
                }
                
                Notification::make()
                    ->title('❌ Notification créée mais l\'envoi a échoué')
                    ->body($errorMessage)
                    ->danger()
                    ->send();
            }
        } catch (\Exception $e) {
            $record->update([
                'status' => 'failed',
                'error_message' => $e->getMessage(),
            ]);
            
            Notification::make()
                ->title('❌ Erreur lors de l\'envoi')
                ->body($e->getMessage())
                ->danger()
                ->send();
        }
    }
}
