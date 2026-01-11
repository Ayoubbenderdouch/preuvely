<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('banners', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->string('title_ar')->nullable();
            $table->string('title_fr')->nullable();
            $table->string('subtitle')->nullable();
            $table->string('subtitle_ar')->nullable();
            $table->string('subtitle_fr')->nullable();
            $table->string('image_url');
            $table->string('link_type')->default('none'); // none, store, category, url
            $table->string('link_value')->nullable(); // store slug, category slug, or URL
            $table->string('background_color')->default('#22C55E'); // hex color
            $table->integer('sort_order')->default(0);
            $table->boolean('is_active')->default(true);
            $table->timestamp('starts_at')->nullable();
            $table->timestamp('ends_at')->nullable();
            $table->timestamps();

            $table->index(['is_active', 'sort_order']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('banners');
    }
};
