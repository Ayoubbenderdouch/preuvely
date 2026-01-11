<?php

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Facades\Storage;

class StoreResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'slug' => $this->slug,
            'description' => $this->description,
            'city' => $this->city,
            'logo' => $this->full_logo_url,
            'status' => $this->status->value,
            'is_verified' => $this->is_verified ?? false,
            'avg_rating' => round($this->avg_rating_cache ?? 0, 1),
            'reviews_count' => $this->reviews_count_cache ?? 0,
            'is_high_risk' => $this->whenLoaded('categories', fn () => $this->isHighRisk()),
            'categories' => CategoryResource::collection($this->whenLoaded('categories')),
            'links' => StoreLinkResource::collection($this->whenLoaded('links')),
            'contacts' => $this->whenLoaded('contacts', fn () => $this->contacts ? new StoreContactResource($this->contacts) : null),
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
