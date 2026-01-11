<?php

namespace App\Exceptions;

use Exception;
use Illuminate\Http\JsonResponse;

class DuplicateStoreException extends Exception
{
    protected string $duplicateType;
    protected array $existingStore;

    public function __construct(
        string $duplicateType,
        array $existingStore,
        string $message = 'A store with similar details already exists'
    ) {
        parent::__construct($message);
        $this->duplicateType = $duplicateType;
        $this->existingStore = $existingStore;
    }

    public function getDuplicateType(): string
    {
        return $this->duplicateType;
    }

    public function getExistingStore(): array
    {
        return $this->existingStore;
    }

    /**
     * Render the exception as an HTTP response.
     */
    public function render(): JsonResponse
    {
        $message = match ($this->duplicateType) {
            'name' => 'A store with a similar name already exists.',
            'handle' => 'A store with this social media handle already exists.',
            'social_link' => 'A store with this social media link already exists.',
            default => 'This store already exists.',
        };

        return response()->json([
            'message' => $message,
            'error' => 'duplicate_store',
            'duplicate_type' => $this->duplicateType,
            'existing_store' => $this->existingStore,
        ], 409); // 409 Conflict
    }
}
