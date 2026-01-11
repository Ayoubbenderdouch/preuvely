<?php

namespace App\Policies;

use App\Models\Store;
use App\Models\User;

class StorePolicy
{
    public function viewAny(?User $user): bool
    {
        return true;
    }

    public function view(?User $user, Store $store): bool
    {
        return true;
    }

    public function create(User $user): bool
    {
        return true;
    }

    public function update(User $user, Store $store): bool
    {
        return $user->hasRole('admin') || $user->isOwnerOf($store);
    }

    public function delete(User $user, Store $store): bool
    {
        return $user->hasRole('admin');
    }

    public function verify(User $user, Store $store): bool
    {
        return $user->hasRole('admin');
    }

    public function suspend(User $user, Store $store): bool
    {
        return $user->hasRole('admin');
    }

    public function claim(User $user, Store $store): bool
    {
        return !$user->isOwnerOf($store);
    }
}
