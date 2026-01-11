<?php

namespace App\Http\Requests\Api\V1;

use App\Services\ContentModerationService;
use Illuminate\Foundation\Http\FormRequest;

class StoreReviewRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'stars' => ['required', 'integer', 'min:1', 'max:5'],
            'comment' => ['required', 'string', 'min:8', 'max:500'],
        ];
    }

    public function withValidator($validator): void
    {
        $validator->after(function ($validator) {
            if ($this->comment) {
                $moderationService = app(ContentModerationService::class);
                $result = $moderationService->validate($this->comment);

                if (!$result['valid']) {
                    $validator->errors()->add('comment', $result['message']);
                }
            }
        });
    }

    protected function passedValidation(): void
    {
        $moderationService = app(ContentModerationService::class);
        $this->merge([
            'comment' => $moderationService->sanitize($this->comment),
        ]);
    }
}
