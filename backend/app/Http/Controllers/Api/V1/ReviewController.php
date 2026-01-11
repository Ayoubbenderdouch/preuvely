<?php

namespace App\Http\Controllers\Api\V1;

use App\Enums\ProofStatus;
use App\Enums\ReviewStatus;
use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\StoreProofRequest;
use App\Http\Requests\Api\V1\StoreReplyRequest;
use App\Http\Requests\Api\V1\StoreReviewRequest;
use App\Http\Resources\Api\V1\ReviewResource;
use App\Http\Resources\Api\V1\StoreReplyResource;
use App\Models\Review;
use App\Models\Store;
use App\Services\PrivacyHashService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\Facades\Storage;

/**
 * @group Reviews
 *
 * APIs for managing store reviews
 */
class ReviewController extends Controller
{
    /**
     * List store reviews
     *
     * Get approved reviews for a specific store.
     *
     * @urlParam store integer required The store ID. Example: 1
     * @queryParam per_page integer Results per page (max 50). Example: 15
     *
     * @response {
     *   "data": [
     *     {"id": 1, "stars": 5, "comment": "Great store!", "user": {"id": 1, "name": "John"}}
     *   ]
     * }
     */
    public function index(Store $store, Request $request): AnonymousResourceCollection
    {
        $perPage = min($request->input('per_page', 15), 50);

        $reviews = $store->reviews()
            ->with(['user', 'reply.user'])
            ->approved()
            ->latest()
            ->paginate($perPage);

        return ReviewResource::collection($reviews);
    }

    /**
     * Create a review
     *
     * Submit a review for a store. Each user can only review a store once.
     * High-risk stores require proof upload and admin approval.
     *
     * @authenticated
     * @urlParam store integer required The store ID. Example: 1
     * @bodyParam stars integer required Rating 1-5. Example: 5
     * @bodyParam comment string required Review text (8-500 chars). Example: Great experience with this store!
     *
     * @response 201 {
     *   "message": "Review submitted successfully",
     *   "requires_proof": true,
     *   "data": {"id": 1, "stars": 5, "comment": "Great experience!", "status": "pending"}
     * }
     * @response 409 {"message": "You have already reviewed this store"}
     * @response 429 {"message": "Daily review limit reached"}
     */
    public function store(Store $store, StoreReviewRequest $request, PrivacyHashService $hashService): JsonResponse
    {
        $user = $request->user();

        // Check rate limit: 5 reviews per day
        $rateLimitKey = "reviews:{$user->id}";
        if (RateLimiter::tooManyAttempts($rateLimitKey, 5)) {
            return response()->json([
                'message' => 'Daily review limit reached. You can submit up to 5 reviews per day.',
            ], 429);
        }

        // Check if user already reviewed this store
        if ($store->reviews()->where('user_id', $user->id)->exists()) {
            return response()->json([
                'message' => 'You have already reviewed this store',
            ], 409);
        }

        $isHighRisk = $store->isHighRisk();
        $hashes = $hashService->generateHashes(
            $request->ip(),
            $request->userAgent()
        );

        // Determine if review should be auto-approved
        // Auto-approve only if ALL categories are normal (not high-risk)
        $shouldAutoApprove = !$isHighRisk;

        $review = DB::transaction(function () use ($store, $request, $user, $isHighRisk, $shouldAutoApprove, $hashes) {
            return Review::create([
                'store_id' => $store->id,
                'user_id' => $user->id,
                'stars' => $request->stars,
                'comment' => $request->comment,
                'status' => $shouldAutoApprove ? ReviewStatus::Approved : ReviewStatus::Pending,
                'is_high_risk' => $isHighRisk,
                'auto_approved' => $shouldAutoApprove,
                'ip_hash' => $hashes['ip_hash'],
                'ua_hash' => $hashes['ua_hash'],
                'approved_at' => $shouldAutoApprove ? now() : null,
            ]);
        });

        RateLimiter::hit($rateLimitKey, 86400); // 24 hours

        // Update store rating cache if auto-approved
        if ($shouldAutoApprove) {
            $store->recalculateRatings();
        }

        return response()->json([
            'message' => $isHighRisk
                ? 'Review submitted. Please upload proof for approval.'
                : 'Review submitted successfully.',
            'requires_proof' => $isHighRisk,
            'data' => new ReviewResource($review),
        ], 201);
    }

    /**
     * Upload proof for review
     *
     * Upload proof image for any review. Only the review owner can upload.
     * Proof verification adds a "verified purchase" badge to the review.
     * For high-risk categories, proof is required for review approval.
     * For other categories, proof is optional but recommended.
     *
     * @authenticated
     * @urlParam review integer required The review ID. Example: 1
     * @bodyParam proof file required Proof image (jpg, png, webp; max 5MB).
     *
     * @response 201 {
     *   "message": "Proof uploaded successfully",
     *   "data": {"id": 1, "status": "pending"}
     * }
     * @response 403 {"message": "Not authorized to upload proof for this review"}
     */
    public function uploadProof(Review $review, StoreProofRequest $request): JsonResponse
    {
        $user = $request->user();

        // Check ownership
        if ($review->user_id !== $user->id) {
            return response()->json([
                'message' => 'Not authorized to upload proof for this review.',
            ], 403);
        }

        // Check if proof already exists and is approved
        if ($review->proofs()->where('status', ProofStatus::Approved)->exists()) {
            return response()->json([
                'message' => 'This review already has an approved proof.',
            ], 422);
        }

        // Store the proof file
        $path = $request->file('proof')->store('proofs', 'public');

        $proof = $review->proofs()->create([
            'file_path' => $path,
            'status' => ProofStatus::Pending,
        ]);

        $message = $review->is_high_risk
            ? 'Proof uploaded successfully. Your review will be published after admin approval.'
            : 'Proof uploaded successfully. Once approved, your review will show a verified badge.';

        return response()->json([
            'message' => $message,
            'data' => [
                'id' => $proof->id,
                'url' => $proof->url,
                'status' => $proof->status->value,
            ],
        ], 201);
    }

    /**
     * Reply to a review
     *
     * Store owner can reply to a review. Only one reply per review.
     * Store must be verified and user must be an owner.
     *
     * @authenticated
     * @urlParam review integer required The review ID. Example: 1
     * @bodyParam reply_text string required Reply text (max 300 chars). Example: Thank you for your feedback!
     *
     * @response 201 {
     *   "message": "Reply submitted successfully",
     *   "data": {"id": 1, "reply_text": "Thank you!"}
     * }
     * @response 403 {"message": "Store must be verified to reply"}
     * @response 422 {"message": "Reply already exists for this review"}
     */
    public function reply(Review $review, StoreReplyRequest $request): JsonResponse
    {
        $user = $request->user();
        $store = $review->store;

        // Check if store is verified
        if (!$store->is_verified) {
            return response()->json([
                'message' => 'Store must be verified to reply to reviews.',
            ], 403);
        }

        // Check if user is owner
        if (!$user->isOwnerOf($store)) {
            return response()->json([
                'message' => 'Only store owners can reply to reviews.',
            ], 403);
        }

        // Check if reply already exists
        if ($review->reply()->exists()) {
            return response()->json([
                'message' => 'A reply already exists for this review.',
            ], 422);
        }

        $reply = $review->reply()->create([
            'store_id' => $store->id,
            'user_id' => $user->id,
            'reply_text' => $request->reply_text,
        ]);

        return response()->json([
            'message' => 'Reply submitted successfully.',
            'data' => new StoreReplyResource($reply->load('user')),
        ], 201);
    }

    /**
     * Get user's review for a store
     *
     * Check if the authenticated user has already reviewed a store.
     *
     * @authenticated
     * @urlParam store integer required The store ID. Example: 1
     *
     * @response {
     *   "has_reviewed": true,
     *   "data": {"id": 1, "stars": 5, "comment": "Great!"}
     * }
     * @response {"has_reviewed": false, "data": null}
     */
    public function userReview(Store $store, Request $request): JsonResponse
    {
        $review = $store->reviews()
            ->with('latestProof')
            ->where('user_id', $request->user()->id)
            ->first();

        return response()->json([
            'has_reviewed' => $review !== null,
            'data' => $review ? new ReviewResource($review) : null,
        ]);
    }

    /**
     * Update a review
     *
     * Update an existing review. Only the review owner can update their own review.
     *
     * @authenticated
     * @urlParam review integer required The review ID. Example: 1
     * @bodyParam stars integer required Rating 1-5. Example: 4
     * @bodyParam comment string required Review text (8-500 chars). Example: Updated review text!
     *
     * @response {
     *   "message": "Review updated successfully",
     *   "data": {"id": 1, "stars": 4, "comment": "Updated review text!"}
     * }
     * @response 403 {"message": "Not authorized to update this review"}
     */
    public function update(Review $review, StoreReviewRequest $request): JsonResponse
    {
        $user = $request->user();

        // Check ownership
        if ($review->user_id !== $user->id) {
            return response()->json([
                'message' => 'Not authorized to update this review.',
            ], 403);
        }

        $review->update([
            'stars' => $request->stars,
            'comment' => $request->comment,
        ]);

        // Recalculate store ratings
        $review->store->recalculateRatings();

        return response()->json([
            'message' => 'Review updated successfully.',
            'data' => new ReviewResource($review->fresh()),
        ]);
    }

    /**
     * Get all user's reviews
     *
     * Get all reviews submitted by the authenticated user.
     *
     * @authenticated
     * @queryParam per_page integer Results per page (max 50). Example: 15
     *
     * @response {
     *   "data": [
     *     {"id": 1, "stars": 5, "comment": "Great store!", "store": {"id": 1, "name": "Test Store"}}
     *   ]
     * }
     */
    public function myReviews(Request $request): AnonymousResourceCollection
    {
        $perPage = min($request->input('per_page', 15), 50);

        $reviews = Review::with(['user', 'store', 'latestProof'])
            ->where('user_id', $request->user()->id)
            ->latest()
            ->paginate($perPage);

        return ReviewResource::collection($reviews);
    }
}
