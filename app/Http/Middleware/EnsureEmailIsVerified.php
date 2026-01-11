<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureEmailIsVerified
{
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();

        if (!$user) {
            return $next($request);
        }

        // If user has no email, allow through (phone-only registration)
        if (!$user->email) {
            return $next($request);
        }

        // If user has email but hasn't verified it, deny access
        if (!$user->hasVerifiedEmail()) {
            return response()->json([
                'message' => 'Your email address is not verified.',
                'error' => 'email_not_verified',
            ], 403);
        }

        return $next($request);
    }
}
