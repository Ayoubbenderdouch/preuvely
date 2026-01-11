import Foundation

struct Category: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
    let nameAr: String
    let nameFr: String
    let nameEn: String?
    let slug: String
    let iconKey: String
    let isHighRisk: Bool
    let showOnHome: Bool?
    let storesCount: Int?

    // Note: Using JSONDecoder with .convertFromSnakeCase strategy
    // No explicit CodingKeys needed - snake_case is auto-converted to camelCase

    /// Whether this category should be shown on the home screen
    var shouldShowOnHome: Bool {
        showOnHome ?? true
    }

    /// Display stores count (defaults to 0 if null)
    var displayStoresCount: Int {
        storesCount ?? 0
    }

    /// Get localized name based on current language
    func localizedName(for language: AppLanguage) -> String {
        switch language {
        case .arabic: return nameAr
        case .french: return nameFr
        case .english: return nameEn ?? name
        }
    }

    /// SF Symbol name for the category (fallback)
    var sfSymbol: String {
        switch iconKey.lowercased() {
        case "phones", "electronics": return "iphone"
        case "fashion", "clothing", "clothes": return "tshirt.fill"
        case "beauty", "perfume", "perfumes": return "sparkles"
        case "food", "restaurant": return "fork.knife"
        case "kids", "toys": return "teddybear.fill"
        case "supplements", "health", "wellness": return "pill.fill"
        case "digital", "services": return "laptopcomputer"
        case "credits", "payments", "balances": return "creditcard.fill"
        case "reisen", "travel", "agency": return "airplane"
        case "fast_food", "fastfood": return "takeoutbag.and.cup.and.straw.fill"
        default: return "tag.fill"
        }
    }

    /// Local image asset name for the category
    var localImageName: String {
        switch iconKey.lowercased() {
        case "fashion", "clothing": return "cat_fashion"
        case "phones", "electronics": return "cat_electronics"
        case "beauty", "perfume", "perfumes": return "cat_beauty"
        case "kids", "toys": return "cat_kids"
        case "supplements", "health", "wellness": return "cat_supplements"
        case "food", "restaurant", "fastfood": return "cat_food"
        case "digital", "services": return "cat_digital"
        case "credits", "payments", "balances": return "cat_credits"
        case "reisen", "travel", "agency": return "reisenimg"
        case "fast_food", "fastfood": return "cat_food"
        default: return "cat_fashion" // fallback
        }
    }
}

// MARK: - Sample Data

extension Category {
    static let samples: [Category] = [
        Category(id: 1, name: "Fashion & Clothing", nameAr: "أزياء وملابس", nameFr: "Mode & Vêtements", nameEn: "Fashion & Clothing", slug: "fashion-clothing", iconKey: "fashion", isHighRisk: false, showOnHome: true, storesCount: 456),
        Category(id: 2, name: "Phones & Electronics", nameAr: "هواتف وإلكترونيات", nameFr: "Téléphones & Électronique", nameEn: "Phones & Electronics", slug: "phones-electronics", iconKey: "electronics", isHighRisk: false, showOnHome: true, storesCount: 234),
        Category(id: 3, name: "Beauty & Perfumes", nameAr: "جمال وعطور", nameFr: "Beauté & Parfums", nameEn: "Beauty & Perfumes", slug: "beauty-perfumes", iconKey: "beauty", isHighRisk: false, showOnHome: true, storesCount: 312),
        Category(id: 4, name: "Kids & Toys", nameAr: "أطفال وألعاب", nameFr: "Enfants & Jouets", nameEn: "Kids & Toys", slug: "kids-toys", iconKey: "kids", isHighRisk: false, showOnHome: true, storesCount: 145),
        Category(id: 5, name: "Supplements & Wellness", nameAr: "مكملات وصحة", nameFr: "Suppléments & Bien-être", nameEn: "Supplements & Wellness", slug: "supplements-wellness", iconKey: "supplements", isHighRisk: true, showOnHome: true, storesCount: 87),
        Category(id: 6, name: "Food & Fast Food", nameAr: "طعام ووجبات سريعة", nameFr: "Nourriture & Fast Food", nameEn: "Food & Fast Food", slug: "food-fastfood", iconKey: "food", isHighRisk: false, showOnHome: true, storesCount: 189),
        Category(id: 7, name: "Digital Services", nameAr: "خدمات رقمية", nameFr: "Services Numériques", nameEn: "Digital Services", slug: "digital-services", iconKey: "digital", isHighRisk: true, showOnHome: true, storesCount: 156),
        Category(id: 8, name: "Credits & Balances", nameAr: "أرصدة ومحافظ", nameFr: "Crédits & Soldes", nameEn: "Credits & Balances", slug: "credits-balances", iconKey: "credits", isHighRisk: true, showOnHome: true, storesCount: 134),
        Category(id: 9, name: "Fast Food", nameAr: "وجبات سريعة", nameFr: "Restauration Rapide", nameEn: "Fast Food", slug: "fast-food", iconKey: "fast_food", isHighRisk: false, showOnHome: false, storesCount: 12)
    ]
}
