<?php

namespace App\Models;

use App\Enums\ProofStatus;
use App\Enums\ReviewStatus;
use App\Enums\RiskLevel;
use App\Enums\StoreStatus;
use App\Services\DuplicateStoreDetectionService;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Support\Str;

class Store extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'slug',
        'description',
        'city',
        'logo',
        'logo_data',
        'status',
        'is_verified',
        'verified_at',
        'verified_by',
        'avg_rating_cache',
        'reviews_count_cache',
        'submitted_by',
    ];

    protected function casts(): array
    {
        return [
            'status' => StoreStatus::class,
            'is_verified' => 'boolean',
            'verified_at' => 'datetime',
            'avg_rating_cache' => 'float',
            'reviews_count_cache' => 'integer',
        ];
    }

    protected static function booted(): void
    {
        static::creating(function (Store $store) {
            if (empty($store->slug)) {
                $store->slug = Str::slug($store->name) . '-' . Str::random(6);
            }
        });
    }

    public function categories(): BelongsToMany
    {
        return $this->belongsToMany(Category::class, 'store_category');
    }

    public function links(): HasMany
    {
        return $this->hasMany(StoreLink::class);
    }

    public function contacts(): HasOne
    {
        return $this->hasOne(StoreContact::class);
    }

    public function owners(): BelongsToMany
    {
        return $this->belongsToMany(User::class, 'store_owners')
            ->withPivot('role')
            ->withTimestamps();
    }

    public function claimRequests(): HasMany
    {
        return $this->hasMany(StoreClaimRequest::class);
    }

    public function reviews(): HasMany
    {
        return $this->hasMany(Review::class);
    }

    public function approvedReviews(): HasMany
    {
        return $this->hasMany(Review::class)->where('status', ReviewStatus::Approved);
    }

    public function replies(): HasMany
    {
        return $this->hasMany(StoreReply::class);
    }

    public function verifiedByUser(): BelongsTo
    {
        return $this->belongsTo(User::class, 'verified_by');
    }

    public function submittedBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'submitted_by');
    }

    /**
     * Check if any of the store's categories is high risk.
     * A store is considered high risk if ANY of its categories has risk_level = 'high_risk'.
     */
    public function isHighRisk(): bool
    {
        return $this->categories()->where('risk_level', RiskLevel::HighRisk)->exists();
    }

    public function recalculateRatings(): void
    {
        $approved = $this->approvedReviews();
        $this->reviews_count_cache = $approved->count();
        $this->avg_rating_cache = $approved->avg('stars') ?? 0;
        $this->save();
    }

    public function scopeActive($query)
    {
        return $query->where('status', StoreStatus::Active);
    }

    public function scopeVerified($query)
    {
        return $query->where('is_verified', true);
    }

    /**
     * Get the rating breakdown for the store.
     * Returns an array with counts for each star rating (1-5).
     */
    public function getRatingBreakdown(): array
    {
        $breakdown = $this->approvedReviews()
            ->selectRaw('stars, COUNT(*) as count')
            ->groupBy('stars')
            ->pluck('count', 'stars')
            ->toArray();

        return [
            '1' => $breakdown[1] ?? 0,
            '2' => $breakdown[2] ?? 0,
            '3' => $breakdown[3] ?? 0,
            '4' => $breakdown[4] ?? 0,
            '5' => $breakdown[5] ?? 0,
        ];
    }

    /**
     * Check if the store has any approved proofs.
     */
    public function hasApprovedProofs(): bool
    {
        return $this->approvedReviews()
            ->whereHas('proofs', function ($query) {
                $query->where('status', ProofStatus::Approved);
            })
            ->exists();
    }

    /**
     * Get the normalized name for duplicate detection.
     */
    public function getNormalizedNameAttribute(): string
    {
        return app(DuplicateStoreDetectionService::class)->normalizeName($this->name);
    }

    /**
     * Find potential duplicate stores by name.
     *
     * @return \Illuminate\Support\Collection<Store>
     */
    public static function findPotentialDuplicatesByName(string $name): \Illuminate\Support\Collection
    {
        return app(DuplicateStoreDetectionService::class)->findByName($name);
    }

    /**
     * Find potential duplicate stores by social handle.
     *
     * @return \Illuminate\Support\Collection<Store>
     */
    public static function findPotentialDuplicatesByHandle(string $handle, ?string $platform = null): \Illuminate\Support\Collection
    {
        return app(DuplicateStoreDetectionService::class)->findByHandle($handle, $platform);
    }

    /**
     * Get the full logo URL (returns base64 data URL if available, like Banner model)
     */
    public function getFullLogoUrlAttribute(): ?string
    {
        // Prioritize base64 stored image (works on Laravel Cloud)
        if (!empty($this->logo_data)) {
            return $this->logo_data;
        }

        if (empty($this->logo)) {
            return null;
        }

        // External URL
        if (str_starts_with($this->logo, 'http')) {
            return $this->logo;
        }

        // Base64 data URL stored in logo field
        if (str_starts_with($this->logo, 'data:image')) {
            return $this->logo;
        }

        // Local storage path - fallback (won't work on Laravel Cloud)
        return asset('storage/' . $this->logo);
    }
}
