<?php

namespace App\Filament\Resources\PushNotificationResource\Pages;

use App\Filament\Resources\PushNotificationResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditPushNotification extends EditRecord
{
    protected static string $resource = PushNotificationResource::class;

    protected function mutateFormDataBeforeSave(array $data): array
    {
        // Empêcher la sauvegarde de send_now, le convertir en draft
        if ($data['status'] === 'send_now') {
            $data['status'] = 'draft';
        }
        
        return $data;
    }
}
