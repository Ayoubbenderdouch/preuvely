<?php

namespace App\Http\Requests\Api\V1;

use Illuminate\Foundation\Http\FormRequest;

class StoreClaimRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'requester_name' => ['required', 'string', 'max:255'],
            'requester_phone' => ['required', 'string', 'max:20'],
            'note' => ['nullable', 'string', 'max:1000'],
        ];
    }
}
