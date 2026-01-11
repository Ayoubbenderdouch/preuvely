<?php

namespace App\Http\Requests\Api\V1;

use App\Enums\Platform;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

/**
 * Request validation for bulk updating store links.
 *
 * Used by store owners to update all store links at once.
 * Supports platforms: website, instagram, facebook, tiktok, whatsapp
 */
class UpdateStoreLinksRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     *
     * Authorization is handled in the controller using isOwnerOf() check.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'links' => ['required', 'array'],
            'links.*.platform' => ['required', 'string', Rule::enum(Platform::class)],
            'links.*.url' => ['required', 'string', 'url', 'max:500'],
            'links.*.handle' => ['nullable', 'string', 'max:100'],
        ];
    }

    /**
     * Get custom error messages for validation rules.
     *
     * @return array<string, string>
     */
    public function messages(): array
    {
        return [
            'links.required' => 'Links array is required.',
            'links.array' => 'Links must be an array.',
            'links.*.platform.required' => 'Each link must have a platform.',
            'links.*.platform.enum' => 'Invalid platform. Allowed: website, instagram, facebook, tiktok, whatsapp.',
            'links.*.url.required' => 'Each link must have a URL.',
            'links.*.url.url' => 'Each link must have a valid URL format.',
            'links.*.url.max' => 'Link URL cannot exceed 500 characters.',
            'links.*.handle.max' => 'Handle cannot exceed 100 characters.',
        ];
    }

    /**
     * Get custom attributes for validator errors.
     *
     * @return array<string, string>
     */
    public function attributes(): array
    {
        return [
            'links.*.platform' => 'platform',
            'links.*.url' => 'URL',
            'links.*.handle' => 'handle',
        ];
    }
}
