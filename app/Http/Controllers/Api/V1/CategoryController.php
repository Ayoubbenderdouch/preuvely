<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\Api\V1\CategoryResource;
use App\Models\Category;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

/**
 * @group Categories
 *
 * APIs for browsing categories
 */
class CategoryController extends Controller
{
    /**
     * List all categories
     *
     * Get a list of all available store categories.
     *
     * @response {
     *   "data": [
     *     {"id": 1, "name": "Electronics", "slug": "electronics", "is_high_risk": false},
     *     {"id": 2, "name": "Digital Services", "slug": "digital-services", "is_high_risk": true}
     *   ]
     * }
     */
    public function index(): AnonymousResourceCollection
    {
        $categories = Category::withCount('stores')->orderBy('name_en')->get();

        return CategoryResource::collection($categories);
    }

    /**
     * Get category details
     *
     * Get details of a specific category by slug.
     *
     * @urlParam slug string required The category slug. Example: electronics
     *
     * @response {
     *   "data": {"id": 1, "name": "Electronics", "slug": "electronics", "is_high_risk": false}
     * }
     */
    public function show(string $slug): CategoryResource
    {
        $category = Category::withCount('stores')->where('slug', $slug)->firstOrFail();

        return new CategoryResource($category);
    }
}
