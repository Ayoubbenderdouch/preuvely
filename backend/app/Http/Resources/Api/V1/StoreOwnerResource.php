<?php

namespace App\Http\Resources\Api\V1;

use App\Enums\ReviewStatus;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Facades\Storage;

/**
 * Resource for store owner-specific data.
 *
 * Extends the standard store data with owner-specific information
 * such as the owner's role in the store.
 */
class StoreOwnerResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'slug' => $this->slug,
            'description' => $this->description,
            'city' => $this->city,
            'logo' => $this->logo ? Storage::disk('public')->url($this->logo) : null,
            'status' => $this->status->value,
            'is_verified' => $this->is_verified,
            'avg_rating' => round($this->avg_rating_cache, 1),
            'reviews_count' => $this->reviews_count_cache,

            // Owner-specific data from pivot table
            'owner_role' => $this->whenPivotLoaded('store_owners', function () {
                return $this->pivot->role;
            }),

            // Owner-specific fields for iOS OwnedStore model
            'claim_status' => $this->getClaimStatusForUser($request->user()),
            'pending_reviews_count' => $this->reviews()->where('status', ReviewStatus::Pending)->count(),

            // Related resources
            'is_high_risk' => $this->whenLoaded('categories', fn () => $this->isHighRisk()),
            'categories' => CategoryResource::collection($this->whenLoaded('categories')),
            'links' => StoreLinkResource::collection($this->whenLoaded('links')),
            'contacts' => new StoreContactResource($this->whenLoaded('contacts')),

            // Timestamps
            'created_at' => $this->created_at?->toIso8601String(),
            'updated_at' => $this->updated_at?->toIso8601String(),
        ];
    }

    /**
     * Get the claim status for a specific user on this store.
     *
     * @param User|null $user
     * @return string|null The claim status value (pending, approved, rejected) or null if no claim exists
     */
    protected function getClaimStatusForUser(?User $user): ?string
    {
        if (!$user) {
            return null;
        }

        $claim = $this->claimRequests()
            ->where('user_id', $user->id)
            ->latest()
            ->first();

        return $claim?->status?->value;
    }
}
