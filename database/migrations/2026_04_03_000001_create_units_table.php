<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('units', function (Blueprint $table) {
            $table->id();
            $table->string('name')->unique();           // ex: "Kilogramme"
            $table->string('abbreviation')->unique();    // ex: "kg"
            $table->enum('type', ['poids', 'volume', 'quantite', 'autre'])->default('autre');
            $table->boolean('is_active')->default(true);
            $table->integer('sort_order')->default(0);
            $table->timestamps();
        });

        // Insérer les unités par défaut
        $units = [
            ['name' => 'Kilogramme', 'abbreviation' => 'kg', 'type' => 'poids', 'sort_order' => 1],
            ['name' => 'Gramme', 'abbreviation' => 'g', 'type' => 'poids', 'sort_order' => 2],
            ['name' => 'Milligramme', 'abbreviation' => 'mg', 'type' => 'poids', 'sort_order' => 3],
            ['name' => 'Litre', 'abbreviation' => 'l', 'type' => 'volume', 'sort_order' => 4],
            ['name' => 'Millilitre', 'abbreviation' => 'ml', 'type' => 'volume', 'sort_order' => 5],
            ['name' => 'Centilitre', 'abbreviation' => 'cl', 'type' => 'volume', 'sort_order' => 6],
            ['name' => 'Décilitre', 'abbreviation' => 'dl', 'type' => 'volume', 'sort_order' => 7],
            ['name' => 'Pièce', 'abbreviation' => 'pièce', 'type' => 'quantite', 'sort_order' => 8],
            ['name' => 'Cuillère à soupe', 'abbreviation' => 'c. à s.', 'type' => 'volume', 'sort_order' => 9],
            ['name' => 'Cuillère à café', 'abbreviation' => 'c. à c.', 'type' => 'volume', 'sort_order' => 10],
            ['name' => 'Tasse', 'abbreviation' => 'tasse', 'type' => 'volume', 'sort_order' => 11],
            ['name' => 'Verre', 'abbreviation' => 'verre', 'type' => 'volume', 'sort_order' => 12],
            ['name' => 'Pincée', 'abbreviation' => 'pincée', 'type' => 'quantite', 'sort_order' => 13],
            ['name' => 'Botte', 'abbreviation' => 'botte', 'type' => 'quantite', 'sort_order' => 14],
            ['name' => 'Sachet', 'abbreviation' => 'sachet', 'type' => 'quantite', 'sort_order' => 15],
            ['name' => 'Boîte', 'abbreviation' => 'boîte', 'type' => 'quantite', 'sort_order' => 16],
            ['name' => 'Tranche', 'abbreviation' => 'tranche', 'type' => 'quantite', 'sort_order' => 17],
            ['name' => 'Gousse', 'abbreviation' => 'gousse', 'type' => 'quantite', 'sort_order' => 18],
            ['name' => 'Brin', 'abbreviation' => 'brin', 'type' => 'quantite', 'sort_order' => 19],
            ['name' => 'Feuille', 'abbreviation' => 'feuille', 'type' => 'quantite', 'sort_order' => 20],
        ];

        $now = now();
        foreach ($units as $unit) {
            \DB::table('units')->insert(array_merge($unit, [
                'is_active' => true,
                'created_at' => $now,
                'updated_at' => $now,
            ]));
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('units');
    }
};
