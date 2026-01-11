<?php

namespace Database\Factories;

use App\Enums\StoreStatus;
use App\Models\Store;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Str;

class StoreFactory extends Factory
{
    protected $model = Store::class;

    public function definition(): array
    {
        $name = fake()->company();

        return [
            'name' => $name,
            'slug' => Str::slug($name) . '-' . Str::random(6),
            'description' => fake()->paragraph(),
            'city' => fake()->randomElement(['Algiers', 'Oran', 'Constantine', 'Annaba', 'Blida']),
            'status' => StoreStatus::Active,
            'is_verified' => fake()->boolean(30),
            'verified_at' => fn (array $attrs) => $attrs['is_verified'] ? now() : null,
            'avg_rating_cache' => fake()->randomFloat(2, 1, 5),
            'reviews_count_cache' => fake()->numberBetween(0, 100),
        ];
    }

    public function verified(): static
    {
        return $this->state(fn () => [
            'is_verified' => true,
            'verified_at' => now(),
        ]);
    }

    public function suspended(): static
    {
        return $this->state(fn () => [
            'status' => StoreStatus::Suspended,
        ]);
    }
}
