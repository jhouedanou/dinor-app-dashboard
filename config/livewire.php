<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Temporary File Upload Configuration
    |--------------------------------------------------------------------------
    |
    | Sécurise l'endpoint /livewire/upload-file pour que seuls les admins
    | authentifiés puissent uploader des fichiers temporaires.
    |
    */

    'temporary_file_upload' => [
        'disk' => null,
        'rules' => ['required', 'file', 'max:10240', new \App\Rules\SafeFile()], // 10MB max + validation sécurité
        'directory' => null,
        'middleware' => ['auth:admin'],
        'preview_mimes' => [
            'png', 'gif', 'bmp', 'wav', 'mp4',
            'mov', 'avi', 'wmv', 'mp3', 'm4a',
            'jpg', 'jpeg', 'mpga', 'webp', 'wma',
        ],
        'max_upload_time' => 5,
        'cleanup' => true,
    ],

];
