<?php

namespace App\Models;

use App\Enums\RiskLevel;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Support\Str;

class Category extends Model
{
    use HasFactory;

    protected $fillable = [
        'name_ar',
        'name_fr',
        'name_en',
        'slug',
        'risk_level',
        'icon_key',
        'show_on_home',
    ];

    protected function casts(): array
    {
        return [
            'risk_level' => RiskLevel::class,
            'show_on_home' => 'boolean',
        ];
    }

    /**
     * Check if this category is high risk.
     */
    public function isHighRisk(): bool
    {
        return $this->risk_level === RiskLevel::HighRisk;
    }

    /**
     * Accessor to maintain backward compatibility with is_high_risk.
     */
    public function getIsHighRiskAttribute(): bool
    {
        return $this->isHighRisk();
    }

    protected static function booted(): void
    {
        static::creating(function (Category $category) {
            if (empty($category->slug)) {
                $category->slug = Str::slug($category->name_en);
            }
        });
    }

    public function stores(): BelongsToMany
    {
        return $this->belongsToMany(Store::class, 'store_category');
    }

    public function getNameAttribute(): string
    {
        $locale = app()->getLocale();
        return match ($locale) {
            'ar' => $this->name_ar,
            'fr' => $this->name_fr,
            default => $this->name_en,
        };
    }
}
