import SwiftUI
import Combine

struct CategoryCard: View {
    let category: Category
    var isSelected: Bool = false

    @EnvironmentObject private var localizationManager: LocalizationManager

    var body: some View {
        VStack(spacing: Spacing.sm) {
            // Category Image
            ZStack {
                Circle()
                    .fill(isSelected ? Color.primaryGreen.opacity(0.15) : Color(.secondarySystemBackground))
                    .frame(width: 64, height: 64)

                Image(category.localImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())
            }

            // Name
            Text(category.localizedName(for: localizationManager.currentLanguage))
                .font(.caption2.weight(.medium))
                .foregroundColor(.primary)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
                .multilineTextAlignment(.center)
                .frame(height: 32)

            // Store count
            Text("\(category.storesCount)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.md)
        .background(Color(.systemBackground))
        .cornerRadius(Spacing.radiusMedium)
        .shadow(
            color: .black.opacity(isSelected ? 0.1 : 0.04),
            radius: isSelected ? 8 : 4,
            x: 0,
            y: 2
        )
        .overlay(
            RoundedRectangle(cornerRadius: Spacing.radiusMedium)
                .stroke(isSelected ? Color.primaryGreen : Color.clear, lineWidth: 2)
        )
    }
}

// MARK: - Category Chip (inline)

struct CategoryChip: View {
    let category: Category

    @EnvironmentObject private var localizationManager: LocalizationManager

    var body: some View {
        HStack(spacing: Spacing.xxs) {
            Image(systemName: category.sfSymbol)
                .font(.system(size: 10))

            Text(category.localizedName(for: localizationManager.currentLanguage))
                .font(.caption2)
        }
        .foregroundColor(.secondary)
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xxs)
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(Spacing.radiusSmall)
    }
}

// MARK: - Category Grid

struct CategoryGrid: View {
    let categories: [Category]
    let columns = [
        GridItem(.flexible(), spacing: Spacing.md),
        GridItem(.flexible(), spacing: Spacing.md)
    ]
    var onSelect: ((Category) -> Void)?

    var body: some View {
        LazyVGrid(columns: columns, spacing: Spacing.md) {
            ForEach(categories) { category in
                Button {
                    onSelect?(category)
                } label: {
                    CategoryCard(category: category)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack(spacing: 20) {
            CategoryGrid(categories: Category.samples)
                .padding()

            HStack {
                CategoryChip(category: Category.samples[0])
                CategoryChip(category: Category.samples[1])
            }
        }
    }
    .background(Color(.secondarySystemBackground))
    .environmentObject(LocalizationManager.shared)
}
