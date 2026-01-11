<?php

use App\Http\Controllers\Api\V1\Admin\CategoryController as AdminCategoryController;
use App\Http\Controllers\Api\V1\AuthController;
use App\Http\Controllers\Api\V1\BannerController;
use App\Http\Controllers\Api\V1\CategoryController;
use App\Http\Controllers\Api\V1\ClaimController;
use App\Http\Controllers\Api\V1\NotificationController;
use App\Http\Controllers\Api\V1\ReportController;
use App\Http\Controllers\Api\V1\ReviewController;
use App\Http\Controllers\Api\V1\SocialAuthController;
use App\Http\Controllers\Api\V1\StoreController;
use App\Http\Controllers\Api\V1\StoreOwnerController;
use App\Http\Controllers\Api\V1\UserProfileController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes - Version 1
|--------------------------------------------------------------------------
*/

Route::prefix('v1')->group(function () {

    // Public routes
    Route::get('banners', [BannerController::class, 'index']);
    Route::get('categories', [CategoryController::class, 'index']);
    Route::get('categories/{slug}', [CategoryController::class, 'show']);

    Route::get('stores/search', [StoreController::class, 'search']);
    Route::get('stores/top-rated', [StoreController::class, 'topRated']);
    Route::get('stores/trending', [StoreController::class, 'trending']);
    Route::get('stores/{slug}', [StoreController::class, 'show']);
    Route::get('stores/{slug}/summary', [StoreController::class, 'summary']);
    Route::get('stores/{store}/reviews', [ReviewController::class, 'index']);

    // User profiles (public)
    Route::get('users/{id}/profile', [UserProfileController::class, 'show']);
    Route::get('users/{id}/profile/stores', [UserProfileController::class, 'stores']);
    Route::get('users/{id}/profile/reviews', [UserProfileController::class, 'reviews']);

    // Auth routes
    Route::prefix('auth')->group(function () {
        // Rate limited: 3 attempts per hour to prevent registration abuse
        Route::post('register', [AuthController::class, 'register'])
            ->middleware('throttle:3,60');
        // Rate limited: 5 attempts per minute to prevent brute force attacks
        Route::post('login', [AuthController::class, 'login'])
            ->middleware('throttle:5,1');

        // Email verification (signed URL - no auth required)
        Route::get('email/verify/{id}/{hash}', [AuthController::class, 'verifyEmail'])
            ->middleware('signed')
            ->name('verification.verify');

        // Social OAuth routes
        Route::get('social/{provider}/redirect', [SocialAuthController::class, 'redirect']);
        Route::get('social/{provider}/callback', [SocialAuthController::class, 'callbackGet']);
        Route::post('social/{provider}/callback', [SocialAuthController::class, 'callbackPost']);

        Route::middleware('auth:sanctum')->group(function () {
            Route::post('logout', [AuthController::class, 'logout']);
            Route::get('me', [AuthController::class, 'me']);

            // Profile update endpoints
            Route::match(['put', 'patch'], 'profile', [AuthController::class, 'updateProfile']);
            Route::post('avatar', [AuthController::class, 'uploadAvatar']);

            // Resend verification email (throttled: 10 per hour)
            Route::post('email/resend', [AuthController::class, 'resendVerificationEmail'])
                ->middleware('throttle:10,60')
                ->name('verification.resend');

            // Verify email with OTP code (throttled: 5 per minute)
            Route::post('email/verify-code', [AuthController::class, 'verifyEmailWithCode'])
                ->middleware('throttle:5,1')
                ->name('verification.verify-code');
        });
    });

    // Authenticated routes (only auth required, no email verification needed)
    Route::middleware(['auth:sanctum'])->group(function () {
        // Stores
        Route::post('stores', [StoreController::class, 'store']);

        // Reviews
        Route::get('reviews/my', [ReviewController::class, 'myReviews']);
        Route::post('stores/{store}/reviews', [ReviewController::class, 'store']);
        Route::put('reviews/{review}', [ReviewController::class, 'update']);
        Route::get('stores/{store}/my-review', [ReviewController::class, 'userReview']);
        Route::post('reviews/{review}/proof', [ReviewController::class, 'uploadProof']);
        Route::post('reviews/{review}/reply', [ReviewController::class, 'reply']);

        // Claims
        Route::post('stores/{store}/claim', [ClaimController::class, 'store']);
        Route::get('claims', [ClaimController::class, 'index']);

        // Reports
        Route::post('reports', [ReportController::class, 'store']);
        Route::get('reports', [ReportController::class, 'index']);

        // Notifications
        Route::get('notifications', [NotificationController::class, 'index']);
        Route::get('notifications/unread-count', [NotificationController::class, 'unreadCount']);
        Route::post('notifications/{id}/read', [NotificationController::class, 'markAsRead']);
        Route::post('notifications/mark-all-read', [NotificationController::class, 'markAllAsRead']);
        Route::delete('notifications/{id}', [NotificationController::class, 'destroy']);

        // Store Owner Management
        Route::prefix('my-stores')->group(function () {
            Route::get('/', [StoreOwnerController::class, 'index']);
            Route::put('{store}', [StoreOwnerController::class, 'update']);
            Route::post('{store}/logo', [StoreOwnerController::class, 'uploadLogo']);
            Route::get('{store}/links', [StoreOwnerController::class, 'getLinks']);
            Route::put('{store}/links', [StoreOwnerController::class, 'updateLinks']);
        });

        // Admin routes (requires admin role)
        Route::prefix('admin')->middleware('role:admin')->group(function () {
            Route::put('categories/{category}/risk-level', [AdminCategoryController::class, 'updateRiskLevel']);
        });
    });
});
