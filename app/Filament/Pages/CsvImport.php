<?php

namespace App\Filament\Pages;

use Filament\Pages\Page;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Notifications\Notification;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use App\Models\Recipe;
use App\Models\Tip;
use App\Models\Event;
use App\Models\DinorTv;
use App\Models\Category;
use App\Models\EventCategory;
use App\Models\User;

class CsvImport extends Page
{
    protected static ?string $navigationIcon = 'heroicon-o-document-arrow-up';
    
    protected static string $view = 'filament.pages.csv-import';
    
    protected static ?string $title = 'Import CSV';
    
    protected static ?string $navigationLabel = 'Import CSV';
    
    protected static ?string $navigationGroup = 'Administration';
    
    protected static ?int $navigationSort = 10;

    public ?array $data = [];

    public function mount(): void
    {
        $this->form->fill();
    }

    public function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Import de données par CSV')
                    ->description('Importez en masse vos contenus à partir de fichiers CSV')
                    ->schema([
                        Forms\Components\Select::make('content_type')
                            ->label('Type de contenu')
                            ->options([
                                'recipes' => 'Recettes',
                                'tips' => 'Astuces',
                                'events' => 'Événements',
                                'dinor_tv' => 'Vidéos Dinor TV',
                                'categories' => 'Catégories',
                                'event_categories' => 'Catégories d\'événements',
                                'users' => 'Utilisateurs',
                            ])
                            ->required()
                            ->live()
                            ->afterStateUpdated(fn ($state, $set) => $set('csv_file', null)),

                        Forms\Components\FileUpload::make('csv_file')
                            ->label('Fichier CSV')
                            ->acceptedFileTypes(['text/csv', 'application/csv', 'text/plain'])
                            ->required()
                            ->maxSize(10240) // 10MB
                            ->disk('local')
                            ->directory('csv-imports')
                            ->visibility('private'),

                        Forms\Components\Checkbox::make('has_header')
                            ->label('Le fichier contient une ligne d\'en-tête')
                            ->default(true),

                        Forms\Components\TextInput::make('delimiter')
                            ->label('Délimiteur')
                            ->default(',')
                            ->maxLength(1),

                        Forms\Components\Textarea::make('notes')
                            ->label('Notes (optionnel)')
                            ->rows(3),
                    ]),

                Forms\Components\Section::make('Exemples de fichiers CSV')
                    ->description('Téléchargez les exemples pour voir le format attendu')
                    ->schema([
                        Forms\Components\Placeholder::make('download_examples')
                            ->label('')
                            ->content(view('filament.csv-examples')),
                    ])
                    ->collapsible()
                    ->collapsed(),
            ])
            ->statePath('data');
    }

    public function submit(): void
    {
        $data = $this->form->getState();

        try {
            $this->processImport($data);
            
            Notification::make()
                ->title('Import réussi')
                ->success()
                ->send();

            $this->form->fill();
        } catch (\Exception $e) {
            Notification::make()
                ->title('Erreur lors de l\'import')
                ->body($e->getMessage())
                ->danger()
                ->send();
        }
    }

    protected function processImport(array $data): void
    {
        $filePath = storage_path('app/' . $data['csv_file']);
        
        if (!file_exists($filePath)) {
            throw new \Exception('Fichier CSV non trouvé');
        }

        // Lecture du fichier avec encodage UTF-8 forcé
        $csvContent = file_get_contents($filePath);
        if ($csvContent === false) {
            throw new \Exception('Impossible de lire le fichier CSV');
        }
        
        // Forcer l'encodage UTF-8
        $csvContent = mb_convert_encoding($csvContent, 'UTF-8', 'auto');
        
        // Convertir en tableau
        $lines = explode("\n", $csvContent);
        $csv = array_map(function($line) use ($data) {
            return str_getcsv(trim($line), $data['delimiter'] ?? ',');
        }, array_filter($lines, function($line) {
            return !empty(trim($line));
        }));
        
        if ($data['has_header']) {
            $headers = array_shift($csv);
        }

        $imported = 0;
        $errors = [];

        foreach ($csv as $index => $row) {
            try {
                // Ignorer les lignes vides
                if (empty(array_filter($row))) {
                    continue;
                }
                
                switch ($data['content_type']) {
                    case 'recipes':
                        $this->importRecipe($row, $headers ?? null);
                        break;
                    case 'tips':
                        $this->importTip($row, $headers ?? null);
                        break;
                    case 'events':
                        $this->importEvent($row, $headers ?? null);
                        break;
                    case 'dinor_tv':
                        $this->importDinorTv($row, $headers ?? null);
                        break;
                    case 'categories':
                        $this->importCategory($row, $headers ?? null);
                        break;
                    case 'event_categories':
                        $this->importEventCategory($row, $headers ?? null);
                        break;
                    case 'users':
                        $this->importUser($row, $headers ?? null);
                        break;
                }
                $imported++;
            } catch (\Exception $e) {
                $errors[] = "Ligne " . ($index + 1) . ": " . $e->getMessage();
            }
        }

        if (!empty($errors)) {
            throw new \Exception("Import partiel: $imported éléments importés. Erreurs: " . implode(', ', array_slice($errors, 0, 3)));
        }
    }

    protected function importRecipe(array $row, ?array $headers): void
    {
        if ($headers) {
            $data = array_combine($headers, $row);
            
            // Détecter automatiquement le format basé sur les colonnes disponibles
            if (isset($data['Recipe Name']) && !empty($data['Recipe Name'])) {
                // Format nouveau avec "Recipe Name", "Ingredients", etc.
                $data = [
                    'title' => $data['Recipe Name'] ?? '',
                    'description' => ($data['Cuisine'] ?? '') . ' - ' . (substr($data['Instructions'] ?? '', 0, 100)),
                    'ingredients' => $data['Ingredients'] ?? '',
                    'instructions' => $data['Instructions'] ?? '',
                    'difficulty' => 'medium', // Par défaut
                    'preparation_time' => $this->parseTime($data['Prep Time'] ?? null),
                    'cooking_time' => $this->parseTime($data['Cook Time'] ?? null),
                    'servings' => (int)($data['Servings'] ?? 4),
                    'category' => $data['Cuisine'] ?? 'Plats Traditionnels',
                    'is_published' => true,
                    'is_featured' => false,
                ];
            } elseif (!empty($data['title'])) {
                // Format classique avec "title", "description", etc.
                // Data est déjà correct, on ne change rien
            } else {
                // Ligne sans titre valide, ignorer silencieusement
                return;
            }
        } else {
            $data = [
                'title' => $row[0] ?? '',
                'description' => $row[1] ?? '',
                'content' => $row[2] ?? '',
                'ingredients' => $row[3] ?? '',
                'instructions' => $row[4] ?? '',
                'difficulty' => $row[5] ?? 'easy',
                'preparation_time' => $row[6] ?? null,
                'cooking_time' => $row[7] ?? null,
                'servings' => $row[8] ?? null,
                'category' => $row[9] ?? null,
                'is_published' => $row[10] ?? true,
                'is_featured' => $row[11] ?? false,
            ];
        }

        // Traiter la catégorie
        $categoryId = null;
        if (!empty($data['category'])) {
            $category = Category::firstOrCreate(
                ['name' => $data['category'], 'type' => 'recipe'],
                ['description' => 'Catégorie créée automatiquement']
            );
            $categoryId = $category->id;
        }

        // Validation des données
        if (empty($data['title'])) {
            throw new \Exception('Le titre de la recette est requis');
        }

        // Traitement des ingredients et instructions (conversion en tableau si nécessaire)
        $ingredients = [];
        if (!empty($data['ingredients'])) {
            if (is_string($data['ingredients'])) {
                // Si c'est une chaîne, diviser par des virgules ou des retours à la ligne
                $ingredients = array_filter(array_map('trim', 
                    preg_split('/[,\n\r]+/', $data['ingredients'])
                ));
            } else {
                $ingredients = is_array($data['ingredients']) ? $data['ingredients'] : [];
            }
        }

        $instructions = [];
        if (!empty($data['instructions'])) {
            if (is_string($data['instructions'])) {
                // Si c'est une chaîne, diviser par des points ou des retours à la ligne
                $instructions = array_filter(array_map('trim', 
                    preg_split('/[.\n\r]+/', $data['instructions'])
                ));
            } else {
                $instructions = is_array($data['instructions']) ? $data['instructions'] : [];
            }
        }

        Recipe::create([
            'title' => $data['title'],
            'description' => $data['description'] ?: '',
            'ingredients' => $ingredients, // Tableau d'ingrédients
            'instructions' => $instructions, // Tableau d'instructions
            'difficulty' => $data['difficulty'],
            'preparation_time' => $data['preparation_time'] ? (int)$data['preparation_time'] : null,
            'cooking_time' => $data['cooking_time'] ? (int)$data['cooking_time'] : null,
            'servings' => $data['servings'] ? (int)$data['servings'] : null,
            'category_id' => $categoryId,
            'is_published' => filter_var($data['is_published'], FILTER_VALIDATE_BOOLEAN),
            'is_featured' => filter_var($data['is_featured'], FILTER_VALIDATE_BOOLEAN),
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    protected function importTip(array $row, ?array $headers): void
    {
        $data = $headers ? array_combine($headers, $row) : [
            'title' => $row[0] ?? '',
            'description' => $row[1] ?? '',
            'content' => $row[2] ?? '',
            'category' => $row[3] ?? null,
            'is_published' => $row[4] ?? true,
            'is_featured' => $row[5] ?? false,
        ];

        $categoryId = null;
        if (!empty($data['category'])) {
            $category = Category::firstOrCreate(
                ['name' => $data['category'], 'type' => 'tip'],
                ['description' => 'Catégorie créée automatiquement']
            );
            $categoryId = $category->id;
        }

        // Validation des données
        if (empty($data['title'])) {
            throw new \Exception('Le titre du conseil est requis');
        }

        Tip::create([
            'title' => $data['title'],
            'description' => $data['description'] ?: '',
            'content' => $data['content'] ?? '',
            'category_id' => $categoryId,
            'is_published' => filter_var($data['is_published'], FILTER_VALIDATE_BOOLEAN),
            'is_featured' => filter_var($data['is_featured'], FILTER_VALIDATE_BOOLEAN),
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    protected function importEvent(array $row, ?array $headers): void
    {
        if ($headers) {
            $data = array_combine($headers, $row);
            
            // Ignorer les lignes sans titre valide
            if (empty($data['title']) && empty($data['name'])) {
                return;
            }
        } else {
            $data = [
                'title' => $row[0] ?? '',
                'description' => $row[1] ?? '',
                'content' => $row[2] ?? '',
                'start_datetime' => $row[3] ?? now(),
                'end_datetime' => $row[4] ?? now()->addHours(2),
                'location' => $row[5] ?? '',
                'category' => $row[6] ?? null,
                'is_published' => $row[7] ?? true,
                'is_featured' => $row[8] ?? false,
            ];
        }

        // Validation des données essentielles
        $title = $data['title'] ?? $data['name'] ?? '';
        if (empty($title)) {
            throw new \Exception('Le titre de l\'événement est requis');
        }

        // Traitement de la catégorie
        $categoryId = null;
        $categoryField = $data['category'] ?? $data['event_category'] ?? null;
        if (!empty($categoryField)) {
            // Mapping des catégories courantes
            $categoryMappings = [
                'Gastronomie' => 'Festivals culinaires',
                'Éducation' => 'Formations professionnelles',
                'Commerce' => 'Marchés et foires',
            ];
            
            $categoryName = $categoryMappings[$categoryField] ?? $categoryField;
            
            $category = Category::firstOrCreate(
                ['name' => $categoryName, 'type' => 'event'],
                ['description' => 'Catégorie créée automatiquement']
            );
            $categoryId = $category->id;
        }

        // Traitement des dates
        $startDate = $this->parseDate($data['start_date'] ?? $data['date'] ?? null);
        $endDate = $this->parseDate($data['end_date'] ?? null);
        $startTime = $this->parseTimeFormat($data['start_time'] ?? null);
        $endTime = $this->parseTimeFormat($data['end_time'] ?? null);
        
        // Si pas de date de fin, utiliser la date de début
        if ($endDate === null && $startDate !== null) {
            $endDate = $startDate;
        }

        Event::create([
            'title' => $title,
            'description' => $data['description'] ?? $data['summary'] ?? '',
            'content' => $data['content'] ?? $data['details'] ?? '',
            'start_date' => $startDate ?? now()->toDateString(),
            'end_date' => $endDate ?? now()->toDateString(),
            'start_time' => $startTime,
            'end_time' => $endTime,
            'timezone' => $data['timezone'] ?? 'Europe/Paris',
            'is_all_day' => filter_var($data['is_all_day'] ?? false, FILTER_VALIDATE_BOOLEAN),
            'location' => $data['location'] ?? $data['venue'] ?? '',
            'category_id' => $categoryId,
            'is_published' => filter_var($data['is_published'] ?? true, FILTER_VALIDATE_BOOLEAN),
            'is_featured' => filter_var($data['is_featured'] ?? false, FILTER_VALIDATE_BOOLEAN),
            'status' => $data['status'] ?? 'active',
            'event_type' => $data['event_type'] ?? 'other',
            'event_format' => $data['event_format'] ?? 'in_person',
            'age_restriction' => $data['age_restriction'] ?? 'all_ages',
            'is_online' => filter_var($data['is_online'] ?? false, FILTER_VALIDATE_BOOLEAN),
            'requires_registration' => filter_var($data['requires_registration'] ?? false, FILTER_VALIDATE_BOOLEAN),
            'requires_approval' => filter_var($data['requires_approval'] ?? false, FILTER_VALIDATE_BOOLEAN),
            'is_free' => filter_var($data['is_free'] ?? true, FILTER_VALIDATE_BOOLEAN),
            'price' => floatval($data['price'] ?? 0),
            'currency' => $data['currency'] ?? 'EUR',
            'wheelchair_accessible' => filter_var($data['wheelchair_accessible'] ?? false, FILTER_VALIDATE_BOOLEAN),
            'weather_dependent' => filter_var($data['weather_dependent'] ?? false, FILTER_VALIDATE_BOOLEAN),
            'allow_reviews' => filter_var($data['allow_reviews'] ?? true, FILTER_VALIDATE_BOOLEAN),
            'current_participants' => intval($data['current_participants'] ?? 0),
            'waiting_list_count' => intval($data['waiting_list_count'] ?? 0),
            'views_count' => 0,
            'likes_count' => 0,
            'shares_count' => 0,
            'favorites_count' => 0,
            'rating_average' => 0,
            'rating_count' => 0,
            'comments_count' => 0,
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    protected function importDinorTv(array $row, ?array $headers): void
    {
        $data = $headers ? array_combine($headers, $row) : [
            'title' => $row[0] ?? '',
            'description' => $row[1] ?? '',
            'content' => $row[2] ?? '',
            'video_url' => $row[3] ?? '',
            'duration' => $row[4] ?? null,
            'is_published' => $row[5] ?? true,
            'is_featured' => $row[6] ?? false,
        ];

        DinorTv::create([
            'title' => $data['title'],
            'description' => $data['description'],
            'content' => $data['content'],
            'video_url' => $data['video_url'],
            'duration' => $data['duration'] ? (int)$data['duration'] : null,
            'is_published' => filter_var($data['is_published'], FILTER_VALIDATE_BOOLEAN),
            'is_featured' => filter_var($data['is_featured'], FILTER_VALIDATE_BOOLEAN),
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    protected function importCategory(array $row, ?array $headers): void
    {
        $data = $headers ? array_combine($headers, $row) : [
            'name' => $row[0] ?? '',
            'description' => $row[1] ?? '',
            'type' => $row[2] ?? 'recipe',
        ];

        // Validation des données
        if (empty($data['name'])) {
            throw new \Exception('Le nom de la catégorie est requis');
        }

        Category::create([
            'name' => $data['name'],
            'description' => $data['description'] ?: 'Catégorie créée automatiquement',
            'type' => $data['type'],
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    protected function importEventCategory(array $row, ?array $headers): void
    {
        $data = $headers ? array_combine($headers, $row) : [
            'name' => $row[0] ?? '',
            'description' => $row[1] ?? '',
        ];

        EventCategory::create([
            'name' => $data['name'],
            'description' => $data['description'],
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    protected function importUser(array $row, ?array $headers): void
    {
        $data = $headers ? array_combine($headers, $row) : [
            'name' => $row[0] ?? '',
            'email' => $row[1] ?? '',
            'password' => $row[2] ?? \Illuminate\Support\Str::random(24),
            'role' => $row[3] ?? 'user',
            'is_active' => $row[4] ?? true,
        ];

        User::create([
            'name' => $data['name'],
            'email' => $data['email'],
            'password' => bcrypt($data['password']),
            'role' => $data['role'],
            'is_active' => filter_var($data['is_active'], FILTER_VALIDATE_BOOLEAN),
            'email_verified_at' => now(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    /**
     * Parser les temps comme "40 min", "1h", "1h40" en minutes
     */
    protected function parseTime($timeString): ?int
    {
        if (empty($timeString)) {
            return null;
        }

        $timeString = strtolower(trim($timeString));
        
        // Patterns pour différents formats
        if (preg_match('/(\d+)\s*h\s*(\d+)/', $timeString, $matches)) {
            // Format "1h40"
            return (int)$matches[1] * 60 + (int)$matches[2];
        }
        
        if (preg_match('/(\d+)\s*h/', $timeString, $matches)) {
            // Format "1h"
            return (int)$matches[1] * 60;
        }
        
        if (preg_match('/(\d+)\s*min/', $timeString, $matches)) {
            // Format "40 min"
            return (int)$matches[1];
        }
        
        // Si c'est juste un nombre, considérer comme des minutes
        if (is_numeric($timeString)) {
            return (int)$timeString;
        }
        
        return null;
    }

    /**
     * Parser les dates en différents formats
     */
    protected function parseDateTime($dateString): ?\DateTime
    {
        if (empty($dateString)) {
            return null;
        }

        try {
            // Essayer différents formats de date
            $formats = [
                'Y-m-d H:i:s',      // 2023-12-25 14:30:00
                'Y-m-d H:i',        // 2023-12-25 14:30
                'Y-m-d',            // 2023-12-25
                'd/m/Y H:i:s',      // 25/12/2023 14:30:00
                'd/m/Y H:i',        // 25/12/2023 14:30
                'd/m/Y',            // 25/12/2023
                'm/d/Y H:i:s',      // 12/25/2023 14:30:00
                'm/d/Y H:i',        // 12/25/2023 14:30
                'm/d/Y',            // 12/25/2023
            ];

            foreach ($formats as $format) {
                $date = \DateTime::createFromFormat($format, trim($dateString));
                if ($date !== false) {
                    return $date;
                }
            }

            // Essayer avec strtotime comme dernier recours
            $timestamp = strtotime($dateString);
            if ($timestamp !== false) {
                return new \DateTime('@' . $timestamp);
            }

        } catch (\Exception $e) {
            // Ignorer les erreurs de parsing
        }

        return null;
    }

    /**
     * Parser les dates (sans heure)
     */
    protected function parseDate($dateString): ?string
    {
        if (empty($dateString)) {
            return null;
        }

        try {
            $formats = [
                'Y-m-d',            // 2023-12-25
                'd/m/Y',            // 25/12/2023
                'm/d/Y',            // 12/25/2023
                'd-m-Y',            // 25-12-2023
                'Y/m/d',            // 2023/12/25
            ];

            foreach ($formats as $format) {
                $date = \DateTime::createFromFormat($format, trim($dateString));
                if ($date !== false) {
                    return $date->format('Y-m-d');
                }
            }

            // Essayer avec strtotime
            $timestamp = strtotime($dateString);
            if ($timestamp !== false) {
                return date('Y-m-d', $timestamp);
            }

        } catch (\Exception $e) {
            // Ignorer les erreurs
        }

        return null;
    }

    /**
     * Parser les heures (format time)
     */
    protected function parseTimeFormat($timeString): ?string
    {
        if (empty($timeString)) {
            return null;
        }

        try {
            $formats = [
                'H:i:s',    // 14:30:00
                'H:i',      // 14:30
                'G:i',      // 8:30
                'g:i A',    // 2:30 PM
                'g:i a',    // 2:30 pm
            ];

            foreach ($formats as $format) {
                $time = \DateTime::createFromFormat($format, trim($timeString));
                if ($time !== false) {
                    return $time->format('H:i:s');
                }
            }

        } catch (\Exception $e) {
            // Ignorer les erreurs
        }

        return null;
    }
}