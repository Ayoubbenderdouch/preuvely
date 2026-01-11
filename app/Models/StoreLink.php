<?php

namespace App\Models;

use App\Enums\Platform;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class StoreLink extends Model
{
    use HasFactory;

    protected $fillable = [
        'store_id',
        'platform',
        'url',
        'handle',
    ];

    protected function casts(): array
    {
        return [
            'platform' => Platform::class,
        ];
    }

    public function store(): BelongsTo
    {
        return $this->belongsTo(Store::class);
    }
}
