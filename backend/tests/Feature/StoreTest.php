<?php

namespace Tests\Feature;

use App\Enums\Platform;
use App\Enums\ProofStatus;
use App\Enums\ReviewStatus;
use App\Enums\StoreStatus;
use App\Models\Category;
use App\Models\Review;
use App\Models\ReviewProof;
use App\Models\Store;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class StoreTest extends TestCase
{
    use RefreshDatabase;

    private User $user;
    private Category $category;

    protected function setUp(): void
    {
        parent::setUp();

        $this->user = User::factory()->create();
        $this->category = Category::factory()->create();
    }

    // ==========================================
    // store() Tests - Create new store
    // ==========================================

    public function test_authenticated_user_can_create_store(): void
    {
        $response = $this->actingAs($this->user, 'sanctum')
            ->postJson('/api/v1/stores', [
                'name' => 'My New Store',
                'description' => 'A wonderful store for all your needs.',
                'city' => 'Algiers',
                'category_ids' => [$this->category->id],
            ]);

        $response->assertStatus(201)
            ->assertJsonPath('message', 'Store created successfully')
            ->assertJsonPath('data.name', 'My New Store')
            ->assertJsonPath('data.city', 'Algiers')
            ->assertJsonPath('data.status', 'active');

        $this->assertDatabaseHas('stores', [
            'name' => 'My New Store',
            'description' => 'A wonderful store for all your needs.',
            'city' => 'Algiers',
            'submitted_by' => $this->user->id,
            'status' => StoreStatus::Active->value,
        ]);

        // Verify category was attached
        $store = Store::where('name', 'My New Store')->first();
        $this->assertTrue($store->categories->contains($this->category));
    }

    public function test_unauthenticated_user_cannot_create_store(): void
    {
        $response = $this->postJson('/api/v1/stores', [
            'name' => 'My New Store',
            'category_ids' => [$this->category->id],
        ]);

        $response->assertStatus(401);
    }

    public function test_store_creation_validates_required_fields(): void
    {
        $response = $this->actingAs($this->user, 'sanctum')
            ->postJson('/api/v1/stores', []);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['name', 'category_ids']);
    }

    public function test_store_creation_validates_name_max_length(): void
    {
        $response = $this->actingAs($this->user, 'sanctum')
            ->postJson('/api/v1/stores', [
                'name' => str_repeat('a', 256),
                'category_ids' => [$this->category->id],
            ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors('name');
    }

    public function test_store_creation_validates_category_ids_exist(): void
    {
        $response = $this->actingAs($this->user, 'sanctum')
            ->postJson('/api/v1/stores', [
                'name' => 'My New Store',
                'category_ids' => [99999],
            ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors('category_ids.0');
    }

    public function test_store_creation_requires_at_least_one_category(): void
    {
        $response = $this->actingAs($this->user, 'sanctum')
            ->postJson('/api/v1/stores', [
                'name' => 'My New Store',
                'category_ids' => [],
            ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors('category_ids');
    }

    public function test_store_creation_with_links_and_categories(): void
    {
        $categories = Category::factory()->count(2)->create();

        $response = $this->actingAs($this->user, 'sanctum')
            ->postJson('/api/v1/stores', [
                'name' => 'Store With Links',
                'description' => 'A store with social media links.',
                'city' => 'Oran',
                'category_ids' => $categories->pluck('id')->toArray(),
                'links' => [
                    [
                        'platform' => Platform::Instagram->value,
                        'url' => 'https://instagram.com/mystore',
                        'handle' => 'mystore',
                    ],
                    [
                        'platform' => Platform::Facebook->value,
                        'url' => 'https://facebook.com/mystore',
                    ],
                ],
                'contacts' => [
                    'whatsapp' => '+213555123456',
                    'phone' => '+213555654321',
                ],
            ]);

        $response->assertStatus(201)
            ->assertJsonPath('data.name', 'Store With Links');

        $store = Store::where('name', 'Store With Links')->first();

        // Verify categories
        $this->assertCount(2, $store->categories);

        // Verify links
        $this->assertCount(2, $store->links);
        $platformValues = $store->links->pluck('platform.value')->toArray();
        $this->assertContains(Platform::Instagram->value, $platformValues);
        $this->assertContains(Platform::Facebook->value, $platformValues);

        // Verify contacts
        $this->assertNotNull($store->contacts);
        $this->assertEquals('+213555123456', $store->contacts->whatsapp);
        $this->assertEquals('+213555654321', $store->contacts->phone);
    }

    public function test_store_creation_with_logo(): void
    {
        Storage::fake('public');

        $logo = UploadedFile::fake()->image('logo.jpg', 400, 400);

        $response = $this->actingAs($this->user, 'sanctum')
            ->postJson('/api/v1/stores', [
                'name' => 'Store With Logo',
                'category_ids' => [$this->category->id],
                'logo' => $logo,
            ]);

        $response->assertStatus(201);

        $store = Store::where('name', 'Store With Logo')->first();
        $this->assertNotNull($store->logo);

        Storage::disk('public')->assertExists($store->logo);
    }

    public function test_store_creation_validates_logo_file_type(): void
    {
        Storage::fake('public');

        $invalidFile = UploadedFile::fake()->create('document.pdf', 100);

        $response = $this->actingAs($this->user, 'sanctum')
            ->postJson('/api/v1/stores', [
                'name' => 'Store With Invalid Logo',
                'category_ids' => [$this->category->id],
                'logo' => $invalidFile,
            ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors('logo');
    }

    public function test_store_creation_validates_link_platform(): void
    {
        $response = $this->actingAs($this->user, 'sanctum')
            ->postJson('/api/v1/stores', [
                'name' => 'Store With Invalid Link',
                'category_ids' => [$this->category->id],
                'links' => [
                    [
                        'platform' => 'invalid_platform',
                        'url' => 'https://example.com',
                    ],
                ],
            ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors('links.0.platform');
    }

    public function test_duplicate_store_with_exact_name_is_rejected(): void
    {
        // Create a store first
        Store::factory()->create([
            'name' => 'Test Store',
            'status' => StoreStatus::Active,
        ]);

        // Try to create another store with the same name
        $response = $this->actingAs($this->user, 'sanctum')
            ->postJson('/api/v1/stores', [
                'name' => 'Test Store',
                'category_ids' => [$this->category->id],
            ]);

        // Should be rejected with 409 Conflict
        $response->assertStatus(409)
            ->assertJsonPath('error', 'duplicate_store')
            ->assertJsonPath('duplicate_type', 'name')
            ->assertJsonStructure([
                'message',
                'error',
                'duplicate_type',
                'existing_store' => [
                    'id',
                    'name',
                    'slug',
                ],
            ]);
    }

    public function test_duplicate_store_with_similar_name_is_rejected(): void
    {
        // Create a store first
        $existingStore = Store::factory()->create([
            'name' => 'DumDum BabyCare',
            'status' => StoreStatus::Active,
        ]);

        // Try to create another store with similar name (different casing, dots, spaces)
        $response = $this->actingAs($this->user, 'sanctum')
            ->postJson('/api/v1/stores', [
                'name' => 'doumdoum.babycare',
                'category_ids' => [$this->category->id],
            ]);

        // Should be rejected with 409 Conflict
        $response->assertStatus(409)
            ->assertJsonPath('error', 'duplicate_store')
            ->assertJsonPath('duplicate_type', 'name')
            ->assertJsonPath('existing_store.id', $existingStore->id);
    }

    public function test_duplicate_store_with_same_instagram_handle_is_rejected(): void
    {
        // Create a store with Instagram link
        $existingStore = Store::factory()->create([
            'name' => 'Original Store',
            'status' => StoreStatus::Active,
        ]);
        $existingStore->links()->create([
            'platform' => Platform::Instagram,
            'url' => 'https://instagram.com/mystore',
            'handle' => 'mystore',
        ]);

        // Try to create another store with the same Instagram handle
        $response = $this->actingAs($this->user, 'sanctum')
            ->postJson('/api/v1/stores', [
                'name' => 'Different Store Name',
                'category_ids' => [$this->category->id],
                'links' => [
                    [
                        'platform' => Platform::Instagram->value,
                        'url' => 'https://instagram.com/mystore',
                        'handle' => 'mystore',
                    ],
                ],
            ]);

        // Should be rejected with 409 Conflict
        $response->assertStatus(409)
            ->assertJsonPath('error', 'duplicate_store')
            ->assertJsonPath('existing_store.id', $existingStore->id);
    }

    public function test_duplicate_store_with_normalized_handle_is_rejected(): void
    {
        // Create a store with Instagram link
        $existingStore = Store::factory()->create([
            'name' => 'Original Store',
            'status' => StoreStatus::Active,
        ]);
        $existingStore->links()->create([
            'platform' => Platform::Instagram,
            'url' => 'https://instagram.com/my.store_dz',
            'handle' => 'my.store_dz',
        ]);

        // Try to create another store with the same handle but without dots/underscores
        $response = $this->actingAs($this->user, 'sanctum')
            ->postJson('/api/v1/stores', [
                'name' => 'Different Store Name',
                'category_ids' => [$this->category->id],
                'links' => [
                    [
                        'platform' => Platform::Instagram->value,
                        'url' => 'https://instagram.com/mystoredz',
                        'handle' => 'mystoredz',
                    ],
                ],
            ]);

        // Should be rejected with 409 Conflict
        $response->assertStatus(409)
            ->assertJsonPath('error', 'duplicate_store')
            ->assertJsonPath('existing_store.id', $existingStore->id);
    }

    public function test_store_with_unique_name_and_handle_is_allowed(): void
    {
        // Create a store first
        Store::factory()->create([
            'name' => 'Existing Store',
            'status' => StoreStatus::Active,
        ]);

        // Create another store with a completely different name
        $response = $this->actingAs($this->user, 'sanctum')
            ->postJson('/api/v1/stores', [
                'name' => 'Completely Different Store',
                'category_ids' => [$this->category->id],
            ]);

        // Should succeed
        $response->assertStatus(201);
    }

    public function test_duplicate_detection_ignores_inactive_stores(): void
    {
        // Create a suspended store
        Store::factory()->create([
            'name' => 'Suspended Store',
            'status' => StoreStatus::Suspended,
        ]);

        // Create a store with the same name - should be allowed since the other is suspended
        $response = $this->actingAs($this->user, 'sanctum')
            ->postJson('/api/v1/stores', [
                'name' => 'Suspended Store',
                'category_ids' => [$this->category->id],
            ]);

        // Should succeed since the duplicate is not active
        $response->assertStatus(201);
    }

    public function test_duplicate_response_includes_existing_store_info(): void
    {
        // Create a store first
        $existingStore = Store::factory()->create([
            'name' => 'Existing Store',
            'status' => StoreStatus::Active,
            'is_verified' => true,
            'avg_rating_cache' => 4.5,
            'reviews_count_cache' => 25,
        ]);

        // Try to create duplicate
        $response = $this->actingAs($this->user, 'sanctum')
            ->postJson('/api/v1/stores', [
                'name' => 'Existing Store',
                'category_ids' => [$this->category->id],
            ]);

        $response->assertStatus(409);

        $existingStoreData = $response->json('existing_store');
        $this->assertEquals($existingStore->id, $existingStoreData['id']);
        $this->assertEquals($existingStore->name, $existingStoreData['name']);
        $this->assertEquals($existingStore->slug, $existingStoreData['slug']);
        $this->assertTrue($existingStoreData['is_verified']);
    }

    // ==========================================
    // search() Tests - Search stores with filters
    // ==========================================

    public function test_can_search_stores_by_name(): void
    {
        Store::factory()->create(['name' => 'Electronics Store', 'status' => StoreStatus::Active]);
        Store::factory()->create(['name' => 'Clothing Shop', 'status' => StoreStatus::Active]);
        Store::factory()->create(['name' => 'Tech Electronics', 'status' => StoreStatus::Active]);

        $response = $this->getJson('/api/v1/stores/search?q=Electronics');

        $response->assertStatus(200)
            ->assertJsonCount(2, 'data');
    }

    public function test_can_search_stores_by_description(): void
    {
        Store::factory()->create([
            'name' => 'Generic Shop',
            'description' => 'We sell amazing electronics and gadgets.',
            'status' => StoreStatus::Active,
        ]);
        Store::factory()->create([
            'name' => 'Another Shop',
            'description' => 'Fashion and clothing items.',
            'status' => StoreStatus::Active,
        ]);

        $response = $this->getJson('/api/v1/stores/search?q=electronics');

        $response->assertStatus(200)
            ->assertJsonCount(1, 'data');
    }

    public function test_can_filter_stores_by_category(): void
    {
        $electronicsCategory = Category::factory()->create(['slug' => 'electronics']);
        $clothingCategory = Category::factory()->create(['slug' => 'clothing']);

        $store1 = Store::factory()->create(['status' => StoreStatus::Active]);
        $store1->categories()->attach($electronicsCategory->id);

        $store2 = Store::factory()->create(['status' => StoreStatus::Active]);
        $store2->categories()->attach($clothingCategory->id);

        $store3 = Store::factory()->create(['status' => StoreStatus::Active]);
        $store3->categories()->attach($electronicsCategory->id);

        $response = $this->getJson('/api/v1/stores/search?category=electronics');

        $response->assertStatus(200)
            ->assertJsonCount(2, 'data');
    }

    public function test_can_filter_stores_by_city(): void
    {
        Store::factory()->create(['city' => 'Algiers', 'status' => StoreStatus::Active]);
        Store::factory()->create(['city' => 'Oran', 'status' => StoreStatus::Active]);
        Store::factory()->create(['city' => 'Algiers Center', 'status' => StoreStatus::Active]);

        $response = $this->getJson('/api/v1/stores/search?city=Algiers');

        $response->assertStatus(200)
            ->assertJsonCount(2, 'data');
    }

    public function test_can_filter_stores_by_verified(): void
    {
        Store::factory()->create(['is_verified' => true, 'status' => StoreStatus::Active]);
        Store::factory()->create(['is_verified' => false, 'status' => StoreStatus::Active]);
        Store::factory()->create(['is_verified' => true, 'status' => StoreStatus::Active]);

        $response = $this->getJson('/api/v1/stores/search?verified=true');

        $response->assertStatus(200)
            ->assertJsonCount(2, 'data');
    }

    public function test_search_returns_paginated_results(): void
    {
        Store::factory()->count(25)->create(['status' => StoreStatus::Active]);

        $response = $this->getJson('/api/v1/stores/search?per_page=10');

        $response->assertStatus(200)
            ->assertJsonCount(10, 'data')
            ->assertJsonPath('meta.per_page', 10)
            ->assertJsonPath('meta.total', 25);
    }

    public function test_search_per_page_is_capped_at_50(): void
    {
        Store::factory()->count(60)->create(['status' => StoreStatus::Active]);

        $response = $this->getJson('/api/v1/stores/search?per_page=100');

        $response->assertStatus(200)
            ->assertJsonCount(50, 'data')
            ->assertJsonPath('meta.per_page', 50);
    }

    public function test_search_only_returns_active_stores(): void
    {
        Store::factory()->create(['status' => StoreStatus::Active]);
        Store::factory()->create(['status' => StoreStatus::Active]);
        Store::factory()->create(['status' => StoreStatus::Suspended]);

        $response = $this->getJson('/api/v1/stores/search');

        $response->assertStatus(200)
            ->assertJsonCount(2, 'data');
    }

    public function test_search_includes_categories(): void
    {
        $store = Store::factory()->create(['status' => StoreStatus::Active]);
        $store->categories()->attach($this->category->id);

        $response = $this->getJson('/api/v1/stores/search');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'data' => [
                    '*' => ['id', 'name', 'slug'],
                ],
            ]);
    }

    public function test_search_can_combine_multiple_filters(): void
    {
        $electronicsCategory = Category::factory()->create(['slug' => 'electronics']);

        $store1 = Store::factory()->create([
            'name' => 'Tech Store Algiers',
            'city' => 'Algiers',
            'is_verified' => true,
            'status' => StoreStatus::Active,
        ]);
        $store1->categories()->attach($electronicsCategory->id);

        $store2 = Store::factory()->create([
            'name' => 'Tech Store Oran',
            'city' => 'Oran',
            'is_verified' => true,
            'status' => StoreStatus::Active,
        ]);
        $store2->categories()->attach($electronicsCategory->id);

        $store3 = Store::factory()->create([
            'name' => 'Regular Store Algiers',
            'city' => 'Algiers',
            'is_verified' => false,
            'status' => StoreStatus::Active,
        ]);
        $store3->categories()->attach($electronicsCategory->id);

        $response = $this->getJson('/api/v1/stores/search?q=Tech&city=Algiers&verified=true&category=electronics');

        $response->assertStatus(200)
            ->assertJsonCount(1, 'data');
    }

    public function test_search_orders_by_rating_and_reviews(): void
    {
        Store::factory()->create([
            'name' => 'Low Rated Store',
            'avg_rating_cache' => 2.0,
            'reviews_count_cache' => 10,
            'status' => StoreStatus::Active,
        ]);

        Store::factory()->create([
            'name' => 'High Rated Store',
            'avg_rating_cache' => 5.0,
            'reviews_count_cache' => 50,
            'status' => StoreStatus::Active,
        ]);

        Store::factory()->create([
            'name' => 'Medium Rated Store',
            'avg_rating_cache' => 4.0,
            'reviews_count_cache' => 30,
            'status' => StoreStatus::Active,
        ]);

        $response = $this->getJson('/api/v1/stores/search');

        $response->assertStatus(200);

        $data = $response->json('data');
        $this->assertEquals('High Rated Store', $data[0]['name']);
        $this->assertEquals('Medium Rated Store', $data[1]['name']);
        $this->assertEquals('Low Rated Store', $data[2]['name']);
    }

    public function test_can_search_stores_by_instagram_url(): void
    {
        $store = Store::factory()->create([
            'name' => 'Instagram Store',
            'status' => StoreStatus::Active,
        ]);
        $store->links()->create([
            'platform' => Platform::Instagram,
            'url' => 'https://instagram.com/myinstastore',
            'handle' => '@myinstastore',
        ]);

        Store::factory()->create(['name' => 'Other Store', 'status' => StoreStatus::Active]);

        // Search by full Instagram URL
        $response = $this->getJson('/api/v1/stores/search?q='.urlencode('https://instagram.com/myinstastore'));

        $response->assertStatus(200)
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.name', 'Instagram Store');
    }

    public function test_can_search_stores_by_social_handle(): void
    {
        $store = Store::factory()->create([
            'name' => 'Social Store',
            'status' => StoreStatus::Active,
        ]);
        $store->links()->create([
            'platform' => Platform::Instagram,
            'url' => 'https://instagram.com/socialhandle',
            'handle' => '@socialhandle',
        ]);

        Store::factory()->create(['name' => 'Random Store', 'status' => StoreStatus::Active]);

        // Search by @handle
        $response = $this->getJson('/api/v1/stores/search?q='.urlencode('@socialhandle'));

        $response->assertStatus(200)
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.name', 'Social Store');

        // Search by handle without @
        $response = $this->getJson('/api/v1/stores/search?q=socialhandle');

        $response->assertStatus(200)
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.name', 'Social Store');
    }

    public function test_can_search_stores_by_phone_number(): void
    {
        $store = Store::factory()->create([
            'name' => 'Phone Store',
            'status' => StoreStatus::Active,
        ]);
        $store->contacts()->create([
            'phone' => '+213555123456',
            'whatsapp' => null,
        ]);

        Store::factory()->create(['name' => 'No Phone Store', 'status' => StoreStatus::Active]);

        // Search by full phone number
        $response = $this->getJson('/api/v1/stores/search?q='.urlencode('+213555123456'));

        $response->assertStatus(200)
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.name', 'Phone Store');
    }

    public function test_can_search_stores_by_whatsapp_number(): void
    {
        $store = Store::factory()->create([
            'name' => 'WhatsApp Store',
            'status' => StoreStatus::Active,
        ]);
        $store->contacts()->create([
            'phone' => null,
            'whatsapp' => '0555987654',
        ]);

        Store::factory()->create(['name' => 'Other Store', 'status' => StoreStatus::Active]);

        // Search by WhatsApp number
        $response = $this->getJson('/api/v1/stores/search?q=0555987654');

        $response->assertStatus(200)
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.name', 'WhatsApp Store');
    }

    public function test_search_extracts_username_from_instagram_url(): void
    {
        $store = Store::factory()->create([
            'name' => 'URL Extract Store',
            'status' => StoreStatus::Active,
        ]);
        $store->links()->create([
            'platform' => Platform::Instagram,
            'url' => 'shoptest',
            'handle' => '@shoptest',
        ]);

        Store::factory()->create(['name' => 'Different Store', 'status' => StoreStatus::Active]);

        // Search by Instagram URL - should extract username and find store
        $response = $this->getJson('/api/v1/stores/search?q='.urlencode('https://www.instagram.com/shoptest/'));

        $response->assertStatus(200)
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.name', 'URL Extract Store');
    }

    // ==========================================
    // show() Tests - Get store by slug
    // ==========================================

    public function test_can_get_store_by_slug(): void
    {
        $store = Store::factory()->create([
            'slug' => 'my-test-store',
            'status' => StoreStatus::Active,
        ]);
        $store->categories()->attach($this->category->id);

        $response = $this->getJson('/api/v1/stores/my-test-store');

        $response->assertStatus(200)
            ->assertJsonPath('data.slug', 'my-test-store')
            ->assertJsonPath('data.id', $store->id);
    }

    public function test_show_returns_404_for_nonexistent_store(): void
    {
        $response = $this->getJson('/api/v1/stores/nonexistent-store-slug');

        $response->assertStatus(404);
    }

    public function test_show_returns_404_for_inactive_store(): void
    {
        $store = Store::factory()->create([
            'slug' => 'suspended-store',
            'status' => StoreStatus::Suspended,
        ]);

        $response = $this->getJson('/api/v1/stores/suspended-store');

        $response->assertStatus(404);
    }

    public function test_show_includes_related_data(): void
    {
        $store = Store::factory()->create([
            'slug' => 'detailed-store',
            'status' => StoreStatus::Active,
            'submitted_by' => $this->user->id,
        ]);
        $store->categories()->attach($this->category->id);
        $store->links()->create([
            'platform' => Platform::Instagram,
            'url' => 'https://instagram.com/detailedstore',
            'handle' => 'detailedstore',
        ]);
        $store->contacts()->create([
            'whatsapp' => '+213555111222',
            'phone' => '+213555333444',
        ]);

        $response = $this->getJson('/api/v1/stores/detailed-store');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'data' => [
                    'id',
                    'name',
                    'slug',
                    'description',
                    'city',
                    'status',
                    'is_verified',
                    'avg_rating',
                    'reviews_count',
                    'categories',
                    'links',
                    'contacts',
                ],
            ]);
    }

    public function test_show_includes_categories(): void
    {
        $categories = Category::factory()->count(3)->create();
        $store = Store::factory()->create([
            'slug' => 'multi-category-store',
            'status' => StoreStatus::Active,
        ]);
        $store->categories()->attach($categories->pluck('id'));

        $response = $this->getJson('/api/v1/stores/multi-category-store');

        $response->assertStatus(200)
            ->assertJsonCount(3, 'data.categories');
    }

    public function test_show_includes_multiple_links(): void
    {
        $store = Store::factory()->create([
            'slug' => 'store-with-links',
            'status' => StoreStatus::Active,
        ]);
        $store->links()->createMany([
            ['platform' => Platform::Instagram, 'url' => 'https://instagram.com/store'],
            ['platform' => Platform::Facebook, 'url' => 'https://facebook.com/store'],
            ['platform' => Platform::Website, 'url' => 'https://store.com'],
        ]);

        $response = $this->getJson('/api/v1/stores/store-with-links');

        $response->assertStatus(200)
            ->assertJsonCount(3, 'data.links');
    }

    // ==========================================
    // summary() Tests - Get store summary
    // ==========================================

    public function test_can_get_store_summary(): void
    {
        $store = Store::factory()->create([
            'slug' => 'summary-store',
            'status' => StoreStatus::Active,
            'is_verified' => true,
            'avg_rating_cache' => 4.5,
            'reviews_count_cache' => 25,
        ]);

        $response = $this->getJson('/api/v1/stores/summary-store/summary');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'data' => [
                    'avg_rating',
                    'reviews_count',
                    'is_verified',
                    'rating_breakdown',
                    'proof_badge',
                ],
            ])
            ->assertJsonPath('data.avg_rating', 4.5)
            ->assertJsonPath('data.reviews_count', 25)
            ->assertJsonPath('data.is_verified', true);
    }

    public function test_summary_includes_rating_breakdown(): void
    {
        $store = Store::factory()->create([
            'slug' => 'breakdown-store',
            'status' => StoreStatus::Active,
        ]);

        // Create reviews with different star ratings
        Review::factory()->count(3)->create([
            'store_id' => $store->id,
            'stars' => 5,
            'status' => ReviewStatus::Approved,
        ]);
        Review::factory()->count(2)->create([
            'store_id' => $store->id,
            'stars' => 4,
            'status' => ReviewStatus::Approved,
        ]);
        Review::factory()->create([
            'store_id' => $store->id,
            'stars' => 3,
            'status' => ReviewStatus::Approved,
        ]);
        Review::factory()->create([
            'store_id' => $store->id,
            'stars' => 1,
            'status' => ReviewStatus::Approved,
        ]);

        // Pending reviews should not be counted
        Review::factory()->create([
            'store_id' => $store->id,
            'stars' => 5,
            'status' => ReviewStatus::Pending,
        ]);

        $response = $this->getJson('/api/v1/stores/breakdown-store/summary');

        $response->assertStatus(200);

        $breakdown = $response->json('data.rating_breakdown');
        $this->assertEquals(1, $breakdown['1']);
        $this->assertEquals(0, $breakdown['2']);
        $this->assertEquals(1, $breakdown['3']);
        $this->assertEquals(2, $breakdown['4']);
        $this->assertEquals(3, $breakdown['5']);
    }

    public function test_summary_returns_404_for_nonexistent_store(): void
    {
        $response = $this->getJson('/api/v1/stores/nonexistent-store/summary');

        $response->assertStatus(404);
    }

    public function test_summary_returns_404_for_inactive_store(): void
    {
        $store = Store::factory()->create([
            'slug' => 'inactive-summary-store',
            'status' => StoreStatus::Suspended,
        ]);

        $response = $this->getJson('/api/v1/stores/inactive-summary-store/summary');

        $response->assertStatus(404);
    }

    public function test_summary_shows_proof_badge_when_store_has_approved_proofs(): void
    {
        $store = Store::factory()->create([
            'slug' => 'proof-badge-store',
            'status' => StoreStatus::Active,
        ]);

        $review = Review::factory()->create([
            'store_id' => $store->id,
            'status' => ReviewStatus::Approved,
        ]);

        ReviewProof::create([
            'review_id' => $review->id,
            'file_path' => 'proofs/test-proof.jpg',
            'status' => ProofStatus::Approved,
        ]);

        $response = $this->getJson('/api/v1/stores/proof-badge-store/summary');

        $response->assertStatus(200)
            ->assertJsonPath('data.proof_badge', true);
    }

    public function test_summary_shows_no_proof_badge_without_approved_proofs(): void
    {
        $store = Store::factory()->create([
            'slug' => 'no-proof-badge-store',
            'status' => StoreStatus::Active,
        ]);

        $review = Review::factory()->create([
            'store_id' => $store->id,
            'status' => ReviewStatus::Approved,
        ]);

        // Create a pending proof (not approved)
        ReviewProof::create([
            'review_id' => $review->id,
            'file_path' => 'proofs/test-proof.jpg',
            'status' => ProofStatus::Pending,
        ]);

        $response = $this->getJson('/api/v1/stores/no-proof-badge-store/summary');

        $response->assertStatus(200)
            ->assertJsonPath('data.proof_badge', false);
    }

    public function test_summary_returns_zero_values_for_new_store(): void
    {
        $store = Store::factory()->create([
            'slug' => 'new-store-summary',
            'status' => StoreStatus::Active,
            'avg_rating_cache' => 0,
            'reviews_count_cache' => 0,
            'is_verified' => false,
        ]);

        $response = $this->getJson('/api/v1/stores/new-store-summary/summary');

        $response->assertStatus(200)
            ->assertJsonPath('data.avg_rating', 0)
            ->assertJsonPath('data.reviews_count', 0)
            ->assertJsonPath('data.is_verified', false)
            ->assertJsonPath('data.proof_badge', false);

        $breakdown = $response->json('data.rating_breakdown');
        $this->assertEquals(0, $breakdown['1']);
        $this->assertEquals(0, $breakdown['2']);
        $this->assertEquals(0, $breakdown['3']);
        $this->assertEquals(0, $breakdown['4']);
        $this->assertEquals(0, $breakdown['5']);
    }
}
