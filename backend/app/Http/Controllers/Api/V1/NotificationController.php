<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\NotificationResource;
use App\Models\Notification;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

/**
 * @group Notifications
 *
 * APIs for managing user notifications
 */
class NotificationController extends Controller
{
    /**
     * List notifications
     *
     * Get all notifications for the authenticated user.
     *
     * @authenticated
     * @queryParam per_page integer Results per page (max 50). Example: 15
     *
     * @response {
     *   "data": [
     *     {
     *       "id": 1,
     *       "type": "reviewApproved",
     *       "title": "Review Approved",
     *       "message": "Your review for Store Name has been approved.",
     *       "isRead": false,
     *       "createdAt": "2025-12-26T12:00:00+00:00",
     *       "relatedId": 123,
     *       "userName": null
     *     }
     *   ],
     *   "links": {},
     *   "meta": {"current_page": 1, "last_page": 1, "per_page": 15, "total": 1}
     * }
     */
    public function index(Request $request): AnonymousResourceCollection
    {
        $perPage = min($request->input('per_page', 15), 50);

        $notifications = $request->user()
            ->notifications()
            ->orderBy('created_at', 'desc')
            ->paginate($perPage);

        return NotificationResource::collection($notifications);
    }

    /**
     * Get unread count
     *
     * Get the count of unread notifications.
     *
     * @authenticated
     *
     * @response {"unread_count": 5}
     */
    public function unreadCount(Request $request): JsonResponse
    {
        $count = $request->user()
            ->notifications()
            ->unread()
            ->count();

        return response()->json([
            'unread_count' => $count,
        ]);
    }

    /**
     * Mark notification as read
     *
     * Mark a specific notification as read.
     *
     * @authenticated
     * @urlParam id integer required The notification ID. Example: 1
     *
     * @response {"message": "Notification marked as read"}
     * @response 404 {"message": "Notification not found"}
     */
    public function markAsRead(Request $request, int $id): JsonResponse
    {
        $notification = $request->user()
            ->notifications()
            ->find($id);

        if (!$notification) {
            return response()->json([
                'message' => 'Notification not found',
            ], 404);
        }

        $notification->markAsRead();

        return response()->json([
            'message' => 'Notification marked as read',
        ]);
    }

    /**
     * Mark all as read
     *
     * Mark all notifications as read.
     *
     * @authenticated
     *
     * @response {"message": "All notifications marked as read", "count": 5}
     */
    public function markAllAsRead(Request $request): JsonResponse
    {
        $count = $request->user()
            ->notifications()
            ->unread()
            ->update(['is_read' => true]);

        return response()->json([
            'message' => 'All notifications marked as read',
            'count' => $count,
        ]);
    }

    /**
     * Delete notification
     *
     * Delete a specific notification.
     *
     * @authenticated
     * @urlParam id integer required The notification ID. Example: 1
     *
     * @response {"message": "Notification deleted"}
     * @response 404 {"message": "Notification not found"}
     */
    public function destroy(Request $request, int $id): JsonResponse
    {
        $notification = $request->user()
            ->notifications()
            ->find($id);

        if (!$notification) {
            return response()->json([
                'message' => 'Notification not found',
            ], 404);
        }

        $notification->delete();

        return response()->json([
            'message' => 'Notification deleted',
        ]);
    }
}
