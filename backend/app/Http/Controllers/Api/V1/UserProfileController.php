<?php

namespace App\Http\Controllers\Api\V1;

use App\Enums\StoreStatus;
use App\Http\Controllers\Controller;
use App\Http\Resources\Api\V1\ReviewResource;
use App\Http\Resources\Api\V1\StoreListResource;
use App\Http\Resources\Api\V1\UserProfileResource;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

/**
 * @group User Profiles
 *
 * APIs for viewing public user profiles
 */
class UserProfileController extends Controller
{
    /**
     * Get user profile
     *
     * Get public profile information for a user including their stats,
     * submitted stores, and approved reviews.
     *
     * @urlParam id integer required The user ID. Example: 1
     *
     * @response {
     *   "data": {
     *     "id": 1,
     *     "name": "John Doe",
     *     "avatar": "https://example.com/storage/avatars/user.jpg",
     *     "member_since": "2024-01-15T10:30:00+00:00",
     *     "stats": {
     *       "stores_count": 5,
     *       "reviews_count": 12
     *     },
     *     "submitted_stores": [...],
     *     "reviews": [...]
     *   }
     * }
     * @response 404 {"message": "User not found"}
     */
    public function show(int $id): UserProfileResource
    {
        $user = User::query()
            ->withCount([
                'submittedStores' => fn ($query) => $query->where('status', StoreStatus::Active),
                'approvedReviews',
            ])
            ->with([
                'submittedStores' => fn ($query) => $query
                    ->with('categories')
                    ->where('status', StoreStatus::Active)
                    ->latest()
                    ->limit(10),
                'approvedReviews' => fn ($query) => $query
                    ->with(['store', 'latestProof'])
                    ->latest()
                    ->limit(10),
            ])
            ->findOrFail($id);

        return new UserProfileResource($user);
    }

    /**
     * Get user's submitted stores (paginated)
     *
     * Get paginated list of stores submitted by a user.
     *
     * @urlParam id integer required The user ID. Example: 1
     * @queryParam page integer Page number. Example: 1
     * @queryParam per_page integer Results per page (max 50). Example: 10
     *
     * @response {
     *   "data": [
     *     {"id": 1, "name": "Tech Store", "slug": "tech-store", "avg_rating": 4.5}
     *   ],
     *   "meta": {"current_page": 1, "last_page": 2, "per_page": 10, "total": 15}
     * }
     * @response 404 {"message": "User not found"}
     */
    public function stores(int $id, Request $request): AnonymousResourceCollection
    {
        $user = User::findOrFail($id);

        $perPage = min($request->input('per_page', 10), 50);

        $stores = $user->submittedStores()
            ->with('categories')
            ->where('status', StoreStatus::Active)
            ->latest()
            ->paginate($perPage);

        return StoreListResource::collection($stores);
    }

    /**
     * Get user's reviews (paginated)
     *
     * Get paginated list of approved reviews by a user.
     *
     * @urlParam id integer required The user ID. Example: 1
     * @queryParam page integer Page number. Example: 1
     * @queryParam per_page integer Results per page (max 50). Example: 10
     *
     * @response {
     *   "data": [
     *     {"id": 1, "stars": 5, "comment": "Great store!", "store": {"id": 1, "name": "Test Store"}}
     *   ],
     *   "meta": {"current_page": 1, "last_page": 2, "per_page": 10, "total": 15}
     * }
     * @response 404 {"message": "User not found"}
     */
    public function reviews(int $id, Request $request): AnonymousResourceCollection
    {
        $user = User::findOrFail($id);

        $perPage = min($request->input('per_page', 10), 50);

        $reviews = $user->approvedReviews()
            ->with(['store', 'latestProof'])
            ->latest()
            ->paginate($perPage);

        return ReviewResource::collection($reviews);
    }
}
