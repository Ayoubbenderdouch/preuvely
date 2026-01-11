<?php

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ReportResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'reportable_type' => strtolower(class_basename($this->reportable_type)),
            'reportable_id' => $this->reportable_id,
            'reportable_name' => $this->getReportableName(),
            'reason' => $this->reason->value,
            'note' => $this->note,
            'status' => $this->status->value,
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }

    /**
     * Get a displayable name for the reported content
     */
    private function getReportableName(): ?string
    {
        // Check if relationship is loaded using relationLoaded() to avoid MissingValue issues
        if (!$this->relationLoaded('reportable') || !$this->reportable) {
            return null;
        }

        $reportable = $this->reportable;

        return match (class_basename($this->reportable_type)) {
            'Store' => $reportable->name ?? null,
            'Review' => $reportable->relationLoaded('user') && $reportable->user?->name
                ? "Review by {$reportable->user->name}"
                : 'Review',
            'StoreReply' => 'Store Reply',
            default => null,
        };
    }
}
