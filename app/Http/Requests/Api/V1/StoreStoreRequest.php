<?php

namespace App\Http\Requests\Api\V1;

use App\Enums\Platform;
use App\Rules\NoDuplicateStore;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreStoreRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    protected function prepareForValidation(): void
    {
        // Handle JSON strings for links and contacts (from multipart form data)
        if ($this->has('links') && is_string($this->links)) {
            $decoded = json_decode($this->links, true);
            if (json_last_error() === JSON_ERROR_NONE) {
                $this->merge(['links' => $decoded]);
            }
        }

        if ($this->has('contacts') && is_string($this->contacts)) {
            $decoded = json_decode($this->contacts, true);
            if (json_last_error() === JSON_ERROR_NONE) {
                $this->merge(['contacts' => $decoded]);
            }
        }
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255', new NoDuplicateStore()],
            'description' => ['nullable', 'string', 'max:2000'],
            'city' => ['nullable', 'string', 'max:100'],
            'logo' => ['nullable', 'image', 'mimes:jpeg,png,jpg,webp', 'max:2048'],
            'category_ids' => ['required', 'array', 'min:1'],
            'category_ids.*' => ['exists:categories,id'],
            'links' => ['nullable', 'array'],
            'links.*.platform' => ['required', Rule::enum(Platform::class)],
            'links.*.url' => ['required', 'string', 'max:500'],
            'links.*.handle' => ['nullable', 'string', 'max:100'],
            'contacts' => ['nullable', 'array'],
            'contacts.whatsapp' => ['nullable', 'string', 'max:20'],
            'contacts.phone' => ['nullable', 'string', 'max:20'],
        ];
    }

    public function messages(): array
    {
        return [
            'category_ids.required' => 'At least one category is required.',
            'links.*.platform.required' => 'Each link must have a platform.',
            'links.*.url.required' => 'Each link must have a URL or handle.',
        ];
    }
}
