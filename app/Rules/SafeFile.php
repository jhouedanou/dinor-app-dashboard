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
        'js', 'html', 'htm', 'shtml', 'xhtml',
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

    /**
     * Magic bytes (signatures) pour les formats image autorisés.
     */
    private const IMAGE_MAGIC_BYTES = [
        'image/jpeg' => ["\xFF\xD8\xFF"],
        'image/png'  => ["\x89\x50\x4E\x47\x0D\x0A\x1A\x0A"],
        'image/gif'  => ["GIF87a", "GIF89a"],
        'image/webp' => ["RIFF"],
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

        // Bloquer les noms de fichiers avec des caractères de traversée de chemin
        if (preg_match('/[\/\\\\]|\.\./', $originalName)) {
            $fail("Le nom du fichier contient des caractères non autorisés.");
            return;
        }

        // Vérifier le MIME type réel du fichier (pas celui déclaré par le client)
        $realMimeType = $value->getMimeType();

        if (!in_array($realMimeType, self::ALLOWED_IMAGE_MIMES)) {
            $fail("Le type de fichier ({$realMimeType}) n'est pas autorisé. Types acceptés : JPEG, PNG, GIF, WebP.");
            return;
        }

        // Vérifier les magic bytes (signature binaire) du fichier
        $content = file_get_contents($value->getRealPath(), false, null, 0, 100);
        if ($content === false || strlen($content) < 4) {
            $fail("Le fichier est vide ou illisible.");
            return;
        }

        $validMagicBytes = false;
        if (isset(self::IMAGE_MAGIC_BYTES[$realMimeType])) {
            foreach (self::IMAGE_MAGIC_BYTES[$realMimeType] as $signature) {
                if (str_starts_with($content, $signature)) {
                    $validMagicBytes = true;
                    break;
                }
            }
        }

        if (!$validMagicBytes) {
            $fail("Le fichier ne correspond pas à un format image valide (signature invalide).");
            return;
        }

        // Vérifier que le contenu ne contient pas de code exécutable injecté
        $contentLower = strtolower($content);
        $dangerousPatterns = [
            '<?php', '<?=', '<script', '#!/',
            '<% ', '<%=',  // ASP
        ];

        foreach ($dangerousPatterns as $pattern) {
            if (str_contains($contentLower, $pattern)) {
                $fail("Le fichier contient du code exécutable et a été rejeté.");
                return;
            }
        }

        // Vérification supplémentaire : scanner plus profondément pour les fichiers > 1KB
        if ($value->getSize() > 1024) {
            $deepContent = file_get_contents($value->getRealPath(), false, null, 0, 8192);
            if ($deepContent !== false) {
                $deepContentLower = strtolower($deepContent);
                foreach ($dangerousPatterns as $pattern) {
                    if (str_contains($deepContentLower, $pattern)) {
                        $fail("Le fichier contient du code exécutable injecté et a été rejeté.");
                        return;
                    }
                }
            }
        }
    }
}
