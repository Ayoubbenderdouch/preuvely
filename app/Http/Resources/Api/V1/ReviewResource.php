<?php

namespace App\Http\Resources\Api\V1;

use App\Enums\ReplyStatus;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Facades\Storage;

class ReviewResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'stars' => $this->stars,
            'comment' => $this->comment,
            'status' => $this->status->value,
            'is_high_risk' => $this->is_high_risk,
            'user' => [
                'id' => $this->user->id,
                'name' => $this->user->name,
                'avatar' => $this->getUserAvatarUrl(),
            ],
            'reply' => $this->when(
                $this->relationLoaded('reply') && $this->reply?->status === ReplyStatus::Visible,
                fn () => new StoreReplyResource($this->reply)
            ),
            'proof' => new ReviewProofResource($this->whenLoaded('latestProof')),
            'store' => $this->when(
                $this->relationLoaded('store'),
                fn () => [
                    'id' => $this->store->id,
                    'name' => $this->store->name,
                    'slug' => $this->store->slug,
                ]
            ),
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }

    /**
     * Get the user's avatar URL.
     * Handles both external URLs (social auth) and local storage paths.
     */
    private function getUserAvatarUrl(): ?string
    {
        $avatar = $this->user->avatar;

        if (empty($avatar)) {
            return null;
        }

        // If it's already a full URL (from social auth), return as-is
        if (str_starts_with($avatar, 'http://') || str_starts_with($avatar, 'https://')) {
            return $avatar;
        }

        // Otherwise, it's a local storage path
        return Storage::disk('public')->url($avatar);
    }
}
