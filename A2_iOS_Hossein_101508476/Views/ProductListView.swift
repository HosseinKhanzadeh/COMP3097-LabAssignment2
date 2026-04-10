import SwiftUI
import CoreData

struct ProductListView: View {
    @FetchRequest(
        fetchRequest: {
            let request = Product.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Product.productId, ascending: true)]
            return request
        }(),
        animation: .default
    )
    private var products: FetchedResults<Product>

    var body: some View {
        Group {
            if products.isEmpty {
                VStack(spacing: 12) {
                    Text("No products available")
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 24)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(products, id: \.objectID) { product in
                        productRow(product)
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("All products")
        .navigationBarTitleDisplayMode(.large)
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
