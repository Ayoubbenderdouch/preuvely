<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // Production: Only seed essential data (categories)
        $this->call([
            CategorySeeder::class,
        ]);

        // Development only - uncomment to seed test data:
        // $this->call([
        //     AdminUserSeeder::class,
        //     DemoStoreSeeder::class,
        //     DataEntryUserSeeder::class,
        // ]);
    }
}
