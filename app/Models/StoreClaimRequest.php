<?php

namespace App\Models;

use App\Enums\ClaimStatus;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class StoreClaimRequest extends Model
{
    use HasFactory;

    protected $fillable = [
        'store_id',
        'user_id',
        'requester_name',
        'requester_phone',
        'note',
        'status',
        'handled_by',
        'handled_at',
        'reject_reason',
    ];

    protected function casts(): array
    {
        return [
            'status' => ClaimStatus::class,
            'handled_at' => 'datetime',
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

    public function handler(): BelongsTo
    {
        return $this->belongsTo(User::class, 'handled_by');
    }

    public function isPending(): bool
    {
        return $this->status === ClaimStatus::Pending;
    }
}
