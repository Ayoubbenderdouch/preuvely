<?php

namespace App\Policies;

use App\Models\ReviewProof;
use App\Models\User;

class ReviewProofPolicy
{
    public function viewAny(User $user): bool
    {
        return $user->hasRole('admin');
    }

    public function view(User $user, ReviewProof $proof): bool
    {
        return $user->hasRole('admin') || $proof->review->user_id === $user->id;
    }

    public function approve(User $user, ReviewProof $proof): bool
    {
        return $user->hasRole('admin');
    }

    public function reject(User $user, ReviewProof $proof): bool
    {
        return $user->hasRole('admin');
    }
}
