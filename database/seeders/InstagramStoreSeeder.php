<?php

namespace Database\Seeders;

use App\Models\Category;
use App\Models\Store;
use App\Models\StoreLink;
use Illuminate\Database\Seeder;
use Illuminate\Support\Str;

class InstagramStoreSeeder extends Seeder
{
    /**
     * Map JSON categories to database category slugs
     */
    private array $categoryMap = [
        'General E-commerce' => 'fashion',
        'Fashion & Clothing' => 'fashion',
        'Fashion & Accessories' => 'fashion',
        'Fashion & Beauty' => 'fashion',
        'Shoes & Sneakers' => 'fashion',
        'Phones & Electronics' => 'electronics',
        'Computers & Accessories' => 'electronics',
        'Phone Accessories' => 'electronics',
        'Kids & Toys' => 'kids-toys',
        'Beauty & Cosmetics' => 'beauty-cosmetics',
    ];

    public function run(): void
    {
        $jsonPath = '/Users/macbook/Downloads/preuvely_instagram_seed_stores.json';

        if (!file_exists($jsonPath)) {
            $this->command->error("JSON file not found: {$jsonPath}");
            return;
        }

        $stores = json_decode(file_get_contents($jsonPath), true);

        if (!$stores) {
            $this->command->error("Failed to parse JSON file");
            return;
        }

        $this->command->info("Seeding " . count($stores) . " Instagram stores...");

        foreach ($stores as $storeData) {
            $this->createStore($storeData);
        }

        $this->command->info("Done! Seeded " . count($stores) . " stores.");
    }

    private function createStore(array $data): void
    {
        $handle = $data['handle'];
        $category = $data['category'];
        $url = $data['url'];

        // Generate store name from handle (make it readable)
        $name = $this->handleToName($handle);

        // Generate unique slug
        $baseSlug = Str::slug($name);
        $slug = $baseSlug . '-' . Str::random(6);

        // Get category ID
        $categorySlug = $this->categoryMap[$category] ?? 'fashion';
        $categoryModel = Category::where('slug', $categorySlug)->first();

        if (!$categoryModel) {
            $this->command->warn("Category not found for: {$category}, using fashion");
            $categoryModel = Category::where('slug', 'fashion')->first();
        }

        // Check if store with this Instagram handle already exists
        $existingStore = Store::whereHas('links', function ($query) use ($handle) {
            $query->where('platform', 'instagram')
                  ->where('handle', $handle);
        })->first();

        if ($existingStore) {
            $this->command->info("Store already exists: {$name} (@{$handle})");
            return;
        }

        // Create store
        $store = Store::create([
            'name' => $name,
            'slug' => $slug,
            'description' => "Official Instagram shop: @{$handle}",
            'is_verified' => false,
        ]);

        // Attach category
        $store->categories()->attach($categoryModel->id);

        // Create Instagram link
        StoreLink::create([
            'store_id' => $store->id,
            'platform' => 'instagram',
            'url' => $url,
            'handle' => $handle,
        ]);

        $this->command->info("Created: {$name} (@{$handle}) - {$categorySlug}");
    }

    /**
     * Convert Instagram handle to readable store name
     */
    private function handleToName(string $handle): string
    {
        // Remove trailing underscores and .dz suffixes
        $name = preg_replace('/[_.]dz_?$/', '', $handle);
        $name = preg_replace('/_dz$/', '', $name);

        // Replace underscores and dots with spaces
        $name = str_replace(['_', '.'], ' ', $name);

        // Title case
        $name = ucwords(strtolower($name));

        // Clean up multiple spaces
        $name = preg_replace('/\s+/', ' ', $name);

        return trim($name);
    }
}
