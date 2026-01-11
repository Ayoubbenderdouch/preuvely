<?php

namespace App\Models;

use Filament\Models\Contracts\FilamentUser;
use Filament\Panel;
use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
use Spatie\Permission\Traits\HasRoles;

class User extends Authenticatable implements FilamentUser, MustVerifyEmail
{
    use HasFactory, Notifiable, HasApiTokens, HasRoles;

    protected $fillable = [
        'name',
        'email',
        'phone',
        'password',
        'avatar',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }

    public function canAccessPanel(Panel $panel): bool
    {
        // Admin panel - only admins
        if ($panel->getId() === 'admin') {
            return $this->hasRole('admin');
        }

        // Data Entry panel - only data_entry role
        if ($panel->getId() === 'dataentry') {
            return $this->hasRole('data_entry');
        }

        return false;
    }

    public function reviews(): HasMany
    {
        return $this->hasMany(Review::class);
    }

    public function approvedReviews(): HasMany
    {
        return $this->hasMany(Review::class)->approved();
    }

    public function ownedStores(): BelongsToMany
    {
        return $this->belongsToMany(Store::class, 'store_owners')
            ->withPivot('role')
            ->withTimestamps();
    }

    public function stores(): BelongsToMany
    {
        return $this->belongsToMany(Store::class, 'store_owners')
            ->withPivot('role')
            ->withTimestamps();
    }

    public function claimRequests(): HasMany
    {
        return $this->hasMany(StoreClaimRequest::class);
    }

    public function replies(): HasMany
    {
        return $this->hasMany(StoreReply::class);
    }

    public function reports(): HasMany
    {
        return $this->hasMany(Report::class, 'reporter_user_id');
    }

    public function submittedStores(): HasMany
    {
        return $this->hasMany(Store::class, 'submitted_by');
    }

    public function auditLogs(): HasMany
    {
        return $this->hasMany(AuditLog::class, 'actor_user_id');
    }

    public function isOwnerOf(Store $store): bool
    {
        return $this->ownedStores()->where('stores.id', $store->id)->exists();
    }

    public function providers(): HasMany
    {
        return $this->hasMany(UserProvider::class);
    }

    public function hasProvider(string $provider): bool
    {
        return $this->providers()->where('provider', $provider)->exists();
    }

    public function notifications(): HasMany
    {
        return $this->hasMany(Notification::class);
    }
}
