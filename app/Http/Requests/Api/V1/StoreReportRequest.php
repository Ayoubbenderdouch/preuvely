<?php

namespace App\Http\Requests\Api\V1;

use App\Enums\ReportReason;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreReportRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'reportable_type' => ['required', Rule::in(['review', 'reply', 'store'])],
            'reportable_id' => ['required', 'integer'],
            'reason' => ['required', Rule::enum(ReportReason::class)],
            'note' => ['nullable', 'string', 'max:1000'],
        ];
    }

    public function withValidator($validator): void
    {
        $validator->after(function ($validator) {
            $type = $this->reportable_type;
            $id = $this->reportable_id;

            $modelClass = match ($type) {
                'review' => \App\Models\Review::class,
                'reply' => \App\Models\StoreReply::class,
                'store' => \App\Models\Store::class,
                default => null,
            };

            if ($modelClass && !$modelClass::find($id)) {
                $validator->errors()->add('reportable_id', "The {$type} does not exist.");
            }
        });
    }
}
