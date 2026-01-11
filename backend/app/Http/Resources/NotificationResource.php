<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * Notification resource matching iOS AppNotification model.
 *
 * iOS expects snake_case format for type field:
 * - id: Int
 * - type: NotificationType (snake_case: review_approved, review_rejected, claim_approved, claim_rejected, new_reply, store_verified)
 * - title: String
 * - message: String
 * - is_read: Bool (snake_case, iOS uses convertFromSnakeCase)
 * - created_at: Date (snake_case, iOS uses convertFromSnakeCase)
 * - related_id: Int? (snake_case, iOS uses convertFromSnakeCase)
 * - user_name: String? (snake_case, iOS uses convertFromSnakeCase)
 */
class NotificationResource extends JsonResource
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
            'type' => $this->type, // Keep snake_case for iOS (review_approved, etc.)
            'title' => $this->title,
            'message' => $this->message,
            'is_read' => $this->is_read,
            'created_at' => $this->created_at->toIso8601String(),
            'related_id' => $this->related_id,
            'user_name' => $this->user_name,
        ];
    }
}
