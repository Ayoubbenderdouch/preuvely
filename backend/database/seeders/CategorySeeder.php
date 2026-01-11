<?php

namespace Database\Seeders;

use App\Enums\RiskLevel;
use App\Models\Category;
use Illuminate\Database\Seeder;

class CategorySeeder extends Seeder
{
    public function run(): void
    {
        $categories = [
            [
                'name_en' => 'Electronics',
                'name_ar' => 'الكترونيات',
                'name_fr' => 'Electronique',
                'slug' => 'electronics',
                'risk_level' => RiskLevel::Normal,
                'icon_key' => 'electronics',
            ],
            [
                'name_en' => 'Fashion',
                'name_ar' => 'أزياء',
                'name_fr' => 'Mode',
                'slug' => 'fashion',
                'risk_level' => RiskLevel::Normal,
                'icon_key' => 'fashion',
            ],
            [
                'name_en' => 'Beauty & Cosmetics',
                'name_ar' => 'الجمال ومستحضرات التجميل',
                'name_fr' => 'Beaute et Cosmetiques',
                'slug' => 'beauty-cosmetics',
                'risk_level' => RiskLevel::Normal,
                'icon_key' => 'beauty',
            ],
            [
                'name_en' => 'Kids & Toys',
                'name_ar' => 'أطفال وألعاب',
                'name_fr' => 'Enfants et Jouets',
                'slug' => 'kids-toys',
                'risk_level' => RiskLevel::Normal,
                'icon_key' => 'kids',
            ],
            [
                'name_en' => 'Supplements & Wellness',
                'name_ar' => 'مكملات وصحة',
                'name_fr' => 'Supplements et Bien-etre',
                'slug' => 'supplements-wellness',
                'risk_level' => RiskLevel::Normal,
                'icon_key' => 'supplements',
            ],
            [
                'name_en' => 'Travel Agency',
                'name_ar' => 'وكالة سفر',
                'name_fr' => 'Agence de Voyage',
                'slug' => 'travel-agency',
                'risk_level' => RiskLevel::Normal,
                'icon_key' => 'reisen',
            ],
            // High-risk categories
            [
                'name_en' => 'Digital Services',
                'name_ar' => 'خدمات رقمية',
                'name_fr' => 'Services Numeriques',
                'slug' => 'digital-services',
                'risk_level' => RiskLevel::HighRisk,
                'icon_key' => 'digital',
            ],
            [
                'name_en' => 'Credits & Balances',
                'name_ar' => 'أرصدة ومحافظ',
                'name_fr' => 'Credits et Soldes',
                'slug' => 'credits-balances',
                'risk_level' => RiskLevel::HighRisk,
                'icon_key' => 'credits',
            ],
            // Hidden from home (only in See All)
            [
                'name_en' => 'Fast Food',
                'name_ar' => 'وجبات سريعة',
                'name_fr' => 'Restauration Rapide',
                'slug' => 'fast-food',
                'risk_level' => RiskLevel::Normal,
                'icon_key' => 'fast_food',
                'show_on_home' => false,
            ],
        ];

        foreach ($categories as $category) {
            Category::updateOrCreate(
                ['slug' => $category['slug']],
                $category
            );
        }
    }
}
