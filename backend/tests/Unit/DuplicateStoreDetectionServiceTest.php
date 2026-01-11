<?php

namespace Tests\Unit;

use App\Services\DuplicateStoreDetectionService;
use Tests\TestCase;

class DuplicateStoreDetectionServiceTest extends TestCase
{
    private DuplicateStoreDetectionService $service;

    protected function setUp(): void
    {
        parent::setUp();
        $this->service = new DuplicateStoreDetectionService();
    }

    /**
     * @dataProvider nameNormalizationProvider
     */
    public function test_normalize_name(string $input, string $expected): void
    {
        $this->assertEquals($expected, $this->service->normalizeName($input));
    }

    public static function nameNormalizationProvider(): array
    {
        return [
            'lowercase conversion' => ['Test Store', 'test'],
            'removes spaces' => ['My Store Name', 'myname'],
            'removes special characters' => ['Store-Name_123', 'name123'],
            'removes dots' => ['store.name', 'name'],
            'handles French ou to u' => ['Doum Doum', 'dumdum'],
            'handles multiple transliterations' => ['DouDoum BabyCare', 'dudumbabycare'],
            'removes common suffixes' => ['My Shop', 'my'],
            'removes dz suffix' => ['Store DZ', ''],
            'complex example' => ['DumDum BabyCare', 'dumdumbabycare'],
            'similar to DumDum' => ['doumdoum.babycare', 'dumdumbabycare'],
        ];
    }

    /**
     * @dataProvider handleNormalizationProvider
     */
    public function test_normalize_handle(string $input, string $expected): void
    {
        $this->assertEquals($expected, $this->service->normalizeHandle($input));
    }

    public static function handleNormalizationProvider(): array
    {
        return [
            'removes @ prefix' => ['@mystore', 'mystore'],
            'lowercase conversion' => ['@MyStore', 'mystore'],
            'removes dots' => ['my.store', 'mystore'],
            'removes underscores' => ['my_store', 'mystore'],
            'removes dots and underscores' => ['my.store_dz', 'mystoredz'],
            'handles @ with dots' => ['@my.store.dz', 'mystoredz'],
        ];
    }

    /**
     * @dataProvider urlHandleExtractionProvider
     */
    public function test_extract_handle_from_url(?string $expected, string $url): void
    {
        $this->assertEquals($expected, $this->service->extractHandleFromUrl($url));
    }

    public static function urlHandleExtractionProvider(): array
    {
        return [
            'instagram url' => ['mystore', 'https://instagram.com/mystore'],
            'instagram url with trailing slash' => ['mystore', 'https://instagram.com/mystore/'],
            'instagram url with www' => ['mystore', 'https://www.instagram.com/mystore'],
            'instagram url with query params' => ['mystore', 'https://instagram.com/mystore?igsh=abc123'],
            'facebook url' => ['mystore', 'https://facebook.com/mystore'],
            'facebook url with www' => ['mystore', 'https://www.facebook.com/mystore'],
            'tiktok url' => ['mystore', 'https://tiktok.com/@mystore'],
            'tiktok url without @' => ['mystore', 'https://tiktok.com/mystore'],
            'whatsapp url' => ['213555123456', 'https://wa.me/213555123456'],
            'generic url returns null' => [null, 'https://mywebsite.com/about'],
        ];
    }

    /**
     * @dataProvider similarityProvider
     */
    public function test_calculate_similarity(float $minExpected, string $a, string $b): void
    {
        $similarity = $this->service->calculateSimilarity($a, $b);
        $this->assertGreaterThanOrEqual($minExpected, $similarity);
    }

    public static function similarityProvider(): array
    {
        return [
            'exact match' => [1.0, 'MyStore', 'MyStore'],
            'case insensitive match' => [1.0, 'MyStore', 'mystore'],
            'normalized match with spaces' => [1.0, 'My Name', 'myname'],
            'similar names' => [0.7, 'TechStore', 'TechStores'],
            'DumDum variations' => [1.0, 'DumDum BabyCare', 'doumdoum.babycare'],
            'very different names' => [0.0, 'Apple', 'Microsoft'],
        ];
    }

    public function test_normalize_url(): void
    {
        $this->assertEquals(
            'instagram.com/mystore',
            $this->service->normalizeUrl('https://www.instagram.com/mystore/')
        );

        $this->assertEquals(
            'facebook.com/mypage',
            $this->service->normalizeUrl('http://facebook.com/mypage')
        );
    }
}
