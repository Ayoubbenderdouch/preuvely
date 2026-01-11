<?php

namespace Database\Seeders;

use App\Enums\Platform;
use App\Models\Category;
use App\Models\Store;
use Illuminate\Database\Seeder;

class DemoStoreSeeder extends Seeder
{
    public function run(): void
    {
        $stores = [
            [
                'name' => 'TechZone DZ',
                'description' => 'Your trusted electronics store in Algeria. We sell phones, laptops, and accessories.',
                'city' => 'Algiers',
                'is_verified' => true,
                'categories' => ['electronics'],
                'links' => [
                    ['platform' => Platform::Instagram, 'url' => 'https://instagram.com/techzonedz', 'handle' => 'techzonedz'],
                    ['platform' => Platform::Facebook, 'url' => 'https://facebook.com/techzonedz'],
                ],
                'contacts' => ['whatsapp' => '+213555111111', 'phone' => '+213555111111'],
            ],
            [
                'name' => 'StyleShop Algeria',
                'description' => 'Latest fashion trends from Turkey and Europe. Authentic products guaranteed.',
                'city' => 'Oran',
                'is_verified' => true,
                'categories' => ['fashion'],
                'links' => [
                    ['platform' => Platform::Instagram, 'url' => 'https://instagram.com/styleshop.dz', 'handle' => 'styleshop.dz'],
                ],
                'contacts' => ['whatsapp' => '+213555222222'],
            ],
            [
                'name' => 'CryptoExchange DZ',
                'description' => 'Buy and sell USDT safely. Fast transactions and competitive rates.',
                'city' => 'Algiers',
                'is_verified' => false,
                'categories' => ['credits-balances', 'digital-services'],
                'links' => [
                    ['platform' => Platform::Website, 'url' => 'https://cryptoexchange-dz.com'],
                ],
                'contacts' => ['whatsapp' => '+213555333333'],
            ],
            [
                'name' => 'GameCards DZ',
                'description' => 'All your gaming needs: PSN, Xbox, Steam, and more!',
                'city' => 'Constantine',
                'is_verified' => true,
                'categories' => ['credits-balances', 'digital-services'],
                'links' => [
                    ['platform' => Platform::Instagram, 'url' => 'https://instagram.com/gamecards.dz', 'handle' => 'gamecards.dz'],
                    ['platform' => Platform::Facebook, 'url' => 'https://facebook.com/gamecards.dz'],
                ],
                'contacts' => ['whatsapp' => '+213555444444', 'phone' => '+213555444444'],
            ],
            [
                'name' => 'BeautyBox Algeria',
                'description' => 'Original cosmetics and skincare products. Authorized distributor for major brands.',
                'city' => 'Blida',
                'is_verified' => true,
                'categories' => ['beauty-cosmetics'],
                'links' => [
                    ['platform' => Platform::Instagram, 'url' => 'https://instagram.com/beautybox.dz', 'handle' => 'beautybox.dz'],
                    ['platform' => Platform::Tiktok, 'url' => 'https://tiktok.com/@beautybox.dz', 'handle' => 'beautybox.dz'],
                ],
                'contacts' => ['whatsapp' => '+213555555555'],
            ],
        ];

        foreach ($stores as $storeData) {
            $categoryIds = Category::whereIn('slug', $storeData['categories'])->pluck('id');

            $store = Store::firstOrCreate(
                ['name' => $storeData['name']],
                [
                    'name' => $storeData['name'],
                    'description' => $storeData['description'],
                    'city' => $storeData['city'],
                    'is_verified' => $storeData['is_verified'],
                    'verified_at' => $storeData['is_verified'] ? now() : null,
                    'avg_rating_cache' => rand(35, 50) / 10,
                    'reviews_count_cache' => rand(5, 50),
                ]
            );

            $store->categories()->syncWithoutDetaching($categoryIds);

            // Add links
            foreach ($storeData['links'] as $link) {
                $store->links()->firstOrCreate(
                    ['platform' => $link['platform']],
                    $link
                );
            }

            // Add contacts
            if (isset($storeData['contacts']) && !$store->contacts) {
                $store->contacts()->create($storeData['contacts']);
            }
        }
    }
}
