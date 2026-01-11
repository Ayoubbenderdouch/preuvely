<?php

namespace App\Enums;

enum ReportReason: string
{
    case Spam = 'spam';
    case Abuse = 'abuse';
    case Fake = 'fake';
    case Other = 'other';

    public function label(): string
    {
        return match ($this) {
            self::Spam => 'Spam',
            self::Abuse => 'Abuse',
            self::Fake => 'Fake',
            self::Other => 'Other',
        };
    }
}
