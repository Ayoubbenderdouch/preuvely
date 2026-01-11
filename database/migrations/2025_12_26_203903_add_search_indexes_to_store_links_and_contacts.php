<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     * Adds indexes to store_links and store_contacts tables for faster search queries.
     */
    public function up(): void
    {
        // Add indexes to store_links table for URL and handle search
        Schema::table('store_links', function (Blueprint $table) {
            $table->index('url');
            $table->index('handle');
            $table->index('platform');
        });

        // Add indexes to store_contacts table for phone number search
        Schema::table('store_contacts', function (Blueprint $table) {
            $table->index('phone');
            $table->index('whatsapp');
        });

        // Add index to stores.slug for faster slug lookups
        Schema::table('stores', function (Blueprint $table) {
            // Check if index doesn't already exist
            if (! Schema::hasIndex('stores', 'stores_slug_index')) {
                $table->index('slug');
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('store_links', function (Blueprint $table) {
            $table->dropIndex(['url']);
            $table->dropIndex(['handle']);
            $table->dropIndex(['platform']);
        });

        Schema::table('store_contacts', function (Blueprint $table) {
            $table->dropIndex(['phone']);
            $table->dropIndex(['whatsapp']);
        });

        Schema::table('stores', function (Blueprint $table) {
            if (Schema::hasIndex('stores', 'stores_slug_index')) {
                $table->dropIndex(['slug']);
            }
        });
    }
};
