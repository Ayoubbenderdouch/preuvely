<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Notification extends Model
{
    use HasFactory;

    /**
     * Notification types matching iOS AppNotification.NotificationType
     */
    public const TYPE_REVIEW_APPROVED = 'review_approved';
    public const TYPE_REVIEW_REJECTED = 'review_rejected';
    public const TYPE_CLAIM_APPROVED = 'claim_approved';
    public const TYPE_CLAIM_REJECTED = 'claim_rejected';
    public const TYPE_NEW_REPLY = 'new_reply';
    public const TYPE_STORE_VERIFIED = 'store_verified';

    protected $fillable = [
        'user_id',
        'type',
        'title',
        'message',
        'is_read',
        'related_id',
        'user_name',
    ];

    protected function casts(): array
    {
        return [
            'is_read' => 'boolean',
            'related_id' => 'integer',
        ];
    }

    /**
     * Get the user that owns the notification.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Scope to get unread notifications.
     */
    public function scopeUnread($query)
    {
        return $query->where('is_read', false);
    }

    /**
     * Scope to get read notifications.
     */
    public function scopeRead($query)
    {
        return $query->where('is_read', true);
    }

    /**
     * Mark the notification as read.
     */
    public function markAsRead(): void
    {
        if (!$this->is_read) {
            $this->update(['is_read' => true]);
        }
    }

    /**
     * Get all valid notification types.
     */
    public static function getTypes(): array
    {
        return [
            self::TYPE_REVIEW_APPROVED,
            self::TYPE_REVIEW_REJECTED,
            self::TYPE_CLAIM_APPROVED,
            self::TYPE_CLAIM_REJECTED,
            self::TYPE_NEW_REPLY,
            self::TYPE_STORE_VERIFIED,
        ];
    }

    /**
     * Convert the type to camelCase for iOS compatibility.
     * Backend uses snake_case, iOS expects camelCase.
     */
    public function getTypeCamelCase(): string
    {
        return lcfirst(str_replace('_', '', ucwords($this->type, '_')));
    }
}
