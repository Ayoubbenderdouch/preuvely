<?php

namespace Tests\Feature;

use App\Enums\RiskLevel;
use App\Models\Category;
use App\Models\Store;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\RateLimiter;
use Tests\TestCase;

class RateLimitTest extends TestCase
{
    use RefreshDatabase;

    private User $user;

    protected function setUp(): void
    {
        parent::setUp();

        $this->user = User::factory()->create();
        RateLimiter::clear("reviews:{$this->user->id}");
    }

    public function test_user_is_limited_to_5_reviews_per_day(): void
    {
        $category = Category::factory()->create(['risk_level' => RiskLevel::Normal]);

        // Create 5 stores and post reviews
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
}
