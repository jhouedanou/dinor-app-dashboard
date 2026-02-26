<?php

namespace App\Rules;

use Closure;
use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Http\UploadedFile;

class SafeCsv implements ValidationRule
{
    /**
     * Extensions dangereuses qui ne doivent jamais être uploadées.
     */
    private const DANGEROUS_EXTENSIONS = [
        'php', 'php3', 'php4', 'php5', 'php7', 'php8', 'phtml', 'phar',
        'sh', 'bash', 'cgi', 'pl', 'py', 'rb', 'jsp', 'asp', 'aspx',
        'exe', 'bat', 'cmd', 'com', 'msi', 'dll', 'scr',
        'htaccess', 'htpasswd', 'ini', 'env',
        'svg', 'js', 'html', 'htm', 'shtml',
    ];

    /**
     * MIME types autorisés pour les fichiers CSV.
     */
    private const ALLOWED_CSV_MIMES = [
        'text/csv',
        'text/plain',
        'application/csv',
        'application/vnd.ms-excel',
        'text/comma-separated-values',
    ];

    public function validate(string $attribute, mixed $value, Closure $fail): void
    {
        if (!$value instanceof UploadedFile) {
            return;
        }

        $originalName = $value->getClientOriginalName();
        $extension = strtolower(pathinfo($originalName, PATHINFO_EXTENSION));

        // Vérifier que l'extension est bien .csv ou .txt
        if (!in_array($extension, ['csv', 'txt'])) {
            $fail("Seuls les fichiers .csv et .txt sont autorisés (reçu : .{$extension}).");
            return;
        }

        // Bloquer les double extensions (ex: data.php.csv)
        $allExtensions = explode('.', strtolower($originalName));
        array_shift($allExtensions); // Retirer le nom du fichier
        foreach ($allExtensions as $ext) {
            if (in_array($ext, self::DANGEROUS_EXTENSIONS)) {
                $fail("Le fichier contient une extension dangereuse (.{$ext}).");
                return;
            }
        }

        // Vérifier le MIME type réel du fichier
        $realMimeType = $value->getMimeType();

        if (!in_array($realMimeType, self::ALLOWED_CSV_MIMES)) {
            $fail("Le type de fichier ({$realMimeType}) n'est pas autorisé pour un CSV.");
            return;
        }

        // Vérifier que le contenu ne contient pas de code exécutable
        $content = file_get_contents($value->getRealPath(), false, null, 0, 500);
        if ($content !== false) {
            $contentLower = strtolower($content);

            // Détecter les signatures de code dangereux
            $dangerousPatterns = [
                '<?php',
                '<?=',
                '<script',
                '#!/',
                '<% ',       // ASP
                '<%=',       // ASP
                'eval(',
                'exec(',
                'system(',
                'passthru(',
                'shell_exec(',
                'base64_decode(',
            ];

            foreach ($dangerousPatterns as $pattern) {
                if (str_contains($contentLower, $pattern)) {
                    $fail("Le fichier CSV contient du code exécutable suspect et a été rejeté.");
                    return;
                }
            }
        }

        // Vérifier que le fichier est bien du texte lisible (pas de bytes nuls)
        if ($content !== false && str_contains($content, "\0")) {
            $fail("Le fichier contient des données binaires et n'est pas un CSV valide.");
            return;
        }
    }
}
