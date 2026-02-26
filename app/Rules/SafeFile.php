<?php

namespace App\Rules;

use Closure;
use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Http\UploadedFile;

class SafeFile implements ValidationRule
{
    /**
     * Extensions dangereuses qui ne doivent jamais être uploadées.
     */
    private const DANGEROUS_EXTENSIONS = [
        'php', 'php3', 'php4', 'php5', 'php7', 'php8', 'phtml', 'phar',
        'sh', 'bash', 'cgi', 'pl', 'py', 'rb', 'jsp', 'asp', 'aspx',
        'exe', 'bat', 'cmd', 'com', 'msi', 'dll', 'scr',
        'htaccess', 'htpasswd', 'ini', 'env',
        'svg', // SVG peut contenir du JavaScript
    ];

    /**
     * MIME types autorisés pour les images.
     */
    private const ALLOWED_IMAGE_MIMES = [
        'image/jpeg',
        'image/png',
        'image/gif',
        'image/webp',
    ];

    public function validate(string $attribute, mixed $value, Closure $fail): void
    {
        if (!$value instanceof UploadedFile) {
            return;
        }

        $originalName = $value->getClientOriginalName();
        $extension = strtolower(pathinfo($originalName, PATHINFO_EXTENSION));

        // Bloquer les double extensions (ex: image.php.jpg)
        $allExtensions = explode('.', strtolower($originalName));
        array_shift($allExtensions); // Retirer le nom du fichier
        foreach ($allExtensions as $ext) {
            if (in_array($ext, self::DANGEROUS_EXTENSIONS)) {
                $fail("Le fichier contient une extension dangereuse (.{$ext}).");
                return;
            }
        }

        // Vérifier le MIME type réel du fichier (pas celui déclaré par le client)
        $realMimeType = $value->getMimeType();

        if (!in_array($realMimeType, self::ALLOWED_IMAGE_MIMES)) {
            $fail("Le type de fichier ({$realMimeType}) n'est pas autorisé. Types acceptés : JPEG, PNG, GIF, WebP.");
            return;
        }

        // Vérifier que le contenu ne commence pas par des signatures PHP
        $content = file_get_contents($value->getRealPath(), false, null, 0, 100);
        if ($content !== false) {
            $contentLower = strtolower($content);
            if (
                str_contains($contentLower, '<?php') ||
                str_contains($contentLower, '<?=') ||
                str_contains($contentLower, '<script') ||
                str_contains($content, '#!') // shebang
            ) {
                $fail("Le fichier contient du code exécutable et a été rejeté.");
                return;
            }
        }
    }
}
