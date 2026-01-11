<?php

use Illuminate\Database\Migrations\Migration;
use Spatie\Permission\Models\Role;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Create the data_entry role if it doesn't exist
        Role::firstOrCreate(
            ['name' => 'data_entry', 'guard_name' => 'web']
        );
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Remove the data_entry role
        Role::where('name', 'data_entry')->delete();
    }
};
