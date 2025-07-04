<?php

namespace App\Filament\Pages;

use Filament\Pages\Page;
use Filament\Forms\Concerns\InteractsWithForms;
use Filament\Forms\Contracts\HasForms;
use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Section;
use Filament\Forms\Components\Actions\Action;
use Filament\Forms\Form;
use Filament\Notifications\Notification;
use App\Models\Recipe;
use App\Models\Event;
use App\Models\Tip;
use App\Models\DinorTv;
use App\Models\Category;
use Illuminate\Support\Facades\Storage;
use League\Csv\Reader;

class ImportCsv extends Page implements HasForms
{
    use InteractsWithForms;

    protected static ?string $navigationIcon = 'heroicon-o-arrow-up-tray';
    protected static string $view = 'filament.pages.import-csv';
    protected static ?string $navigationLabel = 'Import CSV';
    protected static ?string $title = 'Import de contenu via CSV';
    protected static ?string $navigationGroup = 'Gestion';

    public ?array $data = [];

    public function mount(): void
    {
        $this->form->fill();
    }

    public function form(Form $form): Form
    {
        return $form
            ->schema([
                Section::make('Import de contenu')
                    ->description('Importez du contenu en masse via des fichiers CSV')
                    ->schema([
                        Select::make('content_type')
                            ->label('Type de contenu')
                            ->options([
                                'recipes' => 'Recettes',
                                'events' => 'Événements',
                                'tips' => 'Astuces',
                                'dinor_tv' => 'Vidéos (Dinor TV)',
                                'categories' => 'Catégories',
                            ])
                            ->required()
                            ->reactive()
                            ->afterStateUpdated(fn (callable $set) => $set('csv_file', null)),

                        FileUpload::make('csv_file')
                            ->label('Fichier CSV')
                            ->acceptedFileTypes(['text/csv', 'application/csv', '.csv'])
                            ->required()
                            ->disk('local')
                            ->directory('imports')
                            ->helperText(function (callable $get) {
                                $type = $get('content_type');
                                if ($type) {
                                    return "Téléchargez l'exemple CSV pour {$this->getContentTypeName($type)} pour voir le format attendu.";
                                }
                                return 'Sélectionnez d\'abord un type de contenu.';
                            }),
                    ])
                    ->columns(2),

                Section::make('Actions')
                    ->schema([
                        \Filament\Forms\Components\Actions::make([
                            Action::make('download_example')
                                ->label('Télécharger l\'exemple CSV')
                                ->icon('heroicon-o-arrow-down-tray')
                                ->color('secondary')
                                ->action(function (callable $get) {
                                    $type = $get('content_type');
                                    if ($type) {
                                        return $this->downloadExample($type);
                                    }
                                    Notification::make()
                                        ->title('Erreur')
                                        ->body('Veuillez sélectionner un type de contenu.')
                                        ->danger()
                                        ->send();
                                })
                                ->visible(fn (callable $get) => $get('content_type')),

                            Action::make('import')
                                ->label('Importer le fichier')
                                ->icon('heroicon-o-arrow-up-tray')
                                ->color('primary')
                                ->action('import')
                                ->visible(fn (callable $get) => $get('content_type') && $get('csv_file')),
                        ])
                    ])
            ])
            ->statePath('data');
    }

    public function import()
    {
        $data = $this->form->getState();
        
        try {
            $filePath = Storage::disk('local')->path($data['csv_file']);
            $csv = Reader::createFromPath($filePath, 'r');
            $csv->setHeaderOffset(0);
            
            $records = $csv->getRecords();
            $imported = 0;
            $errors = [];

            foreach ($records as $offset => $record) {
                try {
                    $this->importRecord($data['content_type'], $record);
                    $imported++;
                } catch (\Exception $e) {
                    $errors[] = "Ligne " . ($offset + 2) . ": " . $e->getMessage();
                }
            }

            // Clean up uploaded file
            Storage::disk('local')->delete($data['csv_file']);

            if ($imported > 0) {
                Notification::make()
                    ->title('Import réussi')
                    ->body("{$imported} éléments importés avec succès.")
                    ->success()
                    ->send();
            }

            if (!empty($errors)) {
                Notification::make()
                    ->title('Erreurs d\'import')
                    ->body(implode("\n", array_slice($errors, 0, 5)))
                    ->warning()
                    ->send();
            }

            $this->form->fill();

        } catch (\Exception $e) {
            Notification::make()
                ->title('Erreur d\'import')
                ->body($e->getMessage())
                ->danger()
                ->send();
        }
    }

    private function importRecord(string $type, array $record): void
    {
        switch ($type) {
            case 'recipes':
                $this->importRecipe($record);
                break;
            case 'events':
                $this->importEvent($record);
                break;
            case 'tips':
                $this->importTip($record);
                break;
            case 'dinor_tv':
                $this->importDinorTv($record);
                break;
            case 'categories':
                $this->importCategory($record);
                break;
        }
    }

    private function importRecipe(array $record): void
    {
        $recipe = Recipe::create([
            'title' => $record['title'],
            'description' => $record['description'],
            'short_description' => $record['short_description'] ?? '',
            'ingredients' => json_decode($record['ingredients'] ?? '[]', true),
            'instructions' => json_decode($record['instructions'] ?? '[]', true),
            'preparation_time' => (int)($record['preparation_time'] ?? 0),
            'cooking_time' => (int)($record['cooking_time'] ?? 0),
            'servings' => (int)($record['servings'] ?? 1),
            'difficulty' => $record['difficulty'] ?? 'medium',
            'meal_type' => $record['meal_type'] ?? 'lunch',
            'diet_type' => $record['diet_type'] ?? 'none',
            'category_id' => $this->findOrCreateCategory($record['category'] ?? 'Général'),
            'tags' => json_decode($record['tags'] ?? '[]', true),
            'is_featured' => (bool)($record['is_featured'] ?? false),
            'is_published' => (bool)($record['is_published'] ?? true),
            'slug' => \Str::slug($record['title']),
        ]);
    }

    private function importEvent(array $record): void
    {
        Event::create([
            'title' => $record['title'],
            'description' => $record['description'],
            'content' => $record['content'] ?? '',
            'short_description' => $record['short_description'] ?? '',
            'start_date' => $record['start_date'],
            'end_date' => $record['end_date'] ?? null,
            'location' => $record['location'] ?? '',
            'address' => $record['address'] ?? '',
            'city' => $record['city'] ?? '',
            'country' => $record['country'] ?? 'Côte d\'Ivoire',
            'category_id' => $this->findOrCreateCategory($record['category'] ?? 'Général'),
            'price' => $record['price'] ?? '0.00',
            'currency' => $record['currency'] ?? 'XOF',
            'is_free' => (bool)($record['is_free'] ?? true),
            'max_participants' => (int)($record['max_participants'] ?? 100),
            'tags' => json_decode($record['tags'] ?? '[]', true),
            'is_featured' => (bool)($record['is_featured'] ?? false),
            'is_published' => (bool)($record['is_published'] ?? true),
            'status' => $record['status'] ?? 'active',
            'slug' => \Str::slug($record['title']),
        ]);
    }

    private function importTip(array $record): void
    {
        Tip::create([
            'title' => $record['title'],
            'content' => $record['content'],
            'category_id' => $this->findOrCreateCategory($record['category'] ?? 'Général'),
            'tags' => json_decode($record['tags'] ?? '[]', true),
            'is_featured' => (bool)($record['is_featured'] ?? false),
            'is_published' => (bool)($record['is_published'] ?? true),
            'difficulty_level' => $record['difficulty_level'] ?? 'beginner',
            'estimated_time' => (int)($record['estimated_time'] ?? 5),
            'slug' => \Str::slug($record['title']),
        ]);
    }

    private function importDinorTv(array $record): void
    {
        DinorTv::create([
            'title' => $record['title'],
            'description' => $record['description'],
            'video_url' => $record['video_url'],
            'is_featured' => (bool)($record['is_featured'] ?? false),
            'is_published' => (bool)($record['is_published'] ?? true),
        ]);
    }

    private function importCategory(array $record): void
    {
        Category::create([
            'name' => $record['name'],
            'slug' => \Str::slug($record['name']),
            'description' => $record['description'] ?? '',
            'color' => $record['color'] ?? '#FF6B6B',
            'icon' => $record['icon'] ?? 'heroicon-o-tag',
            'is_active' => (bool)($record['is_active'] ?? true),
            'type' => $record['type'] ?? 'general',
        ]);
    }

    private function findOrCreateCategory(string $categoryName): int
    {
        $category = Category::where('name', $categoryName)->first();
        
        if (!$category) {
            $category = Category::create([
                'name' => $categoryName,
                'slug' => \Str::slug($categoryName),
                'description' => "Catégorie créée automatiquement lors de l'import",
                'color' => '#FF6B6B',
                'icon' => 'heroicon-o-tag',
                'is_active' => true,
                'type' => 'general',
            ]);
        }

        return $category->id;
    }

    private function getContentTypeName(string $type): string
    {
        return match($type) {
            'recipes' => 'recettes',
            'events' => 'événements',
            'tips' => 'astuces',
            'dinor_tv' => 'vidéos',
            'categories' => 'catégories',
            default => $type,
        };
    }

    public function downloadExample(string $type)
    {
        $examples = [
            'recipes' => [
                ['title', 'description', 'short_description', 'ingredients', 'instructions', 'preparation_time', 'cooking_time', 'servings', 'difficulty', 'meal_type', 'diet_type', 'category', 'tags', 'is_featured', 'is_published'],
                ['Riz au Gras', 'Délicieux riz au gras traditionnel', 'Riz préparé avec de la sauce tomate', '[{"quantity":"2","unit":"tasses","ingredient_id":null}]', '[{"step":"Faire revenir les oignons"}]', '30', '60', '4', 'medium', 'lunch', 'none', 'Plats principaux', '["riz","traditionnel"]', 'true', 'true']
            ],
            'events' => [
                ['title', 'description', 'content', 'short_description', 'start_date', 'end_date', 'location', 'address', 'city', 'country', 'category', 'price', 'currency', 'is_free', 'max_participants', 'tags', 'is_featured', 'is_published', 'status'],
                ['Atelier Cuisine', 'Atelier de cuisine ivoirienne', '<p>Apprenez à cuisiner</p>', 'Cours de cuisine', '2025-08-01 14:00:00', '2025-08-01 17:00:00', 'Centre culturel', 'Rue de la Culture', 'Abidjan', 'Côte d\'Ivoire', 'Ateliers', '15000', 'XOF', 'false', '20', '["atelier","cuisine"]', 'true', 'true', 'active']
            ],
            'tips' => [
                ['title', 'content', 'category', 'tags', 'is_featured', 'is_published', 'difficulty_level', 'estimated_time'],
                ['Bien choisir ses épices', 'Pour bien choisir vos épices...', 'Conseils', '["épices","conseils"]', 'true', 'true', 'beginner', '5']
            ],
            'dinor_tv' => [
                ['title', 'description', 'video_url', 'is_featured', 'is_published'],
                ['Préparation du Bangui', 'Apprenez à préparer le bangui', 'https://youtube.com/watch?v=example', 'true', 'true']
            ],
            'categories' => [
                ['name', 'description', 'color', 'icon', 'is_active', 'type'],
                ['Plats principaux', 'Catégorie pour les plats principaux', '#FF6B6B', 'heroicon-o-squares-plus', 'true', 'general']
            ]
        ];

        $csvContent = '';
        foreach ($examples[$type] as $row) {
            $csvContent .= '"' . implode('","', $row) . '"' . "\n";
        }

        return response($csvContent)
            ->header('Content-Type', 'text/csv')
            ->header('Content-Disposition', 'attachment; filename="exemple_' . $type . '.csv"');
    }
}