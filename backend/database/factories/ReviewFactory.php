<?php

namespace Database\Factories;

use App\Enums\ReviewStatus;
use App\Models\Review;
use App\Models\Store;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

class ReviewFactory extends Factory
{
    protected $model = Review::class;

    public function definition(): array
    {
        return [
            'store_id' => Store::factory(),
            'user_id' => User::factory(),
            'stars' => fake()->numberBetween(1, 5),
            'comment' => fake()->paragraph(),
            'status' => ReviewStatus::Approved,
            'is_high_risk' => false,
            'auto_approved' => true,
            'ip_hash' => hash('sha256', fake()->ipv4()),
            'ua_hash' => hash('sha256', fake()->userAgent()),
        ];
    }

    public function pending(): static
    {
        return $this->state(fn () => [
            'status' => ReviewStatus::Pending,
            'auto_approved' => false,
        ]);
    }

    public function highRisk(): static
    {
        return $this->state(fn () => [
            'is_high_risk' => true,
            'status' => ReviewStatus::Pending,
            'auto_approved' => false,
        ]);
    }

    public function autoApproved(): static
    {
        return $this->state(fn () => [
            'status' => ReviewStatus::Approved,
            'auto_approved' => true,
            'approved_at' => now(),
        ]);
    }

    public function manuallyApproved(): static
    {
        return $this->state(fn () => [
            'status' => ReviewStatus::Approved,
            'auto_approved' => false,
            'approved_at' => now(),
        ]);
    }
}
