import SwiftUI
import CoreData

struct ProductListView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @State private var searchText = ""
    @State private var displayedProducts: [Product] = []
    @State private var storeHasProducts = false
    @State private var hasLoadedOnce = false
    @State private var showingAddProduct = false
    @State private var totalProductCount = 0

    @FocusState private var searchFieldFocused: Bool

    private var trimmedSearch: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        Group {
            if !hasLoadedOnce {
                ZStack {
                    AppTheme.Colors.appBackground.ignoresSafeArea()
                    ProgressView()
                        .tint(AppTheme.Colors.accentGreenBright)
                }
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                        listHeader

                        searchField

                        if !storeHasProducts {
                            emptyStateNoProducts
                        } else if displayedProducts.isEmpty && !trimmedSearch.isEmpty {
                            emptyStateNoMatches
                        } else {
                            LazyVStack(spacing: AppTheme.Spacing.sm) {
                                ForEach(displayedProducts, id: \.objectID) { product in
                                    productRowCard(product)
                                }
                            }
                        }
                    }
                    .appContentPadding()
                    .padding(.top, AppTheme.Spacing.md)
                    .padding(.bottom, AppTheme.Spacing.xxl)
                }
                .appScreenBackground()
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppTheme.Colors.appBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .tint(AppTheme.Colors.accentGreenBright)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add Product") {
                    showingAddProduct = true
                }
                .font(AppTheme.Typography.button15)
                .foregroundStyle(AppTheme.Colors.accentGreenBright)
            }
        }
        .sheet(isPresented: $showingAddProduct, onDismiss: refreshProducts) {
            NavigationStack {
                AddProductView()
            }
        }
        .onAppear(perform: refreshProducts)
        .onChange(of: searchText) { _, _ in
            refreshProducts()
        }
        .preferredColorScheme(.dark)
    }

    private var listHeader: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text("All Products")
                .font(AppTheme.Typography.screenTitle)
                .foregroundStyle(AppTheme.Colors.primaryText)

            AccentGradientBar(width: 36, height: 2)

            Text(productCountCaption)
                .font(AppTheme.Typography.metadataCaption)
                .foregroundStyle(AppTheme.Colors.tertiaryText)
        }
    }

    private var productCountCaption: String {
        if totalProductCount == 1 {
            return "1 product"
        }
        return "\(totalProductCount) products"
    }

    private var searchField: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(AppTheme.Colors.tertiaryText)

            TextField(
                "",
                text: $searchText,
                prompt: Text("Search name or description")
                    .foregroundStyle(AppTheme.Colors.tertiaryText)
            )
            .focused($searchFieldFocused)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .foregroundStyle(AppTheme.Colors.primaryText)
            .font(AppTheme.Typography.body15)
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .frame(height: 44)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.sm, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.sm, style: .continuous)
                .stroke(
                    searchFieldFocused ? AppTheme.Colors.accentGreen : AppTheme.Colors.borderSubtle,
                    lineWidth: searchFieldFocused ? 1.5 : 1
                )
        )
    }

    private var emptyStateNoProducts: some View {
        emptyStateCard(
            icon: "cube.transparent",
            title: "No products available",
            message: "Products you add will appear here. Use Add Product to create one."
        )
    }

    private var emptyStateNoMatches: some View {
        emptyStateCard(
            icon: "magnifyingglass",
            title: "No matching products found",
            message: "Try a different search term."
        )
    }

    private func emptyStateCard(icon: String, title: String, message: String) -> some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 40, weight: .light))
                .foregroundStyle(AppTheme.Colors.tertiaryText)

            Text(title)
                .font(AppTheme.Typography.emptyTitle)
                .foregroundStyle(AppTheme.Colors.primaryText)
                .multilineTextAlignment(.center)

            Text(message)
                .font(AppTheme.Typography.body15)
                .foregroundStyle(AppTheme.Colors.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(AppTheme.Spacing.xl)
        .frame(maxWidth: .infinity)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.lg, style: .continuous)
                .stroke(AppTheme.Colors.borderSubtle, lineWidth: 1)
        )
    }

    private func productRowCard(_ product: Product) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            HStack(alignment: .firstTextBaseline, spacing: AppTheme.Spacing.md) {
                Text(product.name)
                    .font(AppTheme.Typography.rowTitle)
                    .foregroundStyle(AppTheme.Colors.primaryText)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(product.price, format: .currency(code: "USD"))
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(AppTheme.Colors.accentGreenBright)
            }

            Text(product.productDescription)
                .font(AppTheme.Typography.body15)
                .foregroundStyle(AppTheme.Colors.bodyMuted)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

            Rectangle()
                .fill(AppTheme.Colors.divider)
                .frame(height: 1)
                .padding(.vertical, AppTheme.Spacing.xs)

            HStack(alignment: .firstTextBaseline) {
                Text(product.productId)
                    .font(AppTheme.Typography.metadataCaption)
                    .foregroundStyle(AppTheme.Colors.tertiaryText)
                Spacer()
                Text(product.provider)
                    .font(AppTheme.Typography.metadataCaption)
                    .foregroundStyle(AppTheme.Colors.secondaryText)
                    .multilineTextAlignment(.trailing)
            }
        }
        .padding(AppTheme.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous)
                .stroke(AppTheme.Colors.borderSubtle, lineWidth: 1)
        )
    }

    private func refreshProducts() {
        let countRequest = Product.fetchRequest()
        let total = (try? viewContext.count(for: countRequest)) ?? 0
        totalProductCount = total
        storeHasProducts = total > 0

        let request = Product.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Product.productId, ascending: true)]
        if !trimmedSearch.isEmpty {
            request.predicate = NSPredicate(
                format: "(name CONTAINS[cd] %@) OR (productDescription CONTAINS[cd] %@)",
                trimmedSearch,
                trimmedSearch
            )
        }
        displayedProducts = (try? viewContext.fetch(request)) ?? []
        hasLoadedOnce = true
    }
}

#Preview {
    NavigationStack {
        ProductListView()
    }
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    .preferredColorScheme(.dark)
}
