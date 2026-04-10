import CoreData

enum ProductSeeder {
    // Inserts bundled demo products only when the store has no `Product` rows, so user saves are never overwritten.
    static func seedIfNeeded(context: NSManagedObjectContext) {
        let request = Product.fetchRequest()
        request.fetchLimit = 1
        // Cheap existence check: any row means we keep the current database as-is.
        guard let count = try? context.count(for: request), count == 0 else { return }

        // Fixed tuples (id, name, description, price, provider) — lab sample data for a non-empty first launch.
        let rows: [(String, String, String, Double, String)] = [
            (
                "PRD-1001",
                "NovaTune Wireless Earbuds",
                "In-ear buds with hybrid active noise cancellation and a compact charging case rated for about 28 hours of total listening time.",
                149.99,
                "Skyline Audio Inc."
            ),
            (
                "PRD-1002",
                "PulseDock USB-C Hub",
                "Seven-in-one adapter with HDMI 4K, SD and microSD readers, and pass-through charging for slim laptops.",
                79.50,
                "NorthPort Peripherals"
            ),
            (
                "PRD-1003",
                "LumaCurve Desk Lamp",
                "Adjustable color temperature LED arm lamp with touch dimmer and memory for your preferred brightness level.",
                64.00,
                "BrightNest Living"
            ),
            (
                "PRD-1004",
                "KettleForge 1.7L Stainless Kettle",
                "Cordless electric kettle with boil-dry protection and a wide mouth for easy descaling after heavy use.",
                52.25,
                "Harbor Home Goods"
            ),
            (
                "PRD-1005",
                "ErgoGlide Vertical Mouse",
                "Right-handed ergonomic mouse with silent clicks and a textured grip aimed at long spreadsheet sessions.",
                59.99,
                "DeskCraft Supplies"
            ),
            (
                "PRD-1006",
                "ClearGuard Phone Case",
                "Flexible TPU bumper with raised lip around the camera; yellowing-resistant coating for daily carry.",
                24.95,
                "Urban Shell Co."
            ),
            (
                "PRD-1007",
                "Heathrow Cotton Throw",
                "Soft waffle-weave blanket in oatmeal, machine washable, sized for sofas or the foot of a bed.",
                44.00,
                "Willow & Weft Textiles"
            ),
            (
                "PRD-1008",
                "VoltPack 20,000 mAh Power Bank",
                "Two USB-C ports with 45 W output for tablets, plus a small display showing remaining charge percentage.",
                89.00,
                "ChargeRight Electronics"
            ),
            (
                "PRD-1009",
                "ArtisanStack Mug Duo",
                "Set of two hand-glazed ceramic mugs, microwave safe, each holds about 350 ml of coffee or tea.",
                36.75,
                "Kiln & Kitchen"
            ),
            (
                "PRD-1010",
                "FlexLink HDMI 2.1 Cable (2 m)",
                "Braided cable rated for 4K high refresh setups; tight connectors to reduce accidental unplugging.",
                22.49,
                "CableSmith Direct"
            ),
            (
                "PRD-1011",
                "FlowMat Yoga Mat",
                "6 mm cushioned mat with closed-cell surface that resists moisture from hot yoga classes.",
                41.00,
                "Peak Motion Gear"
            ),
            (
                "PRD-1012",
                "Ripple Mini Bluetooth Speaker",
                "Palm-sized speaker with IPX7 rating for poolside use and stereo pairing when you buy a second unit.",
                55.00,
                "EchoBay Mobile Audio"
            )
        ]

        for row in rows {
            let product = Product(context: context)
            product.productId = row.0
            product.name = row.1
            product.productDescription = row.2
            product.price = row.3
            product.provider = row.4
        }

        do {
            try context.save()
        } catch {
            fatalError("Seed save failed: \(error)")
        }
    }
}
