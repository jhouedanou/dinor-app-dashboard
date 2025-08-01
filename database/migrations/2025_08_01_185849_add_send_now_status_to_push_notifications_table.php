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
        // Pour PostgreSQL, nous devons modifier l'enum en utilisant du SQL brut
        DB::statement("ALTER TABLE push_notifications DROP CONSTRAINT push_notifications_status_check");
        DB::statement("ALTER TABLE push_notifications ADD CONSTRAINT push_notifications_status_check CHECK (status IN ('draft', 'scheduled', 'sent', 'failed', 'send_now'))");
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Remettre l'ancienne contrainte
        DB::statement("ALTER TABLE push_notifications DROP CONSTRAINT push_notifications_status_check");
        DB::statement("ALTER TABLE push_notifications ADD CONSTRAINT push_notifications_status_check CHECK (status IN ('draft', 'scheduled', 'sent', 'failed'))");
    }
};
