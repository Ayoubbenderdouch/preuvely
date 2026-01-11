<?php

namespace App\Http\Requests\Api\V1;

use Illuminate\Foundation\Http\FormRequest;

class StoreProofRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'proof' => [
                'required',
                'image',
                'mimes:jpg,jpeg,png,webp',
                'max:5120', // 5MB
            ],
        ];
    }

    public function messages(): array
    {
        return [
            'proof.required' => 'A proof image is required.',
            'proof.image' => 'The proof must be an image.',
            'proof.mimes' => 'The proof must be a JPG, PNG, or WebP image.',
            'proof.max' => 'The proof image must not exceed 5MB.',
        ];
    }
}
