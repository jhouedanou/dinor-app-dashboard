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

        $csv = array_map('str_getcsv', file($filePath));
        
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
        $data = $headers ? array_combine($headers, $row) : [
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

        $categoryId = null;
        if (!empty($data['category'])) {
            $category = EventCategory::firstOrCreate(
                ['name' => $data['category']],
                ['description' => 'Catégorie créée automatiquement']
            );
            $categoryId = $category->id;
        }

        Event::create([
            'title' => $data['title'],
            'description' => $data['description'],
            'content' => $data['content'],
            'start_datetime' => $data['start_datetime'],
            'end_datetime' => $data['end_datetime'],
            'location' => $data['location'],
            'event_category_id' => $categoryId,
            'is_published' => filter_var($data['is_published'], FILTER_VALIDATE_BOOLEAN),
            'is_featured' => filter_var($data['is_featured'], FILTER_VALIDATE_BOOLEAN),
            'status' => 'active',
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
            'password' => $row[2] ?? 'password',
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
}