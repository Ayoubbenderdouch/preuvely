<?php

namespace App\Services;

use App\Enums\StoreStatus;
use App\Models\Store;
use Illuminate\Support\Collection;

class DuplicateStoreDetectionService
{
    /**
     * Check for duplicate stores based on name similarity
     *
     * @return Collection<Store>
     */
    public function findByName(string $name): Collection
    {
        $normalizedName = $this->normalizeName($name);

        return Store::query()
            ->where('status', StoreStatus::Active)
            ->get()
            ->filter(function (Store $store) use ($normalizedName, $name) {
                // Check exact normalized match
                if ($this->normalizeName($store->name) === $normalizedName) {
                    return true;
                }

                // Check if slugified versions match (handles unicode like Arabic)
                if ($this->normalizeToAlphanumeric($store->name) === $this->normalizeToAlphanumeric($name)) {
                    return true;
                }

                // Check similarity score for fuzzy matching
                $similarity = $this->calculateSimilarity($store->name, $name);
                if ($similarity >= 0.85) {
                    return true;
                }

                return false;
            });
    }

    /**
     * Check for duplicate stores by social media handle
     *
     * @return Collection<Store>
     */
    public function findByHandle(string $handle, ?string $platform = null): Collection
    {
        $normalizedHandle = $this->normalizeHandle($handle);

        return Store::query()
            ->where('status', StoreStatus::Active)
            ->whereHas('links', function ($query) use ($normalizedHandle, $platform) {
                $query->where(function ($q) use ($normalizedHandle) {
                    // Check handle field
                    $q->whereRaw('LOWER(REPLACE(REPLACE(handle, ".", ""), "_", "")) = ?', [$normalizedHandle])
                        // Check URL for the handle
                        ->orWhere('url', 'LIKE', '%/' . $normalizedHandle)
                        ->orWhere('url', 'LIKE', '%/' . $normalizedHandle . '/')
                        ->orWhere('url', 'LIKE', '%/@' . $normalizedHandle)
                        ->orWhere('url', 'LIKE', '%/@' . $normalizedHandle . '/');
                });

                if ($platform) {
                    $query->where('platform', $platform);
                }
            })
            ->with('links')
            ->get();
    }

    /**
     * Check for duplicate stores by URL
     *
     * @return Collection<Store>
     */
    public function findByUrl(string $url): Collection
    {
        // Extract the handle/username from the URL
        $handle = $this->extractHandleFromUrl($url);

        if (!$handle) {
            // For websites, compare the full normalized URL
            $normalizedUrl = $this->normalizeUrl($url);

            return Store::query()
                ->where('status', StoreStatus::Active)
                ->whereHas('links', function ($query) use ($normalizedUrl, $url) {
                    $query->where(function ($q) use ($normalizedUrl, $url) {
                        $q->where('url', $url)
                            ->orWhere('url', $normalizedUrl)
                            ->orWhere('url', 'LIKE', '%' . $normalizedUrl . '%');
                    });
                })
                ->with('links')
                ->get();
        }

        return $this->findByHandle($handle);
    }

    /**
     * Comprehensive duplicate check - checks name, handles, and URLs
     *
     * @return array{
     *     has_duplicate: bool,
     *     duplicate_type: string|null,
     *     existing_store: array|null
     * }
     */
    public function checkForDuplicates(string $name, array $links = []): array
    {
        // Check name duplicates first
        $nameDuplicates = $this->findByName($name);
        if ($nameDuplicates->isNotEmpty()) {
            $store = $nameDuplicates->first();
            return [
                'has_duplicate' => true,
                'duplicate_type' => 'name',
                'existing_store' => $this->formatStoreInfo($store),
            ];
        }

        // Check handle/URL duplicates
        foreach ($links as $link) {
            $url = $link['url'] ?? null;
            $handle = $link['handle'] ?? null;

            if ($handle) {
                $handleDuplicates = $this->findByHandle($handle, $link['platform'] ?? null);
                if ($handleDuplicates->isNotEmpty()) {
                    $store = $handleDuplicates->first();
                    return [
                        'has_duplicate' => true,
                        'duplicate_type' => 'handle',
                        'existing_store' => $this->formatStoreInfo($store),
                    ];
                }
            }

            if ($url) {
                $urlDuplicates = $this->findByUrl($url);
                if ($urlDuplicates->isNotEmpty()) {
                    $store = $urlDuplicates->first();
                    return [
                        'has_duplicate' => true,
                        'duplicate_type' => 'social_link',
                        'existing_store' => $this->formatStoreInfo($store),
                    ];
                }
            }
        }

        return [
            'has_duplicate' => false,
            'duplicate_type' => null,
            'existing_store' => null,
        ];
    }

    /**
     * Normalize a store name for comparison.
     * Removes spaces, special characters, converts to lowercase.
     * Handles transliterations like "ou" -> "u" for French names.
     */
    public function normalizeName(string $name): string
    {
        $normalized = mb_strtolower($name, 'UTF-8');

        // Remove common business suffixes
        $suffixes = ['shop', 'store', 'boutique', 'dz', 'algeria', 'algerie'];
        foreach ($suffixes as $suffix) {
            $normalized = preg_replace('/\b' . $suffix . '\b/i', '', $normalized);
        }

        // Handle common transliterations
        $transliterations = [
            'ou' => 'u',      // French ou -> u (doum -> dum)
            'ph' => 'f',      // ph -> f
            'ck' => 'k',      // ck -> k
            'ee' => 'i',      // ee -> i
            'oo' => 'u',      // oo -> u
        ];

        foreach ($transliterations as $from => $to) {
            $normalized = str_replace($from, $to, $normalized);
        }

        // Remove all non-alphanumeric characters
        $normalized = preg_replace('/[^a-z0-9]/u', '', $normalized);

        return $normalized;
    }

    /**
     * Normalize to pure alphanumeric for strict matching
     */
    public function normalizeToAlphanumeric(string $text): string
    {
        // Convert to lowercase
        $text = mb_strtolower($text, 'UTF-8');

        // Transliterate to ASCII
        if (function_exists('transliterator_transliterate')) {
            $text = transliterator_transliterate('Any-Latin; Latin-ASCII; Lower()', $text);
        }

        // Remove all non-alphanumeric characters
        return preg_replace('/[^a-z0-9]/', '', $text);
    }

    /**
     * Normalize a social media handle for comparison
     */
    public function normalizeHandle(string $handle): string
    {
        // Remove @ prefix
        $handle = ltrim($handle, '@');

        // Convert to lowercase
        $handle = mb_strtolower($handle, 'UTF-8');

        // Remove dots and underscores for comparison
        $handle = str_replace(['.', '_'], '', $handle);

        return $handle;
    }

    /**
     * Extract username/handle from a social media URL
     */
    public function extractHandleFromUrl(string $url): ?string
    {
        $patterns = [
            // Instagram
            '#(?:https?://)?(?:www\.)?instagram\.com/([a-zA-Z0-9._]+)/?(?:\?.*)?$#i',
            // Facebook
            '#(?:https?://)?(?:www\.)?(?:facebook|fb)\.com/([a-zA-Z0-9.]+)/?(?:\?.*)?$#i',
            // TikTok
            '#(?:https?://)?(?:www\.)?tiktok\.com/@?([a-zA-Z0-9._]+)/?(?:\?.*)?$#i',
            // WhatsApp
            '#(?:https?://)?wa\.me/(\d+)/?(?:\?.*)?$#i',
        ];

        foreach ($patterns as $pattern) {
            if (preg_match($pattern, $url, $matches)) {
                return $matches[1];
            }
        }

        return null;
    }

    /**
     * Normalize URL for comparison
     */
    public function normalizeUrl(string $url): string
    {
        // Remove protocol
        $url = preg_replace('#^https?://#i', '', $url);

        // Remove www
        $url = preg_replace('#^www\.#i', '', $url);

        // Remove trailing slash
        $url = rtrim($url, '/');

        // Convert to lowercase
        return mb_strtolower($url, 'UTF-8');
    }

    /**
     * Calculate similarity between two strings using multiple algorithms
     */
    public function calculateSimilarity(string $a, string $b): float
    {
        $normalizedA = $this->normalizeName($a);
        $normalizedB = $this->normalizeName($b);

        // Exact match after normalization
        if ($normalizedA === $normalizedB) {
            return 1.0;
        }

        // Levenshtein distance (normalized)
        $maxLen = max(strlen($normalizedA), strlen($normalizedB));
        if ($maxLen === 0) {
            return 0.0;
        }

        $levenshtein = levenshtein($normalizedA, $normalizedB);
        $levenshteinSimilarity = 1 - ($levenshtein / $maxLen);

        // Similar text percentage
        similar_text($normalizedA, $normalizedB, $similarPercent);
        $similarTextScore = $similarPercent / 100;

        // Use the higher of the two scores
        return max($levenshteinSimilarity, $similarTextScore);
    }

    /**
     * Format store info for API response
     */
    private function formatStoreInfo(Store $store): array
    {
        return [
            'id' => $store->id,
            'name' => $store->name,
            'slug' => $store->slug,
            'is_verified' => $store->is_verified,
            'avg_rating' => $store->avg_rating_cache,
            'reviews_count' => $store->reviews_count_cache,
        ];
    }
}
