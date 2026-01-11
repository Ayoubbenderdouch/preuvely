<?php

namespace App\Models;

use App\Enums\ReviewStatus;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Database\Eloquent\Relations\MorphMany;

class Review extends Model
{
    use HasFactory;

    protected $fillable = [
        'store_id',
        'user_id',
        'stars',
        'comment',
        'status',
        'is_high_risk',
        'auto_approved',
        'ip_hash',
        'ua_hash',
        'approved_by',
        'approved_at',
        'rejected_reason',
    ];

    protected function casts(): array
    {
        return [
            'stars' => 'integer',
            'status' => ReviewStatus::class,
            'is_high_risk' => 'boolean',
            'auto_approved' => 'boolean',
            'approved_at' => 'datetime',
        ];
    }

    public function store(): BelongsTo
    {
        return $this->belongsTo(Store::class);
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function approver(): BelongsTo
    {
        return $this->belongsTo(User::class, 'approved_by');
    }

    public function proofs(): HasMany
    {
        return $this->hasMany(ReviewProof::class);
    }

    public function latestProof(): HasOne
    {
        return $this->hasOne(ReviewProof::class)->latestOfMany();
    }

    public function reply(): HasOne
    {
        return $this->hasOne(StoreReply::class);
    }

    public function reports(): MorphMany
    {
        return $this->morphMany(Report::class, 'reportable');
    }

    public function isApproved(): bool
    {
        return $this->status === ReviewStatus::Approved;
    }

    public function isPending(): bool
    {
        return $this->status === ReviewStatus::Pending;
    }

    public function scopeApproved($query)
    {
        return $query->where('status', ReviewStatus::Approved);
    }

    public function scopePending($query)
    {
        return $query->where('status', ReviewStatus::Pending);
    }

    public function scopeHighRisk($query)
    {
        return $query->where('is_high_risk', true);
    }

    public function scopeAutoApproved($query)
    {
        return $query->where('auto_approved', true);
    }

    public function scopeManuallyApproved($query)
    {
        return $query->where('status', ReviewStatus::Approved)
            ->where('auto_approved', false);
    }

    public function scopeHighRiskPending($query)
    {
        return $query->where('is_high_risk', true)
            ->where('status', ReviewStatus::Pending);
    }

    public function isAutoApproved(): bool
    {
        return $this->auto_approved;
    }

    public function wasManuallyApproved(): bool
    {
        return $this->status === ReviewStatus::Approved && !$this->auto_approved;
    }
}
