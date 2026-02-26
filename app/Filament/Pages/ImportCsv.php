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
use App\Models\Banner;
use App\Models\Team;
use App\Models\FootballMatch;
use App\Models\Tournament;
use App\Models\Prediction;
use App\Models\PushNotification;
use App\Models\Ingredient;
use App\Models\EventCategory;
use App\Models\MediaFile;
use App\Models\Page as PageModel;
use App\Models\User;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Hash;
use League\Csv\Reader;
use Illuminate\Support\Str;

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
                                'banners' => 'Bannières',
                                'teams' => 'Équipes',
                                'football_matches' => 'Matchs de Football',
                                'tournaments' => 'Tournois',
                                'predictions' => 'Prédictions',
                                'push_notifications' => 'Notifications Push',
                                'ingredients' => 'Ingrédients',
                                'event_categories' => 'Catégories d\'Événements',
                                'media_files' => 'Fichiers Média',
                                'pages' => 'Pages',
                                'users' => 'Utilisateurs',
                            ])
                            ->required()
                            ->reactive()
                            ->afterStateUpdated(fn (callable $set) => $set('csv_file', null)),

                        FileUpload::make('csv_file')
                            ->label('Fichier CSV')
                            ->acceptedFileTypes(['text/csv', 'application/csv', 'text/plain'])
                            ->required()
                            ->maxSize(10240) // 10MB max
                            ->disk('local')
                            ->directory('imports')
                            ->visibility('private')
                            ->rules([new \App\Rules\SafeCsv()])
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
                                ->label('📥 Télécharger l\'exemple CSV')
                                ->icon('heroicon-o-arrow-down-tray')
                                ->color('info')
                                ->outlined()
                                ->size('lg')
                                ->action(function (callable $get) {
                                    $type = $get('content_type');
                                    if ($type) {
                                        $csvContent = $this->generateExampleCsv($type);
                                        $filename = 'exemple_' . $type . '.csv';
                                        
                                        return response()->streamDownload(function () use ($csvContent) {
                                            echo $csvContent;
                                        }, $filename, [
                                            'Content-Type' => 'text/csv; charset=UTF-8',
                                            'Content-Disposition' => 'attachment; filename="' . $filename . '"'
                                        ]);
                                    }
                                    
                                    Notification::make()
                                        ->title('⚠️ Erreur')
                                        ->body('Veuillez sélectionner un type de contenu.')
                                        ->warning()
                                        ->send();
                                })
                                ->visible(fn (callable $get) => $get('content_type')),

                            Action::make('import')
                                ->label('📤 Importer le fichier')
                                ->icon('heroicon-o-arrow-up-tray')
                                ->color('primary')
                                ->size('lg')
                                ->action('import')
                                ->visible(fn (callable $get) => $get('content_type') && $get('csv_file')),
                        ])
                        ->fullWidth()
                        ->alignment('center')
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
            case 'banners':
                $this->importBanner($record);
                break;
            case 'teams':
                $this->importTeam($record);
                break;
            case 'football_matches':
                $this->importFootballMatch($record);
                break;
            case 'tournaments':
                $this->importTournament($record);
                break;
            case 'predictions':
                $this->importPrediction($record);
                break;
            case 'push_notifications':
                $this->importPushNotification($record);
                break;
            case 'ingredients':
                $this->importIngredient($record);
                break;
            case 'event_categories':
                $this->importEventCategory($record);
                break;
            case 'media_files':
                $this->importMediaFile($record);
                break;
            case 'pages':
                $this->importPage($record);
                break;
            case 'users':
                $this->importUser($record);
                break;
        }
    }

    private function importRecipe(array $record): void
    {
        $ingredients = $this->parseIngredientsColumns($record);
        $instructions = $this->parseInstructionColumns($record);
        $tags = $this->parseTagsColumns($record);

        $recipe = Recipe::create([
            'title' => $record['title'],
            'description' => $record['description'],
            'short_description' => $record['short_description'] ?? '',
            'ingredients' => $ingredients,
            'instructions' => $instructions,
            'preparation_time' => (int)($record['preparation_time'] ?? 0),
            'cooking_time' => (int)($record['cooking_time'] ?? 0),
            'servings' => (int)($record['servings'] ?? 1),
            'difficulty' => $record['difficulty'] ?? 'medium',
            'meal_type' => $record['meal_type'] ?? 'lunch',
            'diet_type' => $record['diet_type'] ?? 'none',
            'category_id' => $this->findOrCreateCategory($record['category'] ?? 'Général', 'recipe'),
            'tags' => $tags,
            'is_featured' => (bool)($record['is_featured'] ?? false),
            'is_published' => (bool)($record['is_published'] ?? true),
            'slug' => \Str::slug($record['title']),
        ]);
    }

    private function importEvent(array $record): void
    {
        Event::create([
            'title' => $record['title'],
            'description' => $record['description'] ?? '',
            'content' => $record['content'] ?? '',
            'short_description' => $record['short_description'] ?? '',
            'start_date' => $record['start_date'],
            'end_date' => $record['end_date'] ?? null,
            'location' => $record['location'] ?? '',
            'address' => $record['address'] ?? '',
            'city' => $record['city'] ?? '',
            'country' => $record['country'] ?? 'Côte d\'Ivoire',
            'category_id' => $this->findOrCreateCategory($record['category'] ?? 'Général', 'event'),
            'price' => $record['price'] ?? '0.00',
            'currency' => $record['currency'] ?? 'XOF',
            'is_free' => (bool)($record['is_free'] ?? true),
            'max_participants' => (int)($record['max_participants'] ?? 100),
            'tags' => $this->parseTagsColumns($record),
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
            'content' => $record['content'] ?? '',
            'category_id' => $this->findOrCreateCategory($record['category'] ?? 'Général', 'tip'),
            'tags' => $this->parseTagsColumns($record),
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

    private function findOrCreateCategory(string $categoryName, string $type = 'general'): int
    {
        $slug = Str::slug($categoryName);
        if ($slug === '') {
            $slug = Str::random(8);
        }

        $category = Category::where('name', $categoryName)->first();

        if (!$category) {
            $category = new Category();
        }

        $category->name = $categoryName;
        $category->slug = $category->slug ?: $slug;
        if ($category->slug === '') {
            $category->slug = $slug;
        }
        $category->description = $category->description ?: "Catégorie créée automatiquement lors de l'import";
        $category->color = $category->color ?: '#FF6B6B';
        $category->icon = $category->icon ?: 'heroicon-o-tag';
        $category->is_active = $category->is_active ?? true;
        $category->type = $category->type ?: $type;

        $category->save();

        return $category->id;
    }

    private function importBanner(array $record): void
    {
        Banner::create([
            'title' => $record['title'],
            'description' => $record['description'] ?? '',
            'type_contenu' => $record['type_contenu'] ?? '',
            'titre' => $record['titre'] ?? $record['title'],
            'sous_titre' => $record['sous_titre'] ?? '',
            'section' => $record['section'] ?? 'home',
            'image_url' => $record['image_url'] ?? '',
            'demo_video_url' => $record['demo_video_url'] ?? '',
            'background_color' => $record['background_color'] ?? '#FF6B6B',
            'text_color' => $record['text_color'] ?? '#FFFFFF',
            'button_text' => $record['button_text'] ?? '',
            'button_url' => $record['button_url'] ?? '',
            'button_color' => $record['button_color'] ?? '#FF6B6B',
            'is_active' => (bool)($record['is_active'] ?? true),
            'order' => (int)($record['order'] ?? 0),
            'position' => $record['position'] ?? 'home',
        ]);
    }

    private function importTeam(array $record): void
    {
        Team::create([
            'name' => $record['name'],
            'short_name' => $record['short_name'] ?? \Str::limit($record['name'], 3, ''),
            'country' => $record['country'] ?? 'Côte d\'Ivoire',
            'logo' => $record['logo'] ?? '',
            'color_primary' => $record['color_primary'] ?? '#FF6B6B',
            'color_secondary' => $record['color_secondary'] ?? '#FFFFFF',
            'is_active' => (bool)($record['is_active'] ?? true),
            'founded_year' => (int)($record['founded_year'] ?? date('Y')),
            'description' => $record['description'] ?? '',
        ]);
    }

    private function importFootballMatch(array $record): void
    {
        $homeTeam = Team::where('name', $record['home_team'])->first();
        $awayTeam = Team::where('name', $record['away_team'])->first();

        if (!$homeTeam || !$awayTeam) {
            throw new \Exception("Équipes non trouvées pour le match {$record['home_team']} vs {$record['away_team']}");
        }

        FootballMatch::create([
            'home_team_id' => $homeTeam->id,
            'away_team_id' => $awayTeam->id,
            'tournament_id' => $record['tournament_id'] ?? null,
            'match_date' => $record['match_date'],
            'predictions_close_at' => $record['predictions_close_at'] ?? $record['match_date'],
            'status' => $record['status'] ?? 'scheduled',
            'home_score' => isset($record['home_score']) ? (int)$record['home_score'] : null,
            'away_score' => isset($record['away_score']) ? (int)$record['away_score'] : null,
            'competition' => $record['competition'] ?? '',
            'round' => $record['round'] ?? '',
            'venue' => $record['venue'] ?? '',
            'notes' => $record['notes'] ?? '',
            'is_active' => (bool)($record['is_active'] ?? true),
            'predictions_enabled' => (bool)($record['predictions_enabled'] ?? true),
        ]);
    }

    private function importTournament(array $record): void
    {
        Tournament::create([
            'name' => $record['name'],
            'slug' => \Str::slug($record['name']),
            'description' => $record['description'] ?? '',
            'start_date' => $record['start_date'],
            'end_date' => $record['end_date'],
            'registration_start' => $record['registration_start'] ?? $record['start_date'],
            'registration_end' => $record['registration_end'] ?? $record['end_date'],
            'prediction_deadline' => $record['prediction_deadline'] ?? $record['start_date'],
            'max_participants' => (int)($record['max_participants'] ?? 100),
            'entry_fee' => $record['entry_fee'] ?? '0.00',
            'currency' => $record['currency'] ?? 'XOF',
            'prize_pool' => $record['prize_pool'] ?? '0.00',
            'status' => $record['status'] ?? 'upcoming',
            'rules' => json_decode($record['rules'] ?? '[]', true),
            'image' => $record['image'] ?? '',
            'is_featured' => (bool)($record['is_featured'] ?? false),
            'is_public' => (bool)($record['is_public'] ?? true),
            'created_by' => 1, // Admin user
        ]);
    }

    private function importPrediction(array $record): void
    {
        $user = User::where('email', $record['user_email'])->first();
        $match = FootballMatch::find($record['football_match_id']);

        if (!$user || !$match) {
            throw new \Exception("Utilisateur ou match non trouvé pour la prédiction");
        }

        Prediction::create([
            'user_id' => $user->id,
            'football_match_id' => $match->id,
            'predicted_home_score' => (int)$record['predicted_home_score'],
            'predicted_away_score' => (int)$record['predicted_away_score'],
            'predicted_winner' => $record['predicted_winner'],
            'points_earned' => (int)($record['points_earned'] ?? 0),
            'is_calculated' => (bool)($record['is_calculated'] ?? false),
            'ip_address' => $record['ip_address'] ?? '127.0.0.1',
            'user_agent' => $record['user_agent'] ?? 'CSV Import',
        ]);
    }

    private function importPushNotification(array $record): void
    {
        PushNotification::create([
            'title' => $record['title'],
            'message' => $record['message'],
            'icon' => $record['icon'] ?? '',
            'url' => $record['url'] ?? '',
            'target_audience' => $record['target_audience'] ?? 'all',
            'target_data' => json_decode($record['target_data'] ?? '[]', true),
            'onesignal_id' => $record['onesignal_id'] ?? '',
            'status' => $record['status'] ?? 'draft',
            'scheduled_at' => $record['scheduled_at'] ?? null,
            'sent_at' => $record['sent_at'] ?? null,
            'statistics' => json_decode($record['statistics'] ?? '[]', true),
            'created_by' => 1, // Admin user
        ]);
    }

    private function importIngredient(array $record): void
    {
        Ingredient::create([
            'name' => $record['name'],
            'category' => $record['category'] ?? 'Autres',
            'subcategory' => $record['subcategory'] ?? '',
            'unit' => $record['unit'] ?? 'pièce',
            'recommended_brand' => $record['recommended_brand'] ?? '',
            'average_price' => $record['average_price'] ?? '0.00',
            'description' => $record['description'] ?? '',
            'image' => $record['image'] ?? '',
            'is_active' => (bool)($record['is_active'] ?? true),
        ]);
    }

    private function importEventCategory(array $record): void
    {
        EventCategory::create([
            'name' => $record['name'],
            'slug' => \Str::slug($record['name']),
            'description' => $record['description'] ?? '',
            'image' => $record['image'] ?? '',
            'color' => $record['color'] ?? '#FF6B6B',
            'icon' => $record['icon'] ?? 'heroicon-o-calendar',
            'is_active' => (bool)($record['is_active'] ?? true),
        ]);
    }

    private function importMediaFile(array $record): void
    {
        MediaFile::create([
            'name' => $record['name'],
            'filename' => $record['filename'],
            'path' => $record['path'],
            'disk' => $record['disk'] ?? 'public',
            'mime_type' => $record['mime_type'] ?? 'image/jpeg',
            'type' => $record['type'] ?? 'image',
            'size' => (int)($record['size'] ?? 0),
            'metadata' => json_decode($record['metadata'] ?? '[]', true),
            'model_type' => $record['model_type'] ?? null,
            'model_id' => $record['model_id'] ?? null,
            'collection_name' => $record['collection_name'] ?? 'default',
            'uploaded_by' => 1, // Admin user
            'alt_text' => $record['alt_text'] ?? '',
            'description' => $record['description'] ?? '',
            'tags' => json_decode($record['tags'] ?? '[]', true),
            'thumbnail_path' => $record['thumbnail_path'] ?? '',
            'responsive_images' => json_decode($record['responsive_images'] ?? '[]', true),
            'title' => $record['title'] ?? $record['name'],
            'caption' => $record['caption'] ?? '',
            'is_optimized' => (bool)($record['is_optimized'] ?? false),
            'is_public' => (bool)($record['is_public'] ?? true),
            'is_featured' => (bool)($record['is_featured'] ?? false),
            'download_count' => (int)($record['download_count'] ?? 0),
            'view_count' => (int)($record['view_count'] ?? 0),
        ]);
    }

    private function importPage(array $record): void
    {
        PageModel::create([
            'title' => $record['title'],
            'content' => $record['content'] ?? '',
            'slug' => \Str::slug($record['title']),
            'meta_title' => $record['meta_title'] ?? $record['title'],
            'meta_description' => $record['meta_description'] ?? '',
            'meta_keywords' => $record['meta_keywords'] ?? '',
            'template' => $record['template'] ?? 'default',
            'url' => $record['url'] ?? '',
            'embed_url' => $record['embed_url'] ?? '',
            'is_external' => (bool)($record['is_external'] ?? false),
            'is_published' => (bool)($record['is_published'] ?? true),
            'is_homepage' => (bool)($record['is_homepage'] ?? false),
            'order' => (int)($record['order'] ?? 0),
            'parent_id' => $record['parent_id'] ?? null,
            'featured_image' => $record['featured_image'] ?? '',
        ]);
    }

    private function importUser(array $record): void
    {
        User::create([
            'name' => $record['name'],
            'email' => $record['email'],
            'password' => Hash::make($record['password'] ?? \Illuminate\Support\Str::random(24)),
            'role' => $record['role'] ?? 'user',
            'is_active' => (bool)($record['is_active'] ?? true),
        ]);
    }

    private function parseTagsColumns(array $record): array
    {
        $tags = [];
        $index = 1;
        $foundColumns = false;

        while (array_key_exists("tag_{$index}", $record)) {
            $foundColumns = true;
            $value = trim((string)($record["tag_{$index}"] ?? ''));
            if ($value !== '') {
                $tags[] = $value;
            }
            $index++;
        }

        if ($foundColumns) {
            return $tags;
        }

        if (!empty($record['tags'])) {
            $rawTags = $record['tags'];
            $decoded = json_decode($rawTags, true);
            if (is_array($decoded)) {
                return array_values(array_filter($decoded, fn ($tag) => trim((string) $tag) !== ''));
            }

            $fallback = array_filter(array_map('trim', preg_split('/[;,|]/', (string) $rawTags)));
            return array_values($fallback);
        }

        return [];
    }

    private function parseInstructionColumns(array $record): array
    {
        $instructions = [];
        $index = 1;
        $foundColumns = false;

        while (array_key_exists("instruction_{$index}", $record) || array_key_exists("step_{$index}", $record)) {
            $foundColumns = true;
            $value = trim((string)($record["instruction_{$index}"] ?? $record["step_{$index}"] ?? ''));

            if ($value !== '') {
                $instructions[] = ['step' => $value];
            }

            $index++;
        }

        if ($foundColumns) {
            return $instructions;
        }

        if (!empty($record['instructions'])) {
            $raw = $record['instructions'];
            $decoded = json_decode($raw, true);
            if (is_array($decoded)) {
                return $decoded;
            }

            $lines = array_filter(array_map('trim', preg_split('/\r\n|\r|\n/', (string) $raw)));
            return array_map(fn ($line) => ['step' => $line], $lines);
        }

        return [];
    }

    private function parseIngredientsColumns(array $record): array
    {
        $ingredients = [];
        $index = 1;
        $foundColumns = false;

        while ($this->hasIngredientColumn($record, $index)) {
            $foundColumns = true;

            $nameKey = "ingredient_{$index}_name";
            $quantityKey = "ingredient_{$index}_quantity";
            $unitKey = "ingredient_{$index}_unit";
            $brandKey = "ingredient_{$index}_brand";
            $idKey = "ingredient_{$index}_id";

            $name = trim((string)($record[$nameKey] ?? ''));
            $quantity = trim((string)($record[$quantityKey] ?? ''));
            $unit = trim((string)($record[$unitKey] ?? ''));
            $brand = trim((string)($record[$brandKey] ?? ''));
            $ingredientId = $record[$idKey] ?? null;
            if ($ingredientId === '') {
                $ingredientId = null;
            }

            if ($ingredientId === null && $name !== '') {
                $candidate = Ingredient::where('name', $name)->first();
                if ($candidate) {
                    $ingredientId = $candidate->id;
                    $unit = $unit ?: ($candidate->unit ?? '');
                    $brand = $brand ?: ($candidate->recommended_brand ?? '');
                }
            }

            if ($ingredientId === null && $name === '' && $quantity === '') {
                $index++;
                continue;
            }

            $ingredients[] = [
                'ingredient_id' => $ingredientId,
                'name' => $name,
                'quantity' => $quantity !== '' ? $quantity : null,
                'unit' => $unit !== '' ? $unit : null,
                'recommended_brand' => $brand !== '' ? $brand : null,
            ];

            $index++;
        }

        if ($foundColumns) {
            return $ingredients;
        }

        if (!empty($record['ingredients'])) {
            $decoded = json_decode($record['ingredients'], true);
            if (is_array($decoded)) {
                return $decoded;
            }
        }

        return [];
    }

    private function hasIngredientColumn(array $record, int $index): bool
    {
        return array_key_exists("ingredient_{$index}_name", $record)
            || array_key_exists("ingredient_{$index}_quantity", $record)
            || array_key_exists("ingredient_{$index}_unit", $record)
            || array_key_exists("ingredient_{$index}_brand", $record)
            || array_key_exists("ingredient_{$index}_id", $record);
    }

    private function getContentTypeName(string $type): string
    {
        return match($type) {
            'recipes' => 'recettes',
            'events' => 'événements',
            'tips' => 'astuces',
            'dinor_tv' => 'vidéos',
            'categories' => 'catégories',
            'banners' => 'bannières',
            'teams' => 'équipes',
            'football_matches' => 'matchs de football',
            'tournaments' => 'tournois',
            'predictions' => 'prédictions',
            'push_notifications' => 'notifications push',
            'ingredients' => 'ingrédients',
            'event_categories' => 'catégories d\'événements',
            'media_files' => 'fichiers média',
            'pages' => 'pages',
            'users' => 'utilisateurs',
            default => $type,
        };
    }

    public function generateExampleCsv(string $type): string
    {
        $examples = $this->getExampleData();
        
        if (!isset($examples[$type])) {
            return '';
        }
        
        $rows = $examples[$type];
        $escapedRows = array_map(function (array $row) {
            return array_map(function ($value) {
                $value = (string) $value;
                return str_replace('"', '""', $value);
            }, $row);
        }, $rows);

        $csvContent = '';
        foreach ($escapedRows as $row) {
            $csvContent .= '"' . implode('","', $row) . '"' . "\n";
        }

        return $csvContent;
    }

    public function downloadExample(string $type)
    {
        $csvContent = $this->generateExampleCsv($type);

        return response($csvContent)
            ->header('Content-Type', 'text/csv; charset=UTF-8')
            ->header('Content-Disposition', 'attachment; filename="exemple_' . $type . '.csv"')
            ->header('Cache-Control', 'no-cache, must-revalidate')
            ->header('Pragma', 'no-cache')
            ->header('Expires', '0');
    }

    private function getExampleData(): array
    {
        return [
            'recipes' => [
                [
                    'title',
                    'description',
                    'short_description',
                    'ingredient_1_name',
                    'ingredient_1_quantity',
                    'ingredient_1_unit',
                    'ingredient_2_name',
                    'ingredient_2_quantity',
                    'ingredient_2_unit',
                    'instruction_1',
                    'instruction_2',
                    'preparation_time',
                    'cooking_time',
                    'servings',
                    'difficulty',
                    'meal_type',
                    'diet_type',
                    'category',
                    'tag_1',
                    'tag_2',
                    'is_featured',
                    'is_published'
                ],
                [
                    'Riz au Gras',
                    'Délicieux riz au gras traditionnel',
                    'Riz préparé avec de la sauce tomate',
                    'Riz jasmin',
                    '2',
                    'tasses',
                    'Viande de bœuf',
                    '300',
                    'g',
                    'Faire revenir les oignons émincés dans l’huile',
                    'Ajouter le riz et laisser cuire 25 minutes à feu doux',
                    '30',
                    '60',
                    '4',
                    'medium',
                    'lunch',
                    'none',
                    'Plats principaux',
                    'riz',
                    'traditionnel',
                    'true',
                    'true'
                ]
            ],
            'events' => [
                ['title', 'description', 'content', 'short_description', 'start_date', 'end_date', 'location', 'address', 'city', 'country', 'category', 'price', 'currency', 'is_free', 'max_participants', 'tag_1', 'tag_2', 'is_featured', 'is_published', 'status'],
                ['Atelier Cuisine', 'Atelier de cuisine ivoirienne', '<p>Apprenez à cuisiner</p>', 'Cours de cuisine', '2025-08-01 14:00:00', '2025-08-01 17:00:00', 'Centre culturel', 'Rue de la Culture', 'Abidjan', 'Côte d\'Ivoire', 'Ateliers', '15000', 'XOF', 'false', '20', 'atelier', 'cuisine', 'true', 'true', 'active']
            ],
            'tips' => [
                ['title', 'content', 'category', 'tag_1', 'tag_2', 'is_featured', 'is_published', 'difficulty_level', 'estimated_time'],
                ['Bien choisir ses épices', 'Pour bien choisir vos épices...', 'Conseils', 'épices', 'conseils', 'true', 'true', 'beginner', '5']
            ],
            'dinor_tv' => [
                ['title', 'description', 'video_url', 'is_featured', 'is_published'],
                ['Préparation du Bangui', 'Apprenez à préparer le bangui', 'https://youtube.com/watch?v=example', 'true', 'true']
            ],
            'categories' => [
                ['name', 'description', 'color', 'icon', 'is_active', 'type'],
                ['Plats principaux', 'Catégorie pour les plats principaux', '#FF6B6B', 'heroicon-o-squares-plus', 'true', 'general']
            ],
            'banners' => [
                ['title', 'description', 'type_contenu', 'titre', 'sous_titre', 'section', 'image_url', 'demo_video_url', 'background_color', 'text_color', 'button_text', 'button_url', 'button_color', 'is_active', 'order', 'position'],
                ['Bannière Accueil', 'Bannière principale de l\'accueil', 'promo', 'Découvrez Dinor', 'L\'app de cuisine ivoirienne', 'hero', 'https://example.com/banner.jpg', 'https://youtube.com/watch?v=demo', '#FF6B6B', '#FFFFFF', 'Découvrir', '/recipes', '#FF6B6B', 'true', '1', 'home']
            ],
            'teams' => [
                ['name', 'short_name', 'country', 'logo', 'color_primary', 'color_secondary', 'is_active', 'founded_year', 'description'],
                ['Éléphants de Côte d\'Ivoire', 'CIV', 'Côte d\'Ivoire', 'teams/elephants.png', '#FF6B00', '#FFFFFF', 'true', '1960', 'Équipe nationale de football de Côte d\'Ivoire']
            ],
            'football_matches' => [
                ['home_team', 'away_team', 'tournament_id', 'match_date', 'predictions_close_at', 'status', 'home_score', 'away_score', 'competition', 'round', 'venue', 'notes', 'is_active', 'predictions_enabled'],
                ['Éléphants de Côte d\'Ivoire', 'Lions du Sénégal', '1', '2025-08-15 20:00:00', '2025-08-15 19:45:00', 'scheduled', '', '', 'CAN 2025', 'Groupe A', 'Stade Félix Houphouët-Boigny', 'Match de poule', 'true', 'true']
            ],
            'tournaments' => [
                ['name', 'description', 'start_date', 'end_date', 'registration_start', 'registration_end', 'prediction_deadline', 'max_participants', 'entry_fee', 'currency', 'prize_pool', 'status', 'rules', 'image', 'is_featured', 'is_public'],
                ['CAN 2025 Predictions', 'Tournoi de prédictions pour la CAN 2025', '2025-08-01 00:00:00', '2025-08-31 23:59:59', '2025-07-01 00:00:00', '2025-07-31 23:59:59', '2025-08-01 00:00:00', '1000', '0.00', 'XOF', '100000.00', 'upcoming', '[]', 'tournaments/can2025.jpg', 'true', 'true']
            ],
            'predictions' => [
                ['user_email', 'football_match_id', 'predicted_home_score', 'predicted_away_score', 'predicted_winner', 'points_earned', 'is_calculated', 'ip_address', 'user_agent'],
                ['user@example.com', '1', '2', '1', 'home', '3', 'true', '192.168.1.1', 'Mozilla/5.0']
            ],
            'push_notifications' => [
                ['title', 'message', 'icon', 'url', 'target_audience', 'target_data', 'onesignal_id', 'status', 'scheduled_at', 'sent_at', 'statistics'],
                ['Nouvelle recette !', 'Une délicieuse recette de riz au gras vient d\'être ajoutée', 'recipe-icon', '/recipes/riz-au-gras', 'all', '[]', '', 'draft', '', '', '[]']
            ],
            'ingredients' => [
                ['name', 'category', 'subcategory', 'unit', 'recommended_brand', 'average_price', 'description', 'image', 'is_active'],
                ['Riz jasmin', 'Céréales et féculents', 'Riz', 'kg', 'Taureau Ailé', '2500.00', 'Riz parfumé de qualité supérieure', 'ingredients/riz-jasmin.jpg', 'true']
            ],
            'event_categories' => [
                ['name', 'description', 'image', 'color', 'icon', 'is_active'],
                ['Ateliers Cuisine', 'Catégorie pour les ateliers de cuisine', 'categories/ateliers.jpg', '#4CAF50', 'heroicon-o-academic-cap', 'true']
            ],
            'media_files' => [
                ['name', 'filename', 'path', 'disk', 'mime_type', 'type', 'size', 'metadata', 'model_type', 'model_id', 'collection_name', 'alt_text', 'description', 'tags', 'thumbnail_path', 'responsive_images', 'title', 'caption', 'is_optimized', 'is_public', 'is_featured', 'download_count', 'view_count'],
                ['Photo recette riz', 'riz-au-gras-1.jpg', 'recipes/riz-au-gras-1.jpg', 'public', 'image/jpeg', 'image', '245760', '{}', 'App\\Models\\Recipe', '1', 'featured_image', 'Délicieux riz au gras', 'Photo du plat fini', '["riz","plat-principal"]', 'recipes/thumbs/riz-au-gras-1-thumb.jpg', '[]', 'Riz au gras', 'Le plat traditionnel ivoirien', 'true', 'true', 'false', '0', '0']
            ],
            'pages' => [
                ['title', 'content', 'meta_title', 'meta_description', 'meta_keywords', 'template', 'url', 'embed_url', 'is_external', 'is_published', 'is_homepage', 'order', 'parent_id', 'featured_image'],
                ['À propos de Dinor', '<h1>À propos de nous</h1><p>Dinor est l\'application de référence...</p>', 'À propos - Dinor', 'Découvrez l\'histoire et la mission de Dinor', 'dinor,cuisine,ivoirienne,recettes', 'default', '/about', '', 'false', 'true', 'false', '1', '', 'pages/about-banner.jpg']
            ],
            'users' => [
                ['name', 'email', 'password', 'role', 'is_active'],
                ['Chef Marie', 'chef.marie@dinor.app', 'ChangeM3!Now_' . date('Y'), 'chef', 'true']
            ]
        ];
    }
}
