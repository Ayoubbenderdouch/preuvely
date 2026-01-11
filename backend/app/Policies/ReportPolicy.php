<?php

namespace App\Policies;

use App\Models\Report;
use App\Models\User;

class ReportPolicy
{
    public function viewAny(User $user): bool
    {
        return $user->hasRole('admin');
    }

    public function view(User $user, Report $report): bool
    {
        return $user->hasRole('admin') || $report->reporter_user_id === $user->id;
    }

    public function create(User $user): bool
    {
        return true;
    }

    public function close(User $user, Report $report): bool
    {
        return $user->hasRole('admin');
    }
}
