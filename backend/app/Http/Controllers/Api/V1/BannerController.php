<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\Api\V1\BannerResource;
use App\Models\Banner;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

/**
 * @group Banners
 *
 * APIs for promotional banners
 */
class BannerController extends Controller
{
    /**
     * List active banners
     *
     * Get all active promotional banners for the home screen carousel.
     * Banners are filtered by date range and ordered by sort_order.
     *
     * @queryParam locale string Language code (en, ar, fr). Example: en
     *
     * @response {
     *   "data": [
     *     {
     *       "id": 1,
     *       "title": "Summer Sale!",
     *       "subtitle": "Up to 50% off on all items",
     *       "image_url": "https://storage.preuvely.com/banners/summer-sale.jpg",
     *       "background_color": "#FF6B35",
     *       "link_type": "category",
     *       "link_value": "fashion"
     *     }
     *   ]
     * }
     */
    public function index(Request $request): AnonymousResourceCollection
    {
        $locale = $request->input('locale', 'en');

        $banners = Banner::active()
            ->ordered()
            ->get();

        return BannerResource::collection($banners)
            ->additional(['locale' => $locale]);
    }
}
