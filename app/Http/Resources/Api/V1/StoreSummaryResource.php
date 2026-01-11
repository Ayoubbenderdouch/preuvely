<?php

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class StoreSummaryResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'avg_rating' => round($this->avg_rating_cache ?? 0, 1),
            'reviews_count' => $this->reviews_count_cache ?? 0,
            'is_verified' => $this->is_verified ?? false,
            'rating_breakdown' => (object) $this->getRatingBreakdown(),
            'proof_badge' => $this->hasApprovedProofs(),
        ];
    }
}
