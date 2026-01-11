<?php

namespace App\Services;

use Illuminate\Support\Facades\Config;

class ContentModerationService
{
    protected array $bannedWords;

    public function __construct()
    {
        $this->bannedWords = Config::get('moderation.banned_words', []);
    }

    public function containsProfanity(string $text): bool
    {
        $lowerText = mb_strtolower($text);

        foreach ($this->bannedWords as $word) {
            if (str_contains($lowerText, mb_strtolower($word))) {
                return true;
            }
        }

        return false;
    }

    public function sanitize(string $text): string
    {
        return strip_tags($text);
    }

    public function validate(string $text): array
    {
        $sanitized = $this->sanitize($text);

        if ($this->containsProfanity($sanitized)) {
            return [
                'valid' => false,
                'message' => 'Content contains inappropriate language.',
                'text' => $sanitized,
            ];
        }

        return [
            'valid' => true,
            'message' => null,
            'text' => $sanitized,
        ];
    }
}
