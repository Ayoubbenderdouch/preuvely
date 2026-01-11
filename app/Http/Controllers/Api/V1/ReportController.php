<?php

namespace App\Http\Controllers\Api\V1;

use App\Enums\ReportStatus;
use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\StoreReportRequest;
use App\Http\Resources\Api\V1\ReportResource;
use App\Models\Report;
use App\Models\Review;
use App\Models\Store;
use App\Models\StoreReply;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\RateLimiter;

/**
 * @group Reports
 *
 * APIs for reporting content
 */
class ReportController extends Controller
{
    /**
     * Submit a report
     *
     * Report a review, reply, or store for moderation.
     *
     * @authenticated
     * @bodyParam reportable_type string required Type of content (review, reply, store). Example: review
     * @bodyParam reportable_id integer required ID of the content. Example: 1
     * @bodyParam reason string required Reason for report (spam, abuse, fake, other). Example: spam
     * @bodyParam note string Additional details. Example: This review looks suspicious...
     *
     * @response 201 {
     *   "message": "Report submitted successfully",
     *   "data": {"id": 1, "reason": "spam", "status": "open"}
     * }
     * @response 429 {"message": "Daily report limit reached"}
     */
    public function store(StoreReportRequest $request): JsonResponse
    {
        $user = $request->user();

        // Check rate limit: 10 reports per day
        $rateLimitKey = "reports:{$user->id}";
        if (RateLimiter::tooManyAttempts($rateLimitKey, 10)) {
            return response()->json([
                'message' => 'Daily report limit reached. You can submit up to 10 reports per day.',
            ], 429);
        }

        $reportableType = match ($request->reportable_type) {
            'review' => Review::class,
            'reply' => StoreReply::class,
            'store' => Store::class,
        };

        // Check if user already reported this content
        $existingReport = Report::where('reporter_user_id', $user->id)
            ->where('reportable_type', $reportableType)
            ->where('reportable_id', $request->reportable_id)
            ->where('status', ReportStatus::Open)
            ->exists();

        if ($existingReport) {
            return response()->json([
                'message' => 'You have already reported this content.',
            ], 422);
        }

        $report = Report::create([
            'reporter_user_id' => $user->id,
            'reportable_type' => $reportableType,
            'reportable_id' => $request->reportable_id,
            'reason' => $request->reason,
            'note' => $request->note,
            'status' => ReportStatus::Open,
        ]);

        RateLimiter::hit($rateLimitKey, 86400);

        return response()->json([
            'message' => 'Report submitted successfully. Thank you for helping keep our platform safe.',
            'data' => new ReportResource($report),
        ], 201);
    }

    /**
     * Get user's reports
     *
     * Get all reports submitted by the authenticated user.
     *
     * @authenticated
     *
     * @response {
     *   "data": [
     *     {"id": 1, "reportable_type": "Review", "reason": "spam", "status": "open"}
     *   ]
     * }
     */
    public function index(Request $request): JsonResponse
    {
        $reports = $request->user()
            ->reports()
            ->with(['reportable'])
            ->latest()
            ->get();

        return response()->json([
            'data' => ReportResource::collection($reports),
        ]);
    }
}
