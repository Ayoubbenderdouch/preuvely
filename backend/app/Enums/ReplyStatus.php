<?php

namespace App\Enums;

enum ReplyStatus: string
{
    case Visible = 'visible';
    case Hidden = 'hidden';

    public function label(): string
    {
        return match ($this) {
            self::Visible => 'Visible',
            self::Hidden => 'Hidden',
        };
    }

    public function color(): string
    {
        return match ($this) {
            self::Visible => 'success',
            self::Hidden => 'gray',
        };
    }
}
