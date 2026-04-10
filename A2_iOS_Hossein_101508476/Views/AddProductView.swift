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

    @FocusState private var focusedField: FocusField?

    private enum FocusField: Hashable {
        case productId
        case name
        case productDescription
        case price
        case provider
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                if let message = validationMessage {
                    ValidationBanner(message: message)
                }

                labeledSingleLineField(
                    label: "Product ID",
                    prompt: "Enter product ID",
                    text: $productId,
                    field: .productId,
                    autocap: .never
                )

                labeledSingleLineField(
                    label: "Product Name",
                    prompt: "Enter product name",
                    text: $name,
                    field: .name,
                    autocap: .words
                )

                labeledMultilineField(
                    label: "Product Description",
                    prompt: "Describe the product",
                    text: $productDescription,
                    field: .productDescription
                )

                labeledSingleLineField(
                    label: "Product Price",
                    prompt: "0.00",
                    text: $priceText,
                    field: .price,
                    keyboard: .decimalPad,
                    autocap: .never
                )

                labeledSingleLineField(
                    label: "Product Provider",
                    prompt: "Enter provider name",
                    text: $provider,
                    field: .provider,
                    autocap: .words
                )

                infoHintCard
            }
            .appContentPadding()
            .padding(.vertical, AppTheme.Spacing.lg)
        }
        .appScreenBackground()
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppTheme.Colors.appBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .tint(AppTheme.Colors.accentGreenBright)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Add Product")
                    .font(AppTheme.Typography.rowTitle)
                    .foregroundStyle(AppTheme.Colors.primaryText)
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
                .font(AppTheme.Typography.button15)
                .foregroundStyle(AppTheme.Colors.secondaryText)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveProduct()
                }
                .font(AppTheme.Typography.rowTitle)
                .foregroundStyle(AppTheme.Colors.accentGreenBright)
            }
        }
        .preferredColorScheme(.dark)
    }

    private var infoHintCard: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            AccentGradientBar(width: 32, height: 2)
            Text("Entries are stored on this device only.")
                .font(AppTheme.Typography.metadataCaption)
                .foregroundStyle(AppTheme.Colors.bodyMuted)
        }
        .padding(AppTheme.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.Colors.accentGreen.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous)
                .stroke(AppTheme.Colors.accentGreen.opacity(0.24), lineWidth: 1)
        )
    }

    private func labeledSingleLineField(
        label: String,
        prompt: String,
        text: Binding<String>,
        field: FocusField,
        keyboard: UIKeyboardType = .default,
        autocap: TextInputAutocapitalization
    ) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            Text(label)
                .font(AppTheme.Typography.fieldLabel)
                .foregroundStyle(AppTheme.Colors.secondaryText)

            TextField(
                "",
                text: text,
                prompt: Text(prompt).foregroundStyle(AppTheme.Colors.tertiaryText)
            )
            .focused($focusedField, equals: field)
            .keyboardType(keyboard)
            .textInputAutocapitalization(autocap)
            .foregroundStyle(AppTheme.Colors.primaryText)
            .font(AppTheme.Typography.body15)
            .padding(.horizontal, AppTheme.Spacing.md)
            .frame(height: 48)
            .appInputChrome(isFocused: focusedField == field)
        }
    }

    private func labeledMultilineField(
        label: String,
        prompt: String,
        text: Binding<String>,
        field: FocusField
    ) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            Text(label)
                .font(AppTheme.Typography.fieldLabel)
                .foregroundStyle(AppTheme.Colors.secondaryText)

            TextField(
                "",
                text: text,
                axis: .vertical,
                prompt: Text(prompt).foregroundStyle(AppTheme.Colors.tertiaryText)
            )
            .focused($focusedField, equals: field)
            .lineLimit(4...10)
            .foregroundStyle(AppTheme.Colors.primaryText)
            .font(AppTheme.Typography.body15)
            .lineSpacing(2)
            .padding(AppTheme.Spacing.md)
            .frame(minHeight: 128, alignment: .topLeading)
            .appInputChrome(isFocused: focusedField == field)
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
    .preferredColorScheme(.dark)
}
