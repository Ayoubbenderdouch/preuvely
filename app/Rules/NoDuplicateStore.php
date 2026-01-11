<?php

namespace App\Rules;

use App\Exceptions\DuplicateStoreException;
use App\Services\DuplicateStoreDetectionService;
use Closure;
use Illuminate\Contracts\Validation\DataAwareRule;
use Illuminate\Contracts\Validation\ValidationRule;

class NoDuplicateStore implements DataAwareRule, ValidationRule
{
    /**
     * All of the data under validation.
     *
     * @var array<string, mixed>
     */
    protected array $data = [];

    protected DuplicateStoreDetectionService $detectionService;

    public function __construct()
    {
        $this->detectionService = app(DuplicateStoreDetectionService::class);
    }

    /**
     * Set the data under validation.
     *
     * @param  array<string, mixed>  $data
     */
    public function setData(array $data): static
    {
        $this->data = $data;

        return $this;
    }

    /**
     * Run the validation rule.
     *
     * @param  \Closure(string, ?string=): \Illuminate\Translation\PotentiallyTranslatedString  $fail
     */
    public function validate(string $attribute, mixed $value, Closure $fail): void
    {
        $name = $this->data['name'] ?? '';
        $links = $this->data['links'] ?? [];

        $result = $this->detectionService->checkForDuplicates($name, $links);

        if ($result['has_duplicate']) {
            // Throw custom exception to be caught by the controller
            // This allows us to return the existing store info in the response
            throw new DuplicateStoreException(
                $result['duplicate_type'],
                $result['existing_store']
            );
        }
    }
}
