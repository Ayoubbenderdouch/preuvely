<?php

namespace App\Http\Controllers\Api\V1;

use App\Enums\StoreStatus;
use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\StoreStoreRequest;
use App\Http\Resources\Api\V1\StoreListResource;
use App\Http\Resources\Api\V1\StoreResource;
use App\Http\Resources\Api\V1\StoreSummaryResource;
use App\Models\Store;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Support\Facades\DB;

/**
 * @group Stores
 *
 * APIs for browsing and managing stores
 */
class StoreController extends Controller
{
    /**
     * Get top-rated stores
     *
     * Returns stores with the highest average ratings.
     *
     * @queryParam limit integer Number of stores to return (max 20). Example: 10
     *
     * @response {
     *   "data": [
     *     {"id": 1, "name": "Tech Store", "slug": "tech-store", "avg_rating": 4.9, "reviews_count": 50}
     *   ]
     * }
     */
    public function topRated(Request $request): AnonymousResourceCollection
    {
        $limit = min($request->input('limit', 10), 20);

        $stores = Store::query()
            ->with('categories')
            ->where('status', StoreStatus::Active)
            ->where('reviews_count_cache', '>', 0)
            ->orderByDesc('avg_rating_cache')
            ->orderByDesc('reviews_count_cache')
            ->limit($limit)
            ->get();

        return StoreListResource::collection($stores);
    }

    /**
     * Get trending stores
     *
     * Returns recently popular stores based on recent reviews.
     *
     * @queryParam limit integer Number of stores to return (max 20). Example: 10
     *
     * @response {
     *   "data": [
     *     {"id": 1, "name": "Tech Store", "slug": "tech-store", "avg_rating": 4.5, "reviews_count": 25}
     *   ]
     * }
     */
    public function trending(Request $request): AnonymousResourceCollection
    {
        $limit = min($request->input('limit', 10), 20);

        $stores = Store::query()
            ->with('categories')
            ->where('status', StoreStatus::Active)
            ->orderByDesc('reviews_count_cache')
            ->orderByDesc('avg_rating_cache')
            ->limit($limit)
            ->get();

        return StoreListResource::collection($stores);
    }

    /**
     * Search stores
     *
     * Search for stores by name, description, social media links, URLs, or phone numbers.
     * Smart search: automatically extracts usernames from URLs and normalizes phone numbers.
     *
     * @queryParam q string Search query (name, URL, @handle, phone number). Example: @techstore
     * @queryParam category string Filter by category slug. Example: electronics
     * @queryParam city string Filter by city. Example: Algiers
     * @queryParam verified boolean Filter verified stores only. Example: true
     * @queryParam per_page integer Results per page (max 50). Example: 15
     *
     * @response {
     *   "data": [
     *     {"id": 1, "name": "Tech Store", "slug": "tech-store", "avg_rating": 4.5, "reviews_count": 25}
     *   ],
     *   "meta": {"current_page": 1, "last_page": 5, "per_page": 15, "total": 75}
     * }
     */
    public function search(Request $request): AnonymousResourceCollection
    {
        $query = Store::query()
            ->with('categories')
            ->where('status', StoreStatus::Active);

        if ($search = $request->input('q')) {
            // Extract search variations for smart matching
            $searchTerms = $this->extractSearchTerms($search);

            $query->where(function ($q) use ($search, $searchTerms) {
                // Search in store name
                $q->where('name', 'LIKE', "%{$search}%")
                    // Search in description
                    ->orWhere('description', 'LIKE', "%{$search}%")
                    // Search in slug
                    ->orWhere('slug', 'LIKE', "%{$search}%");

                // Search in store links (URLs and handles)
                $q->orWhereHas('links', function ($linkQuery) use ($search, $searchTerms) {
                    $linkQuery->where(function ($lq) use ($search, $searchTerms) {
                        // Search the raw URL
                        $lq->where('url', 'LIKE', "%{$search}%");

                        // Also search extracted terms (username from URL, handle without @)
                        foreach ($searchTerms as $term) {
                            if (! empty($term)) {
                                $lq->orWhere('url', 'LIKE', "%{$term}%")
                                    ->orWhere('handle', 'LIKE', "%{$term}%");
                            }
                        }
                    });
                });

                // Search in store contacts (phone numbers)
                $q->orWhereHas('contacts', function ($contactQuery) use ($search, $searchTerms) {
                    $contactQuery->where(function ($cq) use ($search, $searchTerms) {
                        // Search raw phone/whatsapp
                        $cq->where('phone', 'LIKE', "%{$search}%")
                            ->orWhere('whatsapp', 'LIKE', "%{$search}%");

                        // Also search normalized phone number
                        foreach ($searchTerms as $term) {
                            if (! empty($term)) {
                                $cq->orWhere('phone', 'LIKE', "%{$term}%")
                                    ->orWhere('whatsapp', 'LIKE', "%{$term}%");
                            }
                        }
                    });
                });
            });
        }

        if ($category = $request->input('category')) {
            $query->whereHas('categories', function ($q) use ($category) {
                $q->where('slug', $category);
            });
        }

        if ($city = $request->input('city')) {
            $query->where('city', 'LIKE', "%{$city}%");
        }

        if ($request->boolean('verified')) {
            $query->where('is_verified', true);
        }

        $perPage = min($request->input('per_page', 15), 50);

        $stores = $query->orderByDesc('avg_rating_cache')
            ->orderByDesc('reviews_count_cache')
            ->paginate($perPage);

        return StoreListResource::collection($stores);
    }

    /**
     * Extract multiple search terms from a query for smart matching.
     * Examples:
     * - "https://instagram.com/shopname" -> ["shopname", "instagram.com/shopname"]
     * - "@shopname" -> ["shopname"]
     * - "+213 555 123 456" -> ["213555123456", "555123456"]
     * - "0555 12 34 56" -> ["0555123456", "555123456"]
     *
     * @return array<string>
     */
    private function extractSearchTerms(string $search): array
    {
        $terms = [];
        $search = trim($search);

        // Remove @ prefix for social handles
        if (str_starts_with($search, '@')) {
            $terms[] = substr($search, 1);
        }

        // Extract username from social media URLs
        $socialPatterns = [
            // Instagram: instagram.com/username or www.instagram.com/username
            '#(?:https?://)?(?:www\.)?instagram\.com/([a-zA-Z0-9._]+)/?#i',
            // Facebook: facebook.com/username or fb.com/username
            '#(?:https?://)?(?:www\.)?(?:facebook|fb)\.com/([a-zA-Z0-9.]+)/?#i',
            // TikTok: tiktok.com/@username
            '#(?:https?://)?(?:www\.)?tiktok\.com/@?([a-zA-Z0-9._]+)/?#i',
            // WhatsApp: wa.me/number
            '#(?:https?://)?wa\.me/(\d+)/?#i',
        ];

        foreach ($socialPatterns as $pattern) {
            if (preg_match($pattern, $search, $matches)) {
                $terms[] = $matches[1];
            }
        }

        // Extract domain + path from any URL (without protocol)
        if (preg_match('#(?:https?://)(?:www\.)?(.+)#i', $search, $matches)) {
            $terms[] = $matches[1];
            // Also add without trailing slash
            $terms[] = rtrim($matches[1], '/');
        }

        // Normalize phone numbers (remove spaces, dashes, parentheses)
        $normalizedPhone = preg_replace('/[\s\-\(\)]+/', '', $search);
        if ($normalizedPhone !== $search) {
            $terms[] = $normalizedPhone;
        }

        // For Algerian numbers: also try without country code
        if (preg_match('/^(?:\+?213|00213)(\d+)$/', $normalizedPhone, $matches)) {
            // Add the number without country code (with leading 0)
            $terms[] = '0'.$matches[1];
            // And without the leading 0
            $terms[] = $matches[1];
        }

        // If starts with 0, also add without 0
        if (preg_match('/^0(\d{9,})$/', $normalizedPhone, $matches)) {
            $terms[] = $matches[1];
        }

        return array_unique(array_filter($terms));
    }

    /**
     * Get store details
     *
     * Get detailed information about a specific store.
     *
     * @urlParam slug string required The store slug. Example: tech-store
     *
     * @response {
     *   "data": {
     *     "id": 1,
     *     "name": "Tech Store",
     *     "slug": "tech-store",
     *     "description": "Your one-stop electronics shop",
     *     "is_verified": true,
     *     "avg_rating": 4.5,
     *     "reviews_count": 25,
     *     "categories": [...],
     *     "links": [...],
     *     "contacts": {...}
     *   }
     * }
     */
    public function show(string $slug): StoreResource
    {
        $store = Store::with(['categories', 'links', 'contacts'])
            ->where('slug', $slug)
            ->where('status', StoreStatus::Active)
            ->firstOrFail();

        return new StoreResource($store);
    }

    /**
     * Create a new store
     *
     * Submit a new store for listing.
     *
     * @authenticated
     * @bodyParam name string required The store name. Example: My Store
     * @bodyParam description string Store description. Example: A great store for electronics
     * @bodyParam city string Store city. Example: Algiers
     * @bodyParam category_ids array required Array of category IDs. Example: [1, 2]
     * @bodyParam links array Store social media links.
     * @bodyParam links[].platform string required Platform type (instagram, facebook, tiktok, website). Example: instagram
     * @bodyParam links[].url string required Platform URL. Example: https://instagram.com/mystore
     * @bodyParam links[].handle string Platform handle. Example: mystore
     * @bodyParam contacts object Store contact information.
     * @bodyParam contacts.whatsapp string WhatsApp number. Example: +213555123456
     * @bodyParam contacts.phone string Phone number. Example: +213555123456
     *
     * @response 201 {
     *   "message": "Store created successfully",
     *   "data": {"id": 1, "name": "My Store", "slug": "my-store-abc123"}
     * }
     */
    public function store(StoreStoreRequest $request): JsonResponse
    {
        $store = DB::transaction(function () use ($request) {
            $logoData = null;
            if ($request->hasFile('logo')) {
                // Convert to base64 for Laravel Cloud compatibility
                $file = $request->file('logo');
                $mimeType = $file->getMimeType();
                $contents = file_get_contents($file->getRealPath());
                $logoData = 'data:' . $mimeType . ';base64,' . base64_encode($contents);
            }

            $store = Store::create([
                'name' => $request->name,
                'description' => $request->description,
                'city' => $request->city,
                'logo_data' => $logoData,
                'status' => StoreStatus::Active,
                'submitted_by' => $request->user()?->id,
            ]);

            $store->categories()->sync($request->category_ids);

            if ($request->has('links')) {
                foreach ($request->links as $link) {
                    $store->links()->create($link);
                }
            }

            if ($request->has('contacts')) {
                $store->contacts()->create($request->contacts);
            }

            return $store;
        });

        $store->load(['categories', 'links', 'contacts']);

        return response()->json([
            'message' => 'Store created successfully',
            'data' => new StoreResource($store),
        ], 201);
    }

    /**
     * Get store summary
     *
     * Get a summary of store ratings and verification status.
     *
     * @urlParam slug string required The store slug. Example: tech-store
     *
     * @response {
     *   "data": {
     *     "avg_rating": 4.5,
     *     "reviews_count": 25,
     *     "is_verified": true,
     *     "rating_breakdown": {"1": 2, "2": 1, "3": 5, "4": 8, "5": 9},
     *     "proof_badge": true
     *   }
     * }
     */
    public function summary(string $slug): StoreSummaryResource
    {
        $store = Store::query()
            ->where('slug', $slug)
            ->where('status', StoreStatus::Active)
            ->firstOrFail();

        return new StoreSummaryResource($store);
    }
}
