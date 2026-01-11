<?php

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserProfileResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'avatar' => $this->avatar ? asset('storage/' . $this->avatar) : null,
            'member_since' => $this->created_at?->toIso8601String(),
            'stats' => [
                'stores_count' => $this->submitted_stores_count ?? 0,
                'reviews_count' => $this->approved_reviews_count ?? 0,
            ],
            'submitted_stores' => StoreListResource::collection($this->whenLoaded('submittedStores')),
            'reviews' => ReviewResource::collection($this->whenLoaded('approvedReviews')),
        ];
    }
}
