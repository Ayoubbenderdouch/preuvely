<?php

namespace Tests\Feature;

use App\Enums\OwnerRole;
use App\Enums\ReviewStatus;
use App\Enums\RiskLevel;
use App\Models\Category;
use App\Models\Review;
use App\Models\Store;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class ReviewTest extends TestCase
{
    use RefreshDatabase;

    private User $user;
    private Store $store;

    protected function setUp(): void
    {
        parent::setUp();

        $this->user = User::factory()->create();
        $category = Category::factory()->create(['risk_level' => RiskLevel::Normal]);
        $this->store = Store::factory()->create();
        $this->store->categories()->attach($category->id);

        // Clear rate limits for each test
        RateLimiter::clear("reviews:{$this->user->id}");
    }

    public function test_user_can_create_review(): void
    {
        $response = $this->actingAs($this->user, 'sanctum')
            ->postJson("/api/v1/stores/{$this->store->id}/reviews", [
                'stars' => 5,
                'comment' => 'This is a great store with excellent service!',
            ]);

        $response->assertStatus(201)
            ->assertJsonPath('data.stars', 5)
            ->assertJsonPath('data.status', 'approved');

        $this->assertDatabaseHas('reviews', [
            'store_id' => $this->store->id,
            'user_id' => $this->user->id,
            'stars' => 5,
        ]);
    }

    public function test_user_cannot_create_duplicate_review_returns_409(): void
    {
        // Create first review
        Review::factory()->create([
            'store_id' => $this->store->id,
            'user_id' => $this->user->id,
        ]);

        // Try to create second review for the same store
        $response = $this->actingAs($this->user, 'sanctum')
            ->postJson("/api/v1/stores/{$this->store->id}/reviews", [
                'stars' => 4,
                'comment' => 'Another review attempt for the same store.',
            ]);

        // Controller returns 409 Conflict for duplicate reviews
        $response->assertStatus(409)
            ->assertJsonPath('message', 'You have already reviewed this store');
    }

    public function test_high_risk_review_is_pending(): void
    {
        // Create high-risk category and attach to store
        $highRiskCategory = Category::factory()->create(['risk_level' => RiskLevel::HighRisk]);
        $this->store->categories()->attach($highRiskCategory->id);

        $response = $this->actingAs($this->user, 'sanctum')
            ->postJson("/api/v1/stores/{$this->store->id}/reviews", [
                'stars' => 5,
                'comment' => 'Great crypto exchange with fast transactions!',
            ]);

        $response->assertStatus(201)
            ->assertJsonPath('requires_proof', true)
            ->assertJsonPath('data.status', 'pending')
            ->assertJsonPath('data.is_high_risk', true);

        $this->assertDatabaseHas('reviews', [
            'store_id' => $this->store->id,
            'user_id' => $this->user->id,
            'status' => ReviewStatus::Pending->value,
            'is_high_risk' => true,
        ]);
    }

    public function test_only_owner_can_upload_proof(): void
    {
        Storage::fake('public');

        // Create a high-risk review
        $highRiskCategory = Category::factory()->create(['risk_level' => RiskLevel::HighRisk]);
        $this->store->categories()->attach($highRiskCategory->id);

        $review = Review::factory()->create([
            'store_id' => $this->store->id,
            'user_id' => $this->user->id,
            'status' => ReviewStatus::Pending,
            'is_high_risk' => true,
        ]);

        $proofFile = UploadedFile::fake()->image('proof.jpg', 800, 600);

        // Test 1: Review owner can upload proof
        $response = $this->actingAs($this->user, 'sanctum')
            ->postJson("/api/v1/reviews/{$review->id}/proof", [
                'proof' => $proofFile,
            ]);

        $response->assertStatus(201)
            ->assertJsonPath('data.status', 'pending');

        // Test 2: Non-owner cannot upload proof
        $anotherUser = User::factory()->create();
        $newProofFile = UploadedFile::fake()->image('proof2.jpg', 800, 600);

        $response = $this->actingAs($anotherUser, 'sanctum')
            ->postJson("/api/v1/reviews/{$review->id}/proof", [
                'proof' => $newProofFile,
            ]);

        $response->assertStatus(403)
            ->assertJsonPath('message', 'Not authorized to upload proof for this review.');
    }

    public function test_review_rate_limit_works(): void
    {
        $category = Category::factory()->create(['risk_level' => RiskLevel::Normal]);

        // Create 5 stores and post reviews (max allowed per day)
        for ($i = 0; $i < 5; $i++) {
            $store = Store::factory()->create();
            $store->categories()->attach($category->id);

            $response = $this->actingAs($this->user, 'sanctum')
                ->postJson("/api/v1/stores/{$store->id}/reviews", [
                    'stars' => 5,
                    'comment' => "Review number " . ($i + 1) . " for testing purposes.",
                ]);

            $response->assertStatus(201);
        }

        // 6th review should be rate limited
        $store = Store::factory()->create();
        $store->categories()->attach($category->id);

        $response = $this->actingAs($this->user, 'sanctum')
            ->postJson("/api/v1/stores/{$store->id}/reviews", [
                'stars' => 4,
                'comment' => 'This should be rate limited!',
            ]);

        $response->assertStatus(429)
            ->assertJsonPath('message', 'Daily review limit reached. You can submit up to 5 reviews per day.');
    }

    public function test_review_validation_requires_minimum_comment_length(): void
    {
        $response = $this->actingAs($this->user, 'sanctum')
            ->postJson("/api/v1/stores/{$this->store->id}/reviews", [
                'stars' => 5,
                'comment' => 'Short',
            ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors('comment');
    }

    public function test_review_stars_must_be_between_1_and_5(): void
    {
        $response = $this->actingAs($this->user, 'sanctum')
            ->postJson("/api/v1/stores/{$this->store->id}/reviews", [
                'stars' => 6,
                'comment' => 'This is a valid comment length for testing.',
            ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors('stars');
    }

    public function test_unauthenticated_user_cannot_create_review(): void
    {
        $response = $this->postJson("/api/v1/stores/{$this->store->id}/reviews", [
            'stars' => 5,
            'comment' => 'Great store with amazing products!',
        ]);

        $response->assertStatus(401);
    }

    public function test_approved_reviews_are_visible_publicly(): void
    {
        Review::factory()->count(3)->create([
            'store_id' => $this->store->id,
            'status' => ReviewStatus::Approved,
        ]);

        Review::factory()->create([
            'store_id' => $this->store->id,
            'status' => ReviewStatus::Pending,
        ]);

        $response = $this->getJson("/api/v1/stores/{$this->store->id}/reviews");

        $response->assertStatus(200)
            ->assertJsonCount(3, 'data');
    }

    public function test_non_high_risk_review_can_optionally_upload_proof(): void
    {
        // Create a non-high-risk review
        $review = Review::factory()->create([
            'store_id' => $this->store->id,
            'user_id' => $this->user->id,
            'status' => ReviewStatus::Approved,
            'is_high_risk' => false,
        ]);

        Storage::fake('public');
        $proofFile = UploadedFile::fake()->image('proof.jpg', 800, 600);

        // Proof upload is allowed for non-high-risk reviews (optional but adds verified badge)
        $response = $this->actingAs($this->user, 'sanctum')
            ->postJson("/api/v1/reviews/{$review->id}/proof", [
                'proof' => $proofFile,
            ]);

        $response->assertStatus(201)
            ->assertJsonPath('message', 'Proof uploaded successfully. Once approved, your review will show a verified badge.');
    }

    public function test_user_can_check_their_review_for_store(): void
    {
        $review = Review::factory()->create([
            'store_id' => $this->store->id,
            'user_id' => $this->user->id,
            'stars' => 4,
        ]);

        $response = $this->actingAs($this->user, 'sanctum')
            ->getJson("/api/v1/stores/{$this->store->id}/my-review");

        $response->assertStatus(200)
            ->assertJsonPath('has_reviewed', true)
            ->assertJsonPath('data.stars', 4);
    }

    public function test_user_without_review_gets_null(): void
    {
        $response = $this->actingAs($this->user, 'sanctum')
            ->getJson("/api/v1/stores/{$this->store->id}/my-review");

        $response->assertStatus(200)
            ->assertJsonPath('has_reviewed', false)
            ->assertJsonPath('data', null);
    }

    public function test_review_is_auto_approved_for_normal_category(): void
    {
        // Store already has a normal category from setUp
        $response = $this->actingAs($this->user, 'sanctum')
            ->postJson("/api/v1/stores/{$this->store->id}/reviews", [
                'stars' => 5,
                'comment' => 'This is a great store with excellent service!',
            ]);

        $response->assertStatus(201)
            ->assertJsonPath('data.status', 'approved')
            ->assertJsonPath('requires_proof', false);

        $this->assertDatabaseHas('reviews', [
            'store_id' => $this->store->id,
            'user_id' => $this->user->id,
            'status' => ReviewStatus::Approved->value,
            'auto_approved' => true,
        ]);
    }

    public function test_review_is_not_auto_approved_for_high_risk_category(): void
    {
        // Create a store with only high-risk category
        $highRiskStore = Store::factory()->create();
        $highRiskCategory = Category::factory()->create(['risk_level' => RiskLevel::HighRisk]);
        $highRiskStore->categories()->attach($highRiskCategory->id);

        $response = $this->actingAs($this->user, 'sanctum')
            ->postJson("/api/v1/stores/{$highRiskStore->id}/reviews", [
                'stars' => 4,
                'comment' => 'This is a good crypto exchange with fast transactions!',
            ]);

        $response->assertStatus(201)
            ->assertJsonPath('data.status', 'pending')
            ->assertJsonPath('requires_proof', true);

        $this->assertDatabaseHas('reviews', [
            'store_id' => $highRiskStore->id,
            'user_id' => $this->user->id,
            'status' => ReviewStatus::Pending->value,
            'auto_approved' => false,
            'is_high_risk' => true,
        ]);
    }

    public function test_review_not_auto_approved_if_any_category_is_high_risk(): void
    {
        // Store already has a normal category, add a high-risk one
        $highRiskCategory = Category::factory()->create(['risk_level' => RiskLevel::HighRisk]);
        $this->store->categories()->attach($highRiskCategory->id);

        $response = $this->actingAs($this->user, 'sanctum')
            ->postJson("/api/v1/stores/{$this->store->id}/reviews", [
                'stars' => 5,
                'comment' => 'Testing mixed category review approval logic.',
            ]);

        $response->assertStatus(201)
            ->assertJsonPath('data.status', 'pending')
            ->assertJsonPath('requires_proof', true);

        $this->assertDatabaseHas('reviews', [
            'store_id' => $this->store->id,
            'user_id' => $this->user->id,
            'status' => ReviewStatus::Pending->value,
            'auto_approved' => false,
        ]);
    }
}
