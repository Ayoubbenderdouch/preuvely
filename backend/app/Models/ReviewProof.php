<?php

namespace App\Models;

use App\Enums\ProofStatus;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Facades\Storage;

class ReviewProof extends Model
{
    use HasFactory;

    protected $fillable = [
        'review_id',
        'file_path',
        'status',
        'reviewed_by',
        'reviewed_at',
        'rejected_reason',
    ];

    protected function casts(): array
    {
        return [
            'status' => ProofStatus::class,
            'reviewed_at' => 'datetime',
        ];
    }

    public function review(): BelongsTo
    {
        return $this->belongsTo(Review::class);
    }

    public function reviewer(): BelongsTo
    {
        return $this->belongsTo(User::class, 'reviewed_by');
    }

    public function getUrlAttribute(): string
    {
        return Storage::disk('public')->url($this->file_path);
    }

    public function isPending(): bool
    {
        return $this->status === ProofStatus::Pending;
    }

    public function isApproved(): bool
    {
        return $this->status === ProofStatus::Approved;
    }
}
