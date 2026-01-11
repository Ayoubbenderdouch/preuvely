<?php

namespace App\Models;

use App\Enums\ReplyStatus;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\MorphMany;

class StoreReply extends Model
{
    use HasFactory;

    protected $fillable = [
        'review_id',
        'store_id',
        'user_id',
        'reply_text',
        'status',
    ];

    protected function casts(): array
    {
        return [
            'status' => ReplyStatus::class,
        ];
    }

    public function review(): BelongsTo
    {
        return $this->belongsTo(Review::class);
    }

    public function store(): BelongsTo
    {
        return $this->belongsTo(Store::class);
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function reports(): MorphMany
    {
        return $this->morphMany(Report::class, 'reportable');
    }

    public function isVisible(): bool
    {
        return $this->status === ReplyStatus::Visible;
    }

    public function scopeVisible($query)
    {
        return $query->where('status', ReplyStatus::Visible);
    }
}
