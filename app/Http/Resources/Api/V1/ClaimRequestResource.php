<?php

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ClaimRequestResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'store_id' => $this->store_id,
            'store_name' => $this->whenLoaded('store', fn() => $this->store->name),
            'store_slug' => $this->whenLoaded('store', fn() => $this->store->slug),
            'requester_name' => $this->requester_name,
            'requester_phone' => $this->requester_phone,
            'note' => $this->note,
            'status' => $this->status->value,
            'reject_reason' => $this->reject_reason,
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
