<?php

namespace Tests\Feature;

use App\Enums\OwnerRole;
use App\Enums\ReviewStatus;
use App\Models\Category;
use App\Models\Review;
use App\Models\Store;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class StoreReplyTest extends TestCase
{
    use RefreshDatabase;

    private User $owner;
    private Store $store;
    private Review $review;

    protected function setUp(): void
    {
        parent::setUp();

        $this->owner = User::factory()->create();
        $category = Category::factory()->create();
        $this->store = Store::factory()->verified()->create();
        $this->store->categories()->attach($category->id);

        // Make user an owner
        $this->store->owners()->attach($this->owner->id, ['role' => OwnerRole::Owner->value]);

        $this->review = Review::factory()->create([
            'store_id' => $this->store->id,
            'status' => ReviewStatus::Approved,
        ]);
    }

    public function test_verified_store_owner_can_reply_to_review(): void
    {
        $response = $this->actingAs($this->owner, 'sanctum')
            ->postJson("/api/v1/reviews/{$this->review->id}/reply", [
                'reply_text' => 'Thank you for your feedback!',
            ]);

        $response->assertStatus(201)
            ->assertJsonPath('data.reply_text', 'Thank you for your feedback!');

        $this->assertDatabaseHas('store_replies', [
            'review_id' => $this->review->id,
            'store_id' => $this->store->id,
            'user_id' => $this->owner->id,
        ]);
    }

    public function test_non_owner_cannot_reply_to_review(): void
    {
        $nonOwner = User::factory()->create();

        $response = $this->actingAs($nonOwner, 'sanctum')
            ->postJson("/api/v1/reviews/{$this->review->id}/reply", [
                'reply_text' => 'I should not be able to reply!',
            ]);

        $response->assertStatus(403)
            ->assertJsonPath('message', 'Only store owners can reply to reviews.');
    }

    public function test_unverified_store_owner_cannot_reply(): void
    {
        // Make store unverified
        $this->store->update(['is_verified' => false, 'verified_at' => null]);

        $response = $this->actingAs($this->owner, 'sanctum')
            ->postJson("/api/v1/reviews/{$this->review->id}/reply", [
                'reply_text' => 'Store is not verified!',
            ]);

        $response->assertStatus(403)
            ->assertJsonPath('message', 'Store must be verified to reply to reviews.');
    }

    public function test_cannot_reply_twice_to_same_review(): void
    {
        // First reply
        $this->actingAs($this->owner, 'sanctum')
            ->postJson("/api/v1/reviews/{$this->review->id}/reply", [
                'reply_text' => 'First reply!',
            ]);

        // Second reply attempt
        $response = $this->actingAs($this->owner, 'sanctum')
            ->postJson("/api/v1/reviews/{$this->review->id}/reply", [
                'reply_text' => 'Second reply attempt!',
            ]);

        $response->assertStatus(422)
            ->assertJsonPath('message', 'A reply already exists for this review.');
    }

    public function test_reply_text_max_length_is_300(): void
    {
        $longReply = str_repeat('a', 301);

        $response = $this->actingAs($this->owner, 'sanctum')
            ->postJson("/api/v1/reviews/{$this->review->id}/reply", [
                'reply_text' => $longReply,
            ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors('reply_text');
    }
}
