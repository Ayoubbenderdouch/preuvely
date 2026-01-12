<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\UpdateStoreLinksRequest;
use App\Http\Requests\Api\V1\UpdateStoreRequest;
use App\Http\Resources\Api\V1\StoreOwnerResource;
use App\Http\Resources\Api\V1\StoreLinkResource;
use App\Models\Store;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Symfony\Component\HttpFoundation\Response;

/**
 * @group Store Owner Management
 *
 * APIs for store owners to manage their stores.
 * All endpoints require authentication and ownership verification.
 */
class StoreOwnerController extends Controller
{
    /**
     * List my stores
     *
     * Get all stores owned by the authenticated user.
     *
     * @authenticated
     *
     * @response 200 {
     *   "data": [
     *     {
     *       "id": 1,
     *       "name": "My Store",
     *       "slug": "my-store-abc123",
     *       "description": "A great electronics store",
     *       "city": "Algiers",
     *       "logo": "https://example.com/storage/store-logos/logo.jpg",
     *       "status": "active",
     *       "is_verified": true,
     *       "avg_rating": 4.5,
     *       "reviews_count": 25,
     *       "owner_role": "owner",
     *       "categories": [...],
     *       "links": [...],
     *       "created_at": "2024-01-01T00:00:00+00:00"
     *     }
     *   ]
     * }
     */
    public function index(Request $request): AnonymousResourceCollection
    {
        $stores = $request->user()
            ->ownedStores()
            ->with(['categories', 'links', 'contacts'])
            ->get();

        return StoreOwnerResource::collection($stores);
    }

    /**
     * Update store information
     *
     * Update the basic information of a store owned by the authenticated user.
     *
     * @authenticated
     * @urlParam store integer required The store ID. Example: 1
     *
     * @bodyParam name string The store name. Example: My Updated Store
     * @bodyParam description string The store description. Example: Updated description for my store
     * @bodyParam city string The store city. Example: Oran
     *
     * @response 200 {
     *   "message": "Store updated successfully",
     *   "data": {
     *     "id": 1,
     *     "name": "My Updated Store",
     *     "slug": "my-store-abc123",
     *     "description": "Updated description for my store",
     *     "city": "Oran",
     *     "logo": "https://example.com/storage/store-logos/logo.jpg",
     *     "status": "active",
     *     "is_verified": true,
     *     "avg_rating": 4.5,
     *     "reviews_count": 25,
     *     "owner_role": "owner",
     *     "categories": [...],
     *     "links": [...],
     *     "created_at": "2024-01-01T00:00:00+00:00"
     *   }
     * }
     *
     * @response 403 {
     *   "message": "You do not have permission to manage this store."
     * }
     */
    public function update(UpdateStoreRequest $request, Store $store): JsonResponse
    {
        // Verify ownership
        if (!$request->user()->isOwnerOf($store)) {
            return response()->json([
                'message' => 'You do not have permission to manage this store.',
            ], Response::HTTP_FORBIDDEN);
        }

        $validated = $request->validated();

        // Extract contacts if present
        $contacts = $validated['contacts'] ?? null;
        unset($validated['contacts']);

        // Update store basic fields
        $store->update($validated);

        // Update or create contacts if provided
        if ($contacts !== null) {
            $store->contacts()->updateOrCreate(
                ['store_id' => $store->id],
                [
                    'whatsapp' => $contacts['whatsapp'] ?? null,
                    'phone' => $contacts['phone'] ?? null,
                ]
            );
        }

        $store->load(['categories', 'links', 'contacts']);

        // Attach pivot data for resource
        $store->pivot = $request->user()->ownedStores()
            ->where('stores.id', $store->id)
            ->first()
            ->pivot ?? null;

        return response()->json([
            'message' => 'Store updated successfully',
            'data' => new StoreOwnerResource($store),
        ]);
    }

    /**
     * Upload store logo
     *
     * Upload or update the logo for a store owned by the authenticated user.
     *
     * @authenticated
     * @urlParam store integer required The store ID. Example: 1
     *
     * @bodyParam logo file required The logo image file (jpeg, png, jpg, webp). Max size: 2MB. Example: logo.png
     *
     * @response 200 {
     *   "message": "Logo uploaded successfully",
     *   "data": {
     *     "logo": "https://example.com/storage/store-logos/new-logo.jpg"
     *   }
     * }
     *
     * @response 403 {
     *   "message": "You do not have permission to manage this store."
     * }
     *
     * @response 422 {
     *   "message": "The logo field is required.",
     *   "errors": {
     *     "logo": ["The logo field is required."]
     *   }
     * }
     */
    public function uploadLogo(Request $request, Store $store): JsonResponse
    {
        // Verify ownership
        if (!$request->user()->isOwnerOf($store)) {
            return response()->json([
                'message' => 'You do not have permission to manage this store.',
            ], Response::HTTP_FORBIDDEN);
        }

        $request->validate([
            'logo' => ['required', 'image', 'mimes:jpeg,png,jpg,webp', 'max:2048'],
        ]);

        // Delete old logo if exists
        if ($store->logo) {
            Storage::disk('public')->delete($store->logo);
        }

        // Store new logo
        $logoPath = $request->file('logo')->store('store-logos', 'public');
        $store->update(['logo' => $logoPath]);

        return response()->json([
            'message' => 'Logo uploaded successfully',
            'data' => [
                'logo' => Storage::disk('public')->url($logoPath),
            ],
        ]);
    }

    /**
     * Get store links
     *
     * Get all social media and website links for a store owned by the authenticated user.
     *
     * @authenticated
     * @urlParam store integer required The store ID. Example: 1
     *
     * @response 200 {
     *   "data": [
     *     {
     *       "id": 1,
     *       "platform": "instagram",
     *       "platform_label": "Instagram",
     *       "url": "https://instagram.com/mystore",
     *       "handle": "mystore"
     *     },
     *     {
     *       "id": 2,
     *       "platform": "website",
     *       "platform_label": "Website",
     *       "url": "https://mystore.com",
     *       "handle": null
     *     }
     *   ]
     * }
     *
     * @response 403 {
     *   "message": "You do not have permission to manage this store."
     * }
     */
    public function getLinks(Request $request, Store $store): JsonResponse
    {
        // Verify ownership
        if (!$request->user()->isOwnerOf($store)) {
            return response()->json([
                'message' => 'You do not have permission to manage this store.',
            ], Response::HTTP_FORBIDDEN);
        }

        $links = $store->links()->get();

        return response()->json([
            'data' => StoreLinkResource::collection($links),
        ]);
    }

    /**
     * Update store links
     *
     * Bulk update all links for a store owned by the authenticated user.
     * This replaces all existing links with the provided ones.
     *
     * @authenticated
     * @urlParam store integer required The store ID. Example: 1
     *
     * @bodyParam links array required Array of link objects. Example: [{"platform": "instagram", "url": "https://instagram.com/mystore", "handle": "mystore"}]
     * @bodyParam links[].platform string required Platform type: website, instagram, facebook, tiktok, whatsapp. Example: instagram
     * @bodyParam links[].url string required The URL for the platform. Example: https://instagram.com/mystore
     * @bodyParam links[].handle string Optional handle/username for the platform. Example: mystore
     *
     * @response 200 {
     *   "message": "Store links updated successfully",
     *   "data": [
     *     {
     *       "id": 10,
     *       "platform": "instagram",
     *       "platform_label": "Instagram",
     *       "url": "https://instagram.com/mystore",
     *       "handle": "mystore"
     *     }
     *   ]
     * }
     *
     * @response 403 {
     *   "message": "You do not have permission to manage this store."
     * }
     *
     * @response 422 {
     *   "message": "The links field is required.",
     *   "errors": {
     *     "links": ["The links field is required."]
     *   }
     * }
     */
    public function updateLinks(UpdateStoreLinksRequest $request, Store $store): JsonResponse
    {
        // Verify ownership
        if (!$request->user()->isOwnerOf($store)) {
            return response()->json([
                'message' => 'You do not have permission to manage this store.',
            ], Response::HTTP_FORBIDDEN);
        }

        DB::transaction(function () use ($request, $store) {
            // Delete all existing links
            $store->links()->delete();

            // Create new links
            foreach ($request->validated()['links'] as $linkData) {
                $store->links()->create([
                    'platform' => $linkData['platform'],
                    'url' => $linkData['url'],
                    'handle' => $linkData['handle'] ?? null,
                ]);
            }
        });

        // Refresh links
        $links = $store->links()->get();

        return response()->json([
            'message' => 'Store links updated successfully',
            'data' => StoreLinkResource::collection($links),
        ]);
    }
}
