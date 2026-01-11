<?php

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Facades\Storage;

class UserResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'email' => $this->email,
            'phone' => $this->phone,
            'email_verified' => $this->hasVerifiedEmail(),
            'avatar' => $this->getAvatarUrl(),
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }

    /**
     * Get the full avatar URL using Storage facade
     */
    private function getAvatarUrl(): ?string
    {
        if (empty($this->avatar)) {
            return null;
        }

        // If avatar already starts with http, return as-is
        if (str_starts_with($this->avatar, 'http')) {
            return $this->avatar;
        }

        // Use Storage facade to generate proper URL
        try {
            return Storage::disk('public')->url($this->avatar);
        } catch (\Exception $e) {
            // Fallback: construct URL manually
            return config('app.url') . '/storage/' . $this->avatar;
        }
    }
}
