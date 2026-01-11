<?php

namespace Tests\Feature;

use App\Enums\ClaimStatus;
use App\Enums\OwnerRole;
use App\Models\Category;
use App\Models\Store;
use App\Models\StoreClaimRequest;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ClaimTest extends TestCase
{
    use RefreshDatabase;

    private User $user;
    private Store $store;

    protected function setUp(): void
    {
        parent::setUp();

        $this->user = User::factory()->create();
        $category = Category::factory()->create();
        $this->store = Store::factory()->create();
        $this->store->categories()->attach($category->id);
    }

    public function test_user_can_submit_claim(): void
    {
        $response = $this->actingAs($this->user, 'sanctum')
            ->postJson("/api/v1/stores/{$this->store->id}/claim", [
                'requester_name' => 'John Doe',
                'requester_phone' => '+213555123456',
                'note' => 'I am the owner of this store and would like to claim it.',
            ]);

        $response->assertStatus(201)
            ->assertJsonPath('data.status', 'pending');

        $this->assertDatabaseHas('store_claim_requests', [
            'store_id' => $this->store->id,
            'user_id' => $this->user->id,
            'requester_name' => 'John Doe',
            'requester_phone' => '+213555123456',
            'status' => ClaimStatus::Pending->value,
        ]);
    }

    public function test_duplicate_pending_claim_rejected(): void
    {
        // Create first claim
        StoreClaimRequest::create([
            'store_id' => $this->store->id,
            'user_id' => $this->user->id,
            'requester_name' => 'John Doe',
            'requester_phone' => '+213555123456',
            'status' => ClaimStatus::Pending,
        ]);

        // Try to submit another claim while previous is pending
        $response = $this->actingAs($this->user, 'sanctum')
            ->postJson("/api/v1/stores/{$this->store->id}/claim", [
                'requester_name' => 'John Doe',
                'requester_phone' => '+213555123456',
                'note' => 'Another claim attempt.',
            ]);

        $response->assertStatus(422)
            ->assertJsonPath('message', 'You have already submitted a pending claim for this store.');
    }

    public function test_user_can_submit_new_claim_after_rejection(): void
    {
        // Create a rejected claim
        StoreClaimRequest::create([
            'store_id' => $this->store->id,
            'user_id' => $this->user->id,
            'requester_name' => 'John Doe',
            'requester_phone' => '+213555123456',
            'status' => ClaimStatus::Rejected,
            'reject_reason' => 'Invalid documentation.',
        ]);

        // User should be able to submit a new claim
        $response = $this->actingAs($this->user, 'sanctum')
            ->postJson("/api/v1/stores/{$this->store->id}/claim", [
                'requester_name' => 'John Doe Updated',
                'requester_phone' => '+213555987654',
                'note' => 'Submitting with correct documentation this time.',
            ]);

        $response->assertStatus(201)
            ->assertJsonPath('data.status', 'pending');
    }

    public function test_existing_owner_cannot_claim_store(): void
    {
        // Make user an owner of the store
        $this->store->owners()->attach($this->user->id, ['role' => OwnerRole::Owner->value]);

        $response = $this->actingAs($this->user, 'sanctum')
            ->postJson("/api/v1/stores/{$this->store->id}/claim", [
                'requester_name' => 'John Doe',
                'requester_phone' => '+213555123456',
                'note' => 'I am already the owner.',
            ]);

        $response->assertStatus(422)
            ->assertJsonPath('message', 'You are already an owner of this store.');
    }

    public function test_unauthenticated_user_cannot_submit_claim(): void
    {
        $response = $this->postJson("/api/v1/stores/{$this->store->id}/claim", [
            'requester_name' => 'John Doe',
            'requester_phone' => '+213555123456',
        ]);

        $response->assertStatus(401);
    }

    public function test_claim_requires_name_and_phone(): void
    {
        $response = $this->actingAs($this->user, 'sanctum')
            ->postJson("/api/v1/stores/{$this->store->id}/claim", [
                'note' => 'Missing required fields.',
            ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['requester_name', 'requester_phone']);
    }

    public function test_user_can_view_their_claims(): void
    {
        // Create some claims for the user
        StoreClaimRequest::create([
            'store_id' => $this->store->id,
            'user_id' => $this->user->id,
            'requester_name' => 'John Doe',
            'requester_phone' => '+213555123456',
            'status' => ClaimStatus::Pending,
        ]);

        $anotherStore = Store::factory()->create();
        StoreClaimRequest::create([
            'store_id' => $anotherStore->id,
            'user_id' => $this->user->id,
            'requester_name' => 'John Doe',
            'requester_phone' => '+213555123456',
            'status' => ClaimStatus::Approved,
        ]);

        $response = $this->actingAs($this->user, 'sanctum')
            ->getJson('/api/v1/claims');

        $response->assertStatus(200)
            ->assertJsonCount(2, 'data');
    }

    public function test_user_cannot_view_other_users_claims(): void
    {
        $anotherUser = User::factory()->create();

        // Create a claim by another user
        StoreClaimRequest::create([
            'store_id' => $this->store->id,
            'user_id' => $anotherUser->id,
            'requester_name' => 'Another User',
            'requester_phone' => '+213555111222',
            'status' => ClaimStatus::Pending,
        ]);

        // Create a claim for the current user
        StoreClaimRequest::create([
            'store_id' => $this->store->id,
            'user_id' => $this->user->id,
            'requester_name' => 'John Doe',
            'requester_phone' => '+213555123456',
            'status' => ClaimStatus::Pending,
        ]);

        $response = $this->actingAs($this->user, 'sanctum')
            ->getJson('/api/v1/claims');

        $response->assertStatus(200)
            ->assertJsonCount(1, 'data');
    }

    public function test_claim_for_nonexistent_store_returns_404(): void
    {
        $response = $this->actingAs($this->user, 'sanctum')
            ->postJson('/api/v1/stores/99999/claim', [
                'requester_name' => 'John Doe',
                'requester_phone' => '+213555123456',
            ]);

        $response->assertStatus(404);
    }

    public function test_note_is_optional_in_claim(): void
    {
        $response = $this->actingAs($this->user, 'sanctum')
            ->postJson("/api/v1/stores/{$this->store->id}/claim", [
                'requester_name' => 'John Doe',
                'requester_phone' => '+213555123456',
            ]);

        $response->assertStatus(201);

        $this->assertDatabaseHas('store_claim_requests', [
            'store_id' => $this->store->id,
            'user_id' => $this->user->id,
            'note' => null,
        ]);
    }
}
