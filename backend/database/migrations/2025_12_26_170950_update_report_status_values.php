<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * Updates report status values from old enum ('closed') to new enum values ('resolved').
     * This migration aligns the backend with iOS client expectations.
     */
    public function up(): void
    {
        // Update any 'closed' status to 'resolved'
        // This is the most sensible default - closed reports were handled/resolved
        DB::table('reports')->where('status', 'closed')->update(['status' => 'resolved']);
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Revert 'resolved' and 'dismissed' back to 'closed'
        DB::table('reports')->whereIn('status', ['resolved', 'dismissed'])->update(['status' => 'closed']);
    }
};
