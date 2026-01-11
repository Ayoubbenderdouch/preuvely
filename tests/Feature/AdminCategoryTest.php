<?php

namespace Tests\Feature;

use App\Enums\RiskLevel;
use App\Models\Category;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Spatie\Permission\Models\Role;
use Tests\TestCase;

class AdminCategoryTest extends TestCase
{
    use RefreshDatabase;

    private User $admin;
    private User $user;
    private Category $category;

    protected function setUp(): void
    {
        parent::setUp();

        // Create admin role
        Role::create(['name' => 'admin']);

        $this->admin = User::factory()->create();
        $this->admin->assignRole('admin');

        $this->user = User::factory()->create();

        $this->category = Category::factory()->create([
            'risk_level' => RiskLevel::Normal,
        ]);
    }

    public function test_admin_can_update_category_risk_level_to_high_risk(): void
    {
        $response = $this->actingAs($this->admin, 'sanctum')
            ->putJson("/api/v1/admin/categories/{$this->category->id}/risk-level", [
                'risk_level' => 'high_risk',
            ]);

        $response->assertStatus(200)
            ->assertJsonPath('message', 'Category risk level updated successfully.')
            ->assertJsonPath('data.risk_level', 'high_risk')
            ->assertJsonPath('data.is_high_risk', true);

        $this->assertDatabaseHas('categories', [
            'id' => $this->category->id,
            'risk_level' => RiskLevel::HighRisk->value,
        ]);
    }

    public function test_admin_can_update_category_risk_level_to_normal(): void
    {
        // First set to high risk
        $this->category->update(['risk_level' => RiskLevel::HighRisk]);

        $response = $this->actingAs($this->admin, 'sanctum')
            ->putJson("/api/v1/admin/categories/{$this->category->id}/risk-level", [
                'risk_level' => 'normal',
            ]);

        $response->assertStatus(200)
            ->assertJsonPath('message', 'Category risk level updated successfully.')
            ->assertJsonPath('data.risk_level', 'normal')
            ->assertJsonPath('data.is_high_risk', false);

        $this->assertDatabaseHas('categories', [
            'id' => $this->category->id,
            'risk_level' => RiskLevel::Normal->value,
        ]);
    }

    public function test_non_admin_cannot_update_category_risk_level(): void
    {
        $response = $this->actingAs($this->user, 'sanctum')
            ->putJson("/api/v1/admin/categories/{$this->category->id}/risk-level", [
                'risk_level' => 'high_risk',
            ]);

        $response->assertStatus(403);

        // Verify category was not updated
        $this->assertDatabaseHas('categories', [
            'id' => $this->category->id,
            'risk_level' => RiskLevel::Normal->value,
        ]);
    }

    public function test_unauthenticated_user_cannot_update_category_risk_level(): void
    {
        $response = $this->putJson("/api/v1/admin/categories/{$this->category->id}/risk-level", [
            'risk_level' => 'high_risk',
        ]);

        $response->assertStatus(401);
    }

    public function test_update_risk_level_validation_requires_valid_value(): void
    {
        $response = $this->actingAs($this->admin, 'sanctum')
            ->putJson("/api/v1/admin/categories/{$this->category->id}/risk-level", [
                'risk_level' => 'invalid_value',
            ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors('risk_level');
    }

    public function test_update_risk_level_validation_requires_risk_level(): void
    {
        $response = $this->actingAs($this->admin, 'sanctum')
            ->putJson("/api/v1/admin/categories/{$this->category->id}/risk-level", []);

        $response->assertStatus(422)
            ->assertJsonValidationErrors('risk_level');
    }

    public function test_update_risk_level_returns_404_for_non_existent_category(): void
    {
        $response = $this->actingAs($this->admin, 'sanctum')
            ->putJson("/api/v1/admin/categories/99999/risk-level", [
                'risk_level' => 'high_risk',
            ]);

        $response->assertStatus(404);
    }
}
