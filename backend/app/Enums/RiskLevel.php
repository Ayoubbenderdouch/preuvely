<?php

namespace App\Enums;

enum RiskLevel: string
{
    case Normal = 'normal';
    case HighRisk = 'high_risk';

    public function label(): string
    {
        return match ($this) {
            self::Normal => 'Normal',
            self::HighRisk => 'High Risk',
        };
    }

    public function color(): string
    {
        return match ($this) {
            self::Normal => 'success',
            self::HighRisk => 'danger',
        };
    }

    public function isHighRisk(): bool
    {
        return $this === self::HighRisk;
    }
}
