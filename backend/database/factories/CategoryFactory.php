<?php

namespace Database\Factories;

use App\Enums\RiskLevel;
use App\Models\Category;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Str;

class CategoryFactory extends Factory
{
    protected $model = Category::class;

    public function definition(): array
    {
        $name = fake()->unique()->word();

        return [
            'name_en' => ucfirst($name),
            'name_ar' => $name,
            'name_fr' => $name,
            'slug' => Str::slug($name),
            'risk_level' => fake()->boolean(20) ? RiskLevel::HighRisk : RiskLevel::Normal,
            'icon_key' => null,
        ];
    }

    public function highRisk(): static
    {
        return $this->state(fn () => ['risk_level' => RiskLevel::HighRisk]);
    }

    public function normal(): static
    {
        return $this->state(fn () => ['risk_level' => RiskLevel::Normal]);
    }
}
