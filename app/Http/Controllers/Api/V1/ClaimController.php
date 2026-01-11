<?php

namespace App\Http\Controllers\Api\V1;

use App\Enums\ClaimStatus;
use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\StoreClaimRequest;
use App\Http\Resources\Api\V1\ClaimRequestResource;
use App\Models\Store;
use App\Models\StoreClaimRequest as ClaimRequest;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * @group Store Claims
 *
 * APIs for claiming store ownership
 */
class ClaimController extends Controller
{
    /**
     * Submit a claim request
     *
     * Request ownership of a store. The claim will be reviewed by admin.
     *
     * @authenticated
     * @urlParam store integer required The store ID. Example: 1
     * @bodyParam requester_name string required Your full name. Example: John Doe
     * @bodyParam requester_phone string required Your phone number. Example: +213555123456
     * @bodyParam note string Additional note for the admin. Example: I am the owner...
     *
     * @response 201 {
     *   "message": "Claim request submitted successfully",
     *   "data": {"id": 1, "status": "pending"}
     * }
     * @response 422 {"message": "You have already submitted a pending claim for this store"}
     */
    public function store(Store $store, StoreClaimRequest $request): JsonResponse
    {
        $user = $request->user();

        // Check if user is already an owner
        if ($user->isOwnerOf($store)) {
            return response()->json([
                'message' => 'You are already an owner of this store.',
            ], 422);
        }

        // Check for existing pending claim
        $existingClaim = $store->claimRequests()
            ->where('user_id', $user->id)
            ->where('status', ClaimStatus::Pending)
            ->exists();

        if ($existingClaim) {
            return response()->json([
                'message' => 'You have already submitted a pending claim for this store.',
            ], 422);
        }

        $claim = ClaimRequest::create([
            'store_id' => $store->id,
            'user_id' => $user->id,
            'requester_name' => $request->requester_name,
            'requester_phone' => $request->requester_phone,
            'note' => $request->note,
            'status' => ClaimStatus::Pending,
        ]);

        return response()->json([
            'message' => 'Claim request submitted successfully. It will be reviewed by admin.',
            'data' => new ClaimRequestResource($claim),
        ], 201);
    }

    /**
     * Get user's claim requests
     *
     * Get all claim requests submitted by the authenticated user.
     *
     * @authenticated
     *
     * @response {
     *   "data": [
     *     {"id": 1, "store_id": 5, "status": "pending", "created_at": "2024-01-01T00:00:00Z"}
     *   ]
     * }
     */
    public function index(Request $request): JsonResponse
    {
        $claims = $request->user()
            ->claimRequests()
            ->with('store:id,name,slug')
            ->latest()
            ->get();

        return response()->json([
            'data' => ClaimRequestResource::collection($claims),
        ]);
    }
}
