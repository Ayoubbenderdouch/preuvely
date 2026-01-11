<?php

namespace App\Policies;

use App\Models\Review;
use App\Models\Store;
use App\Models\User;

class ReviewPolicy
{
    public function viewAny(?User $user): bool
    {
        return true;
    }

    public function view(?User $user, Review $review): bool
    {
        return $review->isApproved() || ($user && $review->user_id === $user->id);
    }

    public function create(User $user, Store $store): bool
    {
        // Check if user already has a review for this store
        return !$store->reviews()->where('user_id', $user->id)->exists();
    }

    public function uploadProof(User $user, Review $review): bool
    {
        return $review->user_id === $user->id && $review->is_high_risk;
    }

    public function reply(User $user, Review $review): bool
    {
        $store = $review->store;

        return $store->is_verified
            && $user->isOwnerOf($store)
            && !$review->reply()->exists();
    }

    public function update(User $user, Review $review): bool
    {
        // Allow admin or the review owner to update
        return $user->hasRole('admin') || $review->user_id === $user->id;
    }

    public function delete(User $user, Review $review): bool
    {
        return $user->hasRole('admin');
    }

    public function approve(User $user, Review $review): bool
    {
        return $user->hasRole('admin');
    }

    public function reject(User $user, Review $review): bool
    {
        return $user->hasRole('admin');
    }
}
