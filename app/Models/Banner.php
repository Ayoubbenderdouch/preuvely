<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Storage;

class Banner extends Model
{
    use HasFactory;

    /**
     * Default attribute values
     */
    protected $attributes = [
        'image_url' => '',
    ];

    protected $fillable = [
        'title',
        'title_ar',
        'title_fr',
        'subtitle',
        'subtitle_ar',
        'subtitle_fr',
        'image_url',
        'image_data',
        'link_type',
        'link_value',
        'background_color',
        'sort_order',
        'is_active',
        'starts_at',
        'ends_at',
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'starts_at' => 'datetime',
        'ends_at' => 'datetime',
    ];

    /**
     * Scope: Only active banners within date range
     */
    public function scopeActive($query)
    {
        return $query->where('is_active', true)
            ->where(function ($q) {
                $q->whereNull('starts_at')
                    ->orWhere('starts_at', '<=', now());
            })
            ->where(function ($q) {
                $q->whereNull('ends_at')
                    ->orWhere('ends_at', '>=', now());
            });
    }

    /**
     * Scope: Ordered by sort_order
     */
    public function scopeOrdered($query)
    {
        return $query->orderBy('sort_order')->orderByDesc('created_at');
    }

    /**
     * Get full image URL (returns base64 data URL if available)
     */
    public function getFullImageUrlAttribute(): ?string
    {
        // Prioritize base64 stored image
        if (!empty($this->image_data)) {
            return $this->image_data;
        }

        if (empty($this->image_url)) {
            return null;
        }

        // External URL
        if (str_starts_with($this->image_url, 'http')) {
            return $this->image_url;
        }

        // Local storage fallback
        try {
            return Storage::disk('public')->url($this->image_url);
        } catch (\Exception $e) {
            return config('app.url') . '/storage/' . $this->image_url;
        }
    }

    /**
     * Get localized title
     */
    public function getLocalizedTitle(string $locale = 'en'): string
    {
        return match ($locale) {
            'ar' => $this->title_ar ?? $this->title ?? '',
            'fr' => $this->title_fr ?? $this->title ?? '',
            default => $this->title ?? '',
        };
    }

    /**
     * Get localized subtitle
     */
    public function getLocalizedSubtitle(string $locale = 'en'): ?string
    {
        return match ($locale) {
            'ar' => $this->subtitle_ar ?? $this->subtitle,
            'fr' => $this->subtitle_fr ?? $this->subtitle,
            default => $this->subtitle,
        };
    }
}
