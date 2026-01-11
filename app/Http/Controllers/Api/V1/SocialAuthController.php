<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\Api\V1\UserResource;
use App\Models\User;
use App\Models\UserProvider;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Str;
use Laravel\Socialite\Facades\Socialite;
use Firebase\JWT\JWT;
use Firebase\JWT\JWK;
use Firebase\JWT\Key;

/**
 * @group Social Authentication
 *
 * APIs for OAuth social login (Google, Apple)
 */
class SocialAuthController extends Controller
{
    protected array $providers = ['google', 'apple'];

    /**
     * Get OAuth redirect URL
     *
     * Returns the OAuth provider's authorization URL.
     *
     * @urlParam provider string required The OAuth provider (google or apple). Example: google
     *
     * @response {"url": "https://accounts.google.com/o/oauth2/auth?..."}
     * @response 400 {"message": "Unsupported provider: facebook"}
     */
    public function redirect(string $provider): JsonResponse
    {
        if (!$this->isValidProvider($provider)) {
            return response()->json([
                'message' => "Unsupported provider: {$provider}",
            ], 400);
        }

        $driver = Socialite::driver($provider)->stateless();

        if ($provider === 'apple') {
            $driver->scopes(['name', 'email']);
        }

        $url = $driver->redirect()->getTargetUrl();

        return response()->json(['url' => $url]);
    }

    /**
     * Handle OAuth callback (GET)
     *
     * Handles the OAuth callback for providers that use GET (like Google).
     *
     * @urlParam provider string required The OAuth provider. Example: google
     * @queryParam code string required The authorization code.
     *
     * @response {"message": "Login successful", "user": {...}, "token": "...", "is_new_user": false}
     */
    public function callbackGet(Request $request, string $provider): JsonResponse
    {
        return $this->handleCallback($request, $provider);
    }

    /**
     * Handle OAuth callback (POST)
     *
     * Handles OAuth callback via POST. Supports both:
     * - OAuth code flow (web): Send 'code' parameter
     * - ID token flow (mobile): Send 'id_token' parameter
     *
     * @urlParam provider string required The OAuth provider. Example: apple
     * @bodyParam code string The authorization code (for web OAuth flow).
     * @bodyParam id_token string The ID token from native mobile sign-in.
     */
    public function callbackPost(Request $request, string $provider): JsonResponse
    {
        // Check if this is a mobile id_token request
        if ($request->has('id_token')) {
            return $this->handleIdTokenAuth($request, $provider);
        }

        return $this->handleCallback($request, $provider);
    }

    /**
     * Handle mobile authentication using id_token
     */
    protected function handleIdTokenAuth(Request $request, string $provider): JsonResponse
    {
        if (!$this->isValidProvider($provider)) {
            return response()->json([
                'message' => "Unsupported provider: {$provider}",
            ], 400);
        }

        $idToken = $request->input('id_token');

        try {
            $userData = match ($provider) {
                'google' => $this->verifyGoogleIdToken($idToken),
                'apple' => $this->verifyAppleIdToken($idToken),
                default => throw new \Exception("Unsupported provider for id_token: {$provider}"),
            };

            if (!$userData) {
                return response()->json([
                    'message' => 'Invalid or expired token',
                ], 401);
            }

            $result = $this->findOrCreateUserFromToken($userData, $provider);
            $user = $result['user'];
            $isNewUser = $result['is_new_user'];

            $token = $user->createToken('api-token')->plainTextToken;

            return response()->json([
                'message' => 'Login successful',
                'user' => new UserResource($user),
                'token' => $token,
                'is_new_user' => $isNewUser,
            ]);

        } catch (\Exception $e) {
            report($e);
            return response()->json([
                'message' => 'Failed to authenticate with provider',
                'error' => config('app.debug') ? $e->getMessage() : null,
            ], 401);
        }
    }

    /**
     * Verify Google ID token and return user data
     */
    protected function verifyGoogleIdToken(string $idToken): ?array
    {
        // Verify with Google's tokeninfo endpoint
        $response = Http::get('https://oauth2.googleapis.com/tokeninfo', [
            'id_token' => $idToken,
        ]);

        if (!$response->successful()) {
            return null;
        }

        $data = $response->json();

        // Verify the audience matches our client ID
        $validClientIds = [
            config('services.google.client_id'),
            config('services.google.ios_client_id'),
        ];

        if (!in_array($data['aud'] ?? '', array_filter($validClientIds))) {
            return null;
        }

        return [
            'provider_user_id' => $data['sub'],
            'email' => $data['email'] ?? null,
            'name' => $data['name'] ?? $data['email'] ?? 'User',
            'avatar' => $data['picture'] ?? null,
            'email_verified' => ($data['email_verified'] ?? 'false') === 'true',
        ];
    }

    /**
     * Verify Apple ID token and return user data
     */
    protected function verifyAppleIdToken(string $idToken): ?array
    {
        try {
            // Fetch Apple's public keys
            $response = Http::get('https://appleid.apple.com/auth/keys');

            if (!$response->successful()) {
                return null;
            }

            $keys = JWK::parseKeySet($response->json());

            // Decode and verify the token
            $decoded = JWT::decode($idToken, $keys);

            // Verify the audience matches our app
            $validAudiences = [
                config('services.apple.client_id'),
                config('services.apple.bundle_id'),
            ];

            if (!in_array($decoded->aud ?? '', array_filter($validAudiences))) {
                return null;
            }

            // Verify issuer
            if (($decoded->iss ?? '') !== 'https://appleid.apple.com') {
                return null;
            }

            return [
                'provider_user_id' => $decoded->sub,
                'email' => $decoded->email ?? null,
                'name' => null, // Apple doesn't include name in the token
                'avatar' => null,
                'email_verified' => ($decoded->email_verified ?? false) === true || ($decoded->email_verified ?? '') === 'true',
            ];
        } catch (\Exception $e) {
            report($e);
            return null;
        }
    }

    /**
     * Find or create user from verified token data
     */
    protected function findOrCreateUserFromToken(array $userData, string $provider): array
    {
        return DB::transaction(function () use ($userData, $provider) {
            $providerUserId = $userData['provider_user_id'];
            $email = $userData['email'];
            $name = $userData['name'] ?? 'User';

            // Check if this provider account is already linked
            $existingProvider = UserProvider::findByProvider($provider, $providerUserId);

            if ($existingProvider) {
                $existingProvider->update([
                    'email' => $email,
                    'meta_json' => [
                        'avatar' => $userData['avatar'] ?? null,
                        'email_verified' => $userData['email_verified'] ?? false,
                    ],
                ]);

                return [
                    'user' => $existingProvider->user,
                    'is_new_user' => false,
                ];
            }

            // Check if a user with the same verified email exists
            $existingUser = null;
            if ($email) {
                $existingUser = User::where('email', $email)
                    ->whereNotNull('email_verified_at')
                    ->first();
            }

            if ($existingUser) {
                UserProvider::create([
                    'user_id' => $existingUser->id,
                    'provider' => $provider,
                    'provider_user_id' => $providerUserId,
                    'email' => $email,
                    'meta_json' => [
                        'avatar' => $userData['avatar'] ?? null,
                        'email_verified' => $userData['email_verified'] ?? false,
                    ],
                ]);

                return [
                    'user' => $existingUser,
                    'is_new_user' => false,
                ];
            }

            // Create a new user
            $user = User::create([
                'name' => $name,
                'email' => $email,
                'email_verified_at' => $email ? now() : null,
                'password' => Hash::make(Str::random(32)),
            ]);

            UserProvider::create([
                'user_id' => $user->id,
                'provider' => $provider,
                'provider_user_id' => $providerUserId,
                'email' => $email,
                'meta_json' => [
                    'avatar' => $userData['avatar'] ?? null,
                    'email_verified' => $userData['email_verified'] ?? false,
                ],
            ]);

            return [
                'user' => $user,
                'is_new_user' => true,
            ];
        });
    }

    protected function handleCallback(Request $request, string $provider): JsonResponse
    {
        if (!$this->isValidProvider($provider)) {
            return response()->json([
                'message' => "Unsupported provider: {$provider}",
            ], 400);
        }

        try {
            $socialUser = Socialite::driver($provider)->stateless()->user();

            if (!$socialUser) {
                return response()->json([
                    'message' => 'Failed to authenticate with provider',
                ], 400);
            }

            $result = $this->findOrCreateUser($socialUser, $provider);
            $user = $result['user'];
            $isNewUser = $result['is_new_user'];

            $token = $user->createToken('api-token')->plainTextToken;

            return response()->json([
                'message' => 'Login successful',
                'user' => new UserResource($user),
                'token' => $token,
                'is_new_user' => $isNewUser,
            ]);

        } catch (\Exception $e) {
            report($e);
            return response()->json([
                'message' => 'Failed to authenticate with provider',
                'error' => config('app.debug') ? $e->getMessage() : null,
            ], 400);
        }
    }

    protected function findOrCreateUser(object $socialUser, string $provider): array
    {
        return DB::transaction(function () use ($socialUser, $provider) {
            $providerUserId = $socialUser->getId();
            $email = $socialUser->getEmail();
            $name = $socialUser->getName() ?? $socialUser->getNickname() ?? 'User';

            // Check if this provider account is already linked
            $existingProvider = UserProvider::findByProvider($provider, $providerUserId);

            if ($existingProvider) {
                $existingProvider->update([
                    'email' => $email,
                    'meta_json' => $this->buildMetaJson($socialUser, $provider),
                ]);

                return [
                    'user' => $existingProvider->user,
                    'is_new_user' => false,
                ];
            }

            // Check if a user with the same verified email exists
            $existingUser = null;
            if ($email) {
                $existingUser = User::where('email', $email)
                    ->whereNotNull('email_verified_at')
                    ->first();
            }

            if ($existingUser) {
                UserProvider::create([
                    'user_id' => $existingUser->id,
                    'provider' => $provider,
                    'provider_user_id' => $providerUserId,
                    'email' => $email,
                    'meta_json' => $this->buildMetaJson($socialUser, $provider),
                ]);

                return [
                    'user' => $existingUser,
                    'is_new_user' => false,
                ];
            }

            // Create a new user
            $user = User::create([
                'name' => $name,
                'email' => $email,
                'email_verified_at' => $email ? now() : null,
                'password' => Hash::make(Str::random(32)),
            ]);

            UserProvider::create([
                'user_id' => $user->id,
                'provider' => $provider,
                'provider_user_id' => $providerUserId,
                'email' => $email,
                'meta_json' => $this->buildMetaJson($socialUser, $provider),
            ]);

            return [
                'user' => $user,
                'is_new_user' => true,
            ];
        });
    }

    protected function buildMetaJson(object $socialUser, string $provider): array
    {
        $meta = [
            'avatar' => $socialUser->getAvatar(),
            'nickname' => $socialUser->getNickname(),
        ];

        if ($provider === 'google') {
            $meta['locale'] = $socialUser->user['locale'] ?? null;
            $meta['verified_email'] = $socialUser->user['verified_email'] ?? null;
        }

        return array_filter($meta);
    }

    protected function isValidProvider(string $provider): bool
    {
        return in_array($provider, $this->providers);
    }
}
