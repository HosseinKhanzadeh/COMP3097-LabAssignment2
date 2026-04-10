import SwiftUI
import CoreData

// Full list with manual fetches so we can attach a search predicate without replacing the whole view model.
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
                            EmptyStateCard(
                                icon: "cube.transparent",
                                title: "No products available",
                                message: "Products you add will appear here. Use Add Product to create one.",
                                style: .flat
                            )
                        } else if displayedProducts.isEmpty && !trimmedSearch.isEmpty {
                            EmptyStateCard(
                                icon: "magnifyingglass",
                                title: "No matching products found",
                                message: "Try a different search term.",
                                style: .flat
                            )
                        } else {
                            LazyVStack(spacing: AppTheme.Spacing.sm) {
                                ForEach(displayedProducts, id: \.objectID) { product in
                                    productRowCard(product)
                                }
                            }
                        }
                    }
                    .appContentPadding()
                    .padding(.top, AppTheme.Spacing.lg)
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
                .appSubtlePressButtonStyle()
            }
        }
        .sheet(isPresented: $showingAddProduct, onDismiss: refreshProducts) {
            NavigationStack {
                AddProductView()
            }
        }
        .onAppear(perform: refreshProducts)
        // Re-run fetch whenever the search string changes (including clear).
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
                .font(AppTheme.Typography.iconInline)
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
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 44)
        .appInputChrome(isFocused: searchFieldFocused)
    }

    private func productRowCard(_ product: Product) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack(alignment: .firstTextBaseline, spacing: AppTheme.Spacing.md) {
                Text(product.name)
                    .font(AppTheme.Typography.rowTitle)
                    .foregroundStyle(AppTheme.Colors.primaryText)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(product.price, format: .currency(code: "USD"))
                    .font(AppTheme.Typography.rowPrice)
                    .foregroundStyle(AppTheme.Colors.accentGreenBright)
                    .layoutPriority(1)
            }

            Text(product.productDescription)
                .font(AppTheme.Typography.body15)
                .foregroundStyle(AppTheme.Colors.bodyMuted)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

            AppDividerLine()

            HStack(alignment: .firstTextBaseline, spacing: AppTheme.Spacing.md) {
                Text(product.productId)
                    .font(AppTheme.Typography.metadataCaption)
                    .foregroundStyle(AppTheme.Colors.tertiaryText)
                Spacer(minLength: AppTheme.Spacing.md)
                Text(product.provider)
                    .font(AppTheme.Typography.metadataCaption)
                    .foregroundStyle(AppTheme.Colors.secondaryText)
                    .multilineTextAlignment(.trailing)
            }
        }
        .padding(AppTheme.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .subtleBorderedSurface(cornerRadius: AppTheme.Radius.md)
    }

    // Re-query Core Data: total count for the header, then sorted rows filtered by trimmed search text when needed.
    private func refreshProducts() {
        let countRequest = Product.fetchRequest()
        let total = (try? viewContext.count(for: countRequest)) ?? 0
        totalProductCount = total
        storeHasProducts = total > 0

        let request = Product.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Product.productId, ascending: true)]
        if !trimmedSearch.isEmpty {
            // Case-insensitive substring match on name or description (same term for both fields).
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
