<?php

namespace App\Services;

use Illuminate\Support\Facades\Config;

class PrivacyHashService
{
    protected string $salt;

    public function __construct()
    {
        $this->salt = Config::get('app.key', 'preuvely-salt');
    }

    public function hashIp(?string $ip): ?string
    {
        if (empty($ip)) {
            return null;
        }

        return hash('sha256', $ip . $this->salt . 'ip');
    }

    public function hashUserAgent(?string $userAgent): ?string
    {
        if (empty($userAgent)) {
            return null;
        }

        return hash('sha256', $userAgent . $this->salt . 'ua');
    }

    public function generateHashes(?string $ip, ?string $userAgent): array
    {
        return [
            'ip_hash' => $this->hashIp($ip),
            'ua_hash' => $this->hashUserAgent($userAgent),
        ];
    }
}
