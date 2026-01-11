<?php

namespace App\Services;

use App\Models\Notification;
use App\Models\Review;
use App\Models\Store;
use App\Models\StoreClaimRequest;
use App\Models\User;

class NotificationService
{
    /**
     * Send a notification to a user.
     *
     * @param User $user The user to send the notification to
     * @param string $type The notification type (use Notification::TYPE_* constants)
     * @param string $title The notification title
     * @param string $message The notification message
     * @param int|null $relatedId Optional related entity ID (review ID, store ID, etc.)
     * @param string|null $userName Optional username related to the notification
     * @return Notification
     */
    public static function send(
        User $user,
        string $type,
        string $title,
        string $message,
        ?int $relatedId = null,
        ?string $userName = null
    ): Notification {
        return Notification::create([
            'user_id' => $user->id,
            'type' => $type,
            'title' => $title,
            'message' => $message,
            'related_id' => $relatedId,
            'user_name' => $userName,
        ]);
    }

    /**
     * Send notification when a review is approved.
     *
     * @param Review $review The approved review
     * @return Notification|null Returns null if user doesn't exist
     */
    public static function reviewApproved(Review $review): ?Notification
    {
        if (!$review->user) {
            return null;
        }

        $storeName = $review->store?->name ?? 'a store';

        return self::send(
            user: $review->user,
            type: Notification::TYPE_REVIEW_APPROVED,
            title: 'Review Approved',
            message: "Your review for {$storeName} has been approved and is now visible to others.",
            relatedId: $review->id,
        );
    }

    /**
     * Send notification when a review is rejected.
     *
     * @param Review $review The rejected review
     * @param string|null $reason Optional rejection reason
     * @return Notification|null Returns null if user doesn't exist
     */
    public static function reviewRejected(Review $review, ?string $reason = null): ?Notification
    {
        if (!$review->user) {
            return null;
        }

        $storeName = $review->store?->name ?? 'a store';
        $message = "Your review for {$storeName} was not approved.";
        if ($reason) {
            $message .= " Reason: {$reason}";
        }

        return self::send(
            user: $review->user,
            type: Notification::TYPE_REVIEW_REJECTED,
            title: 'Review Not Approved',
            message: $message,
            relatedId: $review->id,
        );
    }

    /**
     * Send notification when a store claim is approved.
     *
     * @param StoreClaimRequest $claim The approved claim request
     * @return Notification|null Returns null if user doesn't exist
     */
    public static function claimApproved(StoreClaimRequest $claim): ?Notification
    {
        if (!$claim->user) {
            return null;
        }

        $storeName = $claim->store?->name ?? 'the store';

        return self::send(
            user: $claim->user,
            type: Notification::TYPE_CLAIM_APPROVED,
            title: 'Claim Approved',
            message: "Your claim request for {$storeName} has been approved. You are now the store owner and can manage the store.",
            relatedId: $claim->store_id,
        );
    }

    /**
     * Send notification when a store claim is rejected.
     *
     * @param StoreClaimRequest $claim The rejected claim request
     * @param string|null $reason Optional rejection reason
     * @return Notification|null Returns null if user doesn't exist
     */
    public static function claimRejected(StoreClaimRequest $claim, ?string $reason = null): ?Notification
    {
        if (!$claim->user) {
            return null;
        }

        $storeName = $claim->store?->name ?? 'the store';
        $message = "Your claim request for {$storeName} was not approved.";
        if ($reason) {
            $message .= " Reason: {$reason}";
        }

        return self::send(
            user: $claim->user,
            type: Notification::TYPE_CLAIM_REJECTED,
            title: 'Claim Not Approved',
            message: $message,
            relatedId: $claim->store_id,
        );
    }

    /**
     * Send notification when a store receives a reply to a review.
     *
     * @param Review $review The review that received a reply
     * @param string $replierName Name of the person who replied
     * @return Notification|null Returns null if user doesn't exist
     */
    public static function newReply(Review $review, string $replierName): ?Notification
    {
        if (!$review->user) {
            return null;
        }

        $storeName = $review->store?->name ?? 'a store';

        return self::send(
            user: $review->user,
            type: Notification::TYPE_NEW_REPLY,
            title: 'New Reply to Your Review',
            message: "{$replierName} replied to your review for {$storeName}.",
            relatedId: $review->id,
            userName: $replierName,
        );
    }

    /**
     * Send notification when a store is verified.
     * Notifies all store owners.
     *
     * @param Store $store The verified store
     * @return array Array of created notifications
     */
    public static function storeVerified(Store $store): array
    {
        $notifications = [];

        // Notify all store owners
        foreach ($store->owners as $owner) {
            $notifications[] = self::send(
                user: $owner,
                type: Notification::TYPE_STORE_VERIFIED,
                title: 'Store Verified',
                message: "Your store {$store->name} has been verified. You can now respond to reviews.",
                relatedId: $store->id,
            );
        }

        return $notifications;
    }

    /**
     * Send notification to the user who submitted a store when it gets verified.
     *
     * @param Store $store The verified store
     * @return Notification|null Returns null if submitter doesn't exist
     */
    public static function storeVerifiedForSubmitter(Store $store): ?Notification
    {
        if (!$store->submittedBy) {
            return null;
        }

        // Don't send duplicate if submitter is already an owner
        if ($store->owners->contains('id', $store->submitted_by)) {
            return null;
        }

        return self::send(
            user: $store->submittedBy,
            type: Notification::TYPE_STORE_VERIFIED,
            title: 'Store Verified',
            message: "The store {$store->name} that you submitted has been verified.",
            relatedId: $store->id,
        );
    }
}
