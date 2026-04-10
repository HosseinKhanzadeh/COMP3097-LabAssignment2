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

    var body: some View {
        NavigationStack {
            Group {
                if products.isEmpty {
                    emptyContent
                } else {
                    productContent(products[validSelectedIndex])
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Product App")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Add Product") {
                        showingAddProduct = true
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        ProductListView()
                    } label: {
                        Text("View All Products")
                    }
                }
            }
            .sheet(isPresented: $showingAddProduct) {
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

    private var emptyContent: some View {
        VStack(spacing: 12) {
            Text("No products available")
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func productContent(_ product: Product) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Current product")
                    .font(.title2)
                    .fontWeight(.semibold)

                VStack(alignment: .leading, spacing: 16) {
                    labeledField("Product ID", product.productId)
                    labeledField("Product Name", product.name)
                    labeledField("Product Description", product.productDescription)
                    labeledField("Product Price", priceText(product.price))
                    labeledField("Product Provider", product.provider)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                HStack(spacing: 16) {
                    Button("Previous") {
                        selectedIndex = validSelectedIndex - 1
                    }
                    .disabled(validSelectedIndex <= 0)

                    Button("Next") {
                        selectedIndex = validSelectedIndex + 1
                    }
                    .disabled(validSelectedIndex >= products.count - 1)
                }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }

    private func labeledField(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.body)
                .frame(maxWidth: .infinity, alignment: .leading)
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
