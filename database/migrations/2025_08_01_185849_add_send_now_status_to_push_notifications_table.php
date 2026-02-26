<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    private function getDriver(): string
    {
        try {
            return Schema::getConnection()->getDriverName();
        } catch (\Exception $e) {
            return config('database.default', 'pgsql');
        }
    }

    /**
     * Run the migrations.
     */
    public function up(): void
    {
        $driver = $this->getDriver();

        if ($driver === 'mysql' || $driver === 'mariadb') {
            // MySQL: modifier l'ENUM pour inclure send_now
            DB::statement("ALTER TABLE push_notifications MODIFY status ENUM('draft','scheduled','sent','failed','send_now') NOT NULL DEFAULT 'draft'");
        } else {
            // PostgreSQL (et autres): utiliser une contrainte CHECK
            DB::statement("ALTER TABLE push_notifications DROP CONSTRAINT IF EXISTS push_notifications_status_check");
            DB::statement("ALTER TABLE push_notifications ADD CONSTRAINT push_notifications_status_check CHECK (status IN ('draft','scheduled','sent','failed','send_now'))");
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        $driver = $this->getDriver();

        if ($driver === 'mysql' || $driver === 'mariadb') {
            // Revenir à l'ENUM sans send_now
            DB::statement("ALTER TABLE push_notifications MODIFY status ENUM('draft','scheduled','sent','failed') NOT NULL DEFAULT 'draft'");
        } else {
            // Restaurer la contrainte CHECK d'origine
            DB::statement("ALTER TABLE push_notifications DROP CONSTRAINT IF EXISTS push_notifications_status_check");
            DB::statement("ALTER TABLE push_notifications ADD CONSTRAINT push_notifications_status_check CHECK (status IN ('draft','scheduled','sent','failed'))");
        }
    }
};
