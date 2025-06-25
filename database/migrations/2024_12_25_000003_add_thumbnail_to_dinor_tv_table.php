<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('dinor_tv', function (Blueprint $table) {
            // Ajouter le champ thumbnail après video_url
            $table->string('thumbnail')->nullable()->after('video_url');
        });
    }

    public function down(): void
    {
        Schema::table('dinor_tv', function (Blueprint $table) {
            $table->dropColumn('thumbnail');
        });
    }
};