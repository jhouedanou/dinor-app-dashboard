<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        $driver = Schema::getConnection()->getDriverName();

        if ($driver === 'mysql') {
            // MySQL: modifier l'ENUM pour inclure send_now
            DB::statement("ALTER TABLE push_notifications MODIFY status ENUM('draft','scheduled','sent','failed','send_now') NOT NULL DEFAULT 'draft'");
        } elseif ($driver === 'pgsql') {
            // PostgreSQL: utiliser une contrainte CHECK (tolérer l'absence de contrainte)
            DB::statement("ALTER TABLE push_notifications DROP CONSTRAINT IF EXISTS push_notifications_status_check");
            DB::statement("ALTER TABLE push_notifications ADD CONSTRAINT push_notifications_status_check CHECK (status IN ('draft','scheduled','sent','failed','send_now'))");
        } else {
            // Autres SGBD: ne rien faire (pas critique)
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        $driver = Schema::getConnection()->getDriverName();

        if ($driver === 'mysql') {
            // Revenir à l'ENUM sans send_now
            DB::statement("ALTER TABLE push_notifications MODIFY status ENUM('draft','scheduled','sent','failed') NOT NULL DEFAULT 'draft'");
        } elseif ($driver === 'pgsql') {
            // Restaurer la contrainte CHECK d'origine
            DB::statement("ALTER TABLE push_notifications DROP CONSTRAINT IF EXISTS push_notifications_status_check");
            DB::statement("ALTER TABLE push_notifications ADD CONSTRAINT push_notifications_status_check CHECK (status IN ('draft','scheduled','sent','failed'))");
        } else {
            // Autres SGBD: pas d'action
        }
    }
};
