import SwiftUI
import CoreData

struct ContentView: View {
    @FetchRequest(
        fetchRequest: {
            let request = Product.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Product.productId, ascending: true)]
            request.fetchLimit = 1
            return request
        }(),
        animation: .default
    )
    private var firstProductResults: FetchedResults<Product>

    var body: some View {
        NavigationStack {
            Group {
                if let product = firstProductResults.first {
                    firstProductContent(product)
                } else {
                    emptyContent
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Product App")
            .navigationBarTitleDisplayMode(.large)
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

    private func firstProductContent(_ product: Product) -> some View {
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
