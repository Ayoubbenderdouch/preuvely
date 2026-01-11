<?php

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class CategoryResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'name_ar' => $this->name_ar,
            'name_fr' => $this->name_fr,
            'name_en' => $this->name_en,
            'slug' => $this->slug,
            'risk_level' => $this->risk_level?->value,
            'is_high_risk' => $this->is_high_risk, // Backward compatibility
            'icon_key' => $this->icon_key,
            'show_on_home' => $this->show_on_home ?? true,
            'stores_count' => $this->stores_count ?? 0,
        ];
    }
}
