<?php

namespace App\Enums;

enum Platform: string
{
    case Instagram = 'instagram';
    case Facebook = 'facebook';
    case Tiktok = 'tiktok';
    case Website = 'website';
    case Whatsapp = 'whatsapp';

    public function label(): string
    {
        return match ($this) {
            self::Instagram => 'Instagram',
            self::Facebook => 'Facebook',
            self::Tiktok => 'TikTok',
            self::Website => 'Website',
            self::Whatsapp => 'WhatsApp',
        };
    }

    public function icon(): string
    {
        return match ($this) {
            self::Instagram => 'heroicon-o-camera',
            self::Facebook => 'heroicon-o-chat-bubble-left-right',
            self::Tiktok => 'heroicon-o-musical-note',
            self::Website => 'heroicon-o-globe-alt',
            self::Whatsapp => 'heroicon-o-phone',
        };
    }

    public function urlPattern(): ?string
    {
        return match ($this) {
            self::Instagram => 'instagram.com',
            self::Facebook => 'facebook.com',
            self::Tiktok => 'tiktok.com',
            self::Website => null,
            self::Whatsapp => 'wa.me',
        };
    }
}
