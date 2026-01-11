<?php

namespace App\Filament\Dataentry\Resources\StoreResource\Pages;

use App\Filament\Dataentry\Resources\StoreResource;
use App\Models\StoreLink;
use App\Models\StoreContact;
use App\Enums\Platform;
use Filament\Resources\Pages\CreateRecord;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Str;
use Filament\Notifications\Notification;

class CreateStore extends CreateRecord
{
    protected static string $resource = StoreResource::class;

    public function getTitle(): string
    {
        return 'Add New Store';
    }

    public function getSubheading(): ?string
    {
        return 'Add a new e-commerce store to Preuvely';
    }

    protected function mutateFormDataBeforeCreate(array $data): array
    {
        // Set the submitted_by to the current user
        $data['submitted_by'] = Auth::id();

        // Generate slug if not set
        if (empty($data['slug'])) {
            $data['slug'] = Str::slug($data['name']);
        }

        // Ensure unique slug
        $originalSlug = $data['slug'];
        $counter = 1;
        while (\App\Models\Store::where('slug', $data['slug'])->exists()) {
            $data['slug'] = $originalSlug . '-' . $counter;
            $counter++;
        }

        return $data;
    }

    protected function afterCreate(): void
    {
        $store = $this->record;
        $data = $this->data;

        // Create store links from form data
        $links = [];

        if (!empty($data['instagram_url'])) {
            $links[] = [
                'store_id' => $store->id,
                'platform' => Platform::Instagram->value,
                'url' => $data['instagram_url'],
                'handle' => $this->extractHandle($data['instagram_url'], 'instagram'),
            ];
        }

        if (!empty($data['tiktok_url'])) {
            $links[] = [
                'store_id' => $store->id,
                'platform' => Platform::Tiktok->value,
                'url' => $data['tiktok_url'],
                'handle' => $this->extractHandle($data['tiktok_url'], 'tiktok'),
            ];
        }

        if (!empty($data['facebook_url'])) {
            $links[] = [
                'store_id' => $store->id,
                'platform' => Platform::Facebook->value,
                'url' => $data['facebook_url'],
                'handle' => $this->extractHandle($data['facebook_url'], 'facebook'),
            ];
        }

        if (!empty($data['website_url'])) {
            $links[] = [
                'store_id' => $store->id,
                'platform' => Platform::Website->value,
                'url' => $data['website_url'],
                'handle' => null,
            ];
        }

        // Insert all links
        foreach ($links as $link) {
            StoreLink::create($link);
        }

        // Create store contact if provided
        if (!empty($data['whatsapp']) || !empty($data['phone'])) {
            StoreContact::create([
                'store_id' => $store->id,
                'whatsapp' => $data['whatsapp'] ?? null,
                'phone' => $data['phone'] ?? null,
            ]);
        }

        // Show success notification
        Notification::make()
            ->title('Store Added Successfully!')
            ->body("'{$store->name}' has been added and is pending verification.")
            ->success()
            ->duration(5000)
            ->send();
    }

    private function extractHandle(string $url, string $platform): ?string
    {
        return match ($platform) {
            'instagram' => $this->extractFromPattern($url, '/instagram\.com\/([^\/\?]+)/'),
            'tiktok' => $this->extractFromPattern($url, '/tiktok\.com\/@?([^\/\?]+)/'),
            'facebook' => $this->extractFromPattern($url, '/facebook\.com\/([^\/\?]+)/'),
            default => null,
        };
    }

    private function extractFromPattern(string $url, string $pattern): ?string
    {
        if (preg_match($pattern, $url, $matches)) {
            return $matches[1] ?? null;
        }
        return null;
    }

    protected function getRedirectUrl(): string
    {
        return $this->getResource()::getUrl('index');
    }

    protected function getCreatedNotification(): ?\Filament\Notifications\Notification
    {
        return null; // We handle notification in afterCreate
    }
}
