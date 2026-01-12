<?php

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Facades\Storage;

class StoreResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        // Check if authenticated user is owner of this store
        // Use auth('sanctum') to check even on public routes
        $isOwner = false;
        $user = auth('sanctum')->user();
        if ($user) {
            $isOwner = $user->isOwnerOf($this->resource);
            // Debug log
            \Log::info('StoreResource isOwner check', [
                'store_id' => $this->id,
                'store_name' => $this->name,
                'user_id' => $user->id,
                'user_name' => $user->name,
                'is_owner' => $isOwner,
                'owned_stores' => $user->ownedStores()->pluck('stores.id')->toArray(),
            ]);
        }

        return [
            'id' => $this->id,
            'name' => $this->name,
            'slug' => $this->slug,
            'description' => $this->description,
            'city' => $this->city,
            'logo' => $this->full_logo_url,
            'status' => $this->status->value,
            'is_verified' => $this->is_verified ?? false,
            'is_owner' => $isOwner,
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
