<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Enums\RiskLevel;
use App\Http\Controllers\Controller;
use App\Http\Resources\Api\V1\CategoryResource;
use App\Models\Category;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

/**
 * @group Admin - Categories
 *
 * APIs for admin category management
 */
class CategoryController extends Controller
{
    /**
     * Update category risk level
     *
     * Update the risk level of a category. Only accessible by admins.
     *
     * @authenticated
     * @urlParam id integer required The category ID. Example: 1
     * @bodyParam risk_level string required The risk level. Example: high_risk
     *
     * @response 200 {
     *   "message": "Category risk level updated successfully",
     *   "data": {"id": 1, "name": "Crypto", "risk_level": "high_risk"}
     * }
     * @response 403 {"message": "Unauthorized"}
     * @response 422 {"message": "Validation error"}
     */
    public function updateRiskLevel(Request $request, Category $category): JsonResponse
    {
        $validated = $request->validate([
            'risk_level' => ['required', 'string', Rule::enum(RiskLevel::class)],
        ]);

        $category->update([
            'risk_level' => $validated['risk_level'],
        ]);

        return response()->json([
            'message' => 'Category risk level updated successfully.',
            'data' => new CategoryResource($category->fresh()),
        ]);
    }
}
