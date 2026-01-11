<?php

namespace App\Filament\Dataentry\Resources\StoreResource\Pages;

use App\Filament\Dataentry\Resources\StoreResource;
use App\Models\StoreLink;
use App\Models\StoreContact;
use App\Enums\Platform;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;
use Filament\Notifications\Notification;

class EditStore extends EditRecord
{
    protected static string $resource = StoreResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\ViewAction::make()
                ->label('View')
                ->icon('heroicon-o-eye'),
            Actions\DeleteAction::make()
                ->label('Delete')
                ->icon('heroicon-o-trash'),
        ];
    }

    protected function mutateFormDataBeforeFill(array $data): array
    {
        // Load existing links into form fields
        $store = $this->record;

        foreach ($store->links as $link) {
            $platform = $link->platform;
            $data["{$platform}_url"] = $link->url;
        }

        // Load contact info
        if ($store->contacts) {
            $data['whatsapp'] = $store->contacts->whatsapp;
            $data['phone'] = $store->contacts->phone;
        }

        return $data;
    }

    protected function afterSave(): void
    {
        $store = $this->record;
        $data = $this->data;

        // Update links
        $linkData = [
            'instagram' => $data['instagram_url'] ?? null,
            'tiktok' => $data['tiktok_url'] ?? null,
            'facebook' => $data['facebook_url'] ?? null,
            'website' => $data['website_url'] ?? null,
        ];

        foreach ($linkData as $platform => $url) {
            $existingLink = $store->links()->where('platform', $platform)->first();

            if ($url) {
                // Create or update link
                StoreLink::updateOrCreate(
                    ['store_id' => $store->id, 'platform' => $platform],
                    [
                        'url' => $url,
                        'handle' => $this->extractHandle($url, $platform),
                    ]
                );
            } elseif ($existingLink) {
                // Remove link if URL is empty
                $existingLink->delete();
            }
        }

        // Update contact info
        StoreContact::updateOrCreate(
            ['store_id' => $store->id],
            [
                'whatsapp' => $data['whatsapp'] ?? null,
                'phone' => $data['phone'] ?? null,
            ]
        );

        Notification::make()
            ->title('Store Updated!')
            ->body("'{$store->name}' has been updated successfully.")
            ->success()
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

    protected function getSavedNotification(): ?\Filament\Notifications\Notification
    {
        return null; // We handle notification in afterSave
    }
}
