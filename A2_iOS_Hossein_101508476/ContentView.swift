import SwiftUI
import CoreData

struct ContentView: View {
    @FetchRequest(
        fetchRequest: {
            let request = Product.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Product.productId, ascending: true)]
            return request
        }(),
        animation: .default
    )
    private var products: FetchedResults<Product>

    @State private var selectedIndex = 0
    @State private var showingAddProduct = false

    private var validSelectedIndex: Int {
        let n = products.count
        guard n > 0 else { return 0 }
        return min(max(0, selectedIndex), n - 1)
    }

    private var canGoPrevious: Bool {
        validSelectedIndex > 0
    }

    private var canGoNext: Bool {
        products.count > 0 && validSelectedIndex < products.count - 1
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                    homeHeader

                    if products.isEmpty {
                        EmptyStateCard(
                            icon: "cube.transparent",
                            title: "No products available",
                            message: "Products you add will appear here. Use Add Product to create one.",
                            style: .elevated,
                            primaryActionTitle: "Add Product",
                            primaryAction: { showingAddProduct = true }
                        )
                    } else {
                        VStack(spacing: AppTheme.Spacing.md) {
                            productCard(products[validSelectedIndex])
                            navigationButtons
                        }
                    }
                }
                .appContentPadding()
                .padding(.top, AppTheme.Spacing.lg)
                .padding(.bottom, AppTheme.Spacing.xxl)
            }
            .appScreenBackground()
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppTheme.Colors.appBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .tint(AppTheme.Colors.accentGreenBright)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Add Product") {
                        showingAddProduct = true
                    }
                    .font(AppTheme.Typography.button15)
                    .foregroundStyle(AppTheme.Colors.accentGreenBright)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        ProductListView()
                    } label: {
                        Text("All Products")
                            .font(AppTheme.Typography.button15)
                            .foregroundStyle(AppTheme.Colors.accentGreenBright)
                    }
                }
            }
            .sheet(isPresented: $showingAddProduct, onDismiss: clampSelectedIndex) {
                NavigationStack {
                    AddProductView()
                }
            }
            .onAppear {
                clampSelectedIndex()
            }
            .onChange(of: products.count) { _, _ in
                clampSelectedIndex()
            }
        }
        .preferredColorScheme(.dark)
    }

    private var homeHeader: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text("Product App")
                .font(AppTheme.Typography.screenTitle)
                .foregroundStyle(AppTheme.Colors.primaryText)

            AccentGradientBar(width: 36, height: 2)

            if !products.isEmpty {
                Text("Product \(validSelectedIndex + 1) of \(products.count)")
                    .font(AppTheme.Typography.metadataCaption)
                    .foregroundStyle(AppTheme.Colors.tertiaryText)
            }

            Text("Current Product")
                .font(AppTheme.Typography.fieldLabel)
                .foregroundStyle(AppTheme.Colors.secondaryText)
                .padding(.top, AppTheme.Spacing.xs)
        }
    }

    private func productCard(_ product: Product) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text(product.productId)
                .font(AppTheme.Typography.metadataCaption)
                .fontWeight(.semibold)
                .foregroundStyle(AppTheme.Colors.accentGreenBright)
                .padding(.horizontal, AppTheme.Spacing.sm)
                .padding(.vertical, AppTheme.Spacing.xxs)
                .background(AppTheme.Colors.accentGreen.opacity(0.18))
                .overlay(
                    Capsule()
                        .stroke(AppTheme.Colors.accentGreen.opacity(0.35), lineWidth: 1)
                )
                .clipShape(Capsule())

            Text(product.name)
                .font(AppTheme.Typography.cardTitle)
                .foregroundStyle(AppTheme.Colors.primaryText)
                .fixedSize(horizontal: false, vertical: true)

            Text(product.productDescription)
                .font(AppTheme.Typography.body15)
                .foregroundStyle(AppTheme.Colors.bodyMuted)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

            Rectangle()
                .fill(AppTheme.Colors.divider)
                .frame(height: 1)
                .padding(.vertical, AppTheme.Spacing.xs)

            metadataRow(
                label: "Product Price",
                value: priceText(product.price),
                valueColor: AppTheme.Colors.accentGreenBright
            )
            metadataRow(
                label: "Product Provider",
                value: product.provider,
                valueColor: AppTheme.Colors.primaryText
            )
        }
        .padding(AppTheme.Spacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .elevatedProductCard()
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.lg, style: .continuous)
                .stroke(AppTheme.Colors.borderSubtle, lineWidth: 1)
        )
    }

    private func metadataRow(label: String, value: String, valueColor: Color) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: AppTheme.Spacing.md) {
            Text(label)
                .font(AppTheme.Typography.fieldLabel)
                .foregroundStyle(AppTheme.Colors.secondaryText)
            Spacer(minLength: AppTheme.Spacing.sm)
            Text(value)
                .font(AppTheme.Typography.body15)
                .fontWeight(.medium)
                .foregroundStyle(valueColor)
                .multilineTextAlignment(.trailing)
        }
    }

    private var navigationButtons: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Button {
                selectedIndex = validSelectedIndex - 1
            } label: {
                HStack(spacing: AppTheme.Spacing.xs) {
                    Image(systemName: "chevron.left")
                    Text("Previous")
                }
                .font(AppTheme.Typography.button15)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
            }
            .buttonStyle(.plain)
            .foregroundStyle(canGoPrevious ? AppTheme.Colors.primaryText : AppTheme.Colors.tertiaryText)
            .background(AppTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous)
                    .stroke(AppTheme.Colors.borderSubtle, lineWidth: 1)
            )
            .appDisabledLook(!canGoPrevious)
            .disabled(!canGoPrevious)

            Button {
                selectedIndex = validSelectedIndex + 1
            } label: {
                HStack(spacing: AppTheme.Spacing.xs) {
                    Text("Next")
                    Image(systemName: "chevron.right")
                }
                .font(AppTheme.Typography.button15)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
            }
            .buttonStyle(.plain)
            .foregroundStyle(canGoNext ? AppTheme.Colors.primaryText : AppTheme.Colors.tertiaryText)
            .background(canGoNext ? AppTheme.Colors.accentGreen : AppTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous)
                    .stroke(canGoNext ? AppTheme.Colors.accentGreen.opacity(0.5) : AppTheme.Colors.borderSubtle, lineWidth: 1)
            )
            .appDisabledLook(!canGoNext)
            .disabled(!canGoNext)
        }
    }

    private func clampSelectedIndex() {
        let n = products.count
        guard n > 0 else { return }
        if selectedIndex > n - 1 {
            selectedIndex = n - 1
        }
        if selectedIndex < 0 {
            selectedIndex = 0
        }
    }

    private func priceText(_ price: Double) -> String {
        price.formatted(.currency(code: "USD"))
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
