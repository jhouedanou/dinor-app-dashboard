<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        // PostgreSQL: supprimer la contrainte CHECK sur unit et convertir en varchar
        DB::statement('ALTER TABLE ingredients DROP CONSTRAINT IF EXISTS ingredients_unit_check');
        DB::statement('ALTER TABLE ingredients ALTER COLUMN unit TYPE varchar(255)');
    }

    public function down(): void
    {
        // Remettre l'enum (les valeurs non valides seront rejetées)
        $allowed = "'kg','g','mg','l','ml','cl','dl','pièce','cuillère à soupe','cuillère à café','tasse','verre','pincée','botte','sachet','boîte','tranche','gousse','brin','feuille'";
        DB::statement("ALTER TABLE ingredients ADD CONSTRAINT ingredients_unit_check CHECK (unit IN ({$allowed}))");
    }
};
