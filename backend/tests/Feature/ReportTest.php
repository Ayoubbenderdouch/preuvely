<?php

namespace Tests\Feature;

use App\Enums\ReportReason;
use App\Enums\ReportStatus;
use App\Enums\ReviewStatus;
use App\Models\Category;
use App\Models\Report;
use App\Models\Review;
use App\Models\Store;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\RateLimiter;
use Tests\TestCase;

class ReportTest extends TestCase
{
    use RefreshDatabase;

    private User $user;
    private Store $store;
    private Review $review;

    protected function setUp(): void
    {
        parent::setUp();

        $this->user = User::factory()->create();

        $category = Category::factory()->create();
        $this->store = Store::factory()->create();
        $this->store->categories()->attach($category->id);

        $this->review = Review::factory()->create([
            'store_id' => $this->store->id,
            'status' => ReviewStatus::Approved,
        ]);

        // Clear rate limits for each test
        RateLimiter::clear("reports:{$this->user->id}");
    }

    public function test_user_can_create_report(): void
    {
        $response = $this->actingAs($this->user, 'sanctum')
            ->postJson('/api/v1/reports', [
                'reportable_type' => 'review',
                'reportable_id' => $this->review->id,
                'reason' => ReportReason::Spam->value,
                'note' => 'This review looks like spam.',
            ]);

        $response->assertStatus(201)
            ->assertJsonPath('data.reason', 'spam')
            ->assertJsonPath('data.status', 'open');

        $this->assertDatabaseHas('reports', [
            'reporter_user_id' => $this->user->id,
            'reportable_type' => Review::class,
            'reportable_id' => $this->review->id,
            'reason' => ReportReason::Spam->value,
        ]);
    }

    public function test_user_can_only_see_own_reports(): void
    {
        // Create reports for the current user
        Report::create([
            'reporter_user_id' => $this->user->id,
            'reportable_type' => Review::class,
            'reportable_id' => $this->review->id,
            'reason' => ReportReason::Spam,
            'status' => ReportStatus::Open,
        ]);

        // Create a second review and report for the user
        $anotherReview = Review::factory()->create([
            'store_id' => $this->store->id,
            'status' => ReviewStatus::Approved,
        ]);
        Report::create([
            'reporter_user_id' => $this->user->id,
            'reportable_type' => Review::class,
            'reportable_id' => $anotherReview->id,
            'reason' => ReportReason::Abuse,
            'status' => ReportStatus::Open,
        ]);

        // Create reports for another user
        $anotherUser = User::factory()->create();
        $thirdReview = Review::factory()->create([
            'store_id' => $this->store->id,
            'status' => ReviewStatus::Approved,
        ]);
        Report::create([
            'reporter_user_id' => $anotherUser->id,
            'reportable_type' => Review::class,
            'reportable_id' => $thirdReview->id,
            'reason' => ReportReason::Fake,
            'status' => ReportStatus::Open,
        ]);

        // User should only see their own 2 reports
        $response = $this->actingAs($this->user, 'sanctum')
            ->getJson('/api/v1/reports');

        $response->assertStatus(200)
            ->assertJsonCount(2, 'data');

        // Verify the reports belong to the user
        $reportIds = collect($response->json('data'))->pluck('id')->toArray();
        $this->assertEquals(2, Report::whereIn('id', $reportIds)->where('reporter_user_id', $this->user->id)->count());
    }

    public function test_user_cannot_report_same_content_twice(): void
    {
        // First report
        $this->actingAs($this->user, 'sanctum')
            ->postJson('/api/v1/reports', [
                'reportable_type' => 'review',
                'reportable_id' => $this->review->id,
                'reason' => ReportReason::Spam->value,
            ]);

        // Second report attempt
        $response = $this->actingAs($this->user, 'sanctum')
            ->postJson('/api/v1/reports', [
                'reportable_type' => 'review',
                'reportable_id' => $this->review->id,
                'reason' => ReportReason::Abuse->value,
            ]);

        $response->assertStatus(422)
            ->assertJsonPath('message', 'You have already reported this content.');
    }

    public function test_report_requires_valid_reportable(): void
    {
        $response = $this->actingAs($this->user, 'sanctum')
            ->postJson('/api/v1/reports', [
                'reportable_type' => 'review',
                'reportable_id' => 9999,
                'reason' => ReportReason::Spam->value,
            ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors('reportable_id');
    }

    public function test_unauthenticated_user_cannot_report(): void
    {
        $response = $this->postJson('/api/v1/reports', [
            'reportable_type' => 'review',
            'reportable_id' => $this->review->id,
            'reason' => ReportReason::Spam->value,
        ]);

        $response->assertStatus(401);
    }

    public function test_user_can_report_store(): void
    {
        $response = $this->actingAs($this->user, 'sanctum')
            ->postJson('/api/v1/reports', [
                'reportable_type' => 'store',
                'reportable_id' => $this->store->id,
                'reason' => ReportReason::Fake->value,
                'note' => 'This store seems fraudulent.',
            ]);

        $response->assertStatus(201)
            ->assertJsonPath('data.reason', 'fake')
            ->assertJsonPath('data.status', 'open');

        $this->assertDatabaseHas('reports', [
            'reporter_user_id' => $this->user->id,
            'reportable_type' => Store::class,
            'reportable_id' => $this->store->id,
            'reason' => ReportReason::Fake->value,
        ]);
    }

    public function test_report_reason_is_required(): void
    {
        $response = $this->actingAs($this->user, 'sanctum')
            ->postJson('/api/v1/reports', [
                'reportable_type' => 'review',
                'reportable_id' => $this->review->id,
            ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors('reason');
    }

    public function test_report_requires_valid_reason(): void
    {
        $response = $this->actingAs($this->user, 'sanctum')
            ->postJson('/api/v1/reports', [
                'reportable_type' => 'review',
                'reportable_id' => $this->review->id,
                'reason' => 'invalid_reason',
            ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors('reason');
    }

    public function test_note_is_optional(): void
    {
        $response = $this->actingAs($this->user, 'sanctum')
            ->postJson('/api/v1/reports', [
                'reportable_type' => 'review',
                'reportable_id' => $this->review->id,
                'reason' => ReportReason::Spam->value,
            ]);

        $response->assertStatus(201);

        $this->assertDatabaseHas('reports', [
            'reporter_user_id' => $this->user->id,
            'reportable_id' => $this->review->id,
            'note' => null,
        ]);
    }

    public function test_different_users_can_report_same_content(): void
    {
        $anotherUser = User::factory()->create();

        // First user reports
        $response1 = $this->actingAs($this->user, 'sanctum')
            ->postJson('/api/v1/reports', [
                'reportable_type' => 'review',
                'reportable_id' => $this->review->id,
                'reason' => ReportReason::Spam->value,
            ]);

        $response1->assertStatus(201);

        // Second user also reports same content
        $response2 = $this->actingAs($anotherUser, 'sanctum')
            ->postJson('/api/v1/reports', [
                'reportable_type' => 'review',
                'reportable_id' => $this->review->id,
                'reason' => ReportReason::Abuse->value,
            ]);

        $response2->assertStatus(201);

        // Both reports should exist
        $this->assertEquals(2, Report::where('reportable_id', $this->review->id)->count());
    }

    public function test_report_rate_limit_works(): void
    {
        // Create 10 reviews to report
        $reviews = [];
        for ($i = 0; $i < 11; $i++) {
            $reviews[] = Review::factory()->create([
                'store_id' => $this->store->id,
                'status' => ReviewStatus::Approved,
            ]);
        }

        // Submit 10 reports (max allowed per day)
        for ($i = 0; $i < 10; $i++) {
            $response = $this->actingAs($this->user, 'sanctum')
                ->postJson('/api/v1/reports', [
                    'reportable_type' => 'review',
                    'reportable_id' => $reviews[$i]->id,
                    'reason' => ReportReason::Spam->value,
                ]);

            $response->assertStatus(201);
        }

        // 11th report should be rate limited
        $response = $this->actingAs($this->user, 'sanctum')
            ->postJson('/api/v1/reports', [
                'reportable_type' => 'review',
                'reportable_id' => $reviews[10]->id,
                'reason' => ReportReason::Spam->value,
            ]);

        $response->assertStatus(429)
            ->assertJsonPath('message', 'Daily report limit reached. You can submit up to 10 reports per day.');
    }

    public function test_unauthenticated_user_cannot_view_reports(): void
    {
        $response = $this->getJson('/api/v1/reports');

        $response->assertStatus(401);
    }
}
