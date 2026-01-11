import SwiftUI
import Combine

struct CategoryStoresView: View {
    let category: Category
    @StateObject private var viewModel: CategoryStoresViewModel
    @EnvironmentObject private var localizationManager: LocalizationManager
    @Environment(\.dismiss) private var dismiss

    init(category: Category) {
        self.category = category
        _viewModel = StateObject(wrappedValue: CategoryStoresViewModel(categorySlug: category.slug))
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if viewModel.isLoading && viewModel.stores.isEmpty {
                    // Loading state
                    ForEach(0..<4, id: \.self) { _ in
                        StoreCardPlaceholder()
                    }
                } else if viewModel.stores.isEmpty && !viewModel.isLoading {
                    // Empty state
                    emptyStateView
                } else {
                    // Store list
                    ForEach(viewModel.stores) { store in
                        NavigationLink(value: store) {
                            StoreCard(store: store)
                        }
                        .buttonStyle(.plain)
                    }

                    // Load more
                    if viewModel.hasMorePages {
                        ProgressView()
                            .padding()
                            .onAppear {
                                Task {
                                    await viewModel.loadMore()
                                }
                            }
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(category.localizedName(for: localizationManager.currentLanguage))
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(for: Store.self) { store in
            StoreDetailsView(store: store)
        }
        .task {
            await viewModel.loadStores()
        }
        .refreshable {
            await viewModel.refresh()
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "storefront")
                .font(.system(size: 50))
                .foregroundColor(.secondary)

            Text("category_no_stores".localized)
                .font(.headline)
                .foregroundColor(.secondary)

            Text("category_no_stores_description".localized)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
}

// MARK: - Store Card Placeholder

struct StoreCardPlaceholder: View {
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray5))
                .frame(width: 60, height: 60)

            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray5))
                    .frame(width: 120, height: 16)

                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray5))
                    .frame(width: 80, height: 12)
            }

            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shimmer()
    }
}

// MARK: - ViewModel

@MainActor
final class CategoryStoresViewModel: ObservableObject {
    @Published var stores: [Store] = []
    @Published var isLoading = false
    @Published var isRefreshing = false
    @Published var hasMorePages = false
    @Published var error: Error?

    private let categorySlug: String
    private let apiClient: APIClient
    private var currentPage = 1
    private let perPage = 15

    init(categorySlug: String, apiClient: APIClient = .shared) {
        self.categorySlug = categorySlug
        self.apiClient = apiClient
    }

    /// Check if an error is a cancellation error (should be ignored)
    private func isCancellationError(_ error: Error) -> Bool {
        if (error as NSError).code == NSURLErrorCancelled {
            return true
        }
        if error is CancellationError {
            return true
        }
        return false
    }

    func loadStores() async {
        guard !isLoading else { return }

        isLoading = true
        currentPage = 1

        do {
            let response = try await apiClient.searchStores(
                query: nil,
                category: categorySlug,
                verifiedOnly: false,
                sortBy: .bestRated,
                page: currentPage,
                perPage: perPage
            )
            stores = response.data
            hasMorePages = response.meta.currentPage < response.meta.lastPage
        } catch {
            // Ignore cancellation errors
            guard !isCancellationError(error) else {
                isLoading = false
                return
            }
            self.error = error
            print("[CategoryStoresViewModel] Error loading stores: \(error)")
        }

        isLoading = false
    }

    func loadMore() async {
        guard !isLoading && hasMorePages else { return }

        isLoading = true
        currentPage += 1

        do {
            let response = try await apiClient.searchStores(
                query: nil,
                category: categorySlug,
                verifiedOnly: false,
                sortBy: .bestRated,
                page: currentPage,
                perPage: perPage
            )
            stores.append(contentsOf: response.data)
            hasMorePages = response.meta.currentPage < response.meta.lastPage
        } catch {
            // Ignore cancellation errors
            guard !isCancellationError(error) else {
                isLoading = false
                return
            }
            self.error = error
            currentPage -= 1
            print("[CategoryStoresViewModel] Error loading more: \(error)")
        }

        isLoading = false
    }

    func refresh() async {
        // Prevent concurrent refreshes
        guard !isRefreshing else { return }
        isRefreshing = true
        stores = []
        await loadStores()
        isRefreshing = false
    }
}

#Preview {
    NavigationStack {
        CategoryStoresView(category: Category.samples[0])
            .environmentObject(LocalizationManager.shared)
    }
}
