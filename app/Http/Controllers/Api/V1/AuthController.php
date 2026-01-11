<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\LoginRequest;
use App\Http\Requests\Api\V1\RegisterRequest;
use App\Http\Requests\Api\V1\UpdateProfileRequest;
use Illuminate\Support\Facades\Storage;
use App\Http\Resources\Api\V1\UserResource;
use App\Models\User;
use Illuminate\Auth\Events\Verified;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;

/**
 * @group Authentication
 *
 * APIs for user authentication
 */
class AuthController extends Controller
{
    /**
     * Register a new user
     *
     * Create a new user account and return an API token.
     *
     * @bodyParam name string required The user's full name. Example: John Doe
     * @bodyParam email string The user's email address (required if phone not provided). Example: john@example.com
     * @bodyParam phone string The user's phone number (required if email not provided). Example: +213555123456
     * @bodyParam password string required The password (min 8 chars). Example: password123
     * @bodyParam password_confirmation string required Password confirmation. Example: password123
     *
     * @response 201 {
     *   "message": "User registered successfully",
     *   "user": {"id": 1, "name": "John Doe", "email": "john@example.com"},
     *   "token": "1|abcdef123456..."
     * }
     */
    public function register(RegisterRequest $request): JsonResponse
    {
        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'phone' => $request->phone,
            'password' => Hash::make($request->password),
        ]);

        // Send email verification notification
        if ($user->email) {
            $user->sendEmailVerificationNotification();
        }

        $token = $user->createToken('api-token')->plainTextToken;

        return response()->json([
            'message' => $user->email
                ? 'User registered successfully. Please check your email to verify your account.'
                : 'User registered successfully.',
            'user' => new UserResource($user),
            'token' => $token,
        ], 201);
    }

    /**
     * Login user
     *
     * Authenticate user and return an API token.
     *
     * @bodyParam email string The user's email (required if phone not provided). Example: john@example.com
     * @bodyParam phone string The user's phone (required if email not provided). Example: +213555123456
     * @bodyParam password string required The user's password. Example: password123
     *
     * @response {
     *   "message": "Login successful",
     *   "user": {"id": 1, "name": "John Doe", "email": "john@example.com"},
     *   "token": "1|abcdef123456..."
     * }
     * @response 401 {"message": "Invalid credentials"}
     */
    public function login(LoginRequest $request): JsonResponse
    {
        $credentials = [];

        if ($request->email) {
            $credentials['email'] = $request->email;
        } elseif ($request->phone) {
            $credentials['phone'] = $request->phone;
        }

        $credentials['password'] = $request->password;

        if (!Auth::attempt($credentials)) {
            return response()->json([
                'message' => 'Invalid credentials',
            ], 401);
        }

        $user = Auth::user();
        $token = $user->createToken('api-token')->plainTextToken;

        return response()->json([
            'message' => 'Login successful',
            'user' => new UserResource($user),
            'token' => $token,
            'email_verified' => $user->hasVerifiedEmail(),
        ]);
    }

    /**
     * Logout user
     *
     * Revoke the current API token.
     *
     * @authenticated
     * @response {"message": "Logged out successfully"}
     */
    public function logout(Request $request): JsonResponse
    {
        $token = $request->user()->currentAccessToken();

        if ($token) {
            $token->delete();
        } else {
            // Fallback: delete all tokens for the user
            $request->user()->tokens()->delete();
        }

        return response()->json([
            'message' => 'Logged out successfully',
        ]);
    }

    /**
     * Get current user
     *
     * Get the authenticated user's profile.
     *
     * @authenticated
     * @response {
     *   "user": {"id": 1, "name": "John Doe", "email": "john@example.com"}
     * }
     */
    public function me(Request $request): JsonResponse
    {
        return response()->json([
            'user' => new UserResource($request->user()),
        ]);
    }

    /**
     * Resend verification email
     *
     * Resend the email verification notification.
     *
     * @authenticated
     * @response {"message": "Verification email resent successfully"}
     * @response 400 {"message": "Email already verified"}
     */
    public function resendVerificationEmail(Request $request): JsonResponse
    {
        $user = $request->user();

        if (!$user->email) {
            return response()->json([
                'message' => 'No email address associated with this account',
            ], 400);
        }

        if ($user->hasVerifiedEmail()) {
            return response()->json([
                'message' => 'Email already verified',
            ], 400);
        }

        $user->sendEmailVerificationNotification();

        return response()->json([
            'message' => 'Verification email resent successfully',
        ]);
    }

    /**
     * Verify email address
     *
     * Verify the user's email address using a signed URL.
     *
     * @urlParam id integer required The user ID. Example: 1
     * @urlParam hash string required The verification hash.
     *
     * @response {"message": "Email verified successfully"}
     * @response 403 {"message": "Invalid verification link"}
     */
    public function verifyEmail(Request $request, int $id, string $hash): JsonResponse
    {
        $user = User::findOrFail($id);

        if (!hash_equals(sha1($user->getEmailForVerification()), $hash)) {
            return response()->json([
                'message' => 'Invalid verification link',
            ], 403);
        }

        if ($user->hasVerifiedEmail()) {
            return response()->json([
                'message' => 'Email already verified',
            ], 400);
        }

        if ($user->markEmailAsVerified()) {
            event(new Verified($user));
        }

        return response()->json([
            'message' => 'Email verified successfully',
        ]);
    }

    /**
     * Update user profile
     *
     * Update the authenticated user's profile information.
     *
     * @authenticated
     * @bodyParam name string The user's full name. Example: John Doe
     * @bodyParam phone string The user's phone number. Example: +213555123456
     *
     * @response {
     *   "message": "Profile updated successfully",
     *   "user": {"id": 1, "name": "John Doe", "email": "john@example.com", "phone": "+213555123456"}
     * }
     */
    public function updateProfile(UpdateProfileRequest $request): JsonResponse
    {
        $user = $request->user();

        $user->update($request->validated());

        return response()->json([
            'message' => 'Profile updated successfully',
            'user' => new UserResource($user->fresh()),
        ]);
    }

    /**
     * Upload avatar
     *
     * Upload or update the authenticated user's profile picture.
     * Uses Cloudinary for persistent cloud storage.
     *
     * @authenticated
     * @bodyParam avatar file required The avatar image file (max 10MB, jpeg/png/jpg/gif/webp/heic). Example: avatar.jpg
     *
     * @response {
     *   "message": "Avatar uploaded successfully",
     *   "user": {"id": 1, "name": "John Doe", "avatar": "https://res.cloudinary.com/xxx/image/upload/avatars/user_1.jpg"}
     * }
     * @response 422 {"message": "The avatar field is required."}
     */
    public function uploadAvatar(Request $request): JsonResponse
    {
        $request->validate([
            'avatar' => ['required', 'image', 'mimes:jpeg,png,jpg,gif,webp,heic', 'max:10240'],
        ]);

        $user = $request->user();

        try {
            // Upload to Cloudinary
            $result = cloudinary()->upload($request->file('avatar')->getRealPath(), [
                'folder' => 'preuvely/avatars',
                'public_id' => 'user_' . $user->id,
                'overwrite' => true,
                'transformation' => [
                    'width' => 400,
                    'height' => 400,
                    'crop' => 'fill',
                    'gravity' => 'face',
                    'quality' => 'auto',
                    'fetch_format' => 'auto',
                ],
            ]);

            $avatarUrl = $result->getSecurePath();

            $user->update(['avatar' => $avatarUrl]);

            return response()->json([
                'message' => 'Avatar uploaded successfully',
                'user' => new UserResource($user->fresh()),
            ]);
        } catch (\Exception $e) {
            \Log::error('Avatar upload failed: ' . $e->getMessage());

            return response()->json([
                'message' => 'Failed to upload avatar. Please try again.',
            ], 500);
        }
    }
}
