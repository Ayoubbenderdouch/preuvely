import SwiftUI
import Combine

// MARK: - Supported Languages

enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case french = "fr"
    case arabic = "ar"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .english: return "English"
        case .french: return "Français"
        case .arabic: return "العربية"
        }
    }

    var flagImage: String {
        switch self {
        case .english: return "united kingdom"
        case .french: return "france"
        case .arabic: return "Algeria"
        }
    }

    var nativeName: String {
        switch self {
        case .english: return "English"
        case .french: return "Français"
        case .arabic: return "العربية"
        }
    }

    var countryName: String {
        switch self {
        case .english: return "United Kingdom"
        case .french: return "France"
        case .arabic: return "Algeria"
        }
    }

    var isRTL: Bool {
        self == .arabic
    }

    var locale: Locale {
        Locale(identifier: rawValue)
    }
}

// MARK: - Localization Manager

final class LocalizationManager: ObservableObject {
    @MainActor static let shared = LocalizationManager()

    @AppStorage("selectedLanguage") private var storedLanguage: String = ""
    @Published var currentLanguage: AppLanguage = .english

    private init() {
        if storedLanguage.isEmpty {
            // Use system language
            let preferredLanguage = Locale.preferredLanguages.first ?? "en"
            if preferredLanguage.starts(with: "ar") {
                currentLanguage = .arabic
            } else if preferredLanguage.starts(with: "fr") {
                currentLanguage = .french
            } else {
                currentLanguage = .english
            }
        } else {
            currentLanguage = AppLanguage(rawValue: storedLanguage) ?? .english
        }
    }

    func setLanguage(_ language: AppLanguage) {
        currentLanguage = language
        storedLanguage = language.rawValue
        UserDefaults.standard.set([language.rawValue], forKey: "AppleLanguages")
        // Clear the localization bundle cache so strings are fetched from the new language
        LocalizationBundleCache.clearCache()
    }

    var layoutDirection: LayoutDirection {
        currentLanguage.isRTL ? .rightToLeft : .leftToRight
    }
}

// MARK: - Localization Bundle Cache

/// A helper class to cache language bundles for efficient string lookups.
/// This avoids repeated file system operations on each string localization.
private enum LocalizationBundleCache {
    /// Cache of language code to bundle mappings
    private static var bundles: [String: Bundle] = [:]

    /// Gets or creates a bundle for the specified language code
    static func bundle(for languageCode: String) -> Bundle {
        // Return cached bundle if available
        if let cached = bundles[languageCode] {
            return cached
        }

        // Find and cache the bundle
        let bundle = findBundle(for: languageCode)
        bundles[languageCode] = bundle
        return bundle
    }

    /// Clears the cache (useful when language changes)
    static func clearCache() {
        bundles.removeAll()
    }

    /// Finds the appropriate bundle for a language code
    private static func findBundle(for languageCode: String) -> Bundle {
        guard let resourcePath = Bundle.main.resourcePath else {
            return Bundle.main
        }

        // List of possible subdirectories where localization files might be located
        let possibleSubdirectories = [
            "Localization",                    // Direct subdirectory
            "Resources/Localization",          // Nested in Resources
            ""                                 // Root of bundle
        ]

        for subdirectory in possibleSubdirectories {
            var langPath: String
            if subdirectory.isEmpty {
                langPath = (resourcePath as NSString).appendingPathComponent("\(languageCode).lproj")
            } else {
                let subPath = (resourcePath as NSString).appendingPathComponent(subdirectory)
                langPath = (subPath as NSString).appendingPathComponent("\(languageCode).lproj")
            }

            if let bundle = Bundle(path: langPath) {
                // Verify the bundle contains Localizable.strings
                if bundle.path(forResource: "Localizable", ofType: "strings") != nil {
                    return bundle
                }
            }
        }

        // Try using Bundle.main.url with subdirectory
        if let url = Bundle.main.url(forResource: languageCode, withExtension: "lproj", subdirectory: "Localization"),
           let bundle = Bundle(url: url) {
            return bundle
        }

        // Try standard path (for when .lproj is at bundle root)
        if let bundlePath = Bundle.main.path(forResource: languageCode, ofType: "lproj"),
           let bundle = Bundle(path: bundlePath) {
            return bundle
        }

        // Fallback to main bundle
        return Bundle.main
    }
}

// MARK: - Localized String Helper

extension String {
    /// Returns the localized string for the current app language.
    /// This property dynamically looks up the correct language bundle based on
    /// the user's selected language in LocalizationManager.
    var localized: String {
        // Get the current language from LocalizationManager
        let languageCode = UserDefaults.standard.string(forKey: "selectedLanguage") ?? {
            // Fallback to system preferred language
            let preferredLanguage = Locale.preferredLanguages.first ?? "en"
            if preferredLanguage.starts(with: "ar") {
                return "ar"
            } else if preferredLanguage.starts(with: "fr") {
                return "fr"
            }
            return "en"
        }()

        // Get the cached bundle for this language
        let bundle = LocalizationBundleCache.bundle(for: languageCode)

        // Get the localized string from the bundle
        let localizedString = bundle.localizedString(forKey: self, value: nil, table: nil)

        // If the key was returned (not found in current language), try English as fallback
        if localizedString == self && languageCode != "en" {
            let englishBundle = LocalizationBundleCache.bundle(for: "en")
            let englishString = englishBundle.localizedString(forKey: self, value: nil, table: nil)
            if englishString != self {
                return englishString
            }
        }

        return localizedString
    }

    /// Returns the localized string with format arguments.
    /// - Parameter arguments: The arguments to insert into the localized format string.
    /// - Returns: The formatted localized string.
    func localized(with arguments: CVarArg...) -> String {
        String(format: self.localized, arguments: arguments)
    }
}

// MARK: - Localization Keys

enum L10n {

    // MARK: - Common

    enum Common {
        static let appName = "app_name"
        static let cancel = "common_cancel"
        static let done = "common_done"
        static let save = "common_save"
        static let delete = "common_delete"
        static let edit = "common_edit"
        static let submit = "common_submit"
        static let loading = "common_loading"
        static let error = "common_error"
        static let retry = "common_retry"
        static let success = "common_success"
        static let search = "common_search"
        static let seeAll = "common_see_all"
        static let noResults = "common_no_results"
        static let ok = "common_ok"
        static let all = "common_all"
        static let optional = "common_optional"
        static let more = "common_more"
        static let reset = "common_reset"
        static let apply = "common_apply"
        static let verified = "common_verified"
        static let tryAgain = "common_try_again"
        static let oops = "common_oops"
    }

    // MARK: - Onboarding

    enum Onboarding {
        static let page1Title = "onboarding_page1_title"
        static let page1Subtitle = "onboarding_page1_subtitle"
        static let page2Title = "onboarding_page2_title"
        static let page2Subtitle = "onboarding_page2_subtitle"
        static let page3Title = "onboarding_page3_title"
        static let page3Subtitle = "onboarding_page3_subtitle"
        static let getStarted = "onboarding_get_started"
        static let continueButton = "onboarding_continue"
        static let skip = "onboarding_skip"
    }

    // MARK: - Tabs

    enum Tabs {
        static let home = "tab_home"
        static let search = "tab_search"
        static let add = "tab_add"
        static let profile = "tab_profile"
        static let account = "tab_account"
    }

    // MARK: - Home

    enum Home {
        static let tagline = "home_tagline"
        static let categories = "home_categories"
        static let trending = "home_trending"
        static let topRated = "home_top_rated"
        static let topReviewed = "home_top_reviewed"
        static let searchPlaceholder = "home_search_placeholder"
        static let allCategories = "home_all_categories"
        static let discoverTrustedStores = "home_discover_trusted_stores"
        static let verifiedReviewsTrust = "home_verified_reviews_trust"
        static let newStoresThisWeek = "home_new_stores_week"
        static let checkLatestAdditions = "home_check_latest"
        static let highRiskProtection = "home_high_risk_protection"
        static let proofVerifiedReviews = "home_proof_verified_reviews"
        static let claimYourStore = "home_claim_your_store"
        static let getVerifiedRespond = "home_get_verified_respond"
        static let reviewsCount = "home_reviews_count"
    }

    // MARK: - Search

    enum Search {
        static let placeholder = "search_placeholder"
        static let filters = "search_filters"
        static let category = "search_category"
        static let verifiedOnly = "search_verified_only"
        static let sortBy = "search_sort_by"
        static let bestRated = "search_best_rated"
        static let mostReviewed = "search_most_reviewed"
        static let newest = "search_newest"
        static let noStoreFound = "search_no_store_found"
        static let addThisStore = "search_add_this_store"
        static let searching = "search_searching"
        static let adjustSearchOrAdd = "search_adjust_or_add"
        static let searchForStores = "search_for_stores"
        static let findStoresByName = "search_find_by_name"
        static let hintTitle = "search_hint_title"
        static let hintName = "search_hint_name"
        static let hintTikTok = "search_hint_tiktok"
        static let hintInstagram = "search_hint_instagram"
        static let hintFacebook = "search_hint_facebook"
        static let hintWhatsApp = "search_hint_whatsapp"
        static let hintPhone = "search_hint_phone"
        static let hintLink = "search_hint_link"
    }

    // MARK: - Store

    enum Store {
        static let verified = "store_verified"
        static let reviews = "store_reviews"
        static let rating = "store_rating"
        static let writeReview = "store_write_review"
        static let claimStore = "store_claim"
        static let reportStore = "store_report"
        static let links = "store_links"
        static let contact = "store_contact"
        static let ratingBreakdown = "store_rating_breakdown"
        static let noReviewsYet = "store_no_reviews_yet"
        static let beFirstToReview = "store_be_first_review"
        static let call = "store_call"
        static let submittedBy = "store_submitted_by"
        static let submitterStats = "store_submitter_stats"
    }

    // MARK: - Review

    enum Review {
        static let yourRating = "review_your_rating"
        static let writeComment = "review_write_comment"
        static let commentPlaceholder = "review_comment_placeholder"
        static let proofRequired = "review_proof_required"
        static let uploadProof = "review_upload_proof"
        static let proofPending = "review_proof_pending"
        static let proofApproved = "review_proof_approved"
        static let proofRejected = "review_proof_rejected"
        static let submitReview = "review_submit"
        static let hasProof = "review_has_proof"
        static let merchantReply = "review_merchant_reply"
        static let successTitle = "review_success_title"
        static let successMessage = "review_success_message"
        static let successMessageProof = "review_success_message_proof"
        static let minCharactersRequired = "review_min_characters"
        static let highRiskProofExplanation = "review_high_risk_explanation"
    }

    // MARK: - Add Store

    enum AddStore {
        static let title = "add_store_title"
        static let storeName = "add_store_name"
        static let platform = "add_store_platform"
        static let linkHandle = "add_store_link"
        static let whatsapp = "add_store_whatsapp"
        static let phone = "add_store_phone"
        static let categories = "add_store_categories"
        static let city = "add_store_city"
        static let submit = "add_store_submit"
        static let success = "add_store_success"
        static let addToPreuvely = "add_store_to_preuvely"
        static let helpOthersDiscover = "add_store_help_discover"
        static let storeNamePlaceholder = "add_store_name_placeholder"
        static let selectCategories = "add_store_select_categories"
        static let cityPlaceholder = "add_store_city_placeholder"
        static let enterLinkOrHandle = "add_store_enter_link"
        static let storeAddedTitle = "add_store_added_title"
        static let storeAddedMessage = "add_store_added_message"
        static let viewStore = "add_store_view_store"
        static let addAnother = "add_store_add_another"
        static let highRisk = "add_store_high_risk"
    }

    // MARK: - Auth

    enum Auth {
        static let signIn = "auth_sign_in"
        static let signUp = "auth_sign_up"
        static let email = "auth_email"
        static let password = "auth_password"
        static let confirmPassword = "auth_confirm_password"
        static let forgotPassword = "auth_forgot_password"
        static let orContinueWith = "auth_or_continue_with"
        static let signInWithGoogle = "auth_google"
        static let signInWithApple = "auth_apple"
        static let verifyEmail = "auth_verify_email"
        static let verifyEmailMessage = "auth_verify_email_message"
        static let resendEmail = "auth_resend_email"
        static let noAccount = "auth_no_account"
        static let haveAccount = "auth_have_account"
        static let logout = "auth_logout"
        static let name = "auth_name"
        static let namePlaceholder = "auth_name_placeholder"
        static let emailPlaceholder = "auth_email_placeholder"
        static let passwordPlaceholder = "auth_password_placeholder"
        static let passwordMinCharacters = "auth_password_min"
        static let passwordsDoNotMatch = "auth_passwords_mismatch"
        static let trustThroughProof = "auth_trust_through_proof"
    }

    // MARK: - Profile

    enum Profile {
        static let guest = "profile_guest"
        static let myReviews = "profile_my_reviews"
        static let myClaims = "profile_my_claims"
        static let settings = "profile_settings"
        static let language = "profile_language"
        static let support = "profile_support"
        static let terms = "profile_terms"
        static let privacy = "profile_privacy"
        static let about = "profile_about"
        static let signInToAccess = "profile_sign_in_to_access"
        static let noReviewsYet = "profile_no_reviews_yet"
        static let noClaimsYet = "profile_no_claims_yet"
        static let seeAllReviews = "profile_see_all_reviews"
        static let followUs = "profile_follow_us"
    }

    // MARK: - Claims

    enum Claim {
        static let title = "claim_title"
        static let ownerName = "claim_owner_name"
        static let phone = "claim_phone"
        static let note = "claim_note"
        static let submit = "claim_submit"
        static let pending = "claim_pending"
        static let approved = "claim_approved"
        static let rejected = "claim_rejected"
        static let submittedTitle = "claim_submitted_title"
        static let submittedMessage = "claim_submitted_message"
        static let claimStoreName = "claim_store_name"
        static let ownerBenefits = "claim_owner_benefits"
        static let ownerNamePlaceholder = "claim_owner_name_placeholder"
        static let notePlaceholder = "claim_note_placeholder"
        static let whatsapp = "claim_whatsapp"
        static let whatsappPlaceholder = "claim_whatsapp_placeholder"
        static let successTitle = "claim_success_title"
        static let successMessage = "claim_success_message"
        static let gotIt = "claim_got_it"
    }

    // MARK: - Report

    enum Report {
        static let title = "report_title"
        static let reason = "report_reason"
        static let note = "report_note"
        static let submit = "report_submit"
        static let success = "report_success"
        static let submittedTitle = "report_submitted_title"
        static let submittedMessage = "report_submitted_message"
        static let thankYouMessage = "report_thank_you_message"
        static let reporting = "report_reporting"
        static let notePlaceholder = "report_note_placeholder"

        enum Reason {
            static let spam = "report_reason_spam"
            static let abuse = "report_reason_abuse"
            static let fake = "report_reason_fake"
            static let other = "report_reason_other"
        }
    }

    // MARK: - Notifications

    enum Notification {
        static let title = "notification_title"
        static let emptyTitle = "notification_empty_title"
        static let emptyMessage = "notification_empty_message"
        static let markAllRead = "notification_mark_all_read"
        static let markRead = "notification_mark_read"
        static let today = "notification_today"
        static let yesterday = "notification_yesterday"
        static let thisWeek = "notification_this_week"
        static let older = "notification_older"

        // Notification Types - Titles
        static let reviewReceivedTitle = "notification_review_received_title"
        static let reviewApprovedTitle = "notification_review_approved_title"
        static let reviewRejectedTitle = "notification_review_rejected_title"
        static let claimApprovedTitle = "notification_claim_approved_title"
        static let claimRejectedTitle = "notification_claim_rejected_title"
        static let storeApprovedTitle = "notification_store_approved_title"
        static let newReplyTitle = "notification_new_reply_title"
        static let storeVerifiedTitle = "notification_store_verified_title"

        // Notification Types - Messages
        static let reviewReceivedMessage = "notification_review_received_message"
        static let reviewApprovedMessage = "notification_review_approved_message"
        static let reviewRejectedMessage = "notification_review_rejected_message"
        static let claimApprovedMessage = "notification_claim_approved_message"
        static let claimRejectedMessage = "notification_claim_rejected_message"
        static let storeApprovedMessage = "notification_store_approved_message"
        static let newReplyMessage = "notification_new_reply_message"
        static let storeVerifiedMessage = "notification_store_verified_message"
    }

    // MARK: - My Stores

    enum MyStores {
        static let title = "my_stores_title"
        static let emptyTitle = "my_stores_empty_title"
        static let emptyMessage = "my_stores_empty_message"
    }

    // MARK: - Edit Store

    enum EditStore {
        static let title = "edit_store_title"
        static let name = "edit_store_name"
        static let namePlaceholder = "edit_store_name_placeholder"
        static let nameRequired = "edit_store_name_required"
        static let description = "edit_store_description"
        static let descriptionPlaceholder = "edit_store_description_placeholder"
        static let city = "edit_store_city"
        static let cityPlaceholder = "edit_store_city_placeholder"
        static let tapToChangeLogo = "edit_store_tap_change_logo"
        static let choosePhoto = "edit_store_choose_photo"
        static let takePhoto = "edit_store_take_photo"
        static let chooseFromLibrary = "edit_store_choose_library"
        static let links = "edit_store_links"
        static let linksSubtitle = "edit_store_links_subtitle"
        static let linksTitle = "edit_store_links_title"
        static let linksHeader = "edit_store_links_header"
        static let linksDescription = "edit_store_links_description"
    }

    // MARK: - User Profile

    enum UserProfile {
        static let title = "user_profile_title"
        static let memberSince = "user_profile_member_since"
        static let storesSubmitted = "user_profile_stores_submitted"
        static let reviewsWritten = "user_profile_reviews_written"
        static let stores = "user_profile_stores"
        static let reviews = "user_profile_reviews"
        static let noStoresTitle = "user_profile_no_stores_title"
        static let noStoresMessage = "user_profile_no_stores_message"
        static let noReviewsTitle = "user_profile_no_reviews_title"
        static let noReviewsMessage = "user_profile_no_reviews_message"
    }

}
