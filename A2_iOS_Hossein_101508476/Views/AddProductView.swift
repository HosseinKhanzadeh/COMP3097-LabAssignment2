import SwiftUI
import CoreData

struct AddProductView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var productId = ""
    @State private var name = ""
    @State private var productDescription = ""
    @State private var priceText = ""
    @State private var provider = ""
    @State private var validationMessage: String?

    var body: some View {
        Form {
            Section {
                TextField("Product ID", text: $productId)
                    .textInputAutocapitalization(.never)
                TextField("Product Name", text: $name)
                TextField("Product Description", text: $productDescription, axis: .vertical)
                    .lineLimit(4...8)
                TextField("Product Price", text: $priceText)
                    .keyboardType(.decimalPad)
                TextField("Product Provider", text: $provider)
            }

            if let message = validationMessage {
                Section {
                    Text(message)
                        .foregroundStyle(.red)
                        .font(.subheadline)
                }
            }
        }
        .navigationTitle("Add Product")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveProduct()
                }
            }
        }
    }

    private func saveProduct() {
        validationMessage = nil

        let idTrim = productId.trimmingCharacters(in: .whitespacesAndNewlines)
        let nameTrim = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let descTrim = productDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        let providerTrim = provider.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !idTrim.isEmpty else {
            validationMessage = "Product ID cannot be empty."
            return
        }
        guard !nameTrim.isEmpty else {
            validationMessage = "Product name cannot be empty."
            return
        }
        guard !descTrim.isEmpty else {
            validationMessage = "Product description cannot be empty."
            return
        }
        guard !providerTrim.isEmpty else {
            validationMessage = "Product provider cannot be empty."
            return
        }

        guard let price = parsePrice(priceText), price >= 0 else {
            validationMessage = "Product price must be a valid number that is zero or greater."
            return
        }

        let product = Product(context: viewContext)
        product.productId = idTrim
        product.name = nameTrim
        product.productDescription = descTrim
        product.price = price
        product.provider = providerTrim

        do {
            try viewContext.save()
            dismiss()
        } catch {
            validationMessage = "Could not save the product. Please try again."
            viewContext.delete(product)
        }
    }

    private func parsePrice(_ raw: String) -> Double? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return nil
        }
        if let value = Double(trimmed) {
            return value
        }
        return Double(trimmed.replacingOccurrences(of: ",", with: "."))
    }
}

#Preview {
    NavigationStack {
        AddProductView()
    }
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
