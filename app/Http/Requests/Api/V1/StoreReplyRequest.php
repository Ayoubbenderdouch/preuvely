<?php

namespace App\Http\Requests\Api\V1;

use App\Services\ContentModerationService;
use Illuminate\Foundation\Http\FormRequest;

class StoreReplyRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'reply_text' => ['required', 'string', 'max:300'],
        ];
    }

    public function withValidator($validator): void
    {
        $validator->after(function ($validator) {
            if ($this->reply_text) {
                $moderationService = app(ContentModerationService::class);
                $result = $moderationService->validate($this->reply_text);

                if (!$result['valid']) {
                    $validator->errors()->add('reply_text', $result['message']);
                }
            }
        });
    }

    protected function passedValidation(): void
    {
        $moderationService = app(ContentModerationService::class);
        $this->merge([
            'reply_text' => $moderationService->sanitize($this->reply_text),
        ]);
    }
}
