import SwiftUI
import CoreData

struct ProductListView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @State private var searchText = ""
    @State private var displayedProducts: [Product] = []
    @State private var storeHasProducts = false
    @State private var hasLoadedOnce = false
    @State private var showingAddProduct = false

    private var trimmedSearch: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        Group {
            if !hasLoadedOnce {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if !storeHasProducts {
                VStack(spacing: 12) {
                    Text("No products available")
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 24)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if displayedProducts.isEmpty && !trimmedSearch.isEmpty {
                VStack(spacing: 12) {
                    Text("No matching products found")
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 24)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(displayedProducts, id: \.objectID) { product in
                        productRow(product)
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("All Products")
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: $searchText, prompt: "Search name or description")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add Product") {
                    showingAddProduct = true
                }
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
    }

    private func refreshProducts() {
        let countRequest = Product.fetchRequest()
        storeHasProducts = ((try? viewContext.count(for: countRequest)) ?? 0) > 0

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

    private func productRow(_ product: Product) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(product.name)
                .font(.headline)
            Text(product.productDescription)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            HStack {
                Text(product.productId)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                Spacer()
                Text(product.price, format: .currency(code: "USD"))
                    .font(.caption)
                    .fontWeight(.medium)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        ProductListView()
    }
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
