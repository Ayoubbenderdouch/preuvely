<?php

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class BannerResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $locale = $request->input('locale', 'en');

        return [
            'id' => $this->id,
            'title' => $this->getLocalizedTitle($locale),
            'subtitle' => $this->getLocalizedSubtitle($locale),
            'image_url' => $this->full_image_url,
            'background_color' => $this->background_color,
            'link_type' => $this->link_type,
            'link_value' => $this->link_value,
        ];
    }
}
