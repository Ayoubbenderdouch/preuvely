<?php

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Facades\Storage;

class StoreListResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'slug' => $this->slug,
            'city' => $this->city,
            'logo' => $this->getLogoUrl(),
            'is_verified' => $this->is_verified ?? false,
            'avg_rating' => round($this->avg_rating_cache ?? 0, 1),
            'reviews_count' => $this->reviews_count_cache ?? 0,
            'categories' => CategoryResource::collection($this->whenLoaded('categories')),
        ];
    }

    private function getLogoUrl(): ?string
    {
        $logo = $this->logo;

        if (empty($logo)) {
            return null;
        }

        if (str_starts_with($logo, 'http://') || str_starts_with($logo, 'https://')) {
            return $logo;
        }

        if (str_starts_with($logo, 'data:image')) {
            return $logo;
        }

        return asset('storage/' . $logo);
    }
}
