<?php

namespace App\Policies;

use App\Models\StoreClaimRequest;
use App\Models\User;

class StoreClaimRequestPolicy
{
    public function viewAny(User $user): bool
    {
        return $user->hasRole('admin');
    }

    public function view(User $user, StoreClaimRequest $claim): bool
    {
        return $user->hasRole('admin') || $claim->user_id === $user->id;
    }

    public function approve(User $user, StoreClaimRequest $claim): bool
    {
        return $user->hasRole('admin');
    }

    public function reject(User $user, StoreClaimRequest $claim): bool
    {
        return $user->hasRole('admin');
    }
}
