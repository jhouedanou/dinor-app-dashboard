<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('recipes', function (Blueprint $table) {
            $table->string('summary_video_url')->nullable()->after('video_url')->comment('URL de la vidéo de résumé du contenu');
        });

        Schema::table('tips', function (Blueprint $table) {
            $table->string('summary_video_url')->nullable()->after('video_url')->comment('URL de la vidéo de résumé du contenu');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('recipes', function (Blueprint $table) {
            $table->dropColumn('summary_video_url');
        });

        Schema::table('tips', function (Blueprint $table) {
            $table->dropColumn('summary_video_url');
        });
    }
};
